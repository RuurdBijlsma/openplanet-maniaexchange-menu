namespace IfaceRender {
    void HoverImage(string url, int width) {
        auto img = Images::CachedFromURL(url);
        if (img.m_texture !is null){
            vec2 thumbSize = img.m_texture.GetSize();
            UI::Image(img.m_texture, vec2(
                width,
                thumbSize.y / (thumbSize.x / width)
            ));
            if (UI::IsItemHovered()) {
                UI::BeginTooltip();
                UI::Image(img.m_texture, vec2(
                    Draw::GetWidth() * 0.6,
                    thumbSize.y / (thumbSize.x / (Draw::GetWidth() * 0.6))
                ));
                UI::EndTooltip();
            }
        } else {
            UI::Text(IfaceRender::GetHourGlass() + " Loading");
            UI::Dummy(vec2(width, width - 16));
        }
    }

    void Image(string url, int width) {
        auto img = Images::CachedFromURL(url);
        if(img.m_texture !is null){
            vec2 thumbSize = img.m_texture.GetSize();
            UI::Image(img.m_texture, vec2(
                width,
                thumbSize.y / (thumbSize.x / width)
            ));
        } else {
            UI::Dummy(vec2(width, width));
        }
    }

    void SimpleTableRow(string[] text){
        UI::TableNextRow();
        for(uint i = 0; i < text.Length; i++) {
            if(i == 0) UI::PushFont(ixMenu.g_fontBold);
            UI::TableSetColumnIndex(i);
            UI::Text(text[i]);
            if(i == 0) UI::PopFont();
        }
    }

    void TabHeader(string header){
        UI::BeginTabBar(header);
        UI::BeginTabItem(header);
        UI::EndTabItem();
        UI::EndTabBar();
    }

    void Tags(IX::ItemTag@[] tags) {
        if (tags.Length == 0) UI::Text("No tags");
        else {
            for (uint i = 0; i < tags.Length; i++) {
                if(i != 0) UI::SameLine();
                IfaceRender::ItemTag(tags[i]);
            }
        }
    }

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