class ItemTab : Tab {
    IX::Item@ item;
    ItemTab(IX::Item@ item){
        @this.item = item;
    }
    bool CanClose() override { return true; }

    string GetLabel() override { return Icons::Tree + " " + item.Name; }

    vec4 GetColor() override { return pluginColorVec; }

    void Render() override {
        float width = (UI::GetWindowSize().x * 0.35) * 0.5;
        vec2 posTop = UI::GetCursorPos();

        UI::BeginChild("ItemImage", vec2(width, 0));

        
        UI::BeginTabBar("ItemImages");
        if(UI::BeginTabItem("Icon")){
            auto img = Images::CachedFromURL("https://" + MXURL + "/item/icon/" + item.ID);
            if(img.m_texture !is null){
                vec2 thumbSize = img.m_texture.GetSize();
                UI::Image(img.m_texture, vec2(
                    width,
                    thumbSize.y / (thumbSize.x / width)
                ));
            }
            UI::EndTabItem();
        }
        if(item.HasThumbnail && UI::BeginTabItem("Thumbnail")){
            auto img = Images::CachedFromURL("https://" + MXURL + "/item/thumbnail/" + item.ID);
            if(img.m_texture !is null){
                vec2 thumbSize = img.m_texture.GetSize();
                UI::Image(img.m_texture, vec2(
                    width,
                    thumbSize.y / (thumbSize.x / width)
                ));
            }
            UI::EndTabItem();
        }
        UI::EndTabBar();


        UI::EndChild();
        UI::SetCursorPos(posTop + vec2(width + 8, 0));
        UI::BeginChild("ItemHeader");

        UI::PushFont(ixMenu.g_fontTitle);
        UI::Text(item.Name);
        UI::PopFont();

        UI::Text(Icons::Bolt + " " + item.Score + " | " + Icons::Download + " " + item.Downloads);
        if(item.SetID != 0){
            UI::SameLine();
            UI::Text(" | " + Icons::Folder + " Part of set ");
            
            UI::SameLine();
            auto buttonBg = vec4(0, 0, 0, 0);
            auto hoverBg = vec4(255, 255, 255, 0.1);
            UI::PushStyleColor(UI::Col::Button, buttonBg);
            UI::PushStyleColor(UI::Col::ButtonHovered, hoverBg);
            UI::PushStyleColor(UI::Col::ButtonActive, buttonBg);
            UI::PushStyleColor(UI::Col::Text, GetColor());
            UI::PushStyleVar(UI::StyleVar::FramePadding, vec2(0, 0));
            // TODO make set clickable
            if(UI::Button(item.SetName)) {
                ixMenu.AddTab(ItemSetTab(item.SetID), true);
            }
            UI::PopStyleVar();
            UI::PopStyleColor(4);
        }

        UI::Separator();
        // UI::PushFont(ixMenu.g_fontHeader2);
        UI::Text(Icons::Info + " Information");
        // UI::PopFont();
        UI::Separator();

        int leftSize = 100;
        vec2 posTop2 = UI::GetCursorPos();
        UI::BeginChild("ItemInfoLeft", vec2(leftSize, 0));
        UI::PushFont(ixMenu.g_fontBold);
        UI::Text("Item ID:");
        UI::Text("Uploaded by:");
        if(item.AuthorLogin != '') UI::Text("Creator Login:");
        if(item.Updated == item.Uploaded){
            UI::Text("Uploaded:");
        } else {
            UI::Text("Uploaded (Ver.):");
        }
        UI::Text("Item Type:");
        UI::Text("Filesize:");
        UI::Text("Tags:");
        UI::PopFont();
        UI::EndChild();

        UI::SetCursorPos(posTop2 + vec2(leftSize + 8, 0));

        UI::BeginChild("ItemInfoRight");
        UI::Text(tostring(item.ID));
        UI::Text(item.Username);
        if(item.AuthorLogin != '') UI::Text(item.AuthorLogin);
        if(item.Updated == item.Uploaded){
            UI::Text(item.Uploaded);
        } else {
            UI::Text(item.Uploaded + " (" + item.Updated + ")");
        }
        UI::Text(tostring(item.Type));
        UI::Text(tostring(item.FileSize) + ' KB');
        
        if (item.Tags.Length == 0) UI::Text("No tags");
        else {
            for (uint i = 0; i < item.Tags.Length; i++) {
                if(i != 0) UI::SameLine();
                IfaceRender::ItemTag(item.Tags[i]);
            }
        }

        IfaceRender::ImportItemButton(item, true);
        UI::EndChild();

        UI::EndChild();
    }
};
