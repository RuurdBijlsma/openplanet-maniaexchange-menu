class BrowseItemTab : ItemListTab {
    string tag = "";
    string name = "";
    string author = "";
    int searchTimer = -1;

    bool IsVisible() override {return Setting_Tab_Featured_Visible;}
    string GetLabel() override {return Icons::Tree + " Items";}

    vec4 GetColor() override { return vec4(0.8f, 0.09f, 0.48f, 1); }

    dictionary@ GetRequestParams() {
        auto params = ItemListTab::GetRequestParams();
        return params;
    }

    void RenderHeader() override {
        UI::PushStyleColor(UI::Col::FrameBg , vec4(1, 1, 1, 0.03));
        UI::Dummy(vec2(0, 0));
        if(UI::BeginTable("Filters", 4)) {
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 0);
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthStretch, 1);
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthStretch, 1);
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthStretch, 1);
            UI::TableNextRow();
            UI::TableSetColumnIndex(1);

            if(UI::BeginCombo("Tag", tag, UI::ComboFlags::None)) {
                for(int i = -1; i < int(IX::m_itemTags.Length); i++) {
                    string tagName = i == -1 ? '' : IX::m_itemTags[i].Name;
                    if(UI::Selectable(tagName, tag == tagName, UI::SelectableFlags::None)) {
                        print("Change tag");
                        searchTimer = 1;
                        tag = tagName;
                    }
                }
                UI::EndCombo();
            }

            UI::TableSetColumnIndex(2);
            string newName = UI::InputText("Item name", name, UI::InputTextFlags::None);
            if(name != newName) {
                print("Change name");
                searchTimer = 60;
                name = newName;
            }

            UI::TableSetColumnIndex(3);
            string newAuthor = UI::InputText("Author", author, UI::InputTextFlags::None);
            if(author != newAuthor) {
                print("Change author");
                searchTimer = 60;
                author = newAuthor;
            }
            UI::EndTable();
        }

        if(searchTimer >= 0 && searchTimer-- == 0) {
            print("FIRE SEARCH");
        }
        UI::PopStyleColor();
    }
};