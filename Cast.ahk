#NoEnv
#SingleInstance Off
#Persistent

SetBatchLines, -1
SetTitleMatchMode 2
DetectHiddenWindows, On

Menu, Tray, NoStandard
Menu, Tray, Add, &Mostrar Chrome, mwt_Restore
Menu, Tray, Add, &Ocultar Chrome, mwt_Hide
Menu, Tray, Add, &Salir, mwt_Exit

WinGet, currentDocumentId, ID, A
if((currentDocumentId==WinActive("ahk_class Progman"))||(currentDocumentId==WinActive("ahk_class WorkerW")))
{
    currentDocumentId:=0
}

castName:="SM-G930F-5"
IniRead, castName, %A_ScriptDir%/Cast.ini, Settings, castName,% castName
IniWrite, %castName%, %A_ScriptDir%/Cast.ini, Settings, castName

OnExit("ExitFunc", -1)
; OnExit, ExitApplication
Run, powershell -command .\bluetooth.ps1 -BluetoothStatus On, %A_ScriptDir%, Hide
IniRead, deviceName, %A_ScriptDir%/Cast.ini, Settings, deviceName,% deviceName
Sleep, 500
BluetoothState(deviceName, 0)
Sleep, 500
GoSub, OpenChromecast

WinGet, winList, List, ahk_exe Cast.exe
Loop %winList%
{
    winget, winpid, PID, % "ahk_id " winList%a_index%
    SendMessage, 0x1001, 1, , , % "ahk_pid " . winpid
}
OnMessage(0x1001,"ReceiveMessage")

#include chrome.ahk

url1 := "https://www.google.com/"

; --- Create a new Chrome instance ---
; winwait, - Google Chrome
IniRead, ChromeDataDirectory, %A_ScriptDir%/Cast.ini, Settings, ChromeDataDirectory,% ChromeDataDirectory
ChromeInst := new Chrome(ChromeDataDirectory,,,"C:\Program Files\Google\Chrome\Application\chrome.exe",,"Min")
winwait, % "ahk_pid " . ChromeInst.PID
pages := ChromeInst.GetPageList()
; msgbox, % pages.Length()
if (pages.Length()>1){
    Page1 := ChromeInst.GetPage( )
    Page1.Call("Cast.disable")
    winkill, % "ahk_pid " . ChromeInst.PID
    ChromeInst.Kill()
    ChromeInst_PID := GetPIDByCommandLine("--remote-debugging-port=" ChromeInst.DebugPort)
    Process, Close, % ChromeInst_PID
    Sleep, 1000
    ChromeInst := new Chrome(ChromeDataDirectory,,,"C:\Program Files\Google\Chrome\Application\chrome.exe",,"Min")
    winwait, % "ahk_pid " . ChromeInst.PID
}

; --- Connect to the page ---
Page1 := ChromeInst.GetPage( )
ChromeInst_PID := GetPIDByCommandLine("--remote-debugging-port=" ChromeInst.DebugPort)
if(ChromeInst_PID){
    SetTimer, MonitorChrome, 2000
}
Page1.Call("Page.navigate", {"url": url1})
Page1.WaitForLoad()
Page1.Call("Cast.enable")

error:=1
Loop 2 {
    try {
        Page1.Call("Cast.stopCasting", { sinkName: castName})
        Sleep, 500
    } catch e {
        ; MsgBox, 16,, % "Exception thrown!`n`nwhat: " e.what "`nfile: " e.file
        ; . "`nline: " e.line "`nmessage: " e.message "`nextra: " e.extra
    }
}
retries:=20
while (error)
{
    retries:=retries-1
    if (retries<=0){
        Run, % A_ScriptDir . "/start_cast.exe"
        GoSub, ExitApplication2
    }
    try {
        Sleep, 500 ; importante
        Page1.Call("Cast.startDesktopMirroring", { sinkName: castName})
        error:=0
    } catch e {
        ; MsgBox, 16,, % "Exception thrown!`n`nwhat: " e.what "`nfile: " e.file
        ; . "`nline: " e.line "`nmessage: " e.message "`nextra: " e.extra
        Sleep, 500
        ; Tooltip, % e . A_TickCount
    }
}
WinHide, % "ahk_pid " . ChromeInst.PID
WinGet, winList, List, % "ahk_pid " . ChromeInst.PID
Loop %winList%
{
    WinHide, % "ahk_id " winList%a_index%
}
title:=""
if (currentDocumentId)
{
    WinSet, Transparent, 255, % "ahk_id " . currentDocumentId
    WinSet, ExStyle, -0x20, % "ahk_id " . currentDocumentId ; DISABLE CLICK THROUGH
    WinSet, Style, -0x8000000, % "ahk_id " . currentDocumentId ; UNSINK CLICK
    WinSet, Style, +0xC40000, % "ahk_id " . currentDocumentId ; ADD CAPTIONS
    WinActivate, ahk_id %currentDocumentId%
    WinActivate, ahk_id %currentDocumentId%
    WinGetTitle, title, ahk_id %currentDocumentId%
}
ChangeBrightness(1)
if (!RegExMatch(title, "m).*Udemy.*"))
{
    SendMessage 0x112, 0xF170, 2, , Program Manager ; Monitor Off
}
KillStartCast()
return

