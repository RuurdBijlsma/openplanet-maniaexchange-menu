namespace Fonts {
    UI::Font@ fontTitle = null;
    UI::Font@ fontBold = null;
    UI::Font@ fontHeader = null;
    UI::Font@ fontHeader2 = null;
    nvg::Font fontRegularHeader;
    bool loaded = false;

    void Load() {
        fontRegularHeader = nvg::LoadFont("Oswald-Regular.ttf");
        @fontTitle = UI::LoadFont("Oswald-Regular.ttf", 32);
        @fontBold = UI::LoadFont("DroidSans-Bold.ttf", 16);
        @fontHeader = UI::LoadFont("DroidSans-Bold.ttf", 24);
        @fontHeader2 = UI::LoadFont("DroidSans-Bold.ttf", 18);
        loaded = true;
    }
}