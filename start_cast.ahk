#NoEnv
#SingleInstance, Force
DetectHiddenWindows, On
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%
winpid := ProcessExist("Cast.exe")
if (winpid){
    SendMessage, 0x1001, 1, , , % "ahk_pid " . winpid
    WinGet, winList, List, ahk_exe Cast.exe
    Loop %winList%
    {
        winget, winpid, PID, % "ahk_id " winList%a_index%
        SendMessage, 0x1001, 1, , , % "ahk_pid " . winpid
    }
    retries:=5
    while(ProcessExist("Cast.exe") && retries>0)
    {
        Sleep, 1000
        retries:=retries-1
    }
}
if FileExist(A_ScriptDir . "/cast.exe")
{
    Run, Cast.exe, %A_ScriptDir%
}
else
{
    Run, C:\Users\NisimHurst\Utilities\Autohotkey\chromecast\Cast.exe
}
return

ProcessExist(Name){
	Process,Exist,%Name%
	return Errorlevel
}

^Esc::
ExitApp
return
