class WorkTab : Tab {
    string GetLabel() override { return Icons::Cube + " Work"; }
    vec4 GetColor() override { return vec4(180. / 255, 90. / 255, 8. / 255, 1); }
    bool updatingItem = false;

    void Render() override {
        if(updatingItem) {
            CTrackMania@ app = cast<CTrackMania>(GetApp());
            auto editorItem = cast<CGameEditorItem>(app.Editor);
            if(editorItem !is null) {
                editorItem.Exit();
                updatingItem = false;
            }
        }

        UI::SetCursorPos(UI::GetCursorPos() + vec2(10, 10));
        UI::PushStyleColor(UI::Col::ChildBg, vec4(1, 1, 1, 0));
        UI::BeginChild("WorkContent");
        UI::PushTextWrapPos(UI::GetContentRegionAvail().x);

        UI::Text("Import items from your " + GetItemsFolder() + " that aren't loaded in the editor yet.");
        UI::TextDisabled("This can be used for loading custom items you created with the NadeoImporter.");

        if(!ixMenu.isInEditor) {
            UI::Text("Go to the editor to use this feature.");
        } else {
            UI::BeginDisabled(Work::busy);
            if(ixMenu.isInEditor && UI::PurpleButton("Scan & import items")) {
                startnew(Work::ImportUnloaded);
            }
            UI::EndDisabled();
            if(Work::busy) {
                UI::Text("Scanning: " + Work::exploringDir);
            }
            if(Work::scanned) {
                UI::Text("Imported " + Work::importedItems.Length + " items");
                for(uint i = 0; i < Work::importedItems.Length; i++) {
                    UI::TextDisabled(Work::importedItems[i]);
                }
                if(Work::unloadedItems.Length > 0) {
                    UI::Text("Failed to import " + Work::unloadedItems.Length + " items");
                    for(uint i = 0; i < Work::unloadedItems.Length; i++) {
                        UI::TextDisabled(Work::unloadedItems[i]);
                    }
                }
            }
            UI::Separator();

            UI::Text("To update a loaded item from file, click the button below, then click on the item you want to update.");
            UI::BeginDisabled(updatingItem);
            if(UI::CyanButton("Update item from file")) {
                CTrackMania@ app = cast<CTrackMania>(GetApp());
                auto editor = cast<CGameCtnEditorCommon@>(app.Editor);
                editor.ButtonItemEditModeOnClick();
                updatingItem = true;
            }
            UI::EndDisabled();
            if(updatingItem && UI::RedButton("Cancel updating item")){ 
                CTrackMania@ app = cast<CTrackMania>(GetApp());
                auto editor = cast<CGameCtnEditorCommon@>(app.Editor);
                editor.PluginMapType.PlaceMode = CGameEditorPluginMap::EPlaceMode::Item;
                updatingItem = false;
            }
        }

        UI::PopTextWrapPos();
        UI::EndChild();
        UI::PopStyleColor(1);
    }
};

namespace Work {
    dictionary@ loadedItems = null;
    string[]@ unloadedItems = {};
    string[]@ importedItems = {};
    bool scanned = false;
    int lastYield = 0;
    string exploringDir = "";
    bool busy = false;

    CGameCtnArticleNodeDirectory@ GetCustomItemsNode() {
        CTrackMania@ app = cast<CTrackMania>(GetApp());
        auto editor = cast<CGameCtnEditorCommon@>(app.Editor);
        auto pmt = editor.PluginMapType;
        auto inventory = pmt.Inventory;
        for(uint i = 0; i < inventory.RootNodes.Length; i++) {
            auto node = cast<CGameCtnArticleNodeDirectory@>(inventory.RootNodes[i]);
            if(node is null) continue;
            for(uint j = 0; j < node.ChildNodes.Length; j++) {
                auto childDir = cast<CGameCtnArticleNodeDirectory@>(node.ChildNodes[j]);
                if(childDir is null) continue;
                if(childDir.Name == "Custom") {
                    return childDir;
                }
            }
        }
        return null;
    }

    
    void PrintLoadedItems(const dictionary &in tree, string indent = ""){
        auto keys = tree.GetKeys();
        for(uint i = 0; i < keys.Length; i++) {
            if(keys[i].StartsWith("art")) {
                string path;
                if(!tree.Get(keys[i], path)){
                    warn("Can't get article path " + keys[i]);
                    continue;
                }
                print(indent + tostring(i) + ": " +  "article: " + path);
                continue;
            }

            print(indent + tostring(i) + ": " + keys[i]);
            dictionary@ innerTree;
            if(!tree.Get(keys[i], @innerTree)){
                warn("Can't find key " + keys[i]);
                continue;
            }
            
            PrintLoadedItems(innerTree, indent + "    ");
        }
    }