MonitorChrome:
if(!WinExist("ahk_pid " . ChromeInst_PID)){
    Run, % A_ScriptDir . "/start_cast.exe"
    GoSub, ExitApplication2
}
return

^Esc::
GoSub, ExitApplication
return

OpenChromecast:
IniRead, APIkey, %A_ScriptDir%/Cast.ini, Settings, APIkey,% APIkey
IniRead, Device, %A_ScriptDir%/Cast.ini, Settings, Device,% Device
IniRead, cmdPrefix, %A_ScriptDir%/Cast.ini, Settings, cmdPrefix,% cmdPrefix
Var := "https://joinjoaomgcd.appspot.com/_ah/api/messaging/v1/sendPush?deviceNames=" . Device . "&text=" . cmdPrefix . "&apikey=" . APIkey
try {
    oHttp := ComObjCreate("WinHttp.Winhttprequest.5.1")
    oHttp.open("GET", Var)
    oHttp.send()
} catch e {
    Tooltip, % e.message
    SetTimer, ClearTooltip, -3000
}
return

ClearTooltip:
Tooltip
return

mwt_Restore:
WinGet, winList, List, % "ahk_pid " . ChromeInst.PID
Loop %winList%
{
    WinShow, % "ahk_id " winList%a_index%
}
ChromeInst_PID := GetPIDByCommandLine("--remote-debugging-port=" ChromeInst.DebugPort)
WinShow, % "ahk_pid " ChromeInst_PID
return

mwt_Exit:
ExitApp
return

mwt_Hide:
WinGet, winList, List, % "ahk_pid " . ChromeInst.PID
Loop %winList%
{
    WinHide, % "ahk_id " winList%a_index%
}
return

CloseChromecast:
IniRead, APIkey, %A_ScriptDir%/Cast.ini, Settings, APIkey,% APIkey
IniRead, Device, %A_ScriptDir%/Cast.ini, Settings, Device,% Device
IniRead, closeCmdPrefix, %A_ScriptDir%/Cast.ini, Settings, closeCmdPrefix,% closeCmdPrefix
Var := "https://joinjoaomgcd.appspot.com/_ah/api/messaging/v1/sendPush?deviceNames=" . Device . "&text=" . closeCmdPrefix . "&apikey=" . APIkey
try {
    oHttp := ComObjCreate("WinHttp.Winhttprequest.5.1")
    oHttp.open("GET", Var)
    oHttp.send()
} catch e {
    
}
return

CloseChromecastFunc(){
    global
    GoSub, CloseChromecast
}


ExitFunc(ExitReason, ExitCode)
{
    if(ExitReason!="Exit")
        GoSub, ExitApplication
}

ExitApplication:
ExitFunction()
ExitApp
return

ExitApplication2:
ExitFunction(0)
ExitApp
return

StopCasting:
try {
    Page1.Call("Cast.stopCasting", { sinkName: castName})
} catch e {
    
}
try {
    Page1.Call("Cast.disable")
} catch e {
    
}
try{
    SoundGet, MuteState, Master, Mute
    if (MuteState="On") {
        SoundSet, -1, Master, mute
    }
} catch e {
    
}
return

