namespace IX {
    void GetAllItemTags() {
        Json::Value resNet;
        if(IsDevMode()){
            log("Using cached tags during development!");
            resNet = tagsCache;
        }else{
            resNet = API::GetAsync("https://"+MXURL+"/api/tags/gettags");
        }
        
        try {
            IX::ItemTag@[] tags = {};
            string[] tagNames = {};
            for (uint i = 0; i < resNet.Length; i++) {
                int tagID = resNet[i]["ID"];
                string tagName = resNet[i]["Name"];

                auto newTag = ItemTag(resNet[i]);
                tags.InsertLast(newTag);
                tagNames.InsertLast(newTag.Name);
            }
            if(tagNames.Length >= 2)
                tagNames.SortAsc();
            for(uint i = 0; i < tagNames.Length; i++) {
                for(uint j = 0; j < tags.Length; j++) {
                    if(tagNames[i] == tags[j].Name) {
                        m_itemTags.InsertLast(tags[j]);
                        break;
                    }
                }
            }
        } catch {
            mxError("Error while loading tags");
            mxError(pluginName + " API is not responding, it must be down.", true);
            APIDown = true;
        }
    }
}