#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
#Persistent

CoordMode, Mouse, Screen
InZone := False ; is true when the mouse is in the defined switching area
switching := True ; is true when the switching is enabled
overtime := False ; is true when the script is running outside of normal work hours
timeOverride := False ; is true when switching is enabled outside of normal work hours
switchSideLeft := False ; is true when the switching direction is set to left
sleepDelay := 50 ; the number of miliseconds the thread will sleep between each loop iteration for mouse position detection

; instals the neccesary icons to the icons directory when the exe is first run
if !FileExist("\icons") {
    FileCreateDir, icons
}
FileInstall, icons\DeviceSwitchingDisabled.ico, icons\DeviceSwitchingDisabled.ico, 1
FileInstall, icons\DisplaySwitchLeft.ico, icons\DisplaySwitchLeft.ico, 1
FileInstall, icons\DisplaySwitchRight.ico, icons\DisplaySwitchRight.ico, 1

; validate that the tray icons are present in the icons directory
iconList := ["icons\DeviceSwitchingDisabled.ico", "icons\DisplaySwitchLeft.ico", "icons\DisplaySwitchRight.ico"]
allFilesExist := true

Loop % iconList.Length() {
    fileName := iconList[A_Index]
    if !FileExist(fileName) {
        allFilesExist := false
        break
    }
}

if !allFilesExist {
    MsgBox The tray icons cannot be found in the icons directory. The script will now close.
    ExitApp
}

; set up the tray
Menu, Tray, Icon, icons\DisplaySwitchRight.ico

Menu, Tray, NoStandard
Menu, Tray, Add, Disable Device Switching, ChangeSwitching
Menu, Tray, Default, Disable Device Switching

Menu, Tray, Add
Menu, Tray, Standard

If (A_IsCompiled) {
    Menu, Tray, Tip, Display Edge Switcher
}

Goto DeviceSwitchingLoop

DeviceSwitchingLoop:
    While switching {
        MouseGetPos, xPos, yPos
        dayOfWeek := A_WDay
        hour := A_Hour

        If (switchSideLeft) {
            xPosSwitch = 0
        }
        Else {
            xPosSwitch := A_ScreenWidth - 1
        }

        ; automatically disables device switching when the hour is not between 8 am and 5 pm, or disables when it is a weekend
        If (timeOverride || (hour > 7 and hour < 18 and dayOfWeek > 1 and dayOfWeek < 7)) {
            If (!InZone and xPos = xPosSwitch and yPos > 600 and yPos < 1050) {
                Run, "switch_to_2.vbs", C:\Program Files\InputSwitcher\
                InZone := True
            }
            Else If(InZone and (xPos != xPosSwitch or yPos < 600)) {
                InZone := False
            }
        }
        Else {
            overtime := True
            If (!timeOverride) {
                Gosub, DisableSwitching
                sleepDelay := 600000 ; sleep delay of 1 minute added to reduce script cpu usage outside of working hours
            }
        }
        Sleep sleepDelay
    }
    Return

DisableSwitching:
    If (switching) {
        switching := !switching
        Menu, Tray, Rename, Disable Device Switching, Enable Device Switching
        Menu, Tray, Icon, icons\DeviceSwitchingDisabled.ico
        sleepDelay := 600000
    }
    Else {
        switching := !switching
        Menu, Tray, Rename, Enable Device Switching, Disable Device Switching
        If (switchSideLeft) {
            Menu, Tray, Icon, icons\DisplaySwitchLeft.ico
        }
        Else {
            Menu, Tray, Icon, icons\DisplaySwitchRight.ico
        }
        Goto DeviceSwitchingLoop
    }

    Return

ChangeSwitching:
    If (switching) {
        If (switchSideLeft) {
            switchSideLeft := !switchSideLeft
            Menu, Tray, Icon, icons\DisplaySwitchRight.ico
            Menu, Tray, Rename, Device Switching Right, Disable Device Switching
        }
        Else {
            switching := !switching
            Menu, Tray, Rename, Disable Device Switching, Enable Device Switching
            Menu, Tray, Icon, icons\DeviceSwitchingDisabled.ico
            sleepDelay := 600000
        }
    }
    Else {
        switching := !switching
        switchSideLeft := True
        If (overtime) {
            timeOverride := True
        }
        Menu, Tray, Icon, icons\DisplaySwitchLeft.ico
        Menu, Tray, Rename, Enable Device Switching, Device Switching Right
        sleepDelay := 50
        Goto DeviceSwitchingLoop
    }
