#Persistent
#NoEnv
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
#Include Lib\Gdip.ahk
#Include Lib\AHK-ViGEm-Bus.ahk
#Include Lib\__utility__.ahk
#Include Lib\__controller_functions__.ahk

hModule := DllCall("LoadLibrary", "Str", A_LineFile "\..\Lib\SuperSleep.dll", "Ptr")
SuperSleep := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", A_LineFile "\..\Lib\SuperSleep.dll", "Ptr"), "AStr", "super_sleep", "Ptr")

ListLines Off
Process, Priority, , A
SetBatchLines, -1
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SendMode Input

SetWorkingDir %A_ScriptDir%
DetectHiddenWindows, On
#Persistent

Global script_start := A_TickCount
Global remote_play_offsetY := 71
Global racecounter := 0
Global resetcounter := 0
Global color_pitstop1 := 0xFFFFFF
Global color_restart1 := 0x6D5223
Global color_racestart := 0x01FF52
Global hairpin_delay := 0
Global PitstopTimings := 0
Global TelegramBotToken  := ""
Global TelegramChatID := ""
Global location := ""
Global TokyoLapCount := 1
Global PitstopTimingsArray :=
Global DynTurnDelay := 0
Global SaveResetClip := 0
Global SetEnd := 0
SetFormat, integerfast, d
ps_win_width := 640
ps_win_height := 360
IniRead, hairpin_delay, config.ini, Vars, hairpin_delay, 0
IniRead, color_pitstop1, config.ini, Vars, color_pitstop1, 0
IniRead, RaceCounterTotal, config.ini, Stats, racecountertotal, 0
IniRead, ResetCounterTotal, config.ini, Stats, resetcountertotal, 0
IniRead, TelegramBotToken, config.ini, API, TelegramBotToken, 0
IniRead, TelegramChatID, config.ini, API, TelegramChatID, 0
IniRead, PitstopTimings, config.ini, Vars, PitStopTimings0, 0
StringSplit, PitstopTimingsArray, PitstopTimings, `,

IniRead, DynTurnDelay, config.ini, Vars, DynTurnDelay, 0
IniRead, SaveResetClip, config.ini, Vars, SaveResetClip, 0
IniRead, color_restart1, config.ini, Vars, color_restart1, 0
IniRead, color_racestart, config.ini, Vars, color_racestart, 0

SetFormat, FloatFast, 0.2
creditcountertotal := 825000*racecountertotal/1000000
StringSplit, PitstopTimingsArray, PitstopTimings, `,

Global controller := new ViGEmDS4()
controller.SubscribeFeedback(Func("OnFeedback"))
OnFeedback(largeMotor, smallMotor, lightbarColor){
}

;- GUI 1 (MAIN) -------------------------------------------------------------------------------------------------
Icon = %A_ScriptDir%\Assets\GT7_Tokyo.ico
Menu, Tray, Icon, %Icon%
Gui, -Caption
Gui, Add, Picture, x0 y0 w650 h207 , %A_ScriptDir%\Assets\tokyo_gui.png
Gui, Add, Button, x222 y80 w300 h80 default gButtonStart, START
Gui, Add, Edit, x530 y80 w101 h22 +readonly
Gui, Add, UpDown, vSetEndUD Range0-200, %SetEnd%
Gui, Add, Button, x530 y110 w101 h50 vSetEndButton gSetEnd +readonly, End after ∞ wins
Gui, Add, Progress, x0 y54 w641 h12 RaceProgress vRaceProgress -Smooth, 0
Gui, Font, S8 CDefault Bold, Verdana
Gui, Add, Text, x440 y3 w160 h20 RaceCounterTotal +BackgroundTrans, // ALL TIME
Gui, Font, ,
Gui, Add, Text, x440 y23 w160 h20 RaceCounterTotal vracecountertotal +BackgroundTrans, Races completed: %racecountertotal%
Gui, Add, Text, x440 y38 w160 h20 ResetCounterTotal vresetcountertotal +BackgroundTrans, Races failed: %resetcountertotal%
Gui, Add, Text, x550 y38 w160 h20 CreditCounterTotal vcreditcountertotal +BackgroundTrans, Credits: ~%creditcountertotal% M
Gui, Font, S8 CDefault Bold, Verdana
Gui, Add, Text, x220 y3 w300 h20 RaceSession vracesession +BackgroundTrans, // SESSION
Gui, Font, ,
Gui, Add, Text, x220 y23 w160 h20 RaceCounterSession vracecountersession +BackgroundTrans, Races completed: 0
Gui, Add, Text, x220 y38 w160 h20 ResetCounterSession vresetcountersession +BackgroundTrans, Races failed: 0
Gui, Add, Text, x330 y23 w160 h20 CreditCounterSession vcreditcountersession +BackgroundTrans, Credits: 0
Gui, Add, Text, x330 y38 w160 h20 CreditAVG vcreditavg +BackgroundTrans, Avg./h: 0
Gui, Add, Text, x10 y38 w150 h20 CounterLap vcurrentlap +BackgroundTrans, Current Lap: 0/12
Gui, Add, Text, x10 y23 w220 h20 CurrentLoop vcurrentloop +BackgroundTrans, Current Location: -
Gui, Add, Button, x222 y170 w300 h20 default gGUIReset, Reset
Gui, Add, Button, x531 y170 w101 h20 default gGUIClose, Exit
Gui, Add, Button, x12 y80 w200 h20 default gRaceSettingsWindow, Settings: Race
Gui, Add, Button, x12 y110 w200 h20 default gMachineSettingsWindow, Settings: Machine/Setup
Gui, Add, Button, x12 y140 w200 h20 default gNotificationsWindow, Settings: Notifications/API
Gui, Add, Button, x12 y170 w200 h20 default gDocumentationWindow, Documentation/Ingame Settings
Gui, Font, S8 CDefault Bold, Verdana
Gui, Add, Text, x10 y3 w620 h20 +BackgroundTrans, // TOKYO CONTROL CENTER
Gui, Add, Statusbar, -Theme Backgroundeeeeee ;#eeeeee, no typo
SB_SetParts(80,270,190)
SB_SetText(" Tokyo X ",1)
SB_SetText(" by problemz.",4)
Gui, Show, x8 y532 h225 w640, GT7 Tokyo // by problemz
guicontrol,, CurrentLoop, Press START, go go!
;- GUI 2 (MACHINE/SETUP) ----------------------------------------------------------------------------------------
;Gui, 2: Add, Picture, x0 y0 w650 h500 , Assets\tokyo_gui.png
Gui, 2: Add, Groupbox, x10 y5 w490 h100, Hairpin Settings
Gui, 2: Add, Text, xp+10 yp+20 w200 h20 +BackgroundTrans , Turn Delay:
Gui, 2: Add, Edit, xp+65 yp-3 w60 vtxthairpindelay gtextchanged, %hairpin_delay%
Gui, 2: Add, Text, xp+65 yp+3 w200 h20 +BackgroundTrans , (ms)
Gui, 2: Add, Slider, x180 yp-5 w260 h25 vsliderhairpindelay  Range0-800 Thick20 +ToolTip TickInterval50 gSliderMove,%hairpin_delay%
Gui, 2: Add, Text, x20 y60 w420 h40 vdeschairpin +BackgroundTrans , Wait %hairpin_delay% ms to turn right after detection: The lower the value, the faster it will turn right.
Gui, 2: Add, Checkbox, x20 y85 w450 vDynTurnDelay +BackgroundTrans Checkbox  Checked%DynTurnDelay%, Dynamic hairpin turn delays (caluculated by time/speed before turn for optimal turns)
Gui, 2: Add, Button, x510 y10 w120 h95 +BackgroundTrans gSaveToIni, Save all settings

Gui, 2: Add, Groupbox, x10 y110 w300 h150, Set detection colors
Gui, 2: Add, Button, xp+10 yp+18 w120 h30 gPit1Color, Grab: Pit stop color
Gui, 2: Font, S40 CDefault, Verdana
Gui, 2: Font, c%color_pitstop1%
Gui, 2: Add, Text, xp+130 yp-24  vcurrentpit1 gcurrentpit1 +BackgroundTrans, ▬
Gui, 2: Font, ,
Gui, 2: Font, S20 CDefault, Verdana
Gui, 2: Add, Text, xp+55 yp+22 +BackgroundTrans, «
Gui, 2: Font, ,
Gui, 2: Font, S10 CDefault, Verdana
Gui, 2: Add, Text, xp+25 yp+10 w200 vcurrentpit2 +BackgroundTrans, %color_pitstop1%
Gui, 2: Font, ,

