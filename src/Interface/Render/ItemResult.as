namespace IfaceRender {
    void ItemBlock(IX::Item@ item) {
        UI::Separator();
        if(UI::BeginTable("ItemBlock", 3)){
            UI::TableSetupColumn("##1" + item.ID, UI::TableColumnFlags::WidthFixed, 50);
            UI::TableSetupColumn("##2" + item.ID, UI::TableColumnFlags::WidthStretch, 1);
            UI::TableSetupColumn("##3" + item.ID, UI::TableColumnFlags::WidthFixed, 75);

            UI::TableNextRow();
            UI::TableSetColumnIndex(0);
            IfaceRender::Image("https://" + MXURL + "/item/icon/" + item.ID, 50);
            UI::TableSetColumnIndex(1);
            UI::PushStyleVar(UI::StyleVar::ItemSpacing, vec2(0, 15));
            IfaceRender::ItemType(item);
            UI::SameLine();
            UI::PushFont(Fonts::fontHeader2);
            UI::Text(item.Name);
            UI::PopFont();
            UI::PopStyleVar();
            UI::Text("By " + Icons::User + " " + item.Username + " | " + Icons::Heart + " " + item.LikeCount + " | " + Icons::Bolt + " " + item.Score + " | " + Icons::Download + " " + item.Downloads);
            UI::TableSetColumnIndex(2);
            
            if (UI::GreenButton(Icons::InfoCircle)) {
                ixMenu.AddTab(ItemTab(item.ID), true);
            }
            UI::SameLine();
            IfaceRender::ImportButton(EImportType::Item, item, 'block' + item.ID);

            UI::EndTable();
        }
        UI::Separator();
    }

    // dense version is 4 rows, otherwise 7 rows
    void ItemRow(IX::Item@ item, bool dense = false) {
        UI::PushStyleVar(UI::StyleVar::FramePadding, vec2(20, 20));

        UI::TableNextRow();

        UI::TableSetColumnIndex(0);

        UI::Dummy(vec2(0, 0));
        UI::SameLine();
        
        IfaceRender::Image("https://" + MXURL + "/item/icon/" + item.ID, 50);

        UI::TableNextColumn();
        
        UI::Dummy(vec2(0,1));
        // Item Type Icon
        IfaceRender::ItemType(item);
        UI::SameLine();

        // Item Name
        UI::Text(item.Name);

        // Item Tags on newline
        IfaceRender::Tags(item.Tags);

        if(!dense) {
            UI::TableNextColumn();
            UI::AlignTextToFramePadding();
            UI::Text(item.Username);

            UI::TableNextColumn();
            auto diff = SecondsDifferenceToString(DateTimeSubtract(ixMenu.nowDateTime, item.uploadedDate));
            UI::Text(diff + " ago");

            UI::TableNextColumn();
            UI::Text(tostring(item.LikeCount));

            UI::TableNextColumn();
            UI::Text(tostring(item.Score));
        }

        UI::TableNextColumn();
        UI::Text(tostring(item.FileSize) + ' KB');

        UI::TableNextColumn();
        UI::PopStyleVar(1);
        UI::PushStyleVar(UI::StyleVar::FramePadding, vec2(6, 20));
        IfaceRender::ImportButton(EImportType::Item, item, 'row' + item.ID);
        UI::SameLine();
        if (UI::GreenButton(Icons::InfoCircle)) {
            ixMenu.AddTab(ItemTab(item.ID), true);
        }
        UI::PopStyleVar(1);
    }
}