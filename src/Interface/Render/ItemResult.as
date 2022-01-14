namespace IfaceRender {
    void ItemResult(IX::Item@ item){
        UI::TableNextRow();
        UI::TableSetColumnIndex(0);

        auto img = Images::CachedFromURL("https://" + MXURL + "/item/icon/" + item.ID);
        auto thumbWidth = 50;
        if(img.m_texture !is null){
            vec2 thumbSize = img.m_texture.GetSize();
            UI::Image(img.m_texture, vec2(
                thumbWidth,
                thumbSize.y / (thumbSize.x / thumbWidth)
            ));
        }

        UI::TableSetColumnIndex(1);
        
        // Item Type Icon
        UI::SetNextWindowContentSize(50, 50);
        auto dl = UI::GetWindowDrawList();
        if(item.Type == EItemType::Ornament){
            UI::Text(Icons::Tree);
        } else if(item.Type == EItemType::Block){
            UI::Text(Icons::Cube);
        }
        UI::SameLine();

        // Item Name
        UI::Text(item.Name);

        // Item Tags on newline
        if (item.Tags.get_Length() == 0) UI::Text("No tags");
        else if (item.Tags.get_Length() == 1) UI::Text(item.Tags[0].Name);
        else {
            for (uint i = 0; i < item.Tags.Length; i++) {
                IfaceRender::ItemTag(item.Tags[i]);
                UI::SameLine();
            }
        }

        UI::TableSetColumnIndex(2);
        UI::Text(item.Username);

        UI::TableSetColumnIndex(3);
        UI::Text(tostring(item.LikeCount));

        UI::TableSetColumnIndex(4);
        UI::Text(tostring(item.Score));

        UI::TableSetColumnIndex(5);
        UI::Text(tostring(item.FileSize) + ' KB');

        UI::TableSetColumnIndex(6);
        if (UI::GreenButton(Icons::InfoCircle)) {
            ixMenu.AddTab(ItemTab(item.ID), true);
        }
        UI::SameLine();
        if (UI::CyanButton(Icons::Download)) {
            startnew(ImportItem, item);
        }
    }
}

void ImportItem(ref@ item){
    editorIX.ImportItem(cast<IX::Item@>(item));
}