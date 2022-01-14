class ItemTab : Tab {
    ItemTab(int itemId){
        
    }

    string GetLabel() override { return "Item"; }

    vec4 GetColor() override { return pluginColorVec; }

    void Render() override {
        UI::Text("Item:");
    }
}