class EditorIX {
    Import::Library@ lib = null;
    Import::Function@ clickFun = null;
    Import::Function@ mousePosFun = null;
    bool isImporting = false;
    string downloadFolder = '';

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

    bool ImportItem(IX::Item@ item, string desiredItemLocation = '') {
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
        isImporting = true;

        string itemFolder = item.Username + '/';
        if(!IO::FolderExists(downloadFolder + itemFolder)) IO::CreateFolder(downloadFolder + itemFolder);
        if(item.SetID != 0) {
            itemFolder += item.SetID + '/';
            if(!IO::FolderExists(downloadFolder + itemFolder)) IO::CreateFolder(downloadFolder + itemFolder);
        }

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

        MyYield();
        // Click "create new item" button
        editor.ButtonItemNewModeOnClick();
        MyYield();
        
        // Click screen at position to enter "create new item" UI
        auto screenWidth = Draw::GetWidth();
        auto screenHeight = Draw::GetHeight();
        auto xClick = screenOffsetLeft + screenWidth / 2;
        auto yClick = screenOffsetTop + screenHeight / 2;
        mousePosFun.Call(xClick, yClick - 2);
        MyYield();
        mousePosFun.Call(xClick, yClick - 1);
        MyYield();
        clickFun.Call(true, xClick, yClick);
        MyYield();

        // Save empty item to file
        auto editorItem = cast<CGameEditorItem>(app.Editor);
        editorItem.FileSaveAs();
        MyYield();
        MyYield();
        app.BasicDialogs.String = desiredItemLocation;
        MyYield();
        app.BasicDialogs.DialogSaveAs_OnValidate();
        MyYield();
        app.BasicDialogs.DialogSaveAs_OnValidate();
        MyYield();
        
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
            MyYield();
            print("Waiting");
        }

        // Click "edit item" button
        editor.ButtonItemEditModeOnClick();
        
        MyYield();
        mousePosFun.Call(true, xClick, yClick - 1);
        auto maxLoops = 100; // 1 seconds
        auto i = 0;
        // Click screen until we're in "edit item" UI
        while(true){
            clickFun.Call(true, xClick, yClick - 2);
            MyYield();
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
            MyYield();
            print("Waiting");
        }

        // undo placing
        print("UNDO");
        editor.ButtonUndoOnClick();
        editor.ButtonUndoOnClick();
        // editor.PluginMapType.Undo();

        print("IX DONE");
    }

    void MyYield(){
        yield();
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