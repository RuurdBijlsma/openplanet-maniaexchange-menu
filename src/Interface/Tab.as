class Tab
{
    bool IsVisible() { return true; }
    bool CanClose() { return false; }

    string GetLabel() { return ""; }

    vec4 GetColor() { return vec4(0.2f, 0.4f, 0.8f, 1); }

    void PushTabStyle()
    {
        vec4 color = GetColor();
        UI::PushStyleVar(UI::StyleVar::ChildRounding, 5.0);
        UI::PushStyleVar(UI::StyleVar::FramePadding, vec2(10, 6));
        UI::PushStyleVar(UI::StyleVar::CellPadding, vec2(12, 6));
        UI::PushStyleColor(UI::Col::ChildBg, vec4(1, 1, 1, .007));

        UI::PushStyleColor(UI::Col::Tab, color * vec4(0.5f, 0.5f, 0.5f, 0.75f));
        UI::PushStyleColor(UI::Col::TabHovered, color * vec4(1.2f, 1.2f, 1.2f, 0.85f));
        UI::PushStyleColor(UI::Col::TabActive, color);

        UI::PushStyleColor(UI::Col::Header, color * vec4(0.5f, 0.5f, 0.5f, 0.75f));
        UI::PushStyleColor(UI::Col::HeaderHovered, color * vec4(1.2f, 1.2f, 1.2f, 0.85f));
        UI::PushStyleColor(UI::Col::HeaderActive, color);

        UI::PushStyleColor(UI::Col::Separator, color * vec4(1.7f, 1.7f, 1.7f, 0.5));
        UI::PushStyleColor(UI::Col::FrameBgHovered, color * vec4(1.7f, 1.7f, 1.7f, 0.2f));
        UI::PushStyleColor(UI::Col::Button, color * vec4(1.7f, 1.7f, 1.7f, 0.5f));
        UI::PushStyleColor(UI::Col::ButtonHovered, color * vec4(1.7f, 1.7f, 1.7f, 0.5f));
        UI::PushStyleColor(UI::Col::ButtonActive, color * vec4(1.7f, 1.7f, 1.7f, 0.7f));
        UI::PushStyleColor(UI::Col::TextSelectedBg, color * vec4(1.7f, 1.7f, 1.7f, 0.3f));
    }

    void PopTabStyle()
    {
        UI::PopStyleColor(13);
        UI::PopStyleVar(3);
    }

    void Render() {}
};
