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
