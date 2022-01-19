namespace IfaceRender {
    void ItemRow(IX::Item@ item){
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
        IfaceRender::ItemType(item);
        UI::SameLine();

        // Item Name
        UI::Text(item.Name);

        // Item Tags on newline
        if (item.Tags.Length == 0) UI::Text("No tags");
        else {
            for (uint i = 0; i < item.Tags.Length; i++) {
                if(i != 0) UI::SameLine();
                IfaceRender::ItemTag(item.Tags[i]);
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
        IfaceRender::ImportItemButton(item);
    }
}