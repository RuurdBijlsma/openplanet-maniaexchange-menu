[Setting name="Main screen offset left" category="Multi-monitor"]
int screenOffsetLeft = 1920;
[Setting name="Main screen offset top" category="Multi-monitor"]
int screenOffsetTop = 0;

[Setting name="Use colored map name" category="UI"]
bool Setting_ColoredMapName = true;

[Setting name="Close Openplanet overlay when loading a map" category="UI"]
bool Setting_CloseOverlayOnLoad = true;

#if TMNEXT
[Setting name="Show Play Button on Royal Maps" category="UI" description="If you try to load Royal maps, the game will return you to the main menu."]
bool Setting_ShowPlayOnRoyalMap = false;
#else
bool Setting_ShowPlayOnRoyalMap = true;
#endif

// Tabs

[Setting name="Most Awarded" category="Display Tabs"]
bool Setting_Tab_MostAwarded_Visible = true;

[Setting name="Featured" category="Display Tabs"]
bool Setting_Tab_Featured_Visible = true;

[Setting name="Tags" category="Display Tabs"]
bool Setting_Tab_Tags_Visible = true;

[Setting name="Latest" category="Display Tabs"]
bool Setting_Tab_Latest_Visible = true;

[Setting name="Recently Awarded" category="Display Tabs"]
bool Setting_Tab_RecentlyAwarded_Visible = false;

#if TMNEXT
[Setting name="TOTDs" category="Display Tabs"]
#endif
bool Setting_Tab_TOTD_Visible = false;

[Setting name="Search" category="Display Tabs"]
bool Setting_Tab_Search_Visible = true;

[Setting name="Map Packs" category="Display Tabs"]
bool Setting_Tab_MapPacks_Visible = true;


#if MP4
enum MP4mxRepos {
    Trackmania,
    Shootmania
}

[Setting name="Repository for maps" category="ManiaPlanet 4" description="This require a reload of the plugin to take effect."]
MP4mxRepos repo = MP4mxRepos::Trackmania;
#endif