class ItemSetTab : Tab {
    IX::ItemSet@ itemSet;
    int ID;
    EGetStatus status = EGetStatus::Downloading;
    EGetStatus secondStatus = EGetStatus::Available;

    ItemSetTab(int setID){
        this.ID = setID;
        downloader.Check('set', ID);
    }

    bool CanClose() override { return true; }
    string GetLabel() override {
        if (status == EGetStatus::Error) 
            return "\\$f00" + Icons::Times + " \\$zError";
        if (status == EGetStatus::Downloading) 
            return Icons::Database + " Loading...";
        return Icons::Database + " " + itemSet.Name;
    }
    vec4 GetColor() override { return pluginColorVec; }

    void Render() override {
        if(status != EGetStatus::Available) {
            status = downloader.Check('set', ID);
            if(status == EGetStatus::Error) {
                UI::Text("\\$f00" + Icons::Times + " \\$zSet not found");
                return;
            }
            if(status == EGetStatus::Downloading) {
                UI::Text(IfaceRender::GetHourGlass() + " Loading...");
                return;
            }
            if(status == EGetStatus::Available || status == EGetStatus::ItemsFailed) {
                @itemSet = downloader.GetSet(ID);
            }
        }
        if(secondStatus == EGetStatus::Downloading) {
            secondStatus = downloader.Check('set', ID);
            if(secondStatus == EGetStatus::Available) {
                print("Full itemset request finished");
                @itemSet = downloader.GetSet(ID);
            }
        }
        if(itemSet.Items.Length == 0 && downloader.Check('set', ID) == EGetStatus::Available) {
            print("Making full itemset request");
            downloader.RefreshCache('set', ID);
            secondStatus = EGetStatus::Downloading;
        }

        float width = UI::GetWindowSize().x * .4;
        vec2 posTop = UI::GetCursorPos();

        UI::BeginChild("ItemImage", vec2(width, 0));

        UI::BeginTabBar("MapImages");

        if (itemSet.ImageCount != 0) {
            for (int i = 1; i < itemSet.ImageCount + 1; i++) {
                if(UI::BeginTabItem(tostring(i))) {
                    IfaceRender::HoverImage("https://" + MXURL + "/set/image/" + itemSet.ID + '/' + i, width);
                    UI::EndTabItem();
                }
            }
        }

        UI::EndTabBar();

        UI::EndChild();
        UI::SetCursorPos(posTop + vec2(width + 8, 0));
        UI::BeginChild("ItemHeader");
        UI::SetCursorPos(UI::GetCursorPos() + vec2(8, 0));
        UI::PushStyleColor(UI::Col::ChildBg, vec4(0, 0, 0, 0));
        UI::BeginChild("PaddedItem");
        UI::Dummy(vec2(0, 1));

        UI::PushFont(ixMenu.g_fontTitle);
        UI::Text(itemSet.Name);
        UI::PopFont();

        UI::Text(Icons::Bolt + " " + itemSet.Score + " | " + Icons::Download + " " + itemSet.Downloads);
        
        IfaceRender::TabHeader(Icons::InfoCircle + " Information");

        if(UI::BeginTable("InfoColumns", 2)) {
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 125);
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthStretch, 1);

            IfaceRender::SimpleTableRow({"Set ID:", tostring(itemSet.ID)});
            IfaceRender::SimpleTableRow({"Uploaded by:", itemSet.Username});
            if(itemSet.Updated == itemSet.Uploaded){
                IfaceRender::SimpleTableRow({"Uploaded:", itemSet.Uploaded});
            } else {
                IfaceRender::SimpleTableRow({"Uploaded (Ver.):", itemSet.Uploaded + " (" + itemSet.Updated + ")"});
            }
            IfaceRender::SimpleTableRow({"Filesize:", tostring(itemSet.FileSize) + ' KB'});
            
            // tag row
            UI::TableNextRow();
            UI::PushFont(ixMenu.g_fontBold);
            UI::TableSetColumnIndex(0);
            UI::Text("Tags:");
            UI::PopFont();
            UI::TableSetColumnIndex(1);
            IfaceRender::Tags(itemSet.Tags);
            // end tag row

            UI::EndTable();
        }
        
        
        if(itemSet.Description != "") {
            IfaceRender::TabHeader(Icons::Pencil + " Description");
            IfaceRender::IXComment(itemSet.Description);
        }

        if(secondStatus == EGetStatus::ItemsFailed) {
            UI::Text("Could not load contents for this set.");
        } else if(itemSet.contentTree !is null && itemSet.Items.Length > 0) {
            IfaceRender::TabHeader(Icons::FolderOpen + " Contents (" + itemSet.Items.Length + ")");
            IfaceRender::ImportButton(EImportType::Tree, itemSet.contentTree, "id" + ID, true);
            
            // Download set button
            UI::SameLine();
            if(ixEditor.isDownloading) UI::BeginDisabled();
            if(UI::Button(Icons::CloudDownload + " Download item set")) {
                startnew(ImportFunctions::DownloadItems, itemSet.Items);
            }
            if(ixEditor.isDownloading) UI::EndDisabled();
            if (UI::IsItemHovered()) {
                UI::BeginTooltip();
                UI::Text("Download this set without importing (game restart is required to access the items)");
                UI::EndTooltip();
            }

            RenderTreeItems(itemSet.contentTree);
            UI::Dummy(vec2(100, 100));
        }

        UI::EndChild();
        UI::PopStyleColor(1);
        UI::EndChild();
    }
    
    void RenderContentTree(string name, const dictionary &in tree, int level = 0, string id = "") {
        if(UI::CollapsingHeader(name + "##" + id)) {
            RenderTreeItems(tree, level, id);
        }
    }

    void RenderTreeItems(const dictionary &in tree, int level = 0, string id = "") {
        auto keys = tree.GetKeys();
        for(uint i = 0; i < keys.Length; i++) {
            if(keys[i] == IX::TreeItemsKey) {
                IX::Item@[]@ items;
                if(!tree.Get(keys[i], @items)) {
                    warn("Can't get array: " + keys[i]);
                    continue;
                }
                Indent(level);
                if (UI::BeginTable("List", 4)) {
                    UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 45);
                    UI::TableSetupColumn("", UI::TableColumnFlags::WidthStretch, 3);
                    UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 45);
                    UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 70);
                    for(uint j = 0; j < items.Length; j++){
                        Indent(level);
                        IfaceRender::ItemRow(items[j], true);
                    }
                    UI::EndTable();
                }
                continue;
            }

            dictionary@ innerTree;
            if(!tree.Get(keys[i], @innerTree)) {
                warn("Can't get child dict: " + keys[i]);
                continue;
            }
            
            Indent(level);
            IfaceRender::ImportButton(EImportType::Tree, innerTree, level + keys[i], false, true);

            UI::SameLine();
            RenderContentTree(keys[i], innerTree, level + 1, id + "|" + keys[i] + "|" + level);
        }
    }

    void Indent(int level) {
        if(level == 0) return;
        UI::Dummy(vec2(level * 15, 0));
        UI::SameLine();
    }
};