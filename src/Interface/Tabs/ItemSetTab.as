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
                if(UI::BeginTabItem(tostring(i))) {
                    IfaceRender::HoverImage("https://" + MXURL + "/set/image/" + itemSet.ID + '/' + i, width);
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
        
        IfaceRender::TabHeader(Icons::InfoCircle + " Information");

        if(UI::BeginTable("InfoColumns", 2)) {
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 125);
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthStretch, 1);

            IfaceRender::SimpleTableRow({"Set ID:", tostring(itemSet.ID)});
            IfaceRender::SimpleTableRow({"Uploaded by:", itemSet.Username});
            if(itemSet.Updated == itemSet.Uploaded){
                IfaceRender::SimpleTableRow({"Uploaded:", itemSet.Uploaded});
            } else {
                IfaceRender::SimpleTableRow({"Uploaded (Ver.):", itemSet.Uploaded + " (" + itemSet.Updated + ")"});
            }
            IfaceRender::SimpleTableRow({"Filesize:", tostring(itemSet.FileSize) + ' KB'});
            
            // tag row
            UI::TableNextRow();
            UI::PushFont(ixMenu.g_fontBold);
            UI::TableSetColumnIndex(0);
            UI::Text("Tags:");
            UI::PopFont();
            UI::TableSetColumnIndex(1);
            IfaceRender::Tags(itemSet.Tags);
            // end tag row

            UI::EndTable();
        }
        
        
        if(itemSet.Description != "") {
            IfaceRender::TabHeader(Icons::Pencil + " Description");
            IfaceRender::IXComment(itemSet.Description);
        }

        IfaceRender::TabHeader(Icons::FolderOpen + " Contents");
        UI::Text("Contents here");


        UI::EndChild();
    }
};