ExitFunction(executeClose=1){
    global
    ; try {
    ;     msgbox, ddd
    ;     Page1.Call("Cast.stopCasting", { sinkName: castName})
    ;     msgbox, eee
    ; } catch e {
    ;     MsgBox, 16,, % "Exception thrown!`n`nwhat: " e.what "`nfile: " e.file
    ;     . "`nline: " e.line "`nmessage: " e.message "`nextra: " e.extra
    ; }
    SetTimer, StopCasting, -1
    Sleep, 2000
    try {
        WinGet, winList, List, % "ahk_pid " . ChromeInst.PID
        Loop %winList%
        {
            WinHide, % "ahk_id " winList%a_index%
            WinClose, % "ahk_id " winList%a_index%
            WinKill, % "ahk_id " winList%a_index%
        }
    } catch e {
    }
    try {
        WinClose, % "ahk_pid " . ChromeInst.PID
        WinKill, % "ahk_pid " . ChromeInst.PID
    } catch e {
    }
    try {
        ChromeInst.Kill()
    } catch e {
    }
    SoundGet, MuteState, Master, Mute
    if (MuteState="On") {
        SoundSet, -1, Master, mute
    }
    ChangeBrightness(100)
    BluetoothState(deviceName, 1)
    if (executeClose){
        KillStartCast()
        CloseChromecastFunc()
    }
}

KillStartCast()
{
    global
    SetTimer, MonitorChrome, Off
    DetectHiddenWindows, On
    WinKill, ahk_exe start_cast.exe
    Process,Close,start_cast.exe
    Run, taskkill /f /im start_cast.exe, , Hide
}

ReceiveMessage(Message) {
    if Message = 1
    {
        SetTimer, ExitApplication2, -1
    }
}

GetPIDByCommandLine(CommandLine) {
	for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process where CommandLine like '%" CommandLine "%'")
		return process.ProcessId
    return 0
}

; ===============================================================================================================================
Class Brightness
{
    Get()                                                                         ; http://msdn.com/library/dd316946(vs.85,en-us)
    {
        VarSetCapacity(buf, 1536, 0)
        DllCall("gdi32.dll\GetDeviceGammaRamp", "Ptr", hDC := DllCall("user32.dll\GetDC", "Ptr", 0, "Ptr"), "Ptr", &buf)
        CLR := {}
        CLR.Red   := NumGet(buf,        2, "UShort") - 128
        CLR.Green := NumGet(buf,  512 + 2, "UShort") - 128
        CLR.Blue  := NumGet(buf, 1024 + 2, "UShort") - 128
        return CLR, DllCall("user32.dll\ReleaseDC", "Ptr", 0, "Ptr", hDC)
    }

    Set(ByRef red := 128, ByRef green := 128, ByRef blue := 128)                  ; http://msdn.com/library/dd372194(vs.85,en-us)
    {
        loop % VarSetCapacity(buf, 1536, 0) / 6
        {
            NumPut((r := (red   + 128) * (A_Index - 1)) > 65535 ? 65535 : r, buf,        2 * (A_Index - 1), "UShort")
            NumPut((g := (green + 128) * (A_Index - 1)) > 65535 ? 65535 : g, buf,  512 + 2 * (A_Index - 1), "UShort")
            NumPut((b := (blue  + 128) * (A_Index - 1)) > 65535 ? 65535 : b, buf, 1024 + 2 * (A_Index - 1), "UShort")
        }
        ret := DllCall("gdi32.dll\SetDeviceGammaRamp", "Ptr", hDC := DllCall("user32.dll\GetDC", "Ptr", 0, "Ptr"), "Ptr", &buf)
        return ret, DllCall("user32.dll\ReleaseDC", "Ptr", 0, "Ptr", hDC)
    }
}

ChangeBrightness( ByRef brightness := 50, timeout = 1 )
{
	if ( brightness >= 0 && brightness <= 100 )
	{
		For property in ComObjGet( "winmgmts:\\.\root\WMI" ).ExecQuery( "SELECT * FROM WmiMonitorBrightnessMethods" )
			property.WmiSetBrightness( timeout, brightness )	
	}
 	else if ( brightness > 100 )
 	{
 		brightness := 100
 	}
 	else if ( brightness < 0 )
 	{
 		brightness := 0
 	}
}

