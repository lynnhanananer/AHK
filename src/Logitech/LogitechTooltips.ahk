#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

; Menu Setup
Menu, Tray, NoStandard

Menu, Tray, Add, Hide Tooltips, ShowTooltips
Menu, Tray, Default, Hide Tooltips

Menu, Tray, Add, Show Device Tooltips, ShowDevice

Menu, LockKeySubmenu, Add, Caps Lock, ShowCapsLock
Menu, LockKeySubmenu, Check, Caps Lock

Menu, LockKeySubmenu, Add, Num Lock, ShowNumLock
Menu, LockKeySubmenu, Check, Num Lock

Menu, LockKeySubmenu, Add, Scroll Lock, ShowScrollLock
Menu, LockKeySubmenu, Check, Scroll Lock

Menu, LockKeySubmenu, Add, Funcion/Media Keys Toggle, ShowFunctionMedia
Menu, LockKeySubmenu, Check, Funcion/Media Keys Toggle
 
Menu, Tray, Add, Lock Key Tooltips, :LockKeySubmenu
Menu, Tray, Add
Menu, Tray, Standard

Menu, Tray, Icon, shell32.dll, 244

If (A_IsCompiled) {
    ; installs the neccesary library to the libraries directory when the exe is first run
    if !FileExist("\libraries") {
        FileCreateDir, libraries
    }
    FileInstall, ..\..\libraries\AHKHID-master\examples\AHKHID.ahk, libraries\AHKHID.ahk, 1

    ; installs the neccesary icon to the resources directory when the exe is first run
    if !FileExist("\resouces") {
        FileCreateDir, resources
    }
    FileInstall, resources\shell32dll-244-x.ico, resources\shell32dll-244-x.ico, 1
    
    ; validate that the tray icon and library are present in the resources and libraries directory
    if !FileExist("resources\shell32dll-244-x.ico")  && !FileExist("libraries\AHKHID.ahk") {
        MsgBox The tray icon or required library cannot be found in the resources directory. The script will now close.
    }

    Menu, Tray, Tip, Logitech Tooltips
}
Else {
    ; validate that the tray icon and library are present in the resources and libraries directory
    if !FileExist("resources\shell32dll-244-x.ico")  && !FileExist("..\..\libraries\AHKHID-master\examples\AHKHID.ahk") {
        MsgBox The tray icon or required library cannot be found in the resources directory. The script will now close.
    }

    ; the path for the library is different when run as an executable
    #Include, ..\..\libraries\AHKHID-master\examples\AHKHID.ahk
}

prevValue := ""
showDevice := False
showCapsLock := True
showNumLock := True
showScrollLock := True
showFunctionMedia := True
showTooltips := True

;Create GUI to receive messages
Gui, +LastFound
hGui := WinExist()

;Intercept WM_INPUT messages
WM_INPUT := 0xFF
OnMessage(WM_INPUT, "InputMsg")

AHKHID_UseConstants()
AHKHID_AddRegister(6)
AHKHID_AddRegister(65280, 1, hGui, RIDEV_INPUTSINK)
AHKHID_AddRegister(65280, 2, hGui, RIDEV_INPUTSINK)
AHKHID_AddRegister(65280, 136, hGui, RIDEV_INPUTSINK)
AHKHID_AddRegister(65280, 161, hGui, RIDEV_INPUTSINK)
AHKHID_AddRegister(12, 1, hGui, RIDEV_INPUTSINK)
AHKHID_AddRegister(65280, 4, hGui, RIDEV_INPUTSINK)

AHKHID_Register()