    void SetLoadedArticle(string path) {
        string[] parts = string(path).Split('\\');
        string articleName = parts[parts.Length - 1];
        string key = 'art' + articleName;
        dictionary@ node = loadedItems;
        for(uint i = 0; i < parts.Length - 1; i++) {
            auto folder = parts[i];
            dictionary@ childNode;
            if(node.Get(folder, @childNode)) {
                // use existing dict for this folder
                @node = childNode;
            } else {
                // create new child dict for this folder
                @childNode = {};
                node[folder] = childNode;
                @node = cast<dictionary@>(node[folder]);
            }
        }
        node.Set(key, path);
    }

    void ExploreCustomItemsNode(CGameCtnArticleNodeDirectory@ node) {
        if(node is null) return;
        auto now = Time::Now;
        if(now - lastYield > 50){
            yield();
            lastYield = now;
        }
        exploringDir = node.Name;
        for(uint i = 0; i < node.ChildNodes.Length; i++) {
            if(node.ChildNodes[i].IsDirectory) {
                auto childDir = cast<CGameCtnArticleNodeDirectory@>(node.ChildNodes[i]);
                if(childDir is null) continue;
                exploringDir = childDir.Name;
                ExploreCustomItemsNode(childDir);
            } else {
                auto childArticle = cast<CGameCtnArticleNodeArticle@>(node.ChildNodes[i]);
                if(childArticle is null) continue;
                SetLoadedArticle(childArticle.Name);
            }
        }
    }

    void Scan() {
        @importedItems = {};
        @loadedItems = {};
        @unloadedItems = {};
        auto customItemsNode = GetCustomItemsNode();
        ExploreCustomItemsNode(customItemsNode);
        // PrintLoadedItems(loadedItems);
        auto paths = IO::IndexFolder(GetItemsFolder(), true);
        for(uint i = 0; i < paths.Length; i++) {
            auto path = paths[i];
            if(!path.ToLower().EndsWith(".item.gbx")) continue;
            auto relParts = path.Split(GetItemsFolder());
            if(relParts.Length < 2) continue;
            string relPath = relParts[1];
            auto parts = relPath.Split("/");
            auto item = parts[parts.Length - 1];

            dictionary@ node = loadedItems;
            bool failed = false;
            for(uint j = 0; j < parts.Length - 1; j++) {
                auto folder = parts[j];
                dictionary@ childNode;
                print("Folder: " + folder);
                if(node.Get(folder, @childNode)) {
                    // use existing dict for this folder
                    @node = childNode;
                } else {
                    failed = true;
                    print("Failed for path: " + path);
                    break;
                }
            }
            auto isLoaded = !failed && node.Exists('art' + item);
            if(!isLoaded) {
                unloadedItems.InsertLast(path);
            }
        }
        scanned = true;
    }

    void ImportUnloaded() {
        if(busy) return;
        busy = true;
        Work::Scan();
        if(!scanned) {
            warn("Scan for items before calling import unloaded");
            return;
        }
        for(int i = int(unloadedItems.Length) - 1; i >= 0; i--) {
            auto path = unloadedItems[i];
            auto relParts = path.Split(GetItemsFolder());
            if(relParts.Length < 2) continue;
            string relPath = relParts[1];

            print("Importing unloaded item: " + relPath);
            string tmpPath = path + ".tmp";
            IO::Move(path, tmpPath);
            if(ixEditor.LoadItem(tmpPath, relPath)) {
                print("load success: Delete tmp: " + tmpPath);
                IO::Delete(tmpPath);
                unloadedItems.RemoveAt(i);
                importedItems.InsertLast(relPath);
            } else {
                print("load failed: Move back tmp: " + tmpPath);
                IO::Move(tmpPath, path);
            }
        }
        busy = false;
    }
}
