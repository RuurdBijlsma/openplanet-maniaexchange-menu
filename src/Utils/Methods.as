string[] BoolsToStrings(bool[] input){
    string[] output = {};
    for(uint i = 0; i < input.Length; i++)
        output.InsertLast(tostring(input[i]));
    return output;
}

string[] IntsToStrings(int[] input){
    string[] output = {};
    for(uint i = 0; i < input.Length; i++)
        output.InsertLast(tostring(input[i]));
    return output;
}

bool IsDevMode(){
    return Meta::ExecutingPlugin().get_Type() == Meta::PluginType::Folder;
}

string GetItemsFolder() {
    auto documents = IO::FromDataFolder("").Split('/Openplanet')[0] + "\\Documents";
    string itemsFolder;
    if(IO::FolderExists(documents + "\\Trackmania2020")) {
        itemsFolder = documents + "\\Trackmania2020\\Items\\";
    } else {
        itemsFolder = documents + "\\Trackmania\\Items\\";
    }
    return itemsFolder.Replace("\\", "/");
}