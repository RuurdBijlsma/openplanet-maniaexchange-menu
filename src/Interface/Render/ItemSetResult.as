namespace IfaceRender {
    void ItemSetBlock(IX::ItemSet@ itemSet) {
        UI::Separator();
        if(UI::BeginTable("ItemSetBlock", 3)){
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 90);
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthStretch, 1);
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 40);

            UI::TableNextRow();
            UI::TableSetColumnIndex(0);
            int imgHeight = 0;
            if(itemSet.ImageCount > 0)
                imgHeight = IfaceRender::HoverImage("https://" + MXURL + "/set/image/" + itemSet.ID + "/1", 100);
            // UI::AlignTextToFramePadding();
            UI::TableSetColumnIndex(1);
            // UI::PushStyleVar(UI::StyleVar::ItemSpacing, vec2(0, 20));
            int dummyHeight = (imgHeight - 60) / 3;
            UI::Dummy(vec2(0, dummyHeight));
            UI::Text(Icons::FolderOpen);
            UI::SameLine();
            UI::PushFont(Fonts::fontHeader2);
            UI::Text(itemSet.Name);
            UI::Dummy(vec2(0, dummyHeight));
            UI::PopFont();
            // UI::PopStyleVar();
            UI::Text("By " + Icons::User + " " + itemSet.Username + " | " + Icons::Heart + " " + itemSet.LikeCount + " | " + Icons::Bolt + " " + itemSet.Score + " | " + Icons::Download + " " + itemSet.Downloads);
            UI::TableSetColumnIndex(2);
            
            UI::PushStyleVar(UI::StyleVar::FramePadding, vec2(7, imgHeight / 2 - 7));
            if (UI::GreenButton(Icons::InfoCircle)) {
                ixMenu.AddTab(ItemSetTab(itemSet.ID), true);
            }
            UI::PopStyleVar(1);

            UI::EndTable();
        }
        UI::Separator();
    }

    // dense version is 4 rows, otherwise 7 rows
    void ItemSetRow(IX::ItemSet@ itemSet, bool dense = false) {
        UI::PushStyleVar(UI::StyleVar::FramePadding, vec2(20, 20));
        // UI::Dummy(vec2(0, 7));
        // UI::Separator();

        UI::TableNextRow();

        UI::TableSetColumnIndex(0);

        UI::Dummy(vec2(0, 0));
        UI::SameLine();
        if(itemSet.ImageCount > 0)
            IfaceRender::HoverImage("https://" + MXURL + "/set/image/" + itemSet.ID + "/0", 0, 50);

        UI::TableNextColumn();
        
        UI::Dummy(vec2(0,1));

        // Item Name
        UI::Text(itemSet.Name);

        // Item Tags on newline
        IfaceRender::Tags(itemSet.Tags);

        if(!dense) {
            UI::TableNextColumn();
            UI::AlignTextToFramePadding();
            UI::Text(itemSet.Username);

            UI::TableNextColumn();
            auto diff = SecondsDifferenceToString(DateTimeSubtract(ixMenu.nowDateTime, itemSet.uploadedDate));
            UI::Text(diff + " ago");

            UI::TableNextColumn();
            UI::Text(tostring(itemSet.LikeCount));

            UI::TableNextColumn();
            UI::Text(tostring(itemSet.Score));
        }

        UI::TableNextColumn();
        UI::Text(tostring(itemSet.FileSize) + ' KB');

        UI::TableNextColumn();
        UI::PopStyleVar(1);
        UI::PushStyleVar(UI::StyleVar::FramePadding, vec2(6, 20));
        if (UI::GreenButton(Icons::InfoCircle)) {
            ixMenu.AddTab(ItemSetTab(itemSet.ID), true);
        }
        UI::PopStyleVar(1);
    }
}