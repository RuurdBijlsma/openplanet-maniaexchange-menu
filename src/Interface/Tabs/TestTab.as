class TestTab : ItemListTab
{
    bool IsVisible() override {return Setting_Tab_Featured_Visible;}
    string GetLabel() override {return Icons::Star + " Featured";}

    vec4 GetColor() override { return vec4(0.8f, 0.09f, 0.48f, 1); }

    dictionary@ GetRequestParams()
    {
        auto params = ItemListTab::GetRequestParams();
        return params;
    }
};