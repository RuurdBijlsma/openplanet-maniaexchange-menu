namespace ItemExchange {
    void ImportUnloadedItems() {
        Work::ImportUnloaded();
    }

    void ShowItemInfo(int itemID) {
        if (!ixMenu.isOpened) ixMenu.isOpened = true;
        ixMenu.AddTab(ItemTab(itemID), true);
    }

    void ShowSetInfo(int setID) {
        if (!ixMenu.isOpened) ixMenu.isOpened = true;
        ixMenu.AddTab(ItemSetTab(setID), true);
    }
}