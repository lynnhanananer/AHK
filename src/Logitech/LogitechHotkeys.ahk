#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
CoordMode, Mouse, Screen

; Menu Options
Menu, Tray, NoStandard
Menu, Tray, Add, View Hotkeys, ViewHotkeys
Menu, Tray, Default, View Hotkeys
Menu, Tray, Add
Menu, Tray, Standard
Menu, Tray, Icon, setupapi.dll, 21

If (A_IsCompiled) {
    Menu, Tray, Tip, Logitech Hotkeys
}

; Hotkeys GUI
Gui, Font, s10
Gui, Add, ListView, h200 w1000 Checked v, Disable|Hotkey|Action|Context
for Index, Element in Hotkeys(Hotkeys)
    LV_Add("Check", "", Element.Hotkey, Element.Action, Element.Context)
LV_ModifyCol()

; ******************** Keyboard Buttons ********************
; Lock Button
<#L::
    Run, "switch_to_2_with_monitor.vbs", C:\Program Files\InputSwitcher\
    FormatTime, currentTime, A_Now, yyyyMMdd HH:mm:ss
    FileAppend % currentTime . " " . A_MSec . ", " . "UsagePage: " . 65280 . ", Usage: " . 1 . ", Data: 1001091E010000, Origin: LogitechHotkeys`n", device_log.txt
    FileAppend % currentTime . " " . A_MSec . ", " . "UsagePage: " . 65280 . ", Usage: " . 1 . ", Data: 10020A1B010000, Origin: LogitechHotkeys`n", device_log.txt
    Return

; Context Menu Key
AppsKey::Menu, Tray, Show

; Camera Button
PrintScreen::+#s

; Calculator Key
Launch_App2::Run, calc

; F4 Media Key
<#a::
    Run, "switch_to_2.vbs", C:\Program Files\InputSwitcher\
    FormatTime, currentTime, A_Now, yyyyMMdd HH:mm:ss
    FileAppend % currentTime . " " . A_MSec . ", " . "UsagePage: " . 65280 . ", Usage: " . 1 . ", Data: 1001091E010000, Origin: LogitechHotkeys`n", device_log.txt
    FileAppend % currentTime . " " . A_MSec . ", " . "UsagePage: " . 65280 . ", Usage: " . 1 . ", Data: 10020A1B010000, Origin: LogitechHotkeys`n", device_log.txt
    Return

; ******************** Mouse Buttons ********************
; Thumb Rest Button
<#Tab::GestureButton("LWin", "#{Tab}", "!{F4}",,,,,False)

#IfWinActive ahk_exe Fusion360.exe
<#Tab::SendInput "{F6}"

#IfWinActive ahk_exe chrome.exe
<#Tab::GestureButton("LWin", "#{Tab}", "^w", "^t",,"^+t",,False)

; Back Button (Thumb button near back of mouse)
~XButton1::Return

; Forward Button (Thumb button near front of mouse)
XButton2::XButton2

#IfWinActive ahk_exe chrome.exe
XButton2::GestureButton("XButton2",,"!g","!+d", "!+w", "^j")

; Mouse Thumb Wheel
; Up/Clockwise
~WheelLeft::Return

; Down/Counterclockwise
~WheelRight::Return

