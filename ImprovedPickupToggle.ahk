#MaxThreadsPerHotkey, 2
#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

toggle := false

Menu, Tray, Icon, Ficon.ico
Menu, Tray, NoStandard

Menu, Tray, Add, Hotkey Settings, HotkeyConfigGui
Menu, Tray, Default, Hotkey Settings
Menu, Tray, Tip, Genshin Auto-Pickup Tool

Menu, Tray, Add
Menu, Tray, Standard

; checks to see if the script is running as administrator
If (not(A_IsAdmin)) {
    MsgBox, 5,, This script needs to be run as administrator to work with Genshin Impact. Press "Retry" to restart the program and attempt to run as administrator or "Cancel" to close the program.

    IfMsgBox, Retry
        Run *RunAs "%A_AhkPath%" "%A_ScriptFullPath%"
    IfMsgBox, Cancel
        ExitApp
}
Else {
    ; checks to see if the ini file exists, if it does not, it creates one
    If InStr(FileExist("hotkeyconfig.ini"), "A") {
        ; if the ini file exists, read the values and start the hotkeys
        IniRead, pickupKey, hotkeyconfig.ini, hotkeys, pickupKey
        IniRead, toggleHotkey, hotkeyconfig.ini, hotkeys, ToggleHotkey
        IniRead, pressHotkey, hotkeyconfig.ini, hotkeys, PressHotkey
        IniRead, pressFreq, hotkeyconfig.ini, hotkeys, PressFreq
        Hotkey, IfWinACtive, ahk_exe GenshinImpact.exe
        Hotkey, %toggleHotkey%, PickupToggle
        Hotkey, %pressHotkey%, PickupPress
    }
    Else {
        ; if the ini files does not exist, write the default values and open the gui
        TrayTip,, Creating .ini file to store hotkey configurations.
        IniWrite, f, hotkeyconfig.ini, hotkeys, PickupKey
        IniWrite, LControl, hotkeyconfig.ini, hotkeys, ToggleHotkey
        IniWrite, f, hotkeyconfig.ini, hotkeys, PressHotkey
        IniWrite, 5, hotkeyconfig.ini, hotkeys, PressFreq
        IniRead, pickupKey, hotkeyconfig.ini, hotkeys, PickupKey
        IniRead, toggleHotkey, hotkeyconfig.ini, hotkeys, ToggleHotkey
        IniRead, pressHotkey, hotkeyconfig.ini, hotkeys, PressHotkey
        IniRead, pressFreq, hotkeyconfig.ini, hotkeys, PressFreq
        gosub HotkeyConfigGui
    }
}
Return

PickupToggle:
    ; get's assigned as a hotkey to toggle autopickup
    
    ; Gets the pointer details to prevent the key from being sent in if there is a pointer/cursor
    PtrStructSize := A_PtrSize + 16
    VarSetCapacity(InfoStruct, PtrStructSize)
    NumPut(PtrStructSize, InfoStruct)
    DllCall("GetCursorInfo", UInt, &InfoStruct)
    Result := NumGet(InfoStruct, 8)

    If (Result == 0 && !toggle) {
        toggle := !toggle  ;toggle on off
        Tooltip % "Pickup ON"
        SetTimer,ToolTipOff,1000 ;set a timer for 1 second to clear the tooltip
        gosub ToggleLoop
    }

    If (toggle) {
        toggle := !toggle  ;toggle on off
        Tooltip % "Pickup OFF"
        SetTimer,ToolTipOff,1000 ;set a timer for 1 second to clear the tooltip
        ; Sleep 1000
        ; Reload
    }
Return

PickupPress:
    ; fires the pickup key when hotkey is held
    While GetKeyState(StrReplace(A_ThisHotkey, "~", ""), "P") {
        If WinActive("Genshin Impact") {
            ControlSend, ahk_parent, {%pickupKey% down}, Genshin Impact
            ControlSend, ahk_parent, {%pickupKey% up}, Genshin Impact
            ; SendInput, {%pickupKey% down}
            ; SendInput, {%pickupKey% up}
            Sleep 1000/pressFreq
        }
    }
Return

ToggleLoop:
    ; loops on another thread until user presses toggle key
    Loop {
        If (!toggle) {
            break
        }
        If WinActive("Genshin Impact") {
            ; Gets the pointer details to prevent the key from being sent in if there is a pointer/cursor
            PtrStructSize := A_PtrSize + 16
            VarSetCapacity(InfoStruct, PtrStructSize)
            NumPut(PtrStructSize, InfoStruct)
            DllCall("GetCursorInfo", UInt, &InfoStruct)
            Result := NumGet(InfoStruct, 8)

            If (Result <> 0) {
                ControlSend, ahk_parent, %pickupKey%, Genshin Impact
                ; SendInput, %pickupKey%
                Sleep 1000/pressFreq
            }
        }
    }
Return

