class ItemListTab : Tab {
    Net::HttpRequest@ m_request;
    array<IX::Item@> items;
    uint totalItems = 0;
    bool m_useRandom = false;
    int m_page = 1;

    IX::ItemTag@ emptyTag = IX::ItemTag(-1, "", "#000000");
    IX::ItemTag@ tag = emptyTag;
    string itemName = "";
    string author = "";
    int searchTimer = -1;
    ESearchOrder searchOrder1 = ESearchOrder::UploadDateNewest;
    ESearchOrder searchOrder2 = ESearchOrder::None;

    dictionary@ GetRequestParams() {
        dictionary@ params = {};
        params.Set("api", "on");
        params.Set("limit", "100");
        params.Set("page", tostring(m_page));
        params.Set("secord", tostring(int(searchOrder2)));
        params.Set("priord", tostring(int(searchOrder1)));
        // as long as only ornaments are supported, filter out blocks/other item types
        params.Set("itype", tostring(int(EItemType::Ornament)));
        params.Set("collections", tostring(int(ECollection::Stadium2020)));
        params.Set("game", tostring(int(EGame::Trackmania)));
        if(itemName != "") {
            params.Set("itemname", itemName);
        }
        if(author != "") {
            params.Set("anyauthor", author);
        }
        if(tag.ID != -1) {
            params.Set("tags", tostring(tag.ID));
        }
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

    void CheckRequest() {
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

    string[] sortableColumns = {"", "itemName",  "username",  "uploadDate",  "likeCount",  "score",  "fileSize", ""};
    void Render() override {
        if(searchTimer >= 0 && searchTimer-- == 0) {
            items = {};
            StartRequest();
        }

        CheckRequest();
        RenderHeader();

        UI::BeginChild("itemList", vec2(), false, UI::WindowFlags::AlwaysVerticalScrollbar);
        if (UI::BeginTable("List", 8, UI::TableFlags::Sortable | UI::TableFlags::SortMulti)) {
            UI::AlignTextToFramePadding();
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed | UI::TableColumnFlags::NoSort, 50);
            UI::TableSetupColumn("Name", UI::TableColumnFlags::WidthStretch | UI::TableColumnFlags::NoSortDescending, 3);
            UI::TableSetupColumn("By", UI::TableColumnFlags::WidthStretch | UI::TableColumnFlags::NoSortDescending, 1);
            UI::TableSetupColumn(Icons::CalendarO, UI::TableColumnFlags::WidthFixed | UI::TableColumnFlags::PreferSortDescending | UI::TableColumnFlags::DefaultSort, 60);
            UI::TableSetupColumn(Icons::Heart, UI::TableColumnFlags::WidthFixed | UI::TableColumnFlags::PreferSortDescending, 25);
            UI::TableSetupColumn(Icons::Bolt, UI::TableColumnFlags::WidthFixed | UI::TableColumnFlags::PreferSortDescending, 30);
            UI::TableSetupColumn(Icons::Kenney::Save, UI::TableColumnFlags::WidthFixed, 60);
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed | UI::TableColumnFlags::NoSort, 70);
            UI::TableSetupScrollFreeze(0, 1); // <-- don't work
            UI::TableHeadersRow();

            if (m_request !is null && items.Length == 0) {
                UI::TableNextRow();
                UI::TableSetColumnIndex(1);
                int HourGlassValue = Time::Stamp % 3;
                string Hourglass = (HourGlassValue == 0 ? Icons::HourglassStart : (HourGlassValue == 1 ? Icons::HourglassHalf : Icons::HourglassEnd));
                UI::Text(Hourglass + " Loading...");
            }

            if (m_request is null && items.Length == 0) {
                UI::TableNextRow();
                UI::TableSetColumnIndex(1);
                UI::Text("No items found.");
            }

            for(uint i = 0; i < items.Length; i++) {
                UI::PushID("ResItem" + i);
                IX::Item@ item = items[i];
                IfaceRender::ItemRow(item);
                UI::PopID();
            }

            if (m_request !is null && totalItems > items.Length && items.Length > 0) {
                UI::TableNextRow();
                UI::TableSetColumnIndex(1);
                UI::Text(Icons::HourglassEnd + " Loading...");
            }
            auto sortSpecs =  UI::TableGetSortSpecs();
            if(sortSpecs.Dirty) {
                searchOrder1 = ESearchOrder::None;
                searchOrder2 = ESearchOrder::None;
                for(uint i = 0; i < sortSpecs.Specs.Length; i++) {
                    auto columnSpec = sortSpecs.Specs[i];
                    if(columnSpec.SortOrder >= 2)
                        continue; // only support 2 layers of sort
                    if(columnSpec.SortOrder == 0) {
                        searchOrder1 = GetSearchOrder(columnSpec.ColumnIndex, columnSpec.SortDirection, columnSpec.SortOrder);
                    }
                    if(columnSpec.SortOrder == 1) {
                        searchOrder2 = GetSearchOrder(columnSpec.ColumnIndex, columnSpec.SortDirection, columnSpec.SortOrder);
                    }
                }
                print("Search order 1: " + tostring(searchOrder1) + ", Search order 2: " + tostring(searchOrder2));
                searchTimer = 0;
                sortSpecs.Dirty = false;
            }
            UI::EndTable();
            if (m_request is null && totalItems > items.Length && UI::GreenButton("Load more")) {
                m_page++;
                StartRequest();
            }
        }
        UI::EndChild();
    }

    ESearchOrder GetSearchOrder(int columnIndex, UI::SortDirection direction, int priority) {
        string colName = sortableColumns[columnIndex];
        if(direction == UI::SortDirection::Ascending) {
            if(colName == "itemName") {
                return ESearchOrder::ItemNameAscending;
            }
            if(colName == "username") {
                return ESearchOrder::UploaderIXUsernameAscending;
            }
            if(colName == "likeCount") {
                return ESearchOrder::LikeCountAscending;
            }
            if(colName == "score") {
                return ESearchOrder::ScoreAscending;
            }
            if(colName == "fileSize") {
                return ESearchOrder::FileSizeAscending;
            }
            if(colName == "uploadDate") {
                return ESearchOrder::UploadDateOldest;
            }
            return priority == 0 ? ESearchOrder::UploadDateOldest : ESearchOrder::None;
        } 
        if(direction == UI::SortDirection::Descending) {
            if(colName == "likeCount") {
                return ESearchOrder::LikeCountDescending;
            }
            if(colName == "score") {
                return ESearchOrder::ScoreDescending;
            }
            if(colName == "fileSize") {
                return ESearchOrder::FileSizeDescending;
            }
            if(colName == "uploadDate") {
                return ESearchOrder::UploadDateNewest;
            }
            return priority == 0 ? ESearchOrder::UploadDateNewest : ESearchOrder::None;
        }
        return ESearchOrder::None;
    }
};
