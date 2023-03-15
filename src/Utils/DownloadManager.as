enum EGetStatus {
    Downloading,
    Available,
    Error,
    ItemsFailed,
};

class DownloadManager { 
    dictionary cache = {};
    string[] downloads = {};
    int[] failedSetIds = {};
    dictionary itemDownloads = {};

    bool IsItemDownloaded(int id) {
        bool downloaded;
        if(itemDownloads.Get(tostring(id), downloaded))
            return downloaded;
        itemDownloads.Set(tostring(id), false);
        return false;
    }

    void SetItemDownloaded(int id, bool isDownloaded) {
        itemDownloads.Set(tostring(id), isDownloaded);
    }

    void CacheItem(IX::Item@ item) {
        cache.Set('item' + item.ID, @item);
    }

    void CacheSet(IX::ItemSet@ itemSet) {
        cache.Set('set' + itemSet.ID, @itemSet);
        // also cache items in set
        for(uint i = 0; i < itemSet.Items.Length; i++){
            cache.Set('item' + itemSet.Items[i].ID, @itemSet.Items[i]);
        }
    }

    void RefreshCache(const string &in key, int id){
        downloads.InsertLast(key + id);
        string[]@ ik = {tostring(id), key};
        startnew(AsyncRefreshCache, @ik);
    }

    EGetStatus Check(const string &in key, int id) {
        if(key == 'set' && failedSetIds.Find(id) != -1) {
            return EGetStatus::ItemsFailed;
        }
        if(downloads.Find(key + id) == -1) {
            // Not downloading yet, or already finished
            if(key == 'item') {
                IX::Item@ item;
                if(cache.Get(key + id, @item)) {
                    // item is cached
                    if(item is null) 
                        return EGetStatus::Error;
                    return EGetStatus::Available;
                }
            } else {
                IX::ItemSet@ itemSet;
                if(cache.Get(key + id, @itemSet)) {
                    // itemSet is cached
                    if(itemSet is null) 
                        return EGetStatus::Error;
                    return EGetStatus::Available;
                }
            }
            // start download
            RefreshCache(key, id);
        } 
        return EGetStatus::Downloading;
    }

    // must check Has method before calling this
    IX::Item@ GetItem(int id){
        IX::Item@ item;
        if(cache.Get('item' + id, @item))
            return item;
        return null;
    }

    // must check Has method before calling this
    IX::ItemSet@ GetSet(int id){
        IX::ItemSet@ set;
        if(cache.Get('set' + id, @set))
            return set;
        return null;
    }
};

DownloadManager downloader;

void AsyncRefreshCache(ref@ idAndKey){
    auto ik = cast<string[]@>(idAndKey);
    auto id = ik[0];
    auto key = ik[1];

    auto json = API::GetAsync("https://" + MXURL + "/api/" + key + "/get_" + key + "_info/multi/" + id);
    if(json.GetType() != Json::Type::Array || json.Length == 0) {
        int idInt = Text::ParseInt(id);
        if(key == 'item' && downloader.GetItem(idInt) is null 
            || key == 'set' && downloader.GetSet(idInt) is null) {
            downloader.cache.Set(key + id, null);
        }
        UI::ShowNotification("Could not load full " + key + ": " + id);

        downloader.failedSetIds.InsertLast(idInt);
    } else {
        if(key == 'item') {
            downloader.CacheItem(IX::Item(json[0]));
        } else {
            downloader.CacheSet(IX::ItemSet(json[0]));
        }
    }
    downloader.downloads.RemoveAt(downloader.downloads.Find(key + id));
}