Gui, 2: Add, Button, x20 yp+32 w120 h30 gRestartColor, Grab: Restart color
Gui, 2: Font, S40 CDefault, Verdana
Gui, 2: Font, c%color_restart1%
Gui, 2: Add, Text, xp+130 yp-24  vcurrentrestart1 gcurrentrestart1 +BackgroundTrans, ▬
Gui, 2: Font, ,
Gui, 2: Font, S20 CDefault, Verdana
Gui, 2: Add, Text, xp+55 yp+22 +BackgroundTrans, «
Gui, 2: Font, ,
Gui, 2: Font, S10 CDefault, Verdana
Gui, 2: Add, Text, xp+25 yp+10  w200 vcurrentrestart2 +BackgroundTrans, %color_restart1%
Gui, 2: Font, ,


Gui, 2: Add, Button, x20 yp+32 w120 h30 gRaceStartColor, Grab: Race Start color
Gui, 2: Font, S40 CDefault, Verdana
Gui, 2: Font, c%color_racestart%
Gui, 2: Add, Text, xp+130 yp-24  vcurrentracestart1 gcurrentracestart1 +BackgroundTrans, ▬
Gui, 2: Font, ,
Gui, 2: Font, S20 CDefault, Verdana
Gui, 2: Add, Text, xp+55 yp+22 +BackgroundTrans, «
Gui, 2: Font, ,
Gui, 2: Font, S10 CDefault, Verdana
Gui, 2: Add, Text, xp+25 yp+10  w220 vcurrentracestart2 +BackgroundTrans, %color_racestart%
Gui, 2: Font, ,





Gui, 2: Font, S7 CDefault, Verdana
Gui, 2: Add, Text, x20 yp+28  w280 +BackgroundTrans, Info: Double-click on color field to change manually.
Gui, 2: Font, ,
Gui, 2: Add, Groupbox, x320 y110 w310 h150, Other features
Gui, 2: Add, Checkbox, xp+10 yp+20 w290 vSaveResetClip +BackgroundTrans Checkbox Checked%SaveResetClip%, Experimental: Save clip (last 3 minutes) after a reset.
	
;- GUI 4 (RACE SETTINGS) ----------------------------------------------------------------------------------------
;Gui, 4: Add, Picture, x0 y0 w650 h450 , Assets\tokyo_gui.png
Gui, 4: Font, S8 CDefault Bold, Verdana
Gui, 4: Add, Text, x220 y20 w200 h20 vFightme +gFightMe +BackgroundTrans , ლ(｀ー´ლ)
Gui, 4: Add, Text, x30 y10 w200 h50 +BackgroundTrans vPitstopText , Pit stop wait timers in ms`n(Read-only):
Gui, 4: Font, ,
Gui, 4: Add, Text, xp yp+40 w100 h20 +BackgroundTrans , Lap 1:
Gui, 4: Add, Edit, +ReadOnly xp+40 yp-3 w50 vNewPitstopTimingsArray1, %PitstopTimingsArray1%
Gui, 4: Add, Text, xp+60 yp+3 w100 h20 +BackgroundTrans , Lap 2:
Gui, 4: Add, Edit, +ReadOnly xp+40 yp-3 w50 vNewPitstopTimingsArray2, %PitstopTimingsArray2%
Gui, 4: Add, Text, xp+60 yp+3 w100 h20 +BackgroundTrans , Lap 3:
Gui, 4: Add, Edit, +ReadOnly xp+40 yp-3 w50 vNewPitstopTimingsArray3, %PitstopTimingsArray3%
Gui, 4: Add, Text, xp+60 yp+3 w100 h20 +BackgroundTrans , Lap 4:
Gui, 4: Add, Edit, +ReadOnly xp+40 yp-3 w50 vNewPitstopTimingsArray4, %PitstopTimingsArray4%
Gui, 4: Add, Text, xp+60 yp+3 w100 h20 +BackgroundTrans , Lap 5:
Gui, 4: Add, Edit, +ReadOnly xp+40 yp-3 w50 vNewPitstopTimingsArray5, %PitstopTimingsArray5%
Gui, 4: Add, Text, xp+60 yp+3 w100 h20 +BackgroundTrans , Lap 6:
Gui, 4: Add, Edit, +ReadOnly xp+40 yp-3 w50 vNewPitstopTimingsArray6, %PitstopTimingsArray6%
Gui, 4: Add, Text, xp-540 yp+30 w100 h20 +BackgroundTrans , Lap 7:
Gui, 4: Add, Edit, +ReadOnly xp+40 yp-3 w50 vNewPitstopTimingsArray7, %PitstopTimingsArray7%
Gui, 4: Add, Text, xp+60 yp+3 w100 h20 +BackgroundTrans , Lap 8:
Gui, 4: Add, Edit, +ReadOnly xp+40 yp-3 w50 vNewPitstopTimingsArray8, %PitstopTimingsArray8%
Gui, 4: Add, Text, xp+60 yp+3 w100 h20 +BackgroundTrans , Lap 9:
Gui, 4: Add, Edit, +ReadOnly xp+40 yp-3 w50 vNewPitstopTimingsArray9, %PitstopTimingsArray9%
Gui, 4: Add, Text, xp+60 yp+3 w100 h20 +BackgroundTrans , Lap 10:
Gui, 4: Add, Edit, +ReadOnly xp+40 yp-3 w50 vNewPitstopTimingsArray10, %PitstopTimingsArray10%
Gui, 4: Add, Text, xp+60 yp+3 w100 h20 +BackgroundTrans , Lap 11:
Gui, 4: Add, Edit, +ReadOnly xp+40 yp-3 w50 vNewPitstopTimingsArray11, %PitstopTimingsArray11%
Gui, 4: Add, Text, xp+60 yp+3 w100 h20 +BackgroundTrans , Lap 12:
Gui, 4: Add, Edit, +ReadOnly xp+40 yp-3 w50 vNewPitstopTimingsArray12, %PitstopTimingsArray12%
Gui, 4: Add, Button, +hidden xp-540 yp+30 w590 h25 vNewPitstopTimingsButton gSaveNewTimings, Save pit stop timings
Gui, 4: Font, S8 CDefault Bold, Verdana
Gui, 4: Add, Text, x370 y10 w120 h20 +BackgroundTrans , Select Race pace:
Gui, 4: Font, ,
Gui, 4: Add, DropDownList, xp+125 yp-3 w125 vRacePaceChoice gRacePaceChoice, Select to change||Safe (slower)|Risky (faster)
Gui, 4: Add, Button, +hidden x230 yp+10 w120 h25 vLoadDevTimings gLoadDevTimings, Load last dev timings

;- GUI 5 (NOTIFICATIONS/API) ------------------------------------------------------------------------------------
;Gui, 5: Add, Picture, x0 y0 w650 h400 , Assets\tokyo_gui.png
Gui, 5: Add, Text, x10 y14 w205 h20 +BackgroundTrans , Telegram Bot Token:
Gui, 5: Add, Edit, x116 y11 w400 vTelegramBotToken Password, %TelegramBotToken%
Gui, 5: Add, Text, x10 y44 w205 h20 +BackgroundTrans , Telegram Chat ID:
Gui, 5: Add, Edit, x116 y41 w400 vTelegramChatID Password, %TelegramChatID%
Gui, 5: Add, Button, x530 y11 w100 h51 +BackgroundTrans gSaveToIni, Save
Return

MachineSettingsWindow:

if (GetKeyState("LShift", "P") AND GetKeyState("LAlt", "P")){
	if (picker_active)
	{
	SetTimer, Refresh, off
	ToolTip
	picker_active := false
	}
	else{
		picker_active := true
	goto, MouseColor
	}
}
	else{
	Gui, 2: Show, x6 y757 w639 h265, Settings: Machine/Setup 
	}
return

RaceSettingsWindow:
  Gui, 4: Show, x6 y757 w639 h140, Settings: Race
return

NotificationsWindow:
  Gui, 5: Show, x6 y757 w639 h70, Settings: Notifications/API
return

DocumentationWindow:
url := "Assets/doc.html"

; a temporary file, running directory must be writeable
outputFile := "a$$$$$$.html"
if (FileExist(outputFile))
    FileDelete, %outputFile%

FileAppend,
(
<html>
<body>
<script>
document.location.href="
),%outputFile%
FileAppend,%url%,%outputFile%
FileAppend,
(
"
</script>
</body>
</html>
),%outputFile%

cmdToRun := "cmd /c " . outputFile
run, %cmdToRun%
return
SaveToIni:
  Gui, Submit, Hide
  IniWrite, %txthairpindelay%, config.ini,Vars, hairpin_delay
  IniWrite, %TelegramBotToken%, config.ini,API, TelegramBotToken
  IniWrite, %TelegramChatID%, config.ini,API, TelegramChatID
  GuiControlGet, DynTurnDelay,,DynTurnDelay
  IniWrite, %DynTurnDelay%, config.ini,VARS, DynTurnDelay
  GuiControlGet, SaveResetClip,,SaveResetClip
  IniWrite, %SaveResetClip%, config.ini,VARS, SaveResetClip
  IniRead, PitstopTimings, config.ini, Vars, PitStopTimings0, 0
  StringSplit, PitstopTimingsArray, PitstopTimings, `,
  IniWrite, %color_pitstop1%, config.ini,Vars, color_pitstop1
  IniWrite, %color_restart1%, config.ini,Vars, color_restart1
  IniWrite, %color_racestart%, config.ini,Vars, color_racestart
