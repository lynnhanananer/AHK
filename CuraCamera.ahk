#SingleInstance, Force
#InstallMouseHook
SendMode Input
SetWorkingDir, %A_ScriptDir%

#UseHook
#IfWinActive ahk_exe Cura.exe
+MButton::
    Send {Blind}{Shift up}
    Click Right Down
    KeyWait MButton
    Click Right Up
    return