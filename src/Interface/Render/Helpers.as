namespace IfaceRender {
    int HoverImage(string url, int width) {
        auto img = Images::CachedFromURL(url);
        int height = 0;
        if (img.m_texture !is null){
            vec2 thumbSize = img.m_texture.GetSize();
            height = thumbSize.y / (thumbSize.x / width);
            UI::Image(img.m_texture, vec2(
                width,
                height
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
            height = width - 16;
            UI::Dummy(vec2(width, width - 16));
        }
        return height;
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

    vec4 noTagsColor = vec4(1, 1, 1, .01);
    void Tags(IX::ItemTag@[] tags) {
        if (tags.Length == 0){
            IfaceRender::Tag("No tags", noTagsColor);
        }
        else {
            for (uint i = 0; i < tags.Length; i++) {
                if(i != 0) {
                    UI::SameLine();
                }
                if(UI::GetCursorPos().x + 75 > UI::GetWindowSize().x) {
                    UI::NewLine();
                }
                IfaceRender::ItemTag(tags[i]);
            }
        }
    }

    string GetHourGlass(){
        int HourGlassValue = Time::Stamp % 3;
        return (HourGlassValue == 0 ? Icons::HourglassStart : (HourGlassValue == 1 ? Icons::HourglassHalf : Icons::HourglassEnd));
    }


    void ImportButton(EImportType importType, ref data, string buttonId, bool showText = false, bool transparentButton = false) {
        if(importType == EImportType::Item) {
            auto item = cast<IX::Item@>(data);
            if(item.IsStoredLocally) {
                string buttonText = Icons::Refresh + (showText ? " Update item" : "") + "##" + buttonId;
                if(ixMenu.isInEditor && UI::RedButton(buttonText)) {
                    print("Refresh button pressed");
                    IO::Delete(item.GetCachePath());
                    IO::Delete(item.GetDestinationPath());
                    item.IsStoredLocally = false;
                    startnew(ImportFunctions::Item, data);
                } 
                if(!ixMenu.isInEditor) {
                    UI::NewLine();
                }
                return;
            }
        }

        bool loading = ixEditor.isImporting;

        string icon = loading ? GetHourGlass() : Icons::Download;

        string extraText = "";
        if(!loading && showText) {
            extraText += " Import into editor";
        } else if(loading && showText) {
            extraText += " Importing...";
        }
        extraText += "##" + buttonId;

        if(loading) UI::BeginDisabled();
        if((loading || ixMenu.isInEditor) && (transparentButton ? UI::TransparentButton(icon + extraText) : UI::CyanButton(icon + extraText))) {
            if(importType == EImportType::Item) {
                startnew(ImportFunctions::Item, data);
            } else if(importType == EImportType::Tree) {
                startnew(ImportFunctions::Tree, data);
            }
        } 
        
        if(!loading && !ixMenu.isInEditor) {
            UI::NewLine();
        }
        if(ixMenu.isInEditor && importType == EImportType::Tree && UI::IsItemHovered()) {
            UI::BeginTooltip();
            UI::Text("Import part of set");
            UI::EndTooltip();
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

enum EImportType {
    Item, Tree
};

namespace ImportFunctions {
    void Item(ref@ itemRef) {
        auto item = cast<IX::Item@>(itemRef);
        ixEditor.ImportItems({item});
    }

    void Tree(ref@ dictRef){
        auto tree = cast<dictionary@>(dictRef);
        auto items = IX::TreeToArray(tree);
        print("Import " + items.Length + " items");
        ixEditor.ImportItems(items);
    }
}