class RequestItemTuple {
    Net::HttpRequest@ request = null;
    IX::Item@ item = null;
    RequestItemTuple(Net::HttpRequest@ request, IX::Item@ item) {
        @this.request = request;
        @this.item = item;
    }
};

class EditorIX {
    Import::Library@ lib = null;
    Import::Function@ clickFun = null;
    Import::Function@ mousePosFun = null;
    bool isImporting = false;
    string downloadFolder = '';
    int importTotal = 1;
    int importFinished = 0;

    EditorIX (){
        print("Getting click dll");
        @lib = GetZippedLibrary("lib/libclick.dll");
        @clickFun = lib.GetFunction("clickPos");
        @mousePosFun = lib.GetFunction("moveMouse");
        if(clickFun is null){
            warn("clickFun is null");
            return;
        }
        if(mousePosFun is null){
            warn("mousePosFun is null");
            return;
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
        if(createPath.Contains("\\"))
            separator = "\\";
        // Format path to the following template
        // basePath: C://Users/Ruurd/ (ends with separator)
        // createPath: OpenplanetNext/Plugins/lib (no separator at start or end)
        if(!basePath.EndsWith(separator)){
            basePath = basePath + separator;
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
            if(!IO::FolderExists(path + parts[i])) {
                IO::CreateFolder(path + parts[i]);
            }
            path += parts[i];
        }
    }

    string GetItemFolder(IX::Item@ item) {
        string itemFolder = item.Username + '/';
        if(item.SetID != 0) {
            itemFolder += item.SetName + '/';
        }
        return itemFolder;
    }

    bool ImportItems(IX::Item@[] items) {
        importFinished = 0;
        importTotal = items.Length;

        if(!WaitForImport()) return false;
        isImporting = true;

        RequestItemTuple@[] requests = {};
        for(uint i = 0; i < items.Length; i++) {
            auto item = items[i];
            auto itemFolder = GetItemFolder(item);
            CreateFolderRecursive(downloadFolder, itemFolder);
            string filePath = downloadFolder + itemFolder + item.FileName;

            if(!IO::FileExists(filePath)) {
                string url = "https://" + MXURL + "/item/download/" + item.ID;                
                auto request = Net::HttpGet(url);
                requests.InsertLast(RequestItemTuple(request, item));
            } else {
                // file already exists in downloads cache, increment counter
                importFinished++;
            }
        }

        // Wait for all downloads to complete
        while(true) {
            for(uint i = requests.Length - 1; i >= 0; i--) {
                auto ri = requests[i];
                if(!ri.request.Finished())
                    continue;
                importFinished++;
                requests.RemoveAt(i);
                auto code = ri.request.ResponseCode();
                if(code < 200 || code >= 300) {
                    warn("Error making request to '" + ri.request.Url + "' error code: " + code);
                    continue;
                }
                string filePath = downloadFolder + GetItemFolder(ri.item) + ri.item.FileName;
                ri.request.SaveToFile(filePath);
            }
            if(importFinished == importTotal) 
                break;
            yield();
        }

        for(uint i = 0; i < items.Length; i++) {
            auto item = items[i];
            auto itemFolder = GetItemFolder(item);
            string filePath = downloadFolder + itemFolder + item.FileName;
            string desiredItemLocation = itemFolder + item.FileName;
            LoadItem(filePath, desiredItemLocation);
            yield();
        }

        isImporting = false;
        return true;
    }

    bool ImportItem(IX::Item@ item, string desiredItemLocation = '') {
        if(!WaitForImport()) return false;
        isImporting = true;

        string itemFolder = item.Username + '/';
        if(item.SetID != 0) {
            itemFolder += item.SetName + '/';
        }
        CreateFolderRecursive(downloadFolder, itemFolder);
        
        string filePath = downloadFolder + itemFolder + item.FileName;
        if(!IO::FileExists(filePath)) {
            API::DownloadToFile("https://" + MXURL + "/item/download/" + item.ID, filePath);
        }

        if(desiredItemLocation == '')
            desiredItemLocation = itemFolder + item.FileName;

        LoadItem(filePath, desiredItemLocation);

        isImporting = false;
        return true;
    }

    void LoadItem(string gbxLocation, string desiredItemLocation) {
        CTrackMania@ app = cast<CTrackMania>(GetApp());
        auto editor = cast<CGameCtnEditorCommon@>(app.Editor);
        if(editor is null) {
            print("Editor is null");
            return;
        }

        yield();
        // Click "create new item" button
        editor.ButtonItemNewModeOnClick();
        yield();
        
        // Click screen at position to enter "create new item" UI
        auto screenWidth = Draw::GetWidth();
        auto screenHeight = Draw::GetHeight();
        auto xClick = screenOffsetLeft + screenWidth / 2;
        auto yClick = screenOffsetTop + screenHeight / 2;
        mousePosFun.Call(xClick, yClick - 2);
        yield();
        mousePosFun.Call(xClick, yClick - 1);
        yield();
        clickFun.Call(true, xClick, yClick);
        yield();

        // Save empty item to file
        auto editorItem = cast<CGameEditorItem>(app.Editor);
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
        
        yield();
        mousePosFun.Call(true, xClick, yClick - 1);
        auto maxLoops = 100; // 1 seconds
        auto i = 0;
        // Click screen until we're in "edit item" UI
        while(true){
            clickFun.Call(true, xClick, yClick - 2);
            yield();
            @editorItem = cast<CGameEditorItem>(app.Editor);
            if(editorItem !is null)
                break;
            if(i++ > maxLoops){
                error("ERROR getting to 'edit item' UI");
                return;
            }
        }

        // Exit edit item UI
        editorItem.Exit();

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

    string GetItemsFolder(){
        return IO::FromDataFolder("").Split('/Openplanet')[0] + "\\Documents\\Trackmania\\Items\\";
    }

    string GetPluginName(){
        IO::FileSource info('info.toml');
        return info.ReadToEnd().Replace(' ', '').Split('name="')[1].Split('"')[0];
    }

    Import::Library@ GetZippedLibrary(string relativeDllPath) {
        auto parts = relativeDllPath.Split("/");
        string fileName = parts[parts.Length - 1];
        const string baseFolder = IO::FromDataFolder('');
        const string dllFolder = baseFolder + 'lib/';
        const string localDllFile = dllFolder + fileName;

        if(!IO::FolderExists(dllFolder)) {
            print("Create folder: " + dllFolder);
            IO::CreateFolder(dllFolder);
        }

        if(!IO::FileExists(localDllFile)) {
            print("Copying dll from zip to local! " + localDllFile);
            IO::FileSource zippedDll(relativeDllPath);
            auto buffer = zippedDll.Read(zippedDll.Size());
            IO::File toItem(localDllFile, IO::FileMode::Write);
            toItem.Write(buffer);
            toItem.Close();
        }

        return Import::GetLibrary(localDllFile);
    }
}