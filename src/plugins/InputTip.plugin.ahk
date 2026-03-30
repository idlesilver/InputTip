; InputTip

/*

- 你可以在这里自定义想要的功能，例如:
    - 自定义快捷键
    - 自定义热字串
    - ...

- 你也可以在 plugins 目录中新建一个或多个 .ahk 文件，然后在此文件中引入，例如:
    - 在 plugins 目录中新建一个文件名为 custom.ahk 的文件
    - 将自定义功能写入 custom.ahk 文件中
    - 在 InputTip.plugin.ahk 文件中引入 custom.ahk 文件: #Include custom.ahk

- 需要注意: 不能存在死循环

- 详情参考:
    - 官方文档: https://inputtip.abgox.com/faq/plugin
    - Github: https://github.com/abgox/InputTip#自定义功能
    - Gitee: https://gitee.com/abgox/InputTip#自定义功能

*/

; Window disable:
; - 当前焦点命中指定窗口时，创建 window_disable.flag
; - 离开指定窗口时，删除 window_disable.flag
; - 依赖主程序中的 window-disable hook

global IT_DISABLE_EXE_LIST := ["mstsc.exe", "ToDesk.exe"]
global IT_DISABLE_TITLE_REGEX := ""
global IT_DISABLE_CHECK_MS := 300
global IT_DISABLE_FLAG := A_ScriptDir "\plugins\window_disable.flag"

global __it_last_disabled := false

SetTimer(__InputTip_WindowDisableWatcher, IT_DISABLE_CHECK_MS)
OnExit(__InputTip_CleanupDisableFlag)

__InputTip_WindowDisableWatcher() {
    global IT_DISABLE_EXE_LIST
    global IT_DISABLE_TITLE_REGEX
    global IT_DISABLE_FLAG
    global __it_last_disabled

    hwnd := WinExist("A")
    if !hwnd {
        return
    }

    exe := ""
    title := ""

    try exe := WinGetProcessName(hwnd)
    catch
        return

    try title := WinGetTitle(hwnd)
    catch
        title := ""

    matched := false
    if (__InputTip_IsTargetDisableExe(exe)) {
        if (IT_DISABLE_TITLE_REGEX = "") {
            matched := true
        } else {
            matched := !!RegExMatch(title, IT_DISABLE_TITLE_REGEX)
        }
    }

    if (matched = __it_last_disabled) {
        return
    }

    try FileDelete(IT_DISABLE_FLAG)
    if (matched) {
        FileAppend("1", IT_DISABLE_FLAG, "UTF-8")
    }

    __it_last_disabled := matched
}

__InputTip_IsTargetDisableExe(exe) {
    global IT_DISABLE_EXE_LIST

    exe := StrLower(exe)
    for targetExe in IT_DISABLE_EXE_LIST {
        if (exe = StrLower(targetExe)) {
            return true
        }
    }
    return false
}

__InputTip_CleanupDisableFlag(*) {
    global IT_DISABLE_FLAG
    try FileDelete(IT_DISABLE_FLAG)
}

; CapsLock:
; - 单击: 切到英文
; - 双击: 切到中文
; - 长按: 执行原来的 CapsLock 切换

global IT_CAPS_HOLD_MS := 300
global IT_CAPS_DOUBLE_MS := 250

global __it_caps_wait_second := false

$*CapsLock::
{
    global IT_CAPS_HOLD_MS
    global IT_CAPS_DOUBLE_MS
    global __it_caps_wait_second

    downTick := A_TickCount
    KeyWait("CapsLock")
    holdMs := A_TickCount - downTick

    if (holdMs >= IT_CAPS_HOLD_MS) {
        __it_caps_wait_second := false
        SetTimer(__it_caps_single_tap_commit, 0)
        SetCapsLockState(GetKeyState("CapsLock", "T") ? "Off" : "On")
        return
    }

    if (__it_caps_is_window_disabled()) {
        return
    }

    if (__it_caps_wait_second) {
        __it_caps_wait_second := false
        SetTimer(__it_caps_single_tap_commit, 0)
        switch_CN()
        return
    }

    __it_caps_wait_second := true
    SetTimer(__it_caps_single_tap_commit, -IT_CAPS_DOUBLE_MS)
}

__it_caps_single_tap_commit() {
    global __it_caps_wait_second

    if (!__it_caps_wait_second) {
        return
    }

    __it_caps_wait_second := false

    if (__it_caps_is_window_disabled()) {
        return
    }

    switch_EN()
}

__it_caps_is_window_disabled() {
    try {
        return __InputTip_IsWindowDisabled()
    } catch {
        return 0
    }
}