GetCurrentBrightNess()
{
	For property in ComObjGet( "winmgmts:\\.\root\WMI" ).ExecQuery( "SELECT * FROM WmiMonitorBrightness" )
		currentBrightness := property.CurrentBrightness	

	return currentBrightness
}
; ===============================================================================================================================

BluetoothState(deviceName, state=0){
    DllCall("LoadLibrary", "str", "Bthprops.cpl", "ptr")
    VarSetCapacity(BLUETOOTH_DEVICE_SEARCH_PARAMS, 24+A_PtrSize*2, 0)
    NumPut(24+A_PtrSize*2, BLUETOOTH_DEVICE_SEARCH_PARAMS, 0, "uint")
    NumPut(1, BLUETOOTH_DEVICE_SEARCH_PARAMS, 4, "uint") ; fReturnAuthenticated
    VarSetCapacity(BLUETOOTH_DEVICE_INFO, 560, 0)
    NumPut(560, BLUETOOTH_DEVICE_INFO, 0, "uint")
    loop
    {
       If (A_Index = 1)
       {
          foundedDevice := DllCall("Bthprops.cpl\BluetoothFindFirstDevice", "ptr", &BLUETOOTH_DEVICE_SEARCH_PARAMS, "ptr", &BLUETOOTH_DEVICE_INFO)
          if !foundedDevice
          {
             ; msgbox "No bluetooth radios found"
             return
          }
       }
       else
       {
          if !DllCall("Bthprops.cpl\BluetoothFindNextDevice", "ptr", foundedDevice, "ptr", &BLUETOOTH_DEVICE_INFO)
          {
             ; msgbox "Device not found"
             break
          }
       }
       if (StrGet(&BLUETOOTH_DEVICE_INFO+64) = deviceName)
       {
          ; msgbox, aaa
          VarSetCapacity(Handsfree, 16)
          DllCall("ole32\CLSIDFromString", "wstr", "{0000111e-0000-1000-8000-00805f9b34fb}", "ptr", &Handsfree) ; https://www.bluetooth.com/specifications/assigned-numbers/service-discovery/
          VarSetCapacity(AudioSink, 16)
          DllCall("ole32\CLSIDFromString", "wstr", "{0000110b-0000-1000-8000-00805f9b34fb}", "ptr", &AudioSink)
          VarSetCapacity(GenAudServ, 16)
          DllCall("ole32\CLSIDFromString", "wstr", "{00001203-0000-1000-8000-00805F9B34FB}", "ptr", &GenAudServ)
          VarSetCapacity(HdstServ, 16)
          DllCall("ole32\CLSIDFromString", "wstr", "{00001108-0000-1000-8000-00805F9B34FB}", "ptr", &HdstServ)
          VarSetCapacity(AVRCTarget, 16)
          DllCall("ole32\CLSIDFromString", "wstr", "{0000110C-0000-1000-8000-00805F9B34FB}", "ptr", &AVRCTarget)
          VarSetCapacity(AVRC, 16)
          DllCall("ole32\CLSIDFromString", "wstr", "{0000110E-0000-1000-8000-00805F9B34FB}", "ptr", &AVRC)
          VarSetCapacity(AVRCController, 16)
          DllCall("ole32\CLSIDFromString", "wstr", "{0000110F-0000-1000-8000-00805F9B34FB}", "ptr", &AVRCController)
          VarSetCapacity(PnP, 16)
          DllCall("ole32\CLSIDFromString", "wstr", "{00001200-0000-1000-8000-00805F9B34FB}", "ptr", &PnP)
 
          hr1 := DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &Handsfree, "int", state) ; voice
          hr2 := DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &AudioSink, "int", state) ; music
          ;hr3 := DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &GenAudServ, "int", 0) ; music
          hr4 := DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &HdstServ, "int", state) ; music
          hr5 := DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &AVRCTarget, "int", state) ; music
          hr6 := DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &AVRC, "int", state) ; music
          ;hr7 := DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &AVRCController, "int", 0) ; music
          ;hr8 := DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &PnP, "int", 0) ; music
 
          if (hr1 = 0) and (hr2 = 0) and (hr4 = 0) and (hr5 = 0) and (hr6 = 0){
             ; MsgBox, "Break"
             break
          }
       }
    }
    DllCall("Bthprops.cpl\BluetoothFindDeviceClose", "ptr", foundedDevice)
 }
