
#MaxThreadsPerHotkey, 2
#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

toggle := false

#IfWinActive Genshin Impact
LControl::
    if (toggle) {
        Tooltip % "Pickup OFF"
        SetTimer,tooltipoff,1000 ;set a timer for 1 second to clear the tooltip
        Sleep 1000
        Reload
    }
    toggle := !toggle  ;toggle on off
    Tooltip % "Pickup " (toggle ? "ON" : "OFF")
    SetTimer,tooltipoff,1000 ;set a timer for 1 second to clear the tooltip

    gosub autoclicker
return

tooltipoff:
    settimer,tooltipoff,off ;turn the timer off
    tooltip ;clear the tooltip
return

autoclicker:
    ; loops on another thread until user presses toggle key
    Loop {
        SendInput, f
        Sleep, 200
    }
