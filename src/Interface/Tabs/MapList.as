class MapListTab : Tab
{
    Net::HttpRequest@ m_request;
    array<MX::MapInfo@> maps;
    int totalItems = 0;

    void GetRequestParams(dictionary@ params)
    {
    }

    void StartRequest()
    {
        //Clear();

        dictionary params;
        GetRequestParams(params);

        string urlParams = "";
        if (!params.IsEmpty()) {
            auto keys = params.GetKeys();
            for (uint i = 0; i < keys.Length; i++) {
                string key = keys[i];
                string value;
                params.Get(key, value);

                urlParams += "&" + key + "=" + Net::UrlEncode(value);
            }
        }

        @m_request = API::Get("https://"+MXURL+"/mapsearch2/search?api=on&"+urlParams);
    }

    void CheckStartRequest()
    {
        // If there's not already a request and the window is appearing, we start a new request
        if (m_request is null && UI::IsWindowAppearing()) {
            StartRequest();
        }
    }

    void CheckRequest()
    {
        CheckStartRequest();

        // If there's a request, check if it has finished
        if (m_request !is null && m_request.Finished()) {
            // Parse the response
            string res = m_request.String();
            @m_request = null;
            auto json = Json::Parse(res);

            // Handle the response
            if (json.HasKey("error")) {
                //HandleErrorResponse(json["error"]);
            } else {
                HandleResponse(json);
            }
        }
    }

    void HandleResponse(const Json::Value &in json)
	{
        MX::MapInfo@ map;
        totalItems = json["totalItemCount"];

		auto items = json["results"];
		for (uint i = 0; i < items.Length; i++) {
			maps.InsertLast(MX::MapInfo(items[i]));
		}
	}

    void Render() override
    {
        CheckRequest();

        if (UI::BeginTable("List", 5)) {
            UI::TableSetupScrollFreeze(0, 1);
            UI::TableSetupColumn("Name", UI::TableColumnFlags::WidthStretch);
            UI::TableSetupColumn("Created by", UI::TableColumnFlags::WidthStretch);
            UI::TableSetupColumn("Style", UI::TableColumnFlags::WidthStretch);
            UI::TableSetupColumn(Icons::Trophy, UI::TableColumnFlags::WidthFixed, 40);
            UI::TableSetupColumn("Actions", UI::TableColumnFlags::WidthFixed, 80);
            UI::TableHeadersRow();
            for(uint i = 0; i < maps.get_Length(); i++)
            {
                UI::PushID("ResMap"+i);
                MX::MapInfo@ map = maps[i];
                IfaceRender::MapResult(map);
                UI::PopID();
            }
            UI::EndTable();
        }
    }
}