InputMsg(wParam, lParam) {
    Local devh, hidData, sLabel
    Local deviceKeyMap := {7698: "Device Connected", 7689: "Device Connected", 152767119: "Device Failed to Connect", 6922: "Device Disconnected", 152963471: "Device Disconnected", 845414407: "Keyboard Connected", 16842756: "Device Connected", 338821127: "Device Connected", 845414408: "Mouse Connected", 54196807: "Device Connected", 327687: "Device Connected", 85196807: "Device Connected"}
    Local keyMap := {16777228: "Media Keys On", 12: "Function Keys On", 524299: "Backlight Brightness Lv 0", 17301515: "Backlight Brightness Lv 1", 34078731: "Backlight Brightness Lv 2", 50855947: "Backlight Brightness Lv 3", 67633163: "Backlight Brightness Lv 4", 84410379: "Backlight Brightness Lv 5", 101187595: "Backlight Brightness Lv 6", 117964811: "Backlight Brightness Lv 7", 872415240: "Fn Down", 8: "Fn Up", 4110: "Smooth Scroll", 69646: "Ratchet Scroll", 14: "NumLock Off", 65550: "NumLock On", 196622: "CapsLock On", 327694: "ScrollLock On"}
    Critical

    ; Get handle of device
    devh := AHKHID_GetInputInfo(lParam, II_DEVHANDLE)

    ; Check for error
    If (devh <> -1) ; Check that it is one of the MX devices
        And (AHKHID_GetDevInfo(devh, DI_DEVTYPE, True) = 2)
    And (AHKHID_GetDevInfo(devh, DI_HID_VENDORID, True) = 1133)
    And (AHKHID_GetDevInfo(devh, DI_HID_PRODUCTID, True) = 50475)
    And (AHKHID_GetDevInfo(devh, DI_HID_VERSIONNUMBER, True) = 9233) {

        ;Get data
        hidData := AHKHID_GetInputData(lParam, uData)

        ;Check for error
        If (hidData <> -1) {

            ; gets the 4 bytes of the data pointer offset by 2 bytes
            ; and converts it into an integer using little-endian order to sequence the integer
            ; ex: 1101080000340000000000000000000000000000 is the data code for fn key down
            ; the 4 bytes at offset 2 are 08000034, interpreted to an int with LE order of 34 00 00 80
            hidData := NumGet(uData, 2, "Int")

            If (keyMap.HasKey(hidData) or deviceKeyMap.HasKey(hidData)) {
                value := keyMap.HasKey(hidData) ? keyMap[hidData] : deviceKeyMap[hidData]

                ; If a device was previously connectd, silence following numLock message
                If (deviceKeyMap.HasKey(hidData) and value = "NumLock On") {
                    prevValue := "Supressed NumLock On"
                    Return
                } Else If (deviceKeyMap.HasKey(hidData) and showDevice and showTooltips) {
                    prevValue := value
                    SetTimer, CloseToolTip, 2000
                } Else {

                    ; If any Lock key was previously turned on and NumLock On is fired, change message to {LockKeyName} off
                    If (InStr(prevValue, "On") and value = "NumLock On") {
                        value := StrReplace(value, "NumLock On", StrReplace(prevValue, " On", " Off"))
                    }
                    prevValue := value

                    If (showTooltips) {
                        ; Only Show Tooltips for Changes in Lock Keys
                        If (InStr(value, "CapsLock") and showCapsLock) {
                            ToolTip, %value%
                            SetTimer, CloseToolTip, 2000
                        }
                        If (InStr(value, "NumLock") and showNumLock) {
                            ToolTip, %value%
                            SetTimer, CloseToolTip, 2000
                        }
                        If (InStr(value, "ScrollLock") and showScrollLock) {
                            ToolTip, %value%
                            SetTimer, CloseToolTip, 2000
                        }
                        If (InStr(value, "Keys") and showFunctionMedia) {
                            ToolTip, %value%
                            SetTimer, CloseToolTip, 2000
                        }
                    }
                }
                Return
            }
            Return
        }
    }
}

CloseToolTip:
    ToolTip,,,
    Return

CloseTrayTip:
    TrayTip
    Return

; Menu Labels
ShowDevice:
    Menu, Tray, ToggleCheck, Show Device Tooltips
    showDevice := !showDevice
    Return

ShowCapsLock:
    Menu, LockKeySubmenu, ToggleCheck, Caps Lock
    showCapsLock := !showCapsLock
    Return

ShowNumLock:
    Menu, LockKeySubmenu, ToggleCheck, Num Lock
    showNumLock := !showNumLock
    Return

ShowScrollLock:
    Menu, LockKeySubmenu, ToggleCheck, Scroll Lock
    showScrollLock := !showScrollLock
    Return

ShowFunctionMedia:
    Menu, LockKeySubmenu, ToggleCheck, Funcion/Media Keys Toggle
    showFunctionMedia := !showFunctionMedia
    Return

ShowTooltips:
    if (showTooltips) {
        Menu, Tray, Rename, Hide Tooltips, Show Tooltips
        Menu, Tray, Icon, resources\shell32dll-244-x.ico
    }
    else {
        Menu, Tray, Rename, Show Tooltips, Hide Tooltips
        Menu, Tray, Icon, shell32.dll, 244
    }
    showTooltips := !showTooltips
    Return

Bin2Hex(addr,len) {
    Static fun, ptr 
    If (fun = "") {
        If A_IsUnicode
            If (A_PtrSize = 8)
                h=4533c94c8bd14585c07e63458bd86690440fb60248ffc2418bc9410fb6c0c0e8043c090fb6c00f97c14180e00f66f7d96683e1076603c8410fb6c06683c1304180f8096641890a418bc90f97c166f7d94983c2046683e1076603c86683c13049ffcb6641894afe75a76645890ac366448909c3
            Else h=558B6C241085ED7E5F568B74240C578B7C24148A078AC8C0E90447BA090000003AD11BD2F7DA66F7DA0FB6C96683E2076603D16683C230668916240FB2093AD01BC9F7D966F7D96683E1070FB6D06603CA6683C13066894E0283C6044D75B433C05F6689065E5DC38B54240833C966890A5DC3
        Else h=558B6C241085ED7E45568B74240C578B7C24148A078AC8C0E9044780F9090F97C2F6DA80E20702D1240F80C2303C090F97C1F6D980E10702C880C1308816884E0183C6024D75CC5FC606005E5DC38B542408C602005DC3
        VarSetCapacity(fun, StrLen(h) // 2)
        Loop % StrLen(h) // 2
            NumPut("0x" . SubStr(h, 2 * A_Index - 1, 2), fun, A_Index - 1, "Char")
        ptr := A_PtrSize ? "Ptr" : "UInt"
        DllCall("VirtualProtect", ptr, &fun, ptr, VarSetCapacity(fun), "UInt", 0x40, "UInt*", 0)
    }
    VarSetCapacity(hex, A_IsUnicode ? 4 * len + 2 : 2 * len + 1)
    DllCall(&fun, ptr, &hex, ptr, addr, "UInt", len, "CDecl")
    VarSetCapacity(hex, -1) ; update StrLen
    Return hex
}