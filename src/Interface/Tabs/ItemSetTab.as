class ItemSetTab : Tab
{
    Net::HttpRequest@ m_IXrequest;
    IX::ItemSet@ m_itemSet;
    int m_setID;
    bool m_isLoading = false;
    bool m_itemSetDownloaded = false;
    bool m_error = false;

    ItemSetTab(int setID) {
        m_setID = setID;
        StartIXRequest(setID);
    }

    bool CanClose() override { return !m_isLoading; }

    string GetLabel() override {
        if (m_error) {
            m_isLoading = false;
            return "\\$f00" + Icons::Times + " \\$zError";
        }
        if (m_itemSet is null) {
            m_isLoading = true;
            return Icons::Database + " Loading...";
        } else {
            m_isLoading = false;
            return Icons::Database + " " + m_itemSet.Name;
        }
    }

    void StartIXRequest(int ID) {
        string url = "https://"+MXURL+"/api/set/get_set_info/multi/" + ID;
        if (IsDevMode()) print("ItemSetTab::StartRequest (IX): " + url);
        @m_IXrequest = API::Get(url);
    }

    void CheckIXRequest() {
        // If there's a request, check if it has finished
        if (m_IXrequest !is null && m_IXrequest.Finished()) {
            // Parse the response
            string res = m_IXrequest.String();
            if (IsDevMode()) print("ItemSetTab::CheckRequest (IX): " + res);
            @m_IXrequest = null;
            auto json = Json::Parse(res);

            if (json.Length == 0) {
                print("ItemSetTab::CheckRequest (IX): Error parsing response");
                HandleIXResponseError();
                return;
            }
            // Handle the response
            HandleIXResponse(json[0]);
        }
    }

    void HandleIXResponse(const Json::Value &in json) {
        @m_itemSet = IX::ItemSet(json);
    }

    void HandleIXResponseError() {
        m_error = true;
    }

    string FormatTime(int time) {
        int hundreths = time % 1000;
        time /= 1000;
        int hours = time / 3600;
        int minutes = (time / 60) % 60;
        int seconds = time % 60;

        return (hours != 0 ? Text::Format("%02d", hours) + ":" : "" ) + (minutes != 0 ? Text::Format("%02d", minutes) + ":" : "") + Text::Format("%02d", seconds) + "." + Text::Format("%03d", hundreths);
    }

    void Render() override {
        CheckIXRequest();

        if (m_error) {
            UI::Text("\\$f00" + Icons::Times + " \\$zItem set not found");
            return;
        }

        if (m_itemSet is null) {
            UI::Text(IfaceRender::GetHourGlass() + " Loading...");
            return;
        }

        float width = UI::GetWindowSize().x*0.35;
        vec2 posTop = UI::GetCursorPos();

        UI::BeginChild("Summary", vec2(width,0));

        UI::BeginTabBar("MapImages");

        if (m_itemSet.ImageCount != 0) {
            for (int i = 1; i < m_itemSet.ImageCount + 1; i++) {
                if(UI::BeginTabItem(tostring(i))){
                    auto img = Images::CachedFromURL("https://"+MXURL+"/set/image/"+m_itemSet.ID+'/'+i);

                    if (img.m_texture !is null){
                        vec2 thumbSize = img.m_texture.GetSize();
                        UI::Image(img.m_texture, vec2(
                            width,
                            thumbSize.y / (thumbSize.x / width)
                        ));
                        if (UI::IsItemHovered()) {
                            UI::BeginTooltip();
                            UI::Image(img.m_texture, vec2(
                                Draw::GetWidth() * 0.6,
                                thumbSize.y / (thumbSize.x / (Draw::GetWidth() * 0.6))
                            ));
                            UI::EndTooltip();
                        }
                    } else {
                        UI::Text(IfaceRender::GetHourGlass() + " Loading");
                    }
                    UI::EndTabItem();
                }
            }
        }

        if(UI::BeginTabItem("Thumbnail")){
            auto thumb = Images::CachedFromURL("https://"+MXURL+"/set/image/"+m_itemSet.ID);
            if (thumb.m_texture !is null){
                vec2 thumbSize = thumb.m_texture.GetSize();
                UI::Image(thumb.m_texture, vec2(
                    width,
                    thumbSize.y / (thumbSize.x / width)
                ));
                if (UI::IsItemHovered()) {
                    UI::BeginTooltip();
                    UI::Image(thumb.m_texture, vec2(
                        Draw::GetWidth() * 0.4,
                        thumbSize.y / (thumbSize.x / (Draw::GetWidth() * 0.4))
                    ));
                    UI::EndTooltip();
                }
            } else {
                UI::Text(IfaceRender::GetHourGlass() + " Loading");
            }
            UI::EndTabItem();
        }

        UI::EndTabBar();
        UI::Separator();

        for (uint i = 0; i < m_itemSet.Tags.Length; i++) {
            IfaceRender::ItemTag(m_itemSet.Tags[i]);
            UI::SameLine();
        }
        UI::NewLine();

        UI::Text(Icons::Trophy + " \\$f77" + m_itemSet.LikeCount);

        UI::Text(Icons::Hashtag+ " \\$f77" + m_itemSet.ID);
        UI::SameLine();
        UI::TextDisabled(Icons::Clipboard);
        if (UI::IsItemHovered()) {
            UI::BeginTooltip();
            UI::Text("Click to copy to clipboard");
            UI::EndTooltip();
        }
        if (UI::IsItemClicked()) {
            IO::SetClipboard(tostring(m_itemSet.ID));
            UI::ShowNotification(Icons::Clipboard + " Track ID copied to clipboard");
        }

        UI::Text(Icons::Calendar + " \\$f77" + m_itemSet.Uploaded);
        if (m_itemSet.Uploaded != m_itemSet.Updated) UI::Text(Icons::Refresh + " \\$f77" + m_itemSet.Updated);

        UI::EndChild();

        UI::SetCursorPos(posTop + vec2(width + 8, 0));
        UI::BeginChild("Description");

        UI::PushFont(ixMenu.g_fontHeader);
        UI::Text(m_itemSet.Name);
        UI::PopFont();

        UI::Separator();

        UI::BeginTabBar("ItemSetTabs");

        if(UI::BeginTabItem("Description")){
            UI::BeginChild("MapDescriptionChild");
            IfaceRender::IXComment(m_itemSet.Description);
            UI::EndChild();
            UI::EndTabItem();
        }

        UI::EndTabBar();

        UI::EndChild();
    }
}