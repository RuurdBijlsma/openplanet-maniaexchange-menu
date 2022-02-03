void log(const string &in msg, bool grey = false){
    print((grey ? "\\$777" : "") + msg);
}
void mxError(const string &in msg, bool showNotification = false){
    if (showNotification) {
        vec4 color = UI::HSV(0.0, 0.5, 1.0);
        UI::ShowNotification(Icons::Kenney::ButtonTimes + " " + pluginName + " - Error", msg, color, 5000);
    }
    print("\\$z[\\$f00Error: " + pluginName + "\\$z] " + msg);
}