class RequestItemTuple {
    Net::HttpRequest@ request = null;
    IX::Item@ item = null;
    RequestItemTuple(Net::HttpRequest@ request, IX::Item@ item) {
        @this.request = request;
        @this.item = item;
    }
};

class IXEditor {
    Import::Library@ lib = null;
    Import::Function@ clickFun = null;
    Import::Function@ mousePosFun = null;
    bool isImporting = false;
    string downloadFolder = '';
    int importTotal = 1;
    int importFinished = 0;

    IXEditor (){
        print("Getting click dll");
        @lib = GetZippedLibrary("lib/libclick.dll");
        if(lib !is null) {
            @clickFun = lib.GetFunction("clickPos");
            @mousePosFun = lib.GetFunction("moveMouse");
        }

        auto opFolder = IO::FromDataFolder('');
        downloadFolder = opFolder + '/IX/';
        if(!IO::FolderExists(downloadFolder))
            IO::CreateFolder(downloadFolder);

        print("IX");
    }

    bool WaitForImport() {
        int waitTime = 0;
        while(isImporting) { 
            waitTime++;
            yield();
            warn("Trying to import an item while another is being imported!");
            // timeout after 5s
            if(waitTime > 500){
                UI::ShowNotification("Couldn't import item, importer is busy.");
                return false;
            }
        }
        return true;
    }

    void CreateFolderRecursive(string basePath, string createPath){
        string separator = "/";
        basePath.Replace("\\", separator);
        createPath.Replace("\\", separator);
        // remove double //
        while(basePath.Contains(separator + separator)){
            basePath = basePath.Replace(separator + separator, separator);
        }
        while(createPath.Contains(separator + separator)){
            createPath = createPath.Replace(separator + separator, separator);
        }
        // Format path to the following template
        // basePath: C://Users/Ruurd/ (ends with separator)
        // createPath: OpenplanetNext/Plugins/lib (no separator at start or end)
        if(basePath.EndsWith(separator)){
            basePath = basePath.SubStr(0, basePath.Length - 1);
        }
        if(createPath.StartsWith(separator)) {
            createPath = createPath.SubStr(1);
        }
        if(createPath.EndsWith(separator)) {
            createPath = createPath.SubStr(0, createPath.Length - 1);
        }
        auto parts = createPath.Split(separator);

        string path = basePath;
        for(uint i = 0; i < parts.Length; i++) {
            if(!IO::FolderExists(path + separator + parts[i])) {
                IO::CreateFolder(path + separator + parts[i]);
            }
            path += separator + parts[i];
        }
    }

    bool ImportItems(IX::Item@[] items) {
        importFinished = 0;
        importTotal = items.Length;

        if(!WaitForImport()) return false;
        isImporting = true;

        RequestItemTuple@[] requests = {};
        for(uint i = 0; i < items.Length; i++) {
            auto item = items[i];
            auto itemFolder = item.GetRelativeFolder();
            CreateFolderRecursive(downloadFolder, itemFolder);

            if(!IO::FileExists(item.GetCachePath())) {
                auto url = "https://" + MXURL + "/item/download/" + item.ID;                
                auto request = Net::HttpGet(url);
                requests.InsertLast(RequestItemTuple(request, item));
            } else {
                // file already exists in downloads cache, increment counter
                importFinished++;
            }
        }

        // Wait for all downloads to complete
        while(true) {
            for(int i = int(requests.Length) - 1; i >= 0; i--) {
                auto ri = requests[i];
                if(!ri.request.Finished())
                    continue;
                print("Item " + ri.item.Name + " finished!");
                importFinished++;
                requests.RemoveAt(i);
                auto code = ri.request.ResponseCode();
                if(code < 200 || code >= 300) {
                    warn("Error making request to '" + ri.request.Url + "' error code: " + code);
                    continue;
                }
                ri.request.SaveToFile(ri.item.GetCachePath());
            }
            if(importFinished == importTotal) 
                break;
            yield();
        }

        for(uint i = 0; i < items.Length; i++) {
            auto item = items[i];
            auto itemFolder = item.GetRelativeFolder();
            if(IO::FileExists(item.GetDestinationPath())){
                // file already exists in items folder
                continue;
            }
            string desiredItemLocation = itemFolder + item.FileName;
            if(LoadItem(item.GetCachePath(), desiredItemLocation)) {
                item.IsStoredLocally = true;
            } else {
                UI::ShowNotification("Couldn't import item: " + item.Name);
            }
            yield();
        }

        isImporting = false;
        return true;
    }

    void DrawText(string text) {
        auto screenHeight = Draw::GetHeight();
        auto screenWidth = Draw::GetWidth();
        auto black = vec4(0, 0, 0, 1);
        auto white = vec4(1, 1, 1, 1);
        nvg::FontFace(ixMenu.g_fontRegularHeader);
        nvg::FontSize(100);
        nvg::FillColor(black);
        nvg::TextAlign(nvg::Align::Center | nvg::Align::Middle);
        nvg::Text(screenWidth / 2 - 2, screenHeight / 4 - 2, text);
        nvg::FillColor(white);
        nvg::Text(screenWidth / 2, screenHeight / 4, text);
    }

    void EnterCreateNewItemUI(CTrackMania@ app) {
        if(mousePosFun !is null && clickFun !is null) {
            auto screenHeight = Draw::GetHeight();
            auto screenWidth = Draw::GetWidth();
            // Click screen at position to enter "create new item" UI
            auto xClick = screenWidth / 2;
            auto yClick = screenHeight / 2;
            mousePosFun.Call(xClick, yClick - 2);
            yield();
            mousePosFun.Call(xClick, yClick - 1);
            yield();
            clickFun.Call(true, xClick, yClick);
        } else {
            // make user click
            auto maxLoops = 1000; // wait max 10 seconds for user to get to item editor
            while(cast<CGameEditorItem>(app.Editor) is null) {
                DrawText("Click in the map!");
                yield();
                if(maxLoops-- <= 0) {
                    UI::ShowOverlay();
                    return;
                }
                print("Waiting for user click");
            }
        }
        UI::ShowOverlay();
    }

