#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
Thread, Interrupt, 1550, 2000
Thread, NoTimers, True

If (not(A_IsAdmin)) {
    MsgBox, 5,, This script needs to be run as administrator to work with Genshin Impact. Press "Retry" to restart the program and attempt to run as administrator or "Cancel" to close the program.

    IfMsgBox, Retry
        Run *RunAs "%A_AhkPath%" "%A_ScriptFullPath%"
    IfMsgBox, Cancel
        ExitApp
}

XButton1::
    Click
    Sleep 350
    Click
    Click, Down Left
    Sleep 600
    SendInput {Space}
    Click, Up Left
Return

f5::ExitApp