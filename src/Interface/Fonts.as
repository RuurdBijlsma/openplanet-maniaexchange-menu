namespace Fonts {
    Resources::Font@ fontTitle = null;
    Resources::Font@ fontRegularHeader = null;
    Resources::Font@ fontBold = null;
    Resources::Font@ fontHeader = null;
    Resources::Font@ fontHeader2 = null;
    bool loaded = false;

    void Load() {
        UI::Font@ fontTitle = UI::LoadFont("Oswald-Regular.ttf", 32);
        nvg::Font fontRegularHeader = nvg::LoadFont("Oswald-Regular.ttf");
        UI::Font@ fontBold = UI::LoadFont("DroidSans-Bold.ttf", 16);
        UI::Font@ fontHeader = UI::LoadFont("DroidSans-Bold.ttf", 24);
        UI::Font@ fontHeader2 = UI::LoadFont("DroidSans-Bold.ttf", 18);
        loaded = true;
    }
}