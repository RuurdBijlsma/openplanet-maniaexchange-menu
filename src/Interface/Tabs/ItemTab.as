class ItemTab : Tab {
    IX::Item@ item;
    int ID;
    EGetStatus status = EGetStatus::Downloading;

    ItemTab(int itemID){
        this.ID = itemID;
        downloader.Check('item', ID);
    }

    bool CanClose() override { return true; }
    string GetLabel() override {
        if (status == EGetStatus::Error) 
            return "\\$f00" + Icons::Times + " \\$zError";
        if (status == EGetStatus::Downloading) 
            return Icons::Database + " Loading...";
        return Icons::Tree + " " + item.Name;
    }

    void Render() override {
        if(status != EGetStatus::Available) {
            status = downloader.Check('item', ID);
            if(status == EGetStatus::Error) {
                UI::Text("\\$f00" + Icons::Times + " \\$zItem not found");
                return;
            }
            if(status == EGetStatus::Downloading) {
                UI::Text(IfaceRender::GetHourGlass() + " Loading...");
                return;
            }
            if(status == EGetStatus::Available) {
                @item = downloader.GetItem(ID);
            }
        }

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
            if(UI::Button(item.SetName)) {
                ixMenu.AddTab(ItemSetTab(item.SetID), true);
            }
            UI::PopStyleVar();
            UI::PopStyleColor(4);
        }

        UI::Separator();
        UI::Text(Icons::Info + " Information");
        UI::Separator();

        IfaceRender::InfoRow("Item ID", tostring(item.ID), 51);
        IfaceRender::InfoRow("Uploaded by", item.Username, 20);
        if(item.AuthorLogin != '') {
            IfaceRender::InfoRow("Creator Login", item.AuthorLogin, 13);
        }
        if(item.Updated == item.Uploaded){
            IfaceRender::InfoRow("Uploaded", item.Uploaded, 40);
        } else {
            IfaceRender::InfoRow("Uploaded (Ver.)", item.Uploaded + " (" + item.Updated + ")", 1);
        }
        IfaceRender::InfoRow("Item Type", tostring(item.Type), 36);
        IfaceRender::InfoRow("Filesize", tostring(item.FileSize) + ' KB', 54);
    
        UI::PushFont(ixMenu.g_fontBold);
        UI::Text("Tags:");
        UI::PopFont();
        UI::SameLine();
        UI::Dummy(vec2(74, 0));
        UI::SameLine();
        if (item.Tags.Length == 0) UI::Text("No tags");
        else {
            for (uint i = 0; i < item.Tags.Length; i++) {
                if(i != 0) UI::SameLine();
                IfaceRender::ItemTag(item.Tags[i]);
            }
        }

        if(ixMenu.isInEditor) {
            UI::Separator();
            IfaceRender::ImportItemButton(item, true);
        }

        if(item.Description != "") {
            UI::Separator();
            UI::Text(Icons::Pencil + " Description");
            UI::Separator();

            IfaceRender::IXComment(item.Description);
        }

        UI::EndChild();
    }
};