; ******************** Gesture Button Function ********************
; Sets gesture based hotkeys for center press and 4 directions. Hold the gesture button for 1.5 seconds to cancel gesture.
GestureButton(GestureHotkey, Center:=False, Up:=False, Right:=False, Down:=False, Left:=False, ShowToolTip:=False, PassUnassigned:=True) {
    ; Show a notification if no gestures are assigned
    If (Not (Center or Up or Right or Down or Left) and PassUnassigned) {
        KeyWait, %GestureHotkey%
        Send {%GestureHotkey%}
        TrayTip, Gesture Button for %GestureHotkey%, %GestureHotkey% has no gestures assigned.`nPlease consider converting hotkey to a keybind., 10
            Return
    }

    ; Get the initial mouse position and wait for the gesture hotkey to be released
    MouseGetPos, xPos, yPos
    KeyWait, %GestureHotkey%, T1.5

    ; Show a notification for cancelled gestures
    If (ErrorLevel != 0) {
        TrayTip, Gesture Button for %GestureHotkey%, %GestureHotkey% gesture was cancelled., 10
            Return
    }

    ; Gets the final mouse position after the getsure hotkey is released and calculates the change in mouse position
    MouseGetPos, xFinalPos, yFinalPos
    deltaX := xFinalPos - xPos
    deltaY := (yFinalPos - yPos) * -1 ; invert delta y so that up is a positive change in y

    ; Determines the direction from the change in mouse position
    ; The gesture angle must be within 60 degrees of the cardinal direction to qualify
    angle := ATan(deltaY/deltaX) * 180 / 3.14
    direction := ""
    If (angle > 60 or angle < -60) {
        If (deltaY > 30) {
            direction := "Up"
        }
        Else If (deltaY < -30) {
            direction := "Down"
        }
        Else {
            direction := "Center"
        }
    }
    Else If (angle < 30 and angle > -30) {
        If (deltaX > 30) {
            direction := "Right"
        } 
        Else If (deltaX < -30) {
            direction := "Left" 
        }
        Else {
            direction := "Center"
        }
    }

    ; Sends the hotkey based on the direction
    If (direction == "Center" and Center) {
        SendInput %Center%
    }
    Else If (direction == "Up" and Up) {
        SendInput %Up%
    }
    Else If (direction == "Right" and Right) {
        SendInput %Right%
    }
    Else If (direction == "Down" and Down) {
        SendInput %Down%
    }
    Else If (direction == "Left" and Left) {
        SendInput %Left%
    }
    Else If (PassUnassigned) {
        SendInput {%GestureHotkey%}
    }

    ; Shows tooltip for debugging purposes
    If (ShowToolTip) {
        Tooltip, %direction%
        SetTimer, CloseToolTip, 1000
    }

    Return
}

; Closes the toolitp after 2 seconds
CloseToolTip:
    ToolTip,,,
Return

ViewHotkeys:
    Gui, Show, h220 w1020
Return

; Read Hotkeys from Script File
Hotkeys(ByRef Hotkeys)
{
    ; Read in the current file and replace any breaking characters
    FileRead, Script, C:\Users\Lyle Hanner\Desktop\Coding and Scripts\AHK\LogitechHotkeys.ahk
    Script := RegExReplace(Script, "ms`a)^\s*/\*.*?^\s*\*/\s*|^\s*\(.*?^\s*\)\s*")

    ; Variables for storing the hotkey information
    Hotkeys := {}
    Context := ""
    ContextLine := 0
    Loop, Parse, Script, `n, `r 
    {
        ; Search for hotkey context lines that appear before hotkeys
        if RegExMatch(A_LoopField, "i)^(#if.*)", ContextMatch) {
            Context := ContextMatch1
            ContextLine := A_Index
        }

        ; Search for hotkeys
        if RegExMatch(A_LoopField,"^\s*(.*):`:(.*)",Match)
        {
            ; If a hotkey returns itself or just "return", don't add it to the list
            if ((Match1 = Match2) or (Match2 = "return") or (Match2 = Return)) {
                continue
            }

            HotkeyName := Match1
            HotkeyAction := Match2

            ; Replace hotkey names with common names
            HotkeyName := StrReplace(HotkeyName, "<#L", "Lock Key")
            HotkeyName := StrReplace(HotkeyName, "AppsKey", "Menu Key")
            HotkeyName := StrReplace(HotkeyName, "PrintScreen", "Camera Key")
            HotkeyName := StrReplace(HotkeyName, "Launch_App2", "Calculator Key")
            HotkeyName := StrReplace(HotkeyName, "<#Tab", "Thumb Button")
            HotkeyName := StrReplace(HotkeyName, "XButton1", "Back Button")
            HotkeyName := StrReplace(HotkeyName, "XButton2", "Forward Button")

            ; Replace hotkey action modifier symbols to words
            HotkeyAction := StrReplace(HotkeyAction, "+", "Shift+")
            HotkeyAction := StrReplace(HotkeyAction, "<^>!", "AltGr+")
            HotkeyAction := StrReplace(HotkeyAction, "<", "Left")
            HotkeyAction := StrReplace(HotkeyAction, ">", "Right")
            HotkeyAction := StrReplace(HotkeyAction, "!", "Alt+")
            HotkeyAction := StrReplace(HotkeyAction, "^", "Ctrl+")
            HotkeyAction := StrReplace(HotkeyAction, "#", "Win+")
            HotkeyAction := StrReplace(HotkeyAction, "{")
            HotkeyAction := StrReplace(HotkeyAction, "}")
            HotkeyAction := StrReplace(HotkeyAction, """")
            HotkeyAction := StrReplace(HotkeyAction, "}")
            HotkeyAction := StrReplace(HotkeyAction, "SendInput ")

            if InStr(HotkeyAction, "GestureButton") {
                HotkeyAction := StrReplace(HotkeyAction, "GestureButton(")
                HotkeyAction := StrReplace(HotkeyAction, ")")
                HotkeyAction := StrReplace(HotkeyAction, "`, ", "`,")
                GestureSplit := StrSplit(HotkeyAction, "`,")

                GestureNames := ["Center: ", "Up: ", "Right: ", "Down: ", "Left: ", "ShowToolTip: ", "PassUnassigned: "]
                HotkeyAction := "GestureButton: "

                GestureSplit.RemoveAt(1)

                for index, GestureAction in GestureSplit {
                    if (GestureAction) {
                        HotkeyAction .= GestureNames[index] . GestureAction
                        if (index != GestureSplit.Count()) {
                            HotkeyAction .= "`, "
                        }
                    }
                }
            }
            if (ContextLine != (A_Index - 1)) {
                Context := ""
            }
            Hotkeys.Push({"Hotkey":HotkeyName, "Action":HotkeyAction, "Context":Context})
        }
    }
    return Hotkeys
}