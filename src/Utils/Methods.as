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