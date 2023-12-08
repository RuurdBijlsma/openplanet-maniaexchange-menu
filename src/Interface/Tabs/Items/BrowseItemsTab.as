class BrowseItemsTab : ListTab {
    bool IsItemsTab() override { return true; }
    string GetLabel() override {return Icons::Tree + " Items";}
    vec4 GetColor() override { return vec4(0.8f, 0.09f, 0.48f, 1); }

    void RenderHeader() override {
        UI::PushStyleColor(UI::Col::FrameBg , vec4(1, 1, 1, 0.03));
        UI::Dummy(vec2(0, 0));
        if(UI::BeginTable("Filters", 4)) {
            UI::TableSetupColumn("##browse1", UI::TableColumnFlags::WidthFixed, 0);
            UI::TableSetupColumn("##browse2", UI::TableColumnFlags::WidthStretch, 1);
            UI::TableSetupColumn("##browse3", UI::TableColumnFlags::WidthStretch, 1);
            UI::TableSetupColumn("##browse4", UI::TableColumnFlags::WidthStretch, 1);
            UI::TableNextRow();
            UI::TableSetColumnIndex(1);

            if(UI::BeginCombo("Tag", tag.Name, UI::ComboFlags::None)) {
                for(int i = -1; i < int(IX::m_itemTags.Length); i++) {
                    UI::PushID("itemTag" + i);
                    auto iterTag = i == -1 ? emptyTag : IX::m_itemTags[i];
                    UI::PushStyleColor(UI::Col::HeaderHovered, iterTag.VecColor);
                    if(UI::Selectable(iterTag.Name, tag.Name == iterTag.Name, UI::SelectableFlags::None)) {
                        searchTimer = 0;
                        @tag = iterTag;
                    }
                    UI::PopStyleColor(1);
                    UI::PopID();
                }
                UI::EndCombo();
            }

            UI::TableSetColumnIndex(2);
            string newName = UI::InputText("Item name", nameQuery, UI::InputTextFlags::None);
            if(nameQuery != newName) {
                searchTimer = 60;
                nameQuery = newName;
            }

            UI::TableSetColumnIndex(3);
            string newAuthor = UI::InputText("Author", author, UI::InputTextFlags::None);
            if(author != newAuthor) {
                searchTimer = 60;
                author = newAuthor;
            }
            UI::EndTable();
        }
        UI::PopStyleColor();
    }
};