    bool EnterEditItemUI(CTrackMania@ app) {
        if(mousePosFun !is null && clickFun !is null) {
            auto screenWidth = Draw::GetWidth();
            auto screenHeight = Draw::GetHeight();
            auto xClick = screenWidth / 2;
            auto yClick = screenHeight / 2;
            mousePosFun.Call(true, xClick, yClick - 1);
            auto maxLoops = 100; // wait max 1 seconds
            // Click screen until we're in "edit item" UI
            while(true){
                clickFun.Call(true, xClick, yClick - 2);
                yield();
                auto editorItem = cast<CGameEditorItem>(app.Editor);
                if(editorItem !is null){
                    UI::ShowOverlay();
                    return true;
                }
                if(maxLoops-- <= 0){
                    UI::ShowOverlay();
                    return false;
                }
            }
        } else {
            // make user click on item
            auto maxLoops = 1000; // wait max 10 seconds for user to get to item editor
            while(cast<CGameEditorItem>(app.Editor) is null){
                DrawText("Click the new cube!");
                yield();
                if(maxLoops-- <= 0) {
                    UI::ShowOverlay();
                    return false;
                }
                print("Waiting for user click");
            }
            UI::ShowOverlay();
            return true;
        }

        return false;
    }

    bool LoadItem(string gbxLocation, string desiredItemLocation) {
        CTrackMania@ app = cast<CTrackMania>(GetApp());
        auto editor = cast<CGameCtnEditorCommon@>(app.Editor);
        if(editor is null) {
            warn("Editor is null");
            return false;
        }

        yield();
        // Click "create new item" button
        editor.ButtonItemNewModeOnClick();
        UI::HideOverlay();
        yield();

        EnterCreateNewItemUI(app);
        yield();

        // Save empty item to file
        auto editorItem = cast<CGameEditorItem>(app.Editor);
        if(editorItem is null){
            warn("Editor item is null");
            return false;
        }
        editorItem.FileSaveAs();
        yield();
        yield();
        app.BasicDialogs.String = desiredItemLocation;
        yield();
        app.BasicDialogs.DialogSaveAs_OnValidate();
        yield();
        app.BasicDialogs.DialogSaveAs_OnValidate();
        yield();
        
        // Exit "create new item" UI
        editorItem.Exit();

        // OVERWRITE ITEM WITH ACTUAL GBX FILE
        
        auto itemLocation = GetItemsFolder() + desiredItemLocation;
        print("itemLocation: " + itemLocation);
        print("OVERWRITE ITEM WITH ACTUAL GBX FILE");
        auto copyFrom = gbxLocation;
        CopyFile(copyFrom, itemLocation);
        
        // Wait until exited item UI
        while(cast<CGameEditorItem>(app.Editor) !is null){
            yield();
            print("Waiting");
        }

        // Click "edit item" button
        editor.ButtonItemEditModeOnClick();
        
        UI::HideOverlay();
        yield();
        if(!EnterEditItemUI(app)) {
            error("ERROR getting to 'edit item' UI");
            return false;
        }

        // Exit edit item UI
        cast<CGameEditorItem>(app.Editor).Exit();

        // Wait until exited item UI
        while(cast<CGameEditorItem>(app.Editor) !is null){
            yield();
            print("Waiting");
        }

        // undo placing
        print("UNDO");
        editor.ButtonUndoOnClick();
        editor.ButtonUndoOnClick();
        // editor.PluginMapType.Undo();

        print("IX DONE");
        return true;
    }

    bool CopyFile(string fromFile, string toFile, bool overwrite = true){
        if(!IO::FileExists(fromFile)){
            warn("fromFile does not exist");
            return false;
        }
        if(!overwrite && IO::FileExists(toFile)){
            warn("toFile already exists, and overwrite is set to false!");
            return false;
        }
        IO::File fromItem(fromFile);
        fromItem.Open(IO::FileMode::Read);
        auto buffer = fromItem.Read(fromItem.Size());
        IO::File toItem(toFile, IO::FileMode::Write);
        toItem.Write(buffer);
        fromItem.Close();
        toItem.Close();
        return true;
    }

    string GetPluginName(){
        auto executingPlugin = Meta::ExecutingPlugin();
        return executingPlugin.Name;
    }

    Import::Library@ GetZippedLibrary(string relativeDllPath) {
        bool preventCache = true;

        auto parts = relativeDllPath.Split("/");
        string fileName = parts[parts.Length - 1];
        const string baseFolder = IO::FromDataFolder('');
        const string dllFolder = baseFolder + 'lib/';
        const string localDllFile = dllFolder + fileName;

        if(!IO::FolderExists(dllFolder)) {
            print("Create folder: " + dllFolder);
            IO::CreateFolder(dllFolder);
        }

        if(preventCache || !IO::FileExists(localDllFile)) {
            try {
                IO::FileSource zippedDll(relativeDllPath);
                print("Copying dll from zip to local! " + localDllFile);
                auto buffer = zippedDll.Read(zippedDll.Size());
                IO::File toItem(localDllFile, IO::FileMode::Write);
                toItem.Write(buffer);
                toItem.Close();
            } catch {
                print("Could not find dll in plugin contents");
                return null;
            }
        }

        return Import::GetLibrary(localDllFile);
    }
};
