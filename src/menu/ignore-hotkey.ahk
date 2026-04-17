; InputTip

fn_ignore_hotkey(*) {
    fn_common({
        title: "指定窗口忽略状态切换快捷键",
        tab: "指定窗口忽略状态切换快捷键",
        config: "App-IgnoreHotKey",
        link: '相关链接: <a href="https://inputtip.abgox.com/faq/ignore-hotkey">指定窗口忽略状态切换快捷键</a>'
    }, fn)
    fn() {
        global app_IgnoreHotKey := StrSplit(readIniSection("App-IgnoreHotKey"), "`n")
    }
}