return

SaveNewTimings:
	MsgBox, 52, Save new pit stop timings?, Save new »Pit stop timings« ?
	IfMsgBox Yes
	{
	Gui, Submit, Hide
	NewPitStopTimings = %NewPitstopTimingsArray1%`,%NewPitstopTimingsArray2%`,%NewPitstopTimingsArray3%`,%NewPitstopTimingsArray4%`,%NewPitstopTimingsArray5%`,%NewPitstopTimingsArray6%`,%NewPitstopTimingsArray7%`,%NewPitstopTimingsArray8%`,%NewPitstopTimingsArray9%`,%NewPitstopTimingsArray10%`,%NewPitstopTimingsArray11%`,%NewPitstopTimingsArray12%
	IniWrite, %NewPitStopTimings%, config.ini,VARS, PitStopTimings0
	IniWrite, %NewPitStopTimings%, config.ini,VARS, PitStopTimings99
	IniRead, PitstopTimings, config.ini, Vars, PitStopTimings0, 0
	StringSplit, PitstopTimingsArray, PitstopTimings, `,
	}
return
  
SetEnd:
guiControlGet, SetEnd,, SetEndUD
if (SetEnd = 0)
guicontrol,, SetEndButton, End after ∞ wins
if (SetEnd = 1)
guicontrol,, SetEndButton, End after next win
if (SetEnd > 1)
guicontrol,, SetEndButton, End after %SetEnd% wins
return

RacePaceChoice:
Gui, Submit, NoHide
If (RacePaceChoice = "Safe (slower)")
    IniRead, PitstopTimings, config.ini, Vars, PitStopTimings1, 0
	IniWrite, %PitstopTimings%, config.ini,VARS, PitStopTimings0
	IniRead, PitstopTimings, config.ini, Vars, PitStopTimings0, 0
	StringSplit, PitstopTimingsArray, PitstopTimings, `,
	guicontrol,, NewPitstopTimingsArray1, %PitstopTimingsArray1%
    guicontrol,, NewPitstopTimingsArray2, %PitstopTimingsArray2%
    guicontrol,, NewPitstopTimingsArray3, %PitstopTimingsArray3%
    guicontrol,, NewPitstopTimingsArray4, %PitstopTimingsArray4%
    guicontrol,, NewPitstopTimingsArray5, %PitstopTimingsArray5%
    guicontrol,, NewPitstopTimingsArray6, %PitstopTimingsArray6%
    guicontrol,, NewPitstopTimingsArray7, %PitstopTimingsArray7%
    guicontrol,, NewPitstopTimingsArray8, %PitstopTimingsArray8%
    guicontrol,, NewPitstopTimingsArray9, %PitstopTimingsArray9%
    guicontrol,, NewPitstopTimingsArray10, %PitstopTimingsArray10%
    guicontrol,, NewPitstopTimingsArray11, %PitstopTimingsArray11%
    guicontrol,, NewPitstopTimingsArray12, %PitstopTimingsArray12%
	 
If (RacePaceChoice = "Risky (faster)")
    IniRead, PitstopTimings, config.ini, Vars, PitStopTimings2, 0
	IniWrite, %PitstopTimings%, config.ini,VARS, PitStopTimings0
	IniRead, PitstopTimings, config.ini, Vars, PitStopTimings0, 0
	StringSplit, PitstopTimingsArray, PitstopTimings, `,
	guicontrol,, NewPitstopTimingsArray1, %PitstopTimingsArray1%
	guicontrol,, NewPitstopTimingsArray2, %PitstopTimingsArray2%
	guicontrol,, NewPitstopTimingsArray3, %PitstopTimingsArray3%
	guicontrol,, NewPitstopTimingsArray4, %PitstopTimingsArray4%
	guicontrol,, NewPitstopTimingsArray5, %PitstopTimingsArray5%
	guicontrol,, NewPitstopTimingsArray6, %PitstopTimingsArray6%
	guicontrol,, NewPitstopTimingsArray7, %PitstopTimingsArray7%
	guicontrol,, NewPitstopTimingsArray8, %PitstopTimingsArray8%
	guicontrol,, NewPitstopTimingsArray9, %PitstopTimingsArray9%
	guicontrol,, NewPitstopTimingsArray10, %PitstopTimingsArray10%
	guicontrol,, NewPitstopTimingsArray11, %PitstopTimingsArray11%
	guicontrol,, NewPitstopTimingsArray12, %PitstopTimingsArray12%
return

TextChanged:
 guiControlGet, txtvar,, txthairpindelay
	if (txtvar > 800)
	{
		GuiControl,, txthairpindelay, 800
	}
	
  GuiControl,, sliderhairpindelay, %txtvar%
  GuiControl,, deschairpin, Wait %txtvar% ms to turn right after detection: The lower the value, the faster it will turn right.
  return 
  
SliderMove: 
Gui, Submit, nohide
GuiControl,, txthairpindelay, %sliderhairpindelay%
GuiControl,, deschairpin, Wait %sliderhairpindelay% ms to turn right after detection: The lower the value, the faster it will turn right.
Return


Pit1Color:
	MsgBox, 52, Change Pit stop detection color?, Set new »Pit stop« color?`n(only set when in tire menu!)`n`n"Save all settings" afterwards to save new value to ini.
	IfMsgBox Yes
	{
	gosub, GrabRemotePlay
	color_pitstop1 := PixelColorSimple(199, 315+remote_play_offsetY)
	Gui, Font, 
	GuiControl, +c%color_pitstop1%, currentpit1
	gui, color
	GuiControl,, currentpit2, %color_pitstop1%
	}
return
	
currentpit1:
if (A_GuiEvent = "DoubleClick")
{
	InputBox, setpitstop1, Change Pit stop detection color , Enter color in hex (Default: 0xFFFFFF), , 250,140
	if !ErrorLevel
	color_pitstop1 := setpitstop1
    GuiControl, +c%color_pitstop1%, currentpit1
	gui, color
	GuiControl,, currentpit2, %color_pitstop1%
}
return	


RestartColor:
	MsgBox, 52, Change Restart detection color?, Set new »Race restart« color?`n(only set when top bar is shown!)`n`n"Save all settings" afterwards to save new value to ini.
	IfMsgBox Yes
	{
	gosub, GrabRemotePlay
	color_restart1 := PixelColorSimple(162, 114)
	Gui, Font, 
	GuiControl, +c%color_restart1%, currentrestart1
	gui, color
	
	GuiControl,, currentrestart2, %color_restart1%
	}
return
	
currentrestart1:
if (A_GuiEvent = "DoubleClick")
{
	InputBox, setrestart1, Change Restart detection color , Enter color in hex (Café Icon), , 250,140
	if !ErrorLevel
	color_restart1 := setrestart1
    GuiControl, +c%color_restart1%, currentrestart1
	gui, color
	GuiControl,, currentrestart2, %color_restart1%
}
return	
	



