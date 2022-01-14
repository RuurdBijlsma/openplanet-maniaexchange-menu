namespace HomePageTabRender {
    Resources::Font@ g_fontHeader3 = Resources::GetFont("Oswald-Regular.ttf", 20);

    void Home()
    {
        UI::PushFont(g_fontHeader3);
        UI::Text("Welcome to " + pluginName + ", select a tab to begin.");
        UI::PopFont();
    }
}