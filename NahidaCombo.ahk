#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

#MaxHotkeysPerInterval, 1
#HotkeyInterval 1800


If (not(A_IsAdmin)) {
    MsgBox, 5,, This script needs to be run as administrator to work with Genshin Impact. Press "Retry" to restart the program and attempt to run as administrator or "Cancel" to close the program.

    IfMsgBox, Retry
        Run *RunAs "%A_AhkPath%" "%A_ScriptFullPath%"
    IfMsgBox, Cancel
        ExitApp
}

XButton1::
    Critical
    Tooltip
    Click
    Sleep 300
    Click
    Sleep 200
    Click, Down Left
    Sleep 500
    Click, Up Left
    Sleep 100
    SendInput {Space}
Return