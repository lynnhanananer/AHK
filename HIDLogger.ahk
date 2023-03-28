#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

#Include, AHKHID-master\examples\AHKHID.ahk

;Create GUI to receive messages
Gui, +LastFound
hGui := WinExist()

;Intercept WM_INPUT messages
WM_INPUT := 0xFF
OnMessage(WM_INPUT, "InputMsg", 10)

AHKHID_UseConstants()
AHKHID_AddRegister(6)
AHKHID_AddRegister(65280, 1, hGui, RIDEV_INPUTSINK)
AHKHID_AddRegister(65280, 2, hGui, RIDEV_INPUTSINK)
AHKHID_AddRegister(65280, 136, hGui, RIDEV_INPUTSINK)
AHKHID_AddRegister(65280, 161, hGui, RIDEV_INPUTSINK)
AHKHID_AddRegister(12, 1, hGui, RIDEV_INPUTSINK)
AHKHID_AddRegister(65280, 4, hGui, RIDEV_INPUTSINK)

AHKHID_Register()

; object with hex to binary conversions
hexToBin := {0: "0000", 1: "0001", 2: "0010", 3: "0011", 4: "0100", 5: "0101", 6: "0110", 7: "0111", 8: "1000", 9: "1001", A: "1010", B: "1011", C: "1100", D: "1101", E: "1110", F: "1111"}

InputMsg(wParam, lParam) {
    Local devh, hidData, sLabel, usagePage, usage, hexData, hexDataString, binaryDataString
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
            usagePage := AHKHID_GetDevInfo(devh, DI_HID_USAGEPAGE, True)
            usage := AHKHID_GetDevInfo(devh, DI_HID_USAGE, True)
            hexData := Bin2Hex(&uData, hidData)

            ; get the first 22 characters of the hexData
            hexDataString := SubStr(hexData, 1, 22)

            ; loop through the hex data string and convert to binary
            binaryDataString := ""
            Loop, Parse, hexDataString 
            {
                binaryDataString .= hexToBin[A_LoopField] . " "
            }


            FormatTime, currentTime, A_Now, yyyyMMdd HH:mm:ss
            FileAppend % currentTime . " " . A_MSec . ", " . "UsagePage: " . usagePage . ", Usage: " . usage . ", Hex Data: " . hexDataString . ", Binary Data: " binaryDataString . ", Origin: HIDLogitechHotkeys`n", device_log.txt
        }
        Else {
            usagePage := AHKHID_GetDevInfo(devh, DI_HID_USAGEPAGE, True)
            usage := AHKHID_GetDevInfo(devh, DI_HID_USAGE, True)
            FormatTime, currentTime, A_Now, yyyyMMdd HH:mm:ss
            FileAppend % currentTime . " " . A_MSec . ", " . "UsagePage: " . usagePage . ", Usage: " . usage . ", Data: " . "Error getting data" . ", Origin: HIDLogitechHotkeys`n", device_log.txt
        }
    }
    Return
}

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