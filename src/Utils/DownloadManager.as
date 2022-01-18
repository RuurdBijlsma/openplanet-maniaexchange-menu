// enum EGetStatus {
//     Downloading,
//     Success,
//     Error,
// };

// class DownloadManager { 
//     dictionary cache = {};
//     dictionary downloads = {};

//     void CacheItem(IX::Item@ item) {
//         cache['item' + item.ID] = item;
//     }

//     void CacheSet(IX::ItemSet@ itemSet) {
//         cache['set' + itemSet.ID] = itemSet;
//         // also cache items in set
//         for(item in set){
//             cache['item' + item.ID] = item;
//         }
//     }

//     void RefreshCache(string key, int id){
//         // startnew(Download item)
//     }

//     EGetStatus Has(string key, int id) {
//         IX::Item@ item;
//         // check if item is cached already
//         if(cache.Get(key + id, @item) {
//             return EGetStatus::Success;
//         } else {
//             // check if download exists
//             Net::Request@ req;
//             if(downloads.Get(key + id, @req)) {
//                 if(req.status == error) {
//                     return EGetStatus::Error;
//                 } else if (req.finished()){
//                     return EGetStatus::Success;
//                 } else {
//                     return EGetStatus::Downloading;
//                 }
//             } else {
//                 startnew(Download item/set)
//                 return EGetStatus::Downloading;
//             }
//         }
//     }

//     // must check Has method before calling this
//     Item@ GetItem(int id){
//         return cache['item' + id];
//     }

//     // must check Has method before calling this
//     ItemSet@ GetSet(int id){
//         return cache['set' + id];
//     }
// };
