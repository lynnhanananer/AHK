#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
#Persistent

CoordMode, Mouse, Screen
InZone := False
switching := True

Menu, Tray, Icon, DisplaySwitchRight.ico

Menu, Tray, NoStandard
Menu, Tray, Add, Disable Device Switching, ChangeSwitching
Menu, Tray, Default, Disable Device Switching

Menu, Tray, Add
Menu, Tray, Standard

If (A_IsCompiled) {
    Menu, Tray, Tip, Display Edge Switcher
}

switchSideLeft := false

Goto DeviceSwitchingLoop

DeviceSwitchingLoop:
    While switching {
        MouseGetPos, xPos, yPos
        dayOfWeek := A_WDay
        hour := A_Hour
        sleepDelay := 0

        If (switchSideLeft) {
            xPosSwitch = 0
        }
        Else {
            xPosSwitch := A_ScreenWidth - 1
        }

        If (hour > 7 and hour < 18 and dayOfWeek > 1 and dayOfWeek < 7) {
            sleepDelay := 50
            If (!InZone and xPos = xPosSwitch and yPos > 600 and yPos < 1050) {
                Run, "switch_to_2.vbs", C:\Program Files\InputSwitcher\
                InZone := True
            }
            Else If(InZone and (xPos != xPosSwitch or yPos < 600)) {
                InZone := False
            }
        }
        Else {
            sleepDelay := 600000
            Gosub, DisableSwitching
        }
        Sleep sleepDelay
    }
    Return

DisableSwitching:
    If (switching) {
        switching := !switching
        Menu, Tray, Rename, Disable Device Switching, Enable Device Switching
        Menu, Tray, Icon, DeviceSwitchingDisabled.ico
    }
    Else {
        switching := !switching
        Menu, Tray, Rename, Enable Device Switching, Disable Device Switching
        If (switchSideLeft) {
            Menu, Tray, Icon, DisplaySwitchLeft.ico
        }
        Else {
            Menu, Tray, Icon, DisplaySwitchRight.ico
        }
        Goto DeviceSwitchingLoop
    }

    Return

ChangeSwitching:
    If (switching) {
        If (switchSideLeft) {
            switchSideLeft := !switchSideLeft
            Menu, Tray, Icon, DisplaySwitchRight.ico
            Menu, Tray, Rename, Device Switching Right, Disable Device Switching
        }
        Else {
            switching := !switching
            Menu, Tray, Rename, Disable Device Switching, Device Switching Left
            Menu, Tray, Icon, DeviceSwitchingDisabled.ico
        }
    }
    Else {
        switching := !switching
        switchSideLeft := True
        Menu, Tray, Icon, DisplaySwitchLeft.ico
        Menu, Tray, Rename, Device Switching Left, Device Switching Right
        Goto DeviceSwitchingLoop
    }
