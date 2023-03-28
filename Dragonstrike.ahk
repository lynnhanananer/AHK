#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

; 41 frames before dragon strike
XButton2::
    SendInput e
    ; 10% speed boost range 360 - 440
    Sleep, 400
    SendInput, {RButton down}
    Sleep, 30
    SendInput, {Space}
    SendInput, {RButton up}
    SendInput, {LButton 10}

    ; Second e
    Sleep, 800
    SendInput e
    Sleep, 500
    SendInput, {RButton down}
    Sleep, 30
    SendInput, {Space}
    SendInput, {RButton up}
    SendInput, {LButton 10}

    ; Third e
    Sleep, 800
    SendInput e
    Sleep, 700
    SendInput, {RButton down}
    Sleep, 30
    SendInput, {Space}
    SendInput, {RButton up}
    SendInput, {LButton 10}