RaceStartColor:
	MsgBox, 52, Change Race Start detection color?, Set new »Race Start« color?`n(only set when you see your nitro battery!)`n`n"Save all settings" afterwards to save new value to ini.
	IfMsgBox Yes
	{
	gosub, GrabRemotePlay
	color_racestart := PixelColorSimple(182, 437)
	Gui, Font, 
	GuiControl, +c%color_racestart%, currentracestart1
	gui, color
	
	GuiControl,, currentracestart2, %color_racestart%
	}
return
	
currentracestart1:
if (A_GuiEvent = "DoubleClick")
{
	InputBox, setracestart1, Change Race Start detection color , Enter color in hex (Nitro battery), , 250,140
	if !ErrorLevel
	color_racestart := setracestart1
    GuiControl, +c%color_racestart%, currentracestart1
	gui, color
	GuiControl,, currentracestart2, %color_racestart%
}
return	

ButtonStart:
  SetTimer, UpdateTimer, 1000
  Gui, Submit, NoHide
  id := ""
  SetKeyDelay, 10
  Process, priority, , High
  gosub, GrabRemotePlay
  if (id = "")
    return
  gosub, PauseLoop
  CoordMode, Pixel, Screen
  CoordMode, ToolTip, Screen
  loop {
    Press_X()
    Race_Tokyo()
  }

PixelTuning:
  x_ratio := ps_win_width/640
  y_ratio := ps_win_height/360
return

GrabRemotePlay:
  WinGet, remotePlay_id, List, ahk_exe RemotePlay.exe
  if (remotePlay_id = 0)
  {
    MsgBox, PS4 Remote Play not found
    return
  }
  Loop, %remotePlay_id%
  {
    id := remotePlay_id%A_Index%
    WinGetTitle, title, % "ahk_id " id
    If InStr(title, "PS Remote Play")
      break
  }
    WinMove, ahk_id %id%,, 0, 0, 640, 540
  
  ControlFocus,, ahk_class %remotePlay_class%
  WinActivate, ahk_id %id%
  GetClientSize(remotePlay_id5, ps_win_width, ps_win_height)
  gosub, PixelTuning
return

FightMe:
if (A_GuiEvent = "DoubleClick")
{
    guicontrol, -readonly, NewPitstopTimingsArray1
    guicontrol, -readonly, NewPitstopTimingsArray2
    guicontrol, -readonly, NewPitstopTimingsArray3
    guicontrol, -readonly, NewPitstopTimingsArray4
    guicontrol, -readonly, NewPitstopTimingsArray5
    guicontrol, -readonly, NewPitstopTimingsArray6
    guicontrol, -readonly, NewPitstopTimingsArray7
    guicontrol, -readonly, NewPitstopTimingsArray8
    guicontrol, -readonly, NewPitstopTimingsArray9
    guicontrol, -readonly, NewPitstopTimingsArray10
    guicontrol, -readonly, NewPitstopTimingsArray11
    guicontrol, -readonly, NewPitstopTimingsArray12
    guicontrol, -hidden, NewPitstopTimingsButton
    guicontrol, -hidden, LoadDevTimings
	guicontrol,, PitstopText, Pit stop wait timers in ms`ndevmode unlocked ლ(｀ー´ლ):
	guicontrol, +hidden, FightMe
}
return

