class ItemSetTab : Tab {
    IX::ItemSet@ itemSet;
    int ID;
    EGetStatus status = EGetStatus::Downloading;

    ItemSetTab(int setID){
        this.ID = setID;
        downloader.Check('set', ID);
    }

    bool CanClose() override { return true; }
    string GetLabel() override {
        if (status == EGetStatus::Error) 
            return "\\$f00" + Icons::Times + " \\$zError";
        if (status == EGetStatus::Downloading) 
            return Icons::Database + " Loading...";
        return Icons::Database + " " + itemSet.Name;
    }
    vec4 GetColor() override { return pluginColorVec; }

    void Render() override {
        if(status != EGetStatus::Available) {
            status = downloader.Check('set', ID);
            if(status == EGetStatus::Error) {
                UI::Text("\\$f00" + Icons::Times + " \\$zSet not found");
                return;
            }
            if(status == EGetStatus::Downloading) {
                UI::Text(IfaceRender::GetHourGlass() + " Loading...");
                return;
            }
            if(status == EGetStatus::Available) {
                @itemSet = downloader.GetSet(ID);
            }
        }

        float width = UI::GetWindowSize().x * .4;
        vec2 posTop = UI::GetCursorPos();

        UI::BeginChild("ItemImage", vec2(width, 0));

        UI::BeginTabBar("MapImages");

        if (itemSet.ImageCount != 0) {
            for (int i = 1; i < itemSet.ImageCount + 1; i++) {
                if(UI::BeginTabItem(tostring(i))){
                    auto img = Images::CachedFromURL("https://"+MXURL+"/set/image/"+itemSet.ID+'/'+i);

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
                    }
                    UI::EndTabItem();
                }
            }
        }

        UI::EndTabBar();


        UI::EndChild();
        UI::SetCursorPos(posTop + vec2(width + 8, 0));
        UI::BeginChild("ItemHeader");

        UI::PushFont(ixMenu.g_fontTitle);
        UI::Text(itemSet.Name);
        UI::PopFont();

        UI::Text(Icons::Bolt + " " + itemSet.Score + " | " + Icons::Download + " " + itemSet.Downloads);

        UI::Separator();
        UI::Text(Icons::Info + "Information");
        UI::Separator();

        IfaceRender::InfoRow("Set ID", tostring(itemSet.ID), 61);
        IfaceRender::InfoRow("Uploaded by", itemSet.Username, 20);
        if(itemSet.Updated == itemSet.Uploaded){
            IfaceRender::InfoRow("Uploaded", itemSet.Uploaded, 40);
        } else {
            IfaceRender::InfoRow("Uploaded (Ver.)", itemSet.Uploaded + " (" + itemSet.Updated + ")", 1);
        }
        IfaceRender::InfoRow("Filesize", tostring(itemSet.FileSize) + ' KB', 54);
    
        UI::PushFont(ixMenu.g_fontBold);
        UI::Text("Tags:");
        UI::PopFont();
        UI::SameLine();
        UI::Dummy(vec2(74, 0));
        UI::SameLine();
        if (itemSet.Tags.Length == 0) UI::Text("No tags");
        else {
            for (uint i = 0; i < itemSet.Tags.Length; i++) {
                if(i != 0) UI::SameLine();
                IfaceRender::ItemTag(itemSet.Tags[i]);
            }
        }

        // UI::Text("Set ID:            " + itemSet.ID);
        // UI::Text("Uploaded by:       " + itemSet.Username);
        // if(itemSet.Updated == itemSet.Uploaded){
        // UI::Text("Uploaded:          " + itemSet.Uploaded);
        // } else {
        // UI::Text("Uploaded (Ver.):   " + itemSet.Uploaded + " (" + itemSet.Updated + ")");
        // }
        // UI::Text("Filesize:" + tostring(itemSet.FileSize) + ' KB');
        // UI::Text("Tags:");
        // UI::SameLine();
        // if (itemSet.Tags.Length == 0) UI::Text("No tags");
        // else {
        //     for (uint i = 0; i < itemSet.Tags.Length; i++) {
        //         if(i != 0) UI::SameLine();
        //         IfaceRender::ItemTag(itemSet.Tags[i]);
        //     }
        // }

        if(itemSet.Description != "") {
            UI::Separator();
            UI::Text(Icons::Pencil + " Description");
            UI::Separator();

            IfaceRender::IXComment(itemSet.Description);
        }

        UI::Separator();
        UI::Text(Icons::Folder + " Contents");
        UI::Separator();

        UI::Text("Contents here");

        UI::EndChild();
    }
};
