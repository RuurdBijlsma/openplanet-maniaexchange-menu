class HomePageTab : Tab {
    string GetLabel() override { return Icons::Home; }

    vec4 GetColor() override { return pluginColorVec; }

    void Render() override {
        float width = (UI::GetWindowSize().x*0.35)*0.5;
        vec2 posTop = UI::GetCursorPos();

        UI::BeginChild("Summary", vec2(width,0));

        auto logo = Images::CachedFromURL("https://images.mania.exchange/logos/ix/square_sm.png");
        if (logo.m_texture !is null){
            vec2 logoSize = logo.m_texture.GetSize();
            UI::Image(logo.m_texture, vec2(
                width,
                logoSize.y / (logoSize.x / width)
            ));
        }

        UI::EndChild();
        UI::SetCursorPos(posTop + vec2(width + 8, 0));
        UI::BeginChild("Description");
        UI::PushFont(ixMenu.g_fontTitle);
        UI::Text("Welcome to " + pluginName);
        UI::PopFont();
        UI::PushFont(ixMenu.g_fontHeader2);
        UI::TextDisabled("The content network for Trackmania - driven by the community.");
        UI::PopFont();

        UI::Separator();

        UI::BeginTabBar("HomePageTabs");
        if(UI::BeginTabItem(Icons::Home + " Welcome!")){
            HomePageTabRender::Home();
            UI::EndTabItem();
        }
        if(UI::BeginTabItem(Icons::InfoCircle + " About")){
            HomePageTabRender::About();
            UI::EndTabItem();
        }
        UI::EndTabBar();
        UI::EndChild();
    }
};