HotkeyConfigGui:
    ; generate the strings for the alternate hotkey dropdowns
    dropdownString := "None|LControl|RControl|LAlt|RAlt|LButton|RButton|MButton|XButton1|XButton2"
    toggleKeyDropdown := StrReplace(DropdownString, toggleHotkey, toggleHotkey . "|")
    pressKeyDropdown := StrReplace(DropdownString, pressHotkey, pressHotkey . "|")

    Gui, New, , Auto-Pickup Configuration
    Gui, Add, GroupBox, w324 h232, Hotkey Settings
    
    Gui, Add, Text,   x24 y32 w90, Pick Up Key:
    Gui, Add, Hotkey, x+16 y28 w80 vPickupKey, %pickupKey%

    Gui, Add, Text,   x24 y+16 w90, Toggle Hotkey:
    Gui, Add, Hotkey, x+16 y60 w80 vToggleHotkey, %toggleHotkey%
    Gui, Add, DropDownList, x+16 y60 w90 gToggleItemSelected vAltToggleHotkey, %toggleKeyDropdown%
    
    Gui, Add, Text,   x24 y+16 w90, Press Hotkey:
    Gui, Add, Hotkey, x+16 y92 w80 vPressHotkey, %pressHotkey%
    Gui, Add, DropDownList, x+16 y92 w90 gPressItemSelected vAltPressHotkey, %pressKeyDropdown%
    
    Gui, Add, Text,   x24 y+16 vSliderText w200, Pickup Key Presses Per Second: %pressFreq%
    Gui, Add, Slider, x16 y+8 w200 vPressFreq Range2-12 TickInterval2 gSliderValue AltSubmit, %pressFreq%
    
    Gui, Add, Button, x22 y+16 w190 gResetToDefault, Reset to Defaults
    
    Gui, Add, Button, w80 x122 y256 gCancel, Cancel
    Gui, Add, Button, w80 xp-108 y256 gSubmitClose, OK
    Gui Show, w348 h292
Return

SliderValue:
    GuiControl,, SliderText, Pickup Key Presses Per Second: %PressFreq%
Return


ToggleItemSelected:
    GuiControl,, ToggleHotkey, AltToggleHotkey
    Return

PressItemSelected:
    GuiControl,, PressHotkey, AltPressHotkey
    Return

SubmitClose:
    ; handles when the OK button is pressed in the gui
    Gui, Submit, NoHide
    Gui, Destroy

    gosub DisableHotkeys

    IniWrite, %PickupKey%, hotkeyconfig.ini, hotkeys, PickupKey

    If (ToggleHotkey = "") {
        If (AltToggleHotkey != "") {
            IniWrite, %AltToggleHotkey%, hotkeyconfig.ini, hotkeys, ToggleHotkey
        }
        Else {
            MsgBox, Error: Could not get Toggle Hotkey, assigning as default.
            IniWrite, LControl, hotkeyconfig.ini, hotkeys, ToggleHotkey
        }
    }
    Else {
        IniWrite, %ToggleHotkey%, hotkeyconfig.ini, hotkeys, ToggleHotkey
    }

    If (PressHotkey = "") {
        If (AltPressHotkey != "") {
            IniWrite, %AltPressHotkey%, hotkeyconfig.ini, hotkeys, PressHotkey
        }
        Else {
            MsgBox, Error: Could not get Press Hotkey, assigning as default.
            IniWrite, LControl, hotkeyconfig.ini, hotkeys, PressHotkey
        }
    }
    Else {
        IniWrite, %PressHotkey%, hotkeyconfig.ini, hotkeys, PressHotkey
    }

    IniWrite, %PressFreq%, hotkeyconfig.ini, hotkeys, PressFreq
    

    IniRead, pickupKey, hotkeyconfig.ini, hotkeys, PickupKey
    IniRead, toggleHotkey, hotkeyconfig.ini, hotkeys, ToggleHotkey
    IniRead, pressHotkey, hotkeyconfig.ini, hotkeys, PressHotkey
    IniRead, pressFreq, hotkeyconfig.ini, hotkeys, PressFreq

    gosub EnableHotkeys
Return

ResetToDefault:
    GuiControl,, PickupKey, f
    GuiControl,, ToggleHotkey, LControl
    GuiControl,, PressHotkey, f
    GuiControl,, PressFreq, 5
    GuiControl,, SliderText, Pickup Key Presses Per Second: 5
Return

    
ToolTipOff:
    SetTimer,ToolTipOff,off ;turn the timer off
    tooltip ;clear the tooltip
Return

DisableHotkeys:
    IniRead, tempToggleHotkey, hotkeyconfig.ini, hotkeys, ToggleHotkey
    IniRead, tempPressHotkey, hotkeyconfig.ini, hotkeys, Pres || A_TimeSinceThisHotkey = 0sHotkey
    Hotkey, IfWinACtive, ahk_exe GenshinImpact.exe
    Hotkey, %tempToggleHotkey%, PickupToggle, off
    Hotkey, %tempPressHotkey%, PickupPress, off
Return

EnableHotkeys:
    IniRead, tempToggleHotkey, hotkeyconfig.ini, hotkeys, ToggleHotkey
    IniRead, tempPressHotkey, hotkeyconfig.ini, hotkeys, PressHotkey
    Hotkey, IfWinACtive, ahk_exe GenshinImpact.exe
    Hotkey, %tempToggleHotkey%, PickupToggle, on
    Hotkey, %tempPressHotkey%, PickupPress, on
Return

F1::ExitApp
!+L::WinMove, A,, -2, -26
