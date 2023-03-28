#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

If (not(A_IsAdmin)) {
    MsgBox, 5,, This script needs to be run as administrator to work with Genshin Impact. Press "Retry" to restart the program and attempt to run as administrator or "Cancel" to close the program.

    IfMsgBox, Retry
        Run *RunAs "%A_AhkPath%" "%A_ScriptFullPath%"
    IfMsgBox, Cancel
        ExitApp
}
Else {
    currentChar := GetCurrentCharacter()
}

#IfWinActive Genshin Impact
XButton1::
    If (currentChar = 5) {
        currentChar := GetCurrentCharacter()
    }
    If (currentChar = 4 and CheckIfChar4()) {
        SendInput, 1
    }
    Else {
        SendInput % currentChar + 1
    }
    currentChar := GetCurrentCharacter(400)
    Tooltip, %currentChar%, 20, 20
    SetTimer, CloseTooltip, 1000
Return

#IfWinActive Genshin Impact
XButton2::
    If (currentChar = 5) {
        currentChar := GetCurrentCharacter()
    }
    If (currentChar = 1 and CheckIfChar1()) {
        SendInput, 4
    }
    Else {
        SendInput % currentChar - 1
    }
    currentChar := GetCurrentCharacter(400)
    Tooltip, %currentChar%, 20, 20
    SetTimer, CloseTooltip, 1500
Return

GetCurrentCharacter(delay:=0) {
    Sleep delay

    ImageSearch, FoundX, FoundY, 2400, 300, 2550, 800, *60 Character1.jpg
    1Found := ErrorLevel = 1
    ImageSearch, FoundX, FoundY, 2400, 300, 2550, 800, *60 Character2.jpg
    2Found := ErrorLevel = 1
    ImageSearch, FoundX, FoundY, 2400, 300, 2550, 800, *60 Character3.jpg
    3Found := ErrorLevel = 1
    ImageSearch, FoundX, FoundY, 2400, 300, 2550, 800, *60 Character4.jpg
    4Found := ErrorLevel = 1

    If (1Found) {
        Return 1
    }
    If (2Found) {
        Return 2
    }
    If (3Found) {
        Return 3
    }
    If (4Found) {
        Return 4
    }
    Else {
        Return 5
    }
}

CheckIfChar1() {
    ImageSearch, FoundX, FoundY, 2400, 300, 2550, 800, *60 Character1.jpg
    Return ErrorLevel = 1
}

CheckIfChar4() {
    ImageSearch, FoundX, FoundY, 2400, 300, 2550, 800, *60 Character4.jpg
    Return ErrorLevel = 1
}

#IfWinActive Genshin Impact
~1::
    currentChar := GetCurrentCharacter(400)
    Tooltip, %currentChar%, 20, 20
    SetTimer, CloseTooltip, 1200
    Return

#IfWinActive Genshin Impact
~2::
    currentChar := GetCurrentCharacter(400)
    Tooltip, %currentChar%, 20, 20
    SetTimer, CloseTooltip, 1200
    Return

#IfWinActive Genshin Impact
~3::
    currentChar := GetCurrentCharacter(400)
    Tooltip, %currentChar%, 20, 20
    SetTimer, CloseTooltip, 1200
    Return

#IfWinActive Genshin Impact
~4::
    currentChar := GetCurrentCharacter(400)
    Tooltip, %currentChar%, 20, 20
    SetTimer, CloseTooltip, 1200
    Return

CloseTooltip:
    Tooltip,,,
    SetTimer,, Off
    Return
