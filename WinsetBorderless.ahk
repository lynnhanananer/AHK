#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

^L::
; WinSet, Style, -0xC00000, A
WinMove, A,, -2, -26
; WinSet, Region, w2560 h1440 0-0, A
Return