enum EGetStatus {
    Downloading,
    Available,
    Error,
};

class DownloadManager { 
    dictionary cache = {};
    string[] downloads = {};

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

    void RefreshCache(string key, int id){
        string[]@ ik = {tostring(id), key};
        startnew(AsyncRefreshCache, @ik);
    }

    EGetStatus Check(string key, int id) {
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
    downloader.downloads.InsertLast(key + id);

    auto json = API::GetAsync("https://" + MXURL + "/api/" + key + "/get_" + key + "_info/multi/" + id);
    if(json.GetType() != Json::Type::Array || json.Length == 0) {
        downloader.cache.Set(key + id, null);
        return;
    }
    if(key == 'item') {
        downloader.cache.Set(key + id, @IX::Item(json[0]));
    } else {
        downloader.cache.Set(key + id, @IX::ItemSet(json[0]));
    }
    downloader.downloads.RemoveAt(downloader.downloads.Find(key + id));
}