enum EItemType {
    None = 0,
    Ornament = 1,
    PickUp = 2,
    Character = 3,
    Vehicle = 4,
    Spot = 5,
    Cannon = 6,
    Group = 7,
    Decal = 8,
    Turret = 9,
    Wagon = 10,
    Block = 11,
    EntitySpawner = 12,
    Macroblock = 13,
};

enum ECollection {
    Storm = -1,
    Common = 0,
    Canyon = 1,
    Stadium = 2,
    Valley = 3,
    Lagoon = 4,
    Stadium2020 = 5,
};

enum EGame {
    Unknown = -1,
    Common = 0,
    Maniaplanet = 1,
    Trackmania = 2,
};

enum ESearchOrder {
    ItemNameAscending = 0,
    UploaderIXUsernameAscending = 1,
    UploadDateNewest = 2,
    UploadDateOldest = 3,
    UpdateDateNewest = 4,
    UpdateDateOldest = 5,
    LikeCountDescending = 6,
    LikeCountAscending = 7,
    CommentCountDescending = 8,
    CommentCountAscending = 9,
    DownloadCountDescending = 10,
    DownloadCountAscending = 11,
    ScoreDescending = 12,
    ScoreAscending = 13,
    FileSizeDescending = 18,
    FileSizeAscending = 19,
    None = 888,
};

enum ESpecialSearchMode {
    Normal = 0,
    UserSets = 1,
    LatestSets = 2,
    RecentlyLikedSets = 3,
    BestOfTheWeek = 4,
    BestOfTheMonth = 5,
    AllTimeFavorites = 6,
    UserDownloads = 7,
    UserLikes = 8,
    MXSupporterSets = 10,
    BestScoreOfTheWeek = 12,
    BestScoreOfTheMonth = 13,
    BestScoreOfAllTime = 14,
};