namespace IX {
    array<Item@> SearchItems(
        int limit = 40, int page = 1,
        int[] tags = {},
        string[] itemName = {},
        string[] author = {},
        bool[] anyAuthor = {},
        ESearchOrder firstSort = ESearchOrder::UploadDateNewest,
        ESearchOrder secondSort = ESearchOrder::None,
        ESpecialSearchMode mode = ESpecialSearchMode::Normal,
        int64 setId = 0,
        EItemType itemType = EItemType::None,
        string[] filename = {},
        int64 userId = -1,
        string[] originalBlock = {},
        int[] navigation = {},
        int[] excludeTags = {},
        bool mustIncludeAllTags = false,
        bool released = true
    ) {
        string[] stringTags = {};
        for(uint i = 0; i < tags.Length; i++) 
            stringTags.InsertLast(tostring(tags[i]));

        string secondSortParam = "";
        if(secondSort != ESearchOrder::None)
            secondSortParam = "&secord=" + secondSort;

        string itemNameParam = "";
        if(itemName.Length > 0)
            itemNameParam = "&itemname=" + string::Join(itemName, ",");
        string filenameParam = "";
        if(filename.Length > 0)
            filenameParam = "&filename=" + string::Join(filename, ",");
        string authorParam = "";
        if(author.Length > 0)
            authorParam = "&authorlogin=" + string::Join(author, ",");
        string anyAuthorParam = "";
        if(anyAuthor.Length > 0)
            anyAuthorParam = "&anyauthor=" + string::Join(BoolsToStrings(anyAuthor), ",");
        string itemTypeParam = "";
        if(itemType != EItemType::None)
            itemTypeParam = "&itype=" + itemType;
        string tagsParam = "";
        if(tags.Length > 0)
            tagsParam = "&tags=" + string::Join(stringTags, ",");
        string userIdParam = "";
        if(userId != -1)
            userIdParam = "&userid=" + userId;
        string setIdParam = "";
        if(setId != 0)
            setIdParam = "&setid=" + setId;
        string originalBlockParam = "";
        if(originalBlock.Length > 0)
            originalBlockParam = "&originalblock=" + string::Join(originalBlock, ",");
        string navigationParam = "";
        if(navigation.Length > 0)
            navigationParam = "&navigation=" + string::Join(IntsToStrings(navigation), "-");
        string excludeTagsParam = "";
        if(excludeTags.Length > 0)
            excludeTagsParam = "&etags=" + string::Join(IntsToStrings(excludeTags), ",");
        
        string urlParams = "limit=" + limit + "&page=" + page + "&priord=" + firstSort + secondSortParam + "&unreleased=" + (released ? 0 : 1) +
            "&tagsinc=" + (mustIncludeAllTags ? 0 : 1) + originalBlockParam + navigationParam + excludeTagsParam + setIdParam + userIdParam +
            "&mode=" + mode + itemNameParam + filenameParam + authorParam + anyAuthorParam + itemTypeParam + tagsParam + "&format=json";
        string url = "https://"+MXURL+"/itemsearch/search?api=on&" + urlParams;
        auto jsonResult = API::GetAsync(url);
        if(jsonResult.GetType() != Json::Type::Null && jsonResult['results'].GetType() == Json::Type::Array) {
            array<Item@> result = {};
            for(uint i = 0; i < jsonResult.Length; i++)
                result.InsertLast(Item(jsonResult['results'][i]));
            return result;
        } else {
            warn("Search Item error");
            return {};
        }
    }

    array<ItemSet@> SearchSets(
        int limit = 40, int page = 1,
        int[] tags = {},
        string[] setName = {},
        string[] author = {},
        ESearchOrder firstSort = ESearchOrder::UploadDateNewest,
        ESearchOrder secondSort = ESearchOrder::None,
        ESpecialSearchMode mode = ESpecialSearchMode::Normal,
        string[] filename = {},
        int64 userId = -1
    ) {
        string[] stringTags = {};
        for(uint i = 0; i < tags.Length; i++) 
            stringTags.InsertLast(tostring(tags[i]));

        string secondSortParam = "";
        if(secondSort != ESearchOrder::None)
            secondSortParam = "&secord=" + secondSort;

        string setNameParam = "";
        if(setName.Length > 0)
            setNameParam = "&setname=" + string::Join(setName, ",");
        string filenameParam = "";
        if(filename.Length > 0)
            filenameParam = "&filename=" + string::Join(filename, ",");
        string authorParam = "";
        if(author.Length > 0)
            authorParam = "&author=" + string::Join(author, ",");
        string tagsParam = "";
        if(tags.Length > 0)
            tagsParam = "&tags=" + string::Join(stringTags, ",");
        string userIdParam = "";
        if(userId != -1)
            userIdParam = "&userid=" + userId;
        
        string urlParams = "limit=" + limit + "&page=" + page + "&priord=" + firstSort + secondSortParam + 
            "&mode=" + mode + setNameParam + filenameParam + authorParam + tagsParam + "&format=json";
        string url = "https://"+MXURL+"/setsearch/search?api=on&" + urlParams;
        auto jsonResult = API::GetAsync(url);
        if(jsonResult.GetType() != Json::Type::Null && jsonResult['results'].GetType() == Json::Type::Array) {
            array<ItemSet@> result = {};
            for(uint i = 0; i < jsonResult.Length; i++)
                result.InsertLast(ItemSet(jsonResult['results'][i]));
            return result;
        } else {
            warn("Search ItemSets error");
            return {};
        }
    }

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
            for (uint i = 0; i < resNet.Length; i++)
            {
                int tagID = resNet[i]["ID"];
                string tagName = resNet[i]["Name"];

                if (IsDevMode()) log("Loading tag #"+tagID+" - "+tagName, true);

                auto newTag = ItemTag(resNet[i]);
                tags.InsertLast(newTag);
                tagNames.InsertLast(newTag.Name);
            }
            tagNames.SortAsc();
            for(uint i = 0; i < tagNames.Length; i++) {
                for(uint j = 0; j < tags.Length; j++) {
                    if(tagNames[i] == tags[j].Name) {
                        m_itemTags.InsertLast(tags[j]);
                        break;
                    }
                }
            }

            log(m_itemTags.Length + " tags loaded");
        } catch {
            mxError("Error while loading tags");
            mxError(pluginName + " API is not responding, it must be down.", true);
            APIDown = true;
        }
    }
}