namespace IfaceRender {
    string GetHourGlass(){
        int HourGlassValue = Time::Stamp % 3;
        return (HourGlassValue == 0 ? Icons::HourglassStart : (HourGlassValue == 1 ? Icons::HourglassHalf : Icons::HourglassEnd));
    }

    void ImportItemButton(IX::Item@ item, bool showText = false){
        bool loading = editorIX.isImporting;

        string icon = loading ? GetHourGlass() : Icons::Download;

        string extraText = "";
        if(!loading && showText) {
            extraText += " Import into editor";
        }else if(loading && showText) {
            extraText += " Importing...";
        }

        if(loading) UI::BeginDisabled();
        if(ixMenu.isInEditor && UI::CyanButton(icon + extraText)) {
            startnew(ImportItem, item);
        }
        if(loading) UI::EndDisabled();
    }

    void ItemType(IX::Item@ item) {
        if(item.Type == EItemType::Ornament){
            UI::Text(Icons::Tree);
        } else if(item.Type == EItemType::Block){
            UI::Text(Icons::Cube);
        } else {
            UI::Text(Icons::Question);
        }
    }
}

void ImportItem(ref@ item){
    editorIX.ImportItem(cast<IX::Item@>(item));
}