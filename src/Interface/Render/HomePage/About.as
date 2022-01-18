namespace HomePageTabRender {
    void About()
    {                
        if (UI::Button(Icons::KeyboardO + " \\$zContact ManiaExchange")) OpenBrowserURL("https://"+MXURL+"/messaging/compose/11");
        UI::SameLine();
        if (UI::RedButton(Icons::Heart + " \\$zSupport ManiaExchange")) OpenBrowserURL("https://trackmania.exchange/support");

        UI::Text("Follow the ManiaExchange network on");
        UI::SameLine();
        if (UI::Button(Icons::Facebook + " Facebook")) OpenBrowserURL("https://facebook.com/maniaexchange/");
        UI::SameLine();
        if (UI::Button(Icons::Twitter + " Twitter")) OpenBrowserURL("https://twitter.com/maniaexchange/");
        UI::SameLine();
        if (UI::Button(Icons::YoutubePlay + " YouTube")) OpenBrowserURL("https://youtube.com/maniaexchangetracks/");
        UI::SameLine();
        if (UI::Button(Icons::DiscordAlt + " Discord")) OpenBrowserURL("https://discord.mania.exchange/");

        UI::Separator();

        auto executingPlugin = Meta::ExecutingPlugin();
        UI::Text(pluginColor + Icons::Plug);
        UI::SameLine();
        UI::Text("Plugin");
        UI::Text("Made by \\$777" + executingPlugin.Author + " (forked from Greep's ManiaExchange plugin)");
        UI::Text("Version \\$777" + executingPlugin.Version);
        UI::Text("Plugin ID \\$777" + executingPlugin.ID);
        UI::Text("Site ID \\$777" + executingPlugin.SiteID);
        UI::Text("Type \\$777" + changeEnumStyle(tostring(executingPlugin.Type)));
        if (IsDevMode()) {
            UI::SameLine();
            UI::Text("\\$777(\\$f39"+Icons::Code+" \\$777Dev mode)");
        }
        if (UI::Button(Icons::Kenney::GithubAlt + " Github")) OpenBrowserURL(repoURL);
        UI::SameLine();
        if (UI::Button(Icons::Heartbeat + " Plugin Home")) OpenBrowserURL("https://openplanet.nl/files/" + executingPlugin.SiteID);
        
        UI::Separator();
        UI::Text("\\$f39" + Icons::Heartbeat);
        UI::SameLine();
        UI::Text("Openplanet");
        UI::Text("Version \\$777" + Meta::OpenplanetBuildInfo());
    }
}