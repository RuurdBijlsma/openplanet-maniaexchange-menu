class ItemListTab : Tab {
    Net::HttpRequest@ m_request;
    array<IX::Item@> items;
    uint totalItems = 0;
    bool m_useRandom = false;
    int m_page = 1;

    dictionary@ GetRequestParams() {
        dictionary@ params = {};
        params.Set("api", "on");
        params.Set("limit", "100");
        params.Set("page", tostring(m_page));
        if (m_useRandom) {
            params.Set("random", "1");
            m_useRandom = false;
        }
        return params;
    }

    void StartRequest() {
        print("Start request");
        auto params = GetRequestParams();

        string urlParams = "";
        if (!params.IsEmpty()) {
            auto keys = params.GetKeys();
            for (uint i = 0; i < keys.Length; i++) {
                string key = keys[i];
                string value;
                params.Get(key, value);

                urlParams += (i == 0 ? "?" : "&");
                urlParams += key + "=" + Net::UrlEncode(value);
            }
        }

        string url = "https://" + MXURL + "/itemsearch/search" + urlParams;

        if (IsDevMode()) trace("ItemList::StartRequest: " + url);
        @m_request = API::Get(url);
    }

    void CheckStartRequest() {
        // If there's not already a request and the window is appearing, we start a new request
        if (items.Length == 0 && m_request is null && UI::IsWindowAppearing()) {
            StartRequest();
        }
    }

    void CheckRequest() {
        CheckStartRequest();

        // If there's a request, check if it has finished
        if (m_request !is null && m_request.Finished()) {
            // Parse the response
            string res = m_request.String();
            if (IsDevMode()) trace("ItemList::CheckRequest: " + res);
            @m_request = null;
            auto json = Json::Parse(res);

            // Handle the response
            if (json.HasKey("error")) {
                // HandleErrorResponse(json["error"]);
            } else {
                HandleResponse(json);
            }
        }
    }

    void HandleResponse(const Json::Value &in json) {
        totalItems = json["totalItemCount"];

        auto jsonItems = json["results"];
        for (uint i = 0; i < jsonItems.Length; i++) {
            IX::Item@ item = IX::Item(jsonItems[i]);
            downloader.CacheItem(item);
            items.InsertLast(item);
        }
    }

    void RenderHeader(){}

    void Clear() {
        items.RemoveRange(0, items.Length);
        totalItems = 0;
    }

    void Reload() {
        Clear();
        StartRequest();
    }

    void Render() override {
        CheckRequest();
        RenderHeader();

        if (m_request !is null && items.Length == 0) {
            int HourGlassValue = Time::Stamp % 3;
            string Hourglass = (HourGlassValue == 0 ? Icons::HourglassStart : (HourGlassValue == 1 ? Icons::HourglassHalf : Icons::HourglassEnd));
            UI::Text(Hourglass + " Loading...");
        } else {
            if (items.Length == 0) {
                UI::Text("No items found.");
                return;
            }
            UI::BeginChild("itemList");
            if (UI::BeginTable("List", 7)) {
                UI::TableSetupScrollFreeze(0, 1);
                PushTabStyle();
                UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 50);
                UI::TableSetupColumn("Name", UI::TableColumnFlags::WidthStretch, 3);
                UI::TableSetupColumn("By", UI::TableColumnFlags::WidthStretch, 1);
                UI::TableSetupColumn(Icons::Trophy, UI::TableColumnFlags::WidthFixed, 40);
                UI::TableSetupColumn(Icons::Bolt, UI::TableColumnFlags::WidthFixed, 40);
                UI::TableSetupColumn(Icons::Kenney::Save, UI::TableColumnFlags::WidthFixed, 70);
                UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 90);
                UI::TableHeadersRow();
                PopTabStyle();
                for(uint i = 0; i < items.Length; i++) {
                    UI::PushID("ResItem"+i);
                    IX::Item@ item = items[i];
                    IfaceRender::ItemRow(item);
                    UI::PopID();
                }
                if (m_request !is null && totalItems > items.Length) {
                    UI::TableNextRow();
                    UI::TableSetColumnIndex(1);
                    UI::Text(Icons::HourglassEnd + " Loading...");
                }
                UI::EndTable();
                if (m_request is null && totalItems > items.Length && UI::GreenButton("Load more")) {
                    m_page++;
                    StartRequest();
                }
            }
            UI::EndChild();
        }
    }
};
