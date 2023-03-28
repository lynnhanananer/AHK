#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

Gui, +LastFound -SysMenu ToolWindow +AlwaysOnTop -Caption

OnMessage(0x200, "MouseMove")
 
; Gui, Margin, 50, 50
Gui, Add, Picture, x100 y0 vTopMiddle +AltSubmit +BackgroundTrans +0x0100, %A_WorkingDir%\images\topmid.png
Gui, Add, Picture, x0 y27 vTopLeft +AltSubmit +BackgroundTrans +0x0100, %A_WorkingDir%\images\topleft.png
Gui, Add, Picture, x100 y100 vMiddle +AltSubmit +BackgroundTrans +0x0100, %A_WorkingDir%\images\middle.png
WinSet, TransColor, f0f0f0
Gui, Show,, test
 
Return
 
MouseMove(wParam, lParam, Msg, hWnd)
{
    static shown, Overlay_id

    Gui, %A_Gui%: +HwndhGui
    
    if (hwnd = Overlay_id) ; return if mouse over overlay gui
        return
    
    if ((A_GuiControl = "TopMiddle") || (A_GuiControl = "TopLeft")) and (!shown)
        {
            
            shown := true
            GuiControlGet, %A_GuiControl%, Pos
            
            X := %A_GuiControl%x
            Y := %A_GuiControl%y
            w := %A_GuiControl%w
            h := %A_GuiControl%h
            
            VarSetCapacity(POINT, 8, 0)
            NumPut(X, POINT, 0, "Int")
            NumPut(Y, POINT, 4, "Int")
            DllCall("User32.dll\ClientToScreen", "Ptr", hGui, "Ptr", &POINT)
            X := NumGet(POINT, 0, "Int")
            Y := NumGet(POINT, 4, "Int")
            
            DetectHiddenWindows on
            Gui, 2: Color, 888888
            Gui, 2: +hwndOverlay_id +owner%hGui%
            WinSet, Transparent, 100, ahk_id %Overlay_id%
            Gui, 2: -Caption +ToolWindow
            Gui, 2: show, x%x% y%y% h%h% w%w% NA
            DetectHiddenWindows off

        }
        else
        {
            Gui, 2:Destroy
            shown := false
        }
}