LoadDevTimings:
	IniRead, PitstopTimings, config.ini, Vars, PitStopTimings99, 0
	StringSplit, PitstopTimingsArray, PitstopTimings, `,
	guicontrol,, NewPitstopTimingsArray1, %PitstopTimingsArray1%
	guicontrol,, NewPitstopTimingsArray2, %PitstopTimingsArray2%
	guicontrol,, NewPitstopTimingsArray3, %PitstopTimingsArray3%
	guicontrol,, NewPitstopTimingsArray4, %PitstopTimingsArray4%
	guicontrol,, NewPitstopTimingsArray5, %PitstopTimingsArray5%
	guicontrol,, NewPitstopTimingsArray6, %PitstopTimingsArray6%
	guicontrol,, NewPitstopTimingsArray7, %PitstopTimingsArray7%
	guicontrol,, NewPitstopTimingsArray8, %PitstopTimingsArray8%
	guicontrol,, NewPitstopTimingsArray9, %PitstopTimingsArray9%
	guicontrol,, NewPitstopTimingsArray10, %PitstopTimingsArray10%
	guicontrol,, NewPitstopTimingsArray11, %PitstopTimingsArray11%
	guicontrol,, NewPitstopTimingsArray12, %PitstopTimingsArray12%
return

PauseLoop:
  controller.Buttons.Cross.SetState(false)
  controller.Buttons.Square.SetState(false)
  controller.Buttons.Triangle.SetState(false)
  controller.Buttons.Circle.SetState(false)
  controller.Buttons.L1.SetState(false)
  controller.Buttons.L2.SetState(false)
  controller.Axes.L2.SetState(0)
  controller.Buttons.R1.SetState(false)
  controller.Buttons.R2.SetState(false)
  controller.Axes.R2.SetState(0)
  controller.Buttons.RS.SetState(false)
  controller.Axes.RX.SetState(50)
  controller.Axes.RY.SetState(50)
  controller.Buttons.LS.SetState(false)
  controller.Axes.LX.SetState(50)
  controller.Axes.LY.SetState(50)
  controller.Dpad.SetState("None")
return

ResetRace:
	SB_SetText(" - RESET INITIATED -",2)
	guicontrol,, CurrentLoop, Something went wrong, reseting.
	controller.Axes.LX.SetState(50)
	if (SaveResetClip = 1)
	{
	FormatTime, TGTime,, MM/dd hh:mm:ss
	FileAppend, %TGTime%: Race failed - Lap %TokyoLapCount% - %location% - Clip saved.`n, log.txt
	
	if (TelegramBotToken != NULL)
	{
	url := "https://api.telegram.org/bot" TelegramBotToken "/sendMessage?text=" TGTime ": Race failed - Lap " TokyoLapCount " - " location ". Clip saved.&chat_id=" TelegramChatID
	hObject:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
	hObject.Open("GET",url)
	hObject.Send()
	}
	SB_SetText(" Saving clip (last 3 minutes)...",2)
	Sleep(500)
	PressShare()
	Sleep(1500)
	Press_Left()
	Sleep(600)
	Press_X()
	Sleep(600)
	Press_X()
	Sleep(600)
	Press_Down()
	Sleep(600)
	Press_Down()
	Sleep(600)
	Press_Down()
	Sleep(600)
	Press_X()
	Sleep(1500)
	PressShare()
	Sleep(1500)
	Press_Options()
	Sleep(600)
	Press_Right()
	Sleep(600)
	Press_X()
	}
	else {
	FormatTime, TGTime,, MM/dd hh:mm:ss
	FileAppend, %TGTime%: Race failed - Lap %TokyoLapCount% - %location%.`n, log.txt
	
	if (TelegramBotToken != NULL)
	{
	url := "https://api.telegram.org/bot" TelegramBotToken "/sendMessage?text=" TGTime ": Race failed - Lap " TokyoLapCount " - " location ". Clip saved.&chat_id=" TelegramChatID
	hObject:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
	hObject.Open("GET",url)
	hObject.Send()
	}
	SB_SetText(" Restarting race...",2)
	Sleep(500)
	Press_Options()
	Sleep(1000)
	Press_Right()
	Sleep(500)
	Press_X()
	}
	controller.Axes.LX.SetState(65)
	IniRead, ResetCounterTotal, config.ini, Stats, resetcountertotal, 0
	SetFormat, integerfast, d
	resetcounter++
	resetcountertotal++
    IniWrite, %resetcountertotal%, config.ini,Stats, ResetCounterTotal
	guicontrol,, ResetCounterTotal, Races failed: %resetcountertotal%
	guicontrol,, ResetCounterSession, Races failed: %resetcounter%
	guicontrol,, RaceProgress, 0
	Race_Tokyo()
	return


MouseHelp:
	
  coord=relative
  sleep, 1000
  CoordMode, ToolTip, %coord%
  CoordMode, Pixel, %coord%
  CoordMode, Mouse, %coord%
  CoordMode, Caret, %coord%
  CoordMode, Menu, %coord%
return

Refresh:
  MouseGetPos, x, y
  PixelGetColor, cBGR, %x%, %y%,, Alt RGB
  WinGetPos,,, w, h, A
  ToolTip,Location: %x% x %y%`nRGB: %cBGR%`nWindow Size: %w% x %h%
return

MouseColor:
  gosub, MouseHelp
  SetTimer, Refresh, 75
return

GuiClose:
  gosub, PauseLoop
ExitApp
^Esc::ExitApp

GUIReset:
if (GetKeyState("LShift", "P") AND GetKeyState("LAlt", "P")){
	MsgBox, 4,, Reset all data?	
	IfMsgBox Yes
	{
		IniWrite, 0, config.ini,Stats, RaceCounterTotal
		IniWrite, 0, config.ini,Stats, ResetCounterTotal
	}
}
Sleep(500)
gosub, PauseLoop
Reload

Race_Tokyo()
{
	IniRead, hairpin_delay, config.ini, Vars, hairpin_delay, 0
	IniRead, RaceCounterTotal, config.ini, Stats, racecountertotal, 0
	IniRead, ResetCounterTotal, config.ini, Stats, resetcountertotal, 0
	SetFormat, integerfast, d
	TokyoStart:
	;- VARIABLES -----------------------------------------------------------------------------
	SetFormat, integerfast, d
	TokyoLapCount := 1
	maxTime := 200000
	StringSplit, PitstopTimingsArray, PitstopTimings, `,
	;- COORDINATES: TURNS --------------------------------------------------------------------
	TokyoTurn1 := new TokyoTurnContainer(611, 130, 622, 140)
	TokyoTurn2 := new TokyoTurnContainer(618, 141, 601, 147)
	TokyoTurn3 := new TokyoTurnContainer(599, 150, 591, 158)
	TokyoTurn4 := new TokyoTurnContainer(589, 159, 571, 167)
	TokyoTurn5 := new TokyoTurnContainer(567, 167, 556, 161)
	TokyoTurn6 := new TokyoTurnContainer(554, 157, 543, 153)
	TokyoTurn7 := new TokyoTurnContainer(538, 152, 530, 146)
	TokyoTurn8 := new TokyoTurnContainer(530, 146, 510, 143)
	;- COORDINATES: PENALTY WARNINGS ---------------------------------------------------------
	TokyoPenWarning := new TokyoTurnContainer(360, 225, 408, 225)
	TokyoPenIndicator := new TokyoTurnContainer(366, 203)
	;- COORDINATES: HAIRPIN TURN -------------------------------------------------------------
	TokyoHairpinTurn := new TokyoTurnContainer(606, 405)
	;- COORDINATES: PENALTY WARNINGS ---------------------------------------------------------
	TokyoPen := new TokyoTurnContainer(360, 225, 408, 225)
	TokyoPenServed := new TokyoTurnContainer(366, 203)
	;- COORDINATES: HAIRPIN TURN--------------------------------------------------------------
	TokyoHairpinTurn := new TokyoTurnContainer(606, 405)
	;- MISC ----------------------------------------------------------------------------------
	TokyoPitstop := new TokyoTurnContainer(191, 387, 580, 454)
	TokyoPitstopEnter := new TokyoTurnContainer(530, 141)
	TokyoPitstopDone := new TokyoTurnContainer(57, 400)
	TokyoRestartRace := new TokyoTurnContainer(182, 437, 100, 407)
	TokyoMFD := new TokyoTurnContainer(557, 453)
	;- RACE START ----------------------------------------------------------------------------
	CheckTokyoRestartOK(TokyoRestartRace.startX, TokyoRestartRace.startY)
	Sleep(8400)
	SB_SetText(" Race started. Good Luck!",2)
	controller.Axes.LX.SetState(65)
	FormatTime, TGTime,, MM/dd hh:mm:ss
	FileAppend, %TGTime%: Race started.`n, log.txt
	if (TelegramBotToken != NULL)
	{
	ToolTip, TEST
	guicontrol,, CurrentLoop, NICHT LEER
	url := "https://api.telegram.org/bot" TelegramBotToken "/sendMessage?text=" TGTime ": Race started.&chat_id=" TelegramChatID
	hObject:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
	hObject.Open("GET",url)
	hObject.Send()
	}
	guicontrol,, CurrentLoop, Race started. Good luck!
	labellapcount := HexToDec(TokyoLapCount)
	guicontrol,, CurrentLap, Current Lap: %labellapcount%/12
	Accel_On(100)
	loop 3 {
		Press_Triangle(delay:=50)
		Sleep(200)
	}
	Sleep(800)
	controller.Axes.LX.SetState(65)
	CheckTokyoMFD(TokyoMFD.startX, TokyoMFD.startY)
;- 12 LAP LOOP ---------------------------------------------------------------------------
	loop 12 
	{
		location := "Start/Finish"
		guicontrol,, CurrentLoop, Current Location: %location%
		loopStartTime := A_TickCount
		; Turn 1
			location := "T1 Start"
			CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
			CheckTokyoTurn(TokyoTurn1.startX, TokyoTurn1.startY)
			loop 3 {
				Press_Triangle(delay:=50)
				Sleep(200)
			}
			guicontrol,, CurrentLoop, Current Location: %location%
			controller.Axes.LX.SetState(36)
			CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
			Sleep(1000)
			location := "T1 End"
			CheckTokyoTurn(TokyoTurn1.endX, TokyoTurn1.endY)
			guicontrol,, CurrentLoop, Current Location: %location%
			controller.Axes.LX.SetState(35)
			Sleep(1000)
		; Turn 2
			location := "T2 Start"
			CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
			CheckTokyoTurn(TokyoTurn2.startX, TokyoTurn2.startY)
			guicontrol,, CurrentLoop, Current Location: %location%
			controller.Axes.LX.SetState(52)
			CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
			Sleep(1000)
			location := "T2 End"
			CheckTokyoTurn(TokyoTurn2.endX, TokyoTurn2.endY)
			guicontrol,, CurrentLoop, Current Location: %location%
			controller.Axes.LX.SetState(40)
			Sleep(1000)
		; Turn 3
			location := "T3 Start"
			CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
			CheckTokyoTurn(TokyoTurn3.startX, TokyoTurn3.startY)
			guicontrol,, CurrentLoop, Current Location: %location%
			Sleep(1000)
			controller.Axes.LX.SetState(40)
			CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)		
			CheckTokyoTurn(TokyoTurn3.endX, TokyoTurn3.endY)
			guicontrol,, CurrentLoop, Current Location: %location%
			controller.Axes.LX.SetState(70)
			Sleep(1000)
		; Turn 4
			location := "T4 Start"
			Accel_On(85)
			CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
			CheckTokyoTurn(TokyoTurn4.startX, TokyoTurn4.startY)
			guicontrol,, CurrentLoop, Current Location: %location%
			Sleep(1000)
			controller.Axes.LX.SetState(68)
			CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
			CheckTokyoTurn(TokyoTurn4.endX, TokyoTurn4.endY)
			guicontrol,, CurrentLoop, Current Location: %location%
			controller.Axes.LX.SetState(60)
			Accel_On(70)
			Sleep(1000)
		; Turn 5
			location := "T5 Start"
			CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
			CheckTokyoTurn(TokyoTurn5.startX, TokyoTurn5.startY)
			guicontrol,, CurrentLoop, Current Location: %location%
			controller.Axes.LX.SetState(42)
			Sleep(1000)
			CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
			CheckTokyoTurn(TokyoTurn5.endX, TokyoTurn5.endY)
			guicontrol,, CurrentLoop, Current Location: %location%
			controller.Axes.LX.SetState(63)
			Sleep(1000)
		; Turn 6
			location := "T6 Start"
			CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
			CheckTokyoTurn(TokyoTurn6.startX, TokyoTurn6.startY)
			guicontrol,, CurrentLoop, Current Location: %location%
			controller.Axes.LX.SetState(70)
			Sleep(1000)
			Accel_on(75)
			CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
			CheckTokyoTurn(TokyoTurn6.endX, TokyoTurn6.endY)
			guicontrol,, CurrentLoop, Current Location: %location%
			controller.Axes.LX.SetState(40)
			Sleep(1000)
		; Turn 7
			location := "T7 Start"
			Accel_On(100)
			CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
			CheckTokyoTurn(TokyoTurn7.startX, TokyoTurn7.startY)
			guicontrol,, CurrentLoop, Current Location: %location%
			controller.Axes.LX.SetState(40)
			Sleep(1000)
			CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
			CheckTokyoTurn(TokyoTurn7.endX, TokyoTurn7.endY)
			guicontrol,, CurrentLoop, Current Location: %location%
			controller.Axes.LX.SetState(70)
			Sleep(1000)
		; Turn 8
			location := "T8 Start"
			CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
			CheckTokyoTurn(TokyoTurn8.startX, TokyoTurn8.startY)
			guicontrol,, CurrentLoop, Current Location: %location%
			controller.Axes.LX.SetState(65)
			Sleep(1000)
			CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
			CheckTokyoTurn(TokyoTurn8.endX, TokyoTurn8.endY)
			guicontrol,, CurrentLoop, Current Location: %location%
			controller.Axes.LX.SetState(30)
			Sleep(2000)
			Brake_on(100)
			Sleep(2200)
			Brake_off()
			Accel_On(35)
		; Penalty Warning 1
			location := "Hairpin Entrance"
			CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
			CheckTokyoPen1(TokyoPenWarning.startX, TokyoPenWarning.startY)
			guicontrol,, CurrentLoop, Current Location: %location%
			Accel_On(32)
			if (TokyoLapCount=12) { 
            Accel_On(34)    
            }
			controller.Axes.LX.SetState(40)
			Sleep(1000)
			; Hairpin Turn
			CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
			location := "Hairpin Turn"
			CheckTokyoHairpinTurn(TokyoHairpinTurn.startX, TokyoHairpinTurn.startY)
			guicontrol,, CurrentLoop, Current Location: %location%
			
			if (DynTurnDelay = 1)
			{
				if ((ThairpinS - 6000) > 0) {
				hairpin_delayn := HexToDec(hairpin_delay - 20 - ( 50 * Floor((ThairpinS - 6000)/1000)))
					If ( hairpin_delayn <0 ){
						hairpin_delayn := 0
					}
				guicontrol,, CurrentLoop, Turn delay: %hairpin_delayn% (dynamic)	
				}
				if ((ThairpinS - 5000) < 0) {
					hairpin_delayn := HexToDec(hairpin_delay + 50 + ( 20 * Floor((5000 - ThairpinS)/1000) ))
					guicontrol,, CurrentLoop, Turn delay: %hairpin_delayn% (dynamic)	
				}
				if (6000<=ThairpinS>=5000) {
					hairpin_delayn := HexToDec(hairpin_delay)
					guicontrol,, CurrentLoop, Turn delay: %hairpin_delayn% (default)
				}
			Sleep(hairpin_delayn)	
			}
			else
			{
			guicontrol,, CurrentLoop, Turn delay: %hairpin_delay% (static)
			Sleep(hairpin_delay)	
			}
			controller.Axes.LX.SetState(100)
			Sleep(200)
			Accel_Off()
			Sleep(4200)
			Accel_On(45) ;was 40
			controller.Axes.LX.SetState(60)
			Accel_Off()
			Sleep(800)
			controller.Axes.LX.SetState(40)
			Accel_On(50)
			Sleep(5000)
			controller.Axes.LX.SetState(30)
			Sleep(5500)
			Accel_On(80)
			loop 30 { ; failsafe, if we ever get a reset caused by a cone under the car
			Press_Triangle(delay:=100)
			Sleep(200)
			}
			; Penalty Warning 2
			location := "Hairpin exit"
			CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
			CheckTokyoPen2(TokyoPen.endX, TokyoPen.endY)
			guicontrol,, CurrentLoop, Current Location: %location%
			Sleep(1000)
		if (TokyoLapCount <= 11)
		{
				location := "Pit entrance"
				Accel_On(53)
				controller.Axes.LX.SetState(30)
				guicontrol,, CurrentLoop, Current Location: %location%
				CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
				CheckTokyoTurn(TokyoPitstopEnter.startX, TokyoPitstopEnter.startY)
				controller.Axes.LX.SetState(0)
				Accel_On(55)
				CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
				CheckTokyoPitstop1(TokyoPitstop.startX, TokyoPitstop.startY)
				location := "In pit"
				guicontrol,, CurrentLoop, Current Location: %location%
				controller.Axes.LX.SetState(50)
				
				if (TokyoLapCount = 1) 
				{
					SetFormat, integerfast, d
					location := "In pit: Waiting " Round(PitstopTimingsArray1/1000) " seconds."
					guicontrol,, CurrentLoop, %location%
					Sleep (PitstopTimingsArray1)
					Press_Up()
					Sleep (100)
					Press_X()
					Sleep (100)
					Press_X()
				}
				if (TokyoLapCount = 2) 
				{
					SetFormat, integerfast, d
					location := "In pit: Waiting " Round(PitstopTimingsArray2/1000) " seconds."
					guicontrol,, CurrentLoop, %location%
					Sleep (PitstopTimingsArray2)
					Press_Up()
					Sleep (100)
					Press_X()
					Sleep (100)
					Press_X()
				}
				if (TokyoLapCount = 3)
				{
					SetFormat, integerfast, d
					location := "In pit: Waiting " Round(PitstopTimingsArray3/1000) " seconds."
					guicontrol,, CurrentLoop, %location%
					Sleep (PitstopTimingsArray3)
					Press_Up()
					Sleep (100)
					Press_X()
					Sleep (100)
					Press_X()
				}
				if (TokyoLapCount = 4)
				{
					SetFormat, integerfast, d
					location := "In pit: Waiting " Round(PitstopTimingsArray4/1000) " seconds."
					guicontrol,, CurrentLoop, %location%
					Sleep (PitstopTimingsArray4)
					Press_Up()
					Sleep (100)
					Press_X()
					Sleep (100)
					Press_X()
				}
				if (TokyoLapCount = 5)
				{
					SetFormat, integerfast, d
					location := "In pit: Waiting " Round(PitstopTimingsArray5/1000) " seconds."
					guicontrol,, CurrentLoop, %location%
					Sleep (PitstopTimingsArray5)
					Press_Up()
					Sleep (100)
					Press_X()
					Sleep (100)
					Press_X()
				}
				if (TokyoLapCount = 6)
				{
					SetFormat, integerfast, d
					location := "In pit: Waiting " Round(PitstopTimingsArray6/1000) " seconds."
					guicontrol,, CurrentLoop, %location%
					Sleep (PitstopTimingsArray6)
					Press_Up()
					Sleep (100)
					Press_X()
				}
				if (TokyoLapCount = 7)
				{
					SetFormat, integerfast, d
					location := "In pit: Waiting " Round(PitstopTimingsArray7/1000) " seconds."
					guicontrol,, CurrentLoop, %location%
					Sleep (PitstopTimingsArray7)
					Press_Up()
					Sleep (100)
					Press_X()
					Sleep (100)
					Press_X()
				}
					if (TokyoLapCount = 8) 
					{
					SetFormat, integerfast, d
					location := "In pit: Waiting " Round(PitstopTimingsArray8/1000) " seconds."
					guicontrol,, CurrentLoop, %location%
					Sleep (PitstopTimingsArray8)
					Press_Up()
					Sleep (100)
					Press_X()
					Sleep (100)
					Press_X()
				}
				if (TokyoLapCount = 9) 
				{
					SetFormat, integerfast, d
					location := "In pit: Waiting " Round(PitstopTimingsArray9/1000) " seconds."
					guicontrol,, CurrentLoop, %location%
					Sleep (PitstopTimingsArray9)
					Press_Up()
					Sleep (100)
					Press_X()
					Sleep (100)
					Press_X()
				}
				if (TokyoLapCount = 10) 
				{
					SetFormat, integerfast, d
					location := "In pit: Waiting " Round(PitstopTimingsArray10/1000) " seconds."
					guicontrol,, CurrentLoop, %location%
					Sleep (PitstopTimingsArray10)
					Press_Up()
					Sleep (100)
					Press_X()
					Sleep (100)
					Press_X()
				}
				if (TokyoLapCount = 11) 
				{
					SetFormat, integerfast, d
					location := "In pit: Waiting " Round(PitstopTimingsArray11/1000) " seconds."
					guicontrol,, CurrentLoop, %location%
					Sleep (PitstopTimingsArray11)
					Press_Up()
					Sleep (100)
					Press_X()
					Sleep (100)
					Press_X()
				}
				if (TokyoLapCount = 12) 
				{
					SetFormat, integerfast, d
					location := "In pit: Waiting " Round(PitstopTimingsArray12/1000) " seconds."
					guicontrol,, CurrentLoop, %location%
					Sleep (PitstopTimingsArray12)
					Press_Up()
					Sleep (100)
					Press_X()
					Sleep (100)
					Press_X()
				}
				controller.Axes.LX.SetState(20)
				Accel_On(100)
				CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)	
				CheckTokyoPenReceived(TokyoPenServed.startX, TokyoPenServed.startY)
				location := "Start/Finish"
				guicontrol,, CurrentLoop, Current Location: %location%
				controller.Axes.LX.SetState(38)
				Sleep (1500)
				loop 20 {
					Press_Triangle(delay:=200)
					sleep, 200
				}
		}
		else {
				location := "Start/Finish"
				guicontrol,, CurrentLoop, Current Location: %location%
				Accel_On(100)
				controller.Axes.LX.SetState(60)
				CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
				CheckTokyoPenServed(TokyoPenServed.startX, TokyoPenServed.startY)
				}
				SetFormat, integerfast, d
				TokyoLapCount++
				guicontrol,, CurrentLap, Current Lap: %TokyoLapCount% /12	
				ProgressRace := (100/13)*TokyoLapCount
				guicontrol,, RaceProgress, %ProgressRace%
				
				if(TokyoLapCount = "13")
				{
					location := "Finish line"
					
					FormatTime, TGTime,, MM/dd hh:mm:ss
					FileAppend, %TGTime% Race finished.`n, log.txt
					if (TelegramBotToken != NULL)
					{
					url := "https://api.telegram.org/bot" TelegramBotToken "/sendMessage?text=" TGTime ": Race finished.&chat_id=" TelegramChatID
					hObject:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
					hObject.Open("GET",url)
					hObject.Send()
					}
					
					guicontrol,, CurrentLoop, Current Location: %location%
					guicontrol,, CurrentLap, GG!
					controller.Axes.LX.SetState(50)
					SetFormat, integerfast, d
					racecounter++
					SetFormat, integerfast, d
					racecountertotal++
					
					; // THIS SESSION
					SetFormat, integerfast, d
					SetFormat, FloatFast, 0.2
					creditcountersession := (825000*racecounter)/1000000
					SetFormat, integerfast, d
					SetFormat, FloatFast, 0.2
					creditavg := creditcountersession/(A_TickCount-script_start)*3600000
					guicontrol,, RaceCounterSession, Races completed: %racecounter%
					guicontrol,, ResetCounterSession, Races failed: %resetcounter%
					guicontrol,, CreditCounterSession, Credits: ~%creditcountersession% M
					guicontrol,, CreditAVGSession, Avg./h: ~%creditavg% M
					
					; // ALL TIME
					SetFormat, integerfast, d
					SetFormat, FloatFast, 0.2
					creditcountertotal := (825000*racecountertotal)/1000000
					IniWrite, %racecountertotal%, config.ini,Stats, RaceCounterTotal
					IniWrite, %resetcountertotal%, config.ini,Stats, ResetCounterTotal
					guicontrol,, RaceCounterTotal, Races completed: %racecountertotal%
					guicontrol,, ResetCounterTotal, Races failed: %resetcountertotal%	
					guicontrol,, CreditCounterTotal, Credits: ~%creditcountertotal% M
					UpdateAVG(racecounter, script_start)
					lapcounter =
					ProgressRace =
					guicontrol,, RaceProgress, %ProgressRace%
					loop
					{
						restart_found := false
						c2 := BitGrab(162, 114, 2)
						for i, c in c2
							{
							d2 := Distance(c, color_restart1)
							SB_SetText(" Searching... " d2 " < 15",2)
							if (d2 < 15 )
							{
								SB_SetText(" Found: " d2 " < 15",2)
								restart_found := true
								break
							}
						}
							if (restart_found)
							break
						Press_X()
						Sleep(500)
					}
					guicontrol,, CurrentLoop, Setting up next race.
					SB_SetText(" Found: " d2 " < 15",2)
					Sleep(1500)
					Press_O()
					Sleep(1500)
					Press_Right()
					Sleep(1500)
					Press_X()
					Sleep(5000)
					Press_X()
					controller.Axes.LX.SetState(50)
					UpdateAVG(racecounter, script_start)
					Switch
					{
						case SetEnd = 0:
							Goto, TokyoStart
						case SetEnd = 1:
							SetTimer, UpdateTimer, Off
							MsgBox GG! Set end was reached.`nPress Ok to exit the script.
							gosub, GUIClose
						case SetEnd > 2:
							SetEnd--
							guicontrol,, SetEndUD, %SetEnd%
							guicontrol,, SetEndButton, End after %SetEnd% wins
							Goto, TokyoStart
						case SetEnd = 2:
							SetEnd--
							guicontrol,, SetEndUD, %SetEnd%
							guicontrol,, SetEndButton, End after next win
							Goto, TokyoStart
					}
				}
	}
}

class TokyoTurnContainer
{
  __New(startX, startY, endX := 0, endY := 0)
  {
    this.startX := startX
    this.startY := startY
    this.endX   := endX
    this.endY   := endY
  }
}

CheckTokyoRestartOK(x,y, b_size := 1)
{
turnStart := A_TickCount
    loop
	{
		TokyoRestartFound := false
		c2 := BitGrab(182, 437, 2)
		for i, c in c2
		{
			d2 := Distance(c, color_restart2)
			
			if (d2 < 35 )
			{
				TokyoRestartFound := true
				break
			}
		}
		SB_SetText(" Searching Race start: " d2 " < 15",2)
		if (A_TickCount - turnStart > 12000) { 
		; we are lost, where are we?
		gosub, FindMe
		}
	} until TokyoRestartFound = true
	SB_SetText(" Found Race start: " d2 " < 15",2)
    return
}
FindMe:
loop 100 {
		SB_SetText(" Searching safe spot: " d2 " < 15",2)
		c2 := BitGrab(100, 407, 2)
		for i, c in c2
		{
			d2 := Distance(c, 0x1661A3)
			;SB_SetText(" Searching... " d2 " < 15",2)
			if (d2 < 15 )
			{
				;SB_SetText(" Found: " d2 " < 15",2)
				gosub, NotLostAnymore
			}
		}
		} 
		gosub, LostInTokyo
LostInTokyo:
SB_SetText(" We are (still) lost! ",2)
		loop 2 {
		Sleep(1000)
		Press_O()
		}
		Sleep(1500)
		Press_X()
		Sleep(8000)
		gosub, FindMe
NotLostAnymore:
SB_SetText(" Safe spot found! " d2 " < 15",2)
		Sleep(4000)
		SB_SetText(" Starting WTC 600 again... " d2 " < 15",2)
		loop 6 {
			Press_Right()
			Sleep(500)
		}
		loop 3 {
			Sleep(2000)
			Press_X()
		}
		SB_SetText(" That was scary... o_o",2)
		Sleep(8000)
		Press_X()
		Sleep(4000)
		Press_X()
		Race_Tokyo()
CheckTokyoMFD(x,y, b_size := 1)
{
    color_dot := 0x8D8B8C
    TokyoMFD := false
    tries := 1000 ; we shouldn't need more than 6 tries, but I have seen it loop passed
    loop {
	
      tc := BitGrab(x, y, b_size)       
		SB_SetText(" Searching... " td " < 120",2)
      for i, c in tc
      {
        td := Distance(c, color_dot)
        
        if (td < 120){
			SB_SetText(" Found: " td " < 120",2)
            TokyoMFD := true
            break
			}
		else {
			; Gonna try to automate the mfd checker, why not right?
			if (tries > 0){
			SB_SetText(" Searching MFD " td " < 110",2)
			Press_Left()
			Sleep(100) 	
			tries--
			break	
      }
      tries := 1000
      TokyoMFD := true
      break		
		}
  }

    } until TokyoMFD = true
    return
}


CheckTokyoTurn(x,y, b_size := 1)
{
	turnStart := A_TickCount
    color_player := 0xDE6E70
    TokyoTurnComplete := false
    loop {
		SB_SetText(" Searching... " td " < 50",2)
      tc := BitGrab(x, y, b_size)
      for i, c in tc
      {
        td := Distance(c, color_player)
			
        if (td < 50 ){
			SB_SetText(" Found: " td " < 50",2)
            TokyoTurnComplete := true
            break
        }
      }
	; add recovery so we don't kill run looking for turn. Gonna start with a high number, can adjust lower later.
	; added some press down, x's and waits just in case we are in the pit stop
	if (A_TickCount - turnStart > 90000) { 
		Press_Down()
		Sleep(300)
		Press_X()
		Sleep(500)
		Press_X()
		Sleep(7000)
		GoSub, ResetRace
		break
	}

    } until TokyoTurnComplete = true
    return
}

CheckTokyoPen1(x,y, b_size := 1)
{
	pen1Start := A_TickCount

    color_pen := 0xFFC10B
    TokyoPen1 := false
    loop {
	  SB_SetText(" Searching... " td " < 50",2)
      tc := BitGrab(x, y, b_size)
      for i, c in tc
      {
        td := Distance(c, color_pen)
			
        if (td < 50 ){
			SB_SetText(" Found: " td " < 50",2)
            TokyoPen1 := true
            break
        }		
      }
	; add recovery so we don't kill run looking for Pen1. Gonna start with a high number, can adjust lower later.
	; started with 1.5 mins, i had these set to 3:33 on other file and still won.
	if (A_TickCount - pen1Start > 90000) { 
		GoSub, ResetRace
		break
	}

    } until TokyoPen1 = true
    return
}

CheckTokyoHairpinTurn(x,y, b_size := 1)
{
	hairpinStart := A_TickCount

    color_hairpinturn := 0xB3B1B2
    TokyoHairpinTurn := false
    loop {
	  SB_SetText(" Searching... " td " < 5",2)
      tc := BitGrab(x, y, b_size)
      for i, c in tc
      {
        td := Distance(c, color_hairpinturn)
			
        if (td < 5){
			SB_SetText(" Found: " td " < 5",2)
            TokyoHairpinTurn := true
            break
        }
      }
	; add recovery so we don't kill run sitting in hairpin
	; set to 1 minute to start, I had this at 3:33 (200000) on my other file and still won.
	if (A_TickCount - hairpinStart > 90000) { 
		
		GoSub, ResetRace
		break
	}

    } until TokyoHairpinTurn = true
    return
}

CheckTokyoPen2(x,y, b_size := 1)
{
	start := A_TickCount
    color_pen := 0xFFC10B
	RecoveryTried := false
    TokyoPen2 := false
	
    loop {
	  SB_SetText(" Searching... " td " > 60",2)
      tc := BitGrab(x, y, b_size)
      for i, c in tc
      {
        td := Distance(c, color_pen)
			
        if (td > 60 ){
			SB_SetText(" Found: " td " > 60",2)
            TokyoPen2 := true
            break
        }
      }
	if (A_TickCount - start > 24000 AND RecoveryTried = false) {
			SB_SetText(" We stuck? Starting recovery try.",2)
			Accel_off()
			controller.Axes.LX.SetState(50)
			loop 7 {
				Press_Square(delay:=50)
				Sleep(100)
				}
			Accel_on(80)
			Sleep(500)
			loop 9 {
				Press_Triangle(delay:=50)
				Sleep(100)
				}
			controller.Axes.LX.SetState(30)
			RecoveryTried := true
		}
		
	if (A_TickCount - start > 70000) {
			gosub, ResetRace
			break
		}

    } until TokyoPen2 = true
    return
}

CheckTokyoPenServed(x,y, b_size := 1)
{
    color_penserved := 0xAE1B1E
    TokyoPenServed := false
    loop {
	  SB_SetText(" Searching... " td " > 60",2)
      tc := BitGrab(x, y, b_size)
      for i, c in tc
      {
        td := Distance(c, color_penserved)
			
        if (td > 60 ){
			SB_SetText(" Found: " td " > 60",2)
            TokyoPenServed := true
            break
        }
      }

    } until TokyoPenServed = true
    return
}

CheckTokyoPenReceived(x,y, b_size := 1)
{
	start := A_TickCount
    color_penreceived := 0xAE1B1E
    TokyoPenReceived := false
    loop {
	  SB_SetText(" Searching... " td " < 40",2)
      tc := BitGrab(x, y, b_size)
      for i, c in tc
      {
        td := Distance(c, color_penreceived)
		
        if (td < 40 ){
			SB_SetText(" Found: " td " < 40",2)
			guicontrol,, CurrentLoop, Pen received
			TokyoPenReceived := true
			break
        }
		if (TokyoLapCount != 6 AND A_TickCount - start > 36000)
		{
			SB_SetText(" Not found in time. Shifting up.",2)
			loop 6 {
				Press_Triangle(delay:=50)
				Sleep(200)
				TokyoPenReceived := true
				break
		}
        break
		}
		if (TokyoLapCount = 6 AND A_TickCount - start > 46000)
		{
			SB_SetText(" Not found in time. Shifting up.",2)
			loop 20 {
				Press_Triangle(delay:=50)
				Sleep(200)
				TokyoPenReceived := true
				break
		}
        break
		}

      }
    } until TokyoPenReceived = true
    return
}

CheckTokyoPitstopDone(x,y, b_size := 1)
{
	 pitstopDoneStart := A_TickCount

    color_pitstopdone := 0xFFFFFF
    TokyoPitstopDone := false
    loop {
	  SB_SetText(" Searching... " td " > 10",2)
      tc := BitGrab(x, y, b_size)
      for i, c in tc
      {
        td := Distance(c, color_pitstopdone)

        if (td > 10 ){
			SB_SetText(" Found: " td " > 10",2)
            TokyoPitstopDone := true
            break
        }
      }
	; add recovery so we don't kill run sitting in pit, havent tested if press down works to get us out
	if (A_TickCount - pitstopDoneStart > 60000) {
		Press_Down()
		Sleep(300)
		Press_X()
		Sleep(500)
		Press_X()
		Sleep(7000)
		GoSub, ResetRace
	}
    } until TokyoPitstopDone = true
    return
}

CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
{
if ( A_TickCount - loopStartTime > maxTime AND TokyoLapCount <= 10) {
				gosub, ResetRace
			}
else if (A_TickCount - loopStartTime > maxTime+90000 AND TokyoLapCount > 10)
	{
	gosub, ResetRace
	}
}

CheckTokyoPitstop1(x,y, b_size := 1)
{
	pitstop1Start := A_TickCount
	
	;color_pitstop1 := 0xFFFFFF
	;color_pitstop1 := 0x818002
    ;color_pitstop1 := 0xFBFB00 ; old color
    TokyoPitstop := false
    loop {
	  SB_SetText(" Searching... " td " < 10",2)
      tc := BitGrab(x, y, b_size)
      for i, c in tc
      {
        td := Distance(c, color_pitstop1)
			
        if (td < 10 ){
			SB_SetText(" Found: " td " < 10",2)
            TokyoPitstop := true
            break
        }
      }
	; add recovery so we don't kill run sitting in pit, havent tested if press down works to get us out
	if (A_TickCount - pitstop1Start > 60000) {
		Press_Down()
		Sleep(300)
		Press_X()
		Sleep(500)
		Press_X()
		Sleep(7000)
		GoSub, ResetRace
	}
	guicontrol,, CurrentLoop, Stuck in pit? Press GUI Button.

    } until TokyoPitstop = true
    return
}
UpdateAVG(racecounter, script_start)
{
	SetFormat, integerfast, d
	creditcountersession := (825000*racecounter)/1000000
	SetFormat, integerfast, d
	SetFormat, FloatFast, 0.2
	creditavg := creditcountersession/(A_TickCount-script_start)*3600000
	guicontrol,, CreditAVG, Avg./h: ~%creditavg% M
	return
}

UpdateTimer()
{
ElapsedTime := A_TickCount - script_start
	 VarSetCapacity(t,256),DllCall("GetDurationFormat","uint",2048,"uint",0,"ptr",0,"int64",ElapsedTime*10000,"wstr","d' day(s) 'h':'mm':'ss","wstr",t,"int",256)
	SB_SetText("Runtime: " t,3)
	return 
}

HexToDec(hex)
{
    VarSetCapacity(dec, 66, 0)
    , val := DllCall("msvcrt.dll\_wcstoui64", "Str", hex, "UInt", 0, "UInt", 16, "CDECL Int64")
    , DllCall("msvcrt.dll\_i64tow", "Int64", val, "Str", dec, "UInt", 10, "CDECL")
    return dec
}