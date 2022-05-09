#Persistent
#NoEnv
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
#SingleInstance force
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
DetectHiddenWindows, Off

Global controller := new ViGEmDS4()
controller.SubscribeFeedback(Func("OnFeedback"))
OnFeedback(largeMotor, smallMotor, lightbarColor){
}
Global script_start := A_TickCount
Global wizardstarted := 0
Global size_remoteplay := 0
Global racecounter := 0
Global resetcounter := 0
Global racecountertotal := 0
Global resetcountertotal := 0
Global PitstopTimings := 0
Global TelegramBotToken :=
Global TelegramChatID :=
Global location := ""
Global TokyoLapCount := 1
Global PitstopTimingsArray :=
Global SetEnd := 0

Global color_player := 0
Global color_racestart := 0
Global color_restart := 0
Global color_lost := 0
Global color_pen := 0
Global color_penwarn := 0
Global color_pitstop := 0

Global pos_racestartX := 0
Global pos_racestartY := 0

Global pos_pitstopX := 0
Global pos_pitstopY := 0

Global pos_restartX := 0
Global pos_restartY := 0

Global pos_lostX := 0
Global pos_lostY := 0

Global pos_penX := 0
Global pos_penY := 0

Global pos_penwarnX := 0
Global pos_penwarnY := 0

Global pos_t1_startX := 0
Global pos_t1_startY := 0
Global pos_t1_endX := 0
Global pos_t1_endY := 0

Global pos_t2_startX := 0
Global pos_t2_startY := 0
Global pos_t2_endX := 0
Global pos_t2_endY := 0

Global pos_t3_startX := 0
Global pos_t3_startY := 0
Global pos_t3_endX := 0
Global pos_t3_endY := 0

Global pos_t4_startX := 0
Global pos_t4_startY := 0
Global pos_t4_endX := 0
Global pos_t4_endY := 0

Global pos_t5_startX := 0
Global pos_t5_startY := 0
Global pos_t5_endX := 0
Global pos_t5_endY := 0

Global pos_t6_startX := 0
Global pos_t6_startY := 0
Global pos_t6_endX := 0
Global pos_t6_endY := 0

Global pos_t7_startX := 0
Global pos_t7_startY := 0
Global pos_t7_endX := 0
Global pos_t7_endY := 0

Global pos_t8_startX := 0
Global pos_t8_startY := 0
Global pos_t8_endX := 0
Global pos_t8_endY := 0

Global pos_t9_startX := 0
Global pos_t9_startY := 0

Read_Ini()
{
	IniRead, TelegramBotToken, config.ini, API, TelegramBotToken, 0
	IniRead, TelegramChatID, config.ini, API, TelegramChatID, 0
	IniRead, racecountertotal, config.ini, Stats, racecountertotal, 0
	IniRead, resetcountertotal, config.ini, Stats, resetcountertotal, 0
	;IniRead, PitstopTimings, config.ini, Vars, PitStopTimings0, 0
	;StringSplit, PitstopTimingsArray, PitstopTimings, `,

	IniRead, size_remoteplay, config.ini, Vars, size_remoteplay, 0

	IniRead, color_player, config.ini, size%size_remoteplay%, color_player, 0
	IniRead, color_lost, config.ini, size%size_remoteplay%, color_lost, 0
	IniRead, pos_lostX, config.ini, size%size_remoteplay%, pos_lostX, 0
	IniRead, pos_lostY, config.ini, size%size_remoteplay%, pos_lostY, 0
	IniRead, color_pitstop, config.ini, size%size_remoteplay%, color_pitstop, 0
	IniRead, color_restart, config.ini, size%size_remoteplay%, color_restart, 0
	IniRead, color_racestart, config.ini, size%size_remoteplay%, color_racestart, 0
	IniRead, color_pen, config.ini, size%size_remoteplay%, color_pen, 0
	IniRead, pos_racestartX, config.ini, size%size_remoteplay%, pos_racestartX, 0
	IniRead, pos_racestartY, config.ini, size%size_remoteplay%, pos_racestartY, 0
	IniRead, pos_pitstopX, config.ini, size%size_remoteplay%, pos_pitstopX, 0
	IniRead, pos_pitstopY, config.ini, size%size_remoteplay%, pos_pitstopY, 0
	IniRead, pos_restartX, config.ini, size%size_remoteplay%, pos_restartX, 0
	IniRead, pos_restartY, config.ini, size%size_remoteplay%, pos_restartY, 0
	IniRead, pos_penX, config.ini, size%size_remoteplay%, pos_penX, 0
	IniRead, pos_penY, config.ini, size%size_remoteplay%, pos_penY, 0
	IniRead, pos_t1_startX, config.ini, size%size_remoteplay%, pos_t1_startX, 0
	IniRead, pos_t1_startY, config.ini, size%size_remoteplay%, pos_t1_startY, 0
	IniRead, pos_t1_endX, config.ini, size%size_remoteplay%, pos_t1_endX, 0
	IniRead, pos_t1_endY, config.ini, size%size_remoteplay%, pos_t1_endY, 0
	IniRead, pos_t2_startX, config.ini, size%size_remoteplay%, pos_t2_startX, 0
	IniRead, pos_t2_startY, config.ini, size%size_remoteplay%, pos_t2_startY, 0
	IniRead, pos_t2_endX, config.ini, size%size_remoteplay%, pos_t2_endX, 0
	IniRead, pos_t2_endY, config.ini, size%size_remoteplay%, pos_t2_endY, 0
	IniRead, pos_t3_startX, config.ini, size%size_remoteplay%, pos_t3_startX, 0
	IniRead, pos_t3_startY, config.ini, size%size_remoteplay%, pos_t3_startY, 0
	IniRead, pos_t3_endX, config.ini, size%size_remoteplay%, pos_t3_endX, 0
	IniRead, pos_t3_endY, config.ini, size%size_remoteplay%, pos_t3_endY, 0
	IniRead, pos_t4_startX, config.ini, size%size_remoteplay%, pos_t4_startX, 0
	IniRead, pos_t4_startY, config.ini, size%size_remoteplay%, pos_t4_startY, 0
	IniRead, pos_t4_endX, config.ini, size%size_remoteplay%, pos_t4_endX, 0
	IniRead, pos_t4_endY, config.ini, size%size_remoteplay%, pos_t4_endY, 0
	IniRead, pos_t5_startX, config.ini, size%size_remoteplay%, pos_t5_startX, 0
	IniRead, pos_t5_startY, config.ini, size%size_remoteplay%, pos_t5_startY, 0
	IniRead, pos_t5_endX, config.ini, size%size_remoteplay%, pos_t5_endX, 0
	IniRead, pos_t5_endY, config.ini, size%size_remoteplay%, pos_t5_endY, 0
	IniRead, pos_t6_startX, config.ini, size%size_remoteplay%, pos_t6_startX, 0
	IniRead, pos_t6_startY, config.ini, size%size_remoteplay%, pos_t6_startY, 0
	IniRead, pos_t6_endX, config.ini, size%size_remoteplay%, pos_t6_endX, 0
	IniRead, pos_t6_endY, config.ini, size%size_remoteplay%, pos_t6_endY, 0
	IniRead, pos_t7_startX, config.ini, size%size_remoteplay%, pos_t7_startX, 0
	IniRead, pos_t7_startY, config.ini, size%size_remoteplay%, pos_t7_startY, 0
	IniRead, pos_t7_endX, config.ini, size%size_remoteplay%, pos_t7_endX, 0
	IniRead, pos_t7_endY, config.ini, size%size_remoteplay%, pos_t7_endY, 0
	IniRead, pos_t8_startX, config.ini, size%size_remoteplay%, pos_t8_startX, 0
	IniRead, pos_t8_startY, config.ini, size%size_remoteplay%, pos_t8_startY, 0
	IniRead, pos_t8_endX, config.ini, size%size_remoteplay%, pos_t8_endX, 0
	IniRead, pos_t8_endY, config.ini, size%size_remoteplay%, pos_t8_endY, 0
	IniRead, pos_t9_startX, config.ini, size%size_remoteplay%, pos_t9_startX, 0
	IniRead, pos_t9_startY, config.ini, size%size_remoteplay%, pos_t9_startY, 0

	return
}
Read_Ini()
SetFormat, FloatFast, 0.2
creditcountertotal := 825000*racecountertotal/1000000
;StringSplit, PitstopTimingsArray, PitstopTimings, `,

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
;Gui, Add, Button, x12 y80 w200 h20 default gRaceSettingsWindow, Settings: Race
Gui, Add, Button, x12 y110 w200 h20 default gMachineSettingsWindow, Run detection wizard
Gui, Add, Button, x12 y140 w200 h20 default gNotificationsWindow, Settings: Notifications/API
Gui, Add, Button, x12 y170 w200 h20 default gDocumentationWindow, Documentation/Ingame Settings

Gui, Add, Button, x152 y80 w60 h21 default gSetSize, Set size
IniRead, size_remoteplay, config.ini, Vars, size_remoteplay, 0
Gui, Add, DDL,x12 y80 w130 vsize_remoteplay +AltSubmit Choose%size_remoteplay%, Small (640x540)|Middle (1024x768)|Large (1280x1024)
Gui, Font, S8 CDefault Bold, Verdana
Gui, Add, Text, x10 y3 w620 h20 +BackgroundTrans, // TOKYO CONTROL CENTER
Gui, Add, Statusbar, -Theme Backgroundeeeeee ;#eeeeee, no typo
SB_SetParts(80,270,190)
SB_SetText(" Tokyo X4 ",1)
SB_SetText(" by problemz.",4)

switch size_remoteplay
{
case 1: Gui, Show, x7 y533 h225 w640, GT7 Tokyo // by problemz
case 2: Gui, Show, x7 y762 h225 w640, GT7 Tokyo // by problemz
case 3: Gui, Show, x1274 y791 h225 w640, GT7 Tokyo // by problemz
}

guicontrol,, CurrentLoop, Press START, go go!

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
Gosub, GrabRemotePlay
Return

Detectionwizard:
	Gosub, GrabRemotePlay
	wizardstarted := 1
	currentstep := 0
	controller.Axes.LX.SetState(50)
	Sleep(1000)
	SplashImage, %A_ScriptDir%\Assets\Tokyo_Assistant00.png,+x26 +y160 B2,Welcome.`nESC to cancel.`nClick when told.`n, 00 - Wizard started,Detection Assistant
	Sleep(3000)
	controller.Axes.LX.SetState(70)
	Accel_On(50)
	Press_X()
	Sleep(4000)
	Accel_Off()
	Brake_on(100)

	SplashImage, %A_ScriptDir%\Assets\Tokyo_Assistant01.png,+x26 +y160 B2,Double-click the green battery icon now., 01 - Race start,Detection Assistant
Return

SetSize:
	Gui, Submit, nohide
	IniWrite, %size_remoteplay%, config.ini,Vars, size_remoteplay
	Gosub, GrabRemotePlay
return

~ESC::
	SplashImage, Off
	wizardstarted := 0
	currentstep := 0
Return

~LButton:: 
	If (A_TimeSincePriorHotkey<400) and (A_PriorHotkey="~LButton") and (wizardstarted = 1)
	{
		MouseGetPos, pos_mouseX, pos_mouseY
		Switch
		{
		case currentstep = 0: ; BATTERY
			pixelgetcolor, color_racestart, pos_mouseX, pos_mouseY, Slow RGB
			IniWrite, %color_racestart%, config.ini,size%size_remoteplay%, color_racestart
			IniWrite, %pos_mouseX%, config.ini, size%size_remoteplay%, pos_racestartX
			IniWrite, %pos_mouseY%, config.ini, size%size_remoteplay%, pos_racestartY
			SplashImage, %A_ScriptDir%\Assets\Tokyo_Assistant02.png,+x26 +y160 ,Detected:`n`nx: %pos_mouseX% | y: %pos_mouseY% `nColor: %color_racestart%,01 - Race start,Detection Assistant
			currentstep++
			Sleep(2000)
			SplashImage, %A_ScriptDir%\Assets\Tokyo_Assistant05.png,+x26 +y160,Double-click on the red "Penalty" part now.,03 - Penalty,Detection Assistant

		case currentstep = 1:
			pixelgetcolor, color_pen, pos_mouseX, pos_mouseY, Slow RGB
			IniWrite, %color_pen%, config.ini,size%size_remoteplay%, color_pen
			IniWrite, %pos_mouseX%, config.ini, size%size_remoteplay%, pos_penX
			IniWrite, %pos_mouseY%, config.ini, size%size_remoteplay%, pos_penY
			SplashImage, %A_ScriptDir%\Assets\Tokyo_Assistant06.png,+x26 +y160, Detected:`n`nx: %pos_mouseX% | y: %pos_mouseY% `nColor: %color_racestart%,03 - Penalty,Detection Assistant
			currentstep++
			Sleep(2000)
			SplashImage, %A_ScriptDir%\Assets\t1start.png,+x26 +y160,Double-click on the red X location on your minimap now.,04 - Turn 1 Start,Detection Assistant

		case currentstep = 2:
			pixelgetcolor, color_, pos_mouseX, pos_mouseY, Slow RGB
			IniWrite, %pos_mouseX%, config.ini, size%size_remoteplay%, pos_t1_startX
			IniWrite, %pos_mouseY%, config.ini, size%size_remoteplay%, pos_t1_startY
			currentstep++
			Sleep(300)
			SplashImage, %A_ScriptDir%\Assets\t1end.png,+x26 +y160,Double-click on the red X location on your minimap now.,04 - Turn 1 End,Detection Assistant	

		case currentstep = 3:
			pixelgetcolor, color_, pos_mouseX, pos_mouseY, Slow RGB
			IniWrite, %pos_mouseX%, config.ini, size%size_remoteplay%, pos_t1_endX
			IniWrite, %pos_mouseY%, config.ini, size%size_remoteplay%, pos_t1_endY
			currentstep++
			Sleep(300)
			SplashImage, %A_ScriptDir%\Assets\t2start.png,+x26 +y160,Double-click on the red X location on your minimap now.,04 - Turn 2 Start,Detection Assistant	

		case currentstep = 4:
			pixelgetcolor, color_, pos_mouseX, pos_mouseY, Slow RGB
			IniWrite, %pos_mouseX%, config.ini, size%size_remoteplay%, pos_t2_startX
			IniWrite, %pos_mouseY%, config.ini, size%size_remoteplay%, pos_t2_startY
			currentstep++
			Sleep(300)
			SplashImage, %A_ScriptDir%\Assets\t2end.png,+x26 +y160,Double-click on the red X location on your minimap now.,04 - Turn 2 End,Detection Assistant	

		case currentstep = 5:
			pixelgetcolor, color_, pos_mouseX, pos_mouseY, Slow RGB
			IniWrite, %pos_mouseX%, config.ini, size%size_remoteplay%, pos_t2_endX
			IniWrite, %pos_mouseY%, config.ini, size%size_remoteplay%, pos_t2_endY
			currentstep++
			Sleep(300)
			SplashImage, %A_ScriptDir%\Assets\t3start.png,+x26 +y160,Double-click on the red X location on your minimap now.,04 - Turn 3 Start,Detection Assistant	

		case currentstep = 6:
			pixelgetcolor, color_, pos_mouseX, pos_mouseY, Slow RGB
			IniWrite, %pos_mouseX%, config.ini, size%size_remoteplay%, pos_t3_startX
			IniWrite, %pos_mouseY%, config.ini, size%size_remoteplay%, pos_t3_startY
			currentstep++
			Sleep(300)
			SplashImage, %A_ScriptDir%\Assets\t3end.png,+x26 +y160,Double-click on the red X location on your minimap now.,04 - Turn 3 End,Detection Assistant	

		case currentstep = 7:
			pixelgetcolor, color_, pos_mouseX, pos_mouseY, Slow RGB
			IniWrite, %pos_mouseX%, config.ini, size%size_remoteplay%, pos_t3_endX
			IniWrite, %pos_mouseY%, config.ini, size%size_remoteplay%, pos_t3_endY
			currentstep++
			Sleep(300)
			SplashImage, %A_ScriptDir%\Assets\t4start.png,+x26 +y160,Double-click on the red X location on your minimap now.,04 - Turn 4 Start,Detection Assistant	

		case currentstep = 8:
			pixelgetcolor, color_, pos_mouseX, pos_mouseY, Slow RGB
			IniWrite, %pos_mouseX%, config.ini, size%size_remoteplay%, pos_t4_startX
			IniWrite, %pos_mouseY%, config.ini, size%size_remoteplay%, pos_t4_startY
			currentstep++
			Sleep(300)
			SplashImage, %A_ScriptDir%\Assets\t4end.png,+x26 +y160,Double-click on the red X location on your minimap now.,04 - Turn 4 End,Detection Assistant	

		case currentstep = 9:
			pixelgetcolor, color_, pos_mouseX, pos_mouseY, Slow RGB
			IniWrite, %pos_mouseX%, config.ini, size%size_remoteplay%, pos_t4_endX
			IniWrite, %pos_mouseY%, config.ini, size%size_remoteplay%, pos_t4_endY
			currentstep++
			Sleep(300)
			SplashImage, %A_ScriptDir%\Assets\t5start.png,+x26 +y160,Double-click on the red X location on your minimap now.,04 - Turn 5 Start,Detection Assistant	

		case currentstep = 10:
			pixelgetcolor, color_, pos_mouseX, pos_mouseY, Slow RGB
			IniWrite, %pos_mouseX%, config.ini, size%size_remoteplay%, pos_t5_startX
			IniWrite, %pos_mouseY%, config.ini, size%size_remoteplay%, pos_t5_startY
			currentstep++
			Sleep(300)
			SplashImage, %A_ScriptDir%\Assets\t5end.png,+x26 +y160,Double-click on the red X location on your minimap now.,04 - Turn 5 End,Detection Assistant	

		case currentstep = 11:
			pixelgetcolor, color_, pos_mouseX, pos_mouseY, Slow RGB
			IniWrite, %pos_mouseX%, config.ini, size%size_remoteplay%, pos_t5_endX
			IniWrite, %pos_mouseY%, config.ini, size%size_remoteplay%, pos_t5_endY
			currentstep++
			Sleep(300)
			SplashImage, %A_ScriptDir%\Assets\t6start.png,+x26 +y160,Double-click on the red X location on your minimap now.,04 - Turn 6 Start,Detection Assistant	

		case currentstep = 12:
			pixelgetcolor, color_, pos_mouseX, pos_mouseY, Slow RGB
			IniWrite, %pos_mouseX%, config.ini, size%size_remoteplay%, pos_t6_startX
			IniWrite, %pos_mouseY%, config.ini, size%size_remoteplay%, pos_t6_startY
			currentstep++
			Sleep(300)
			SplashImage, %A_ScriptDir%\Assets\t6end.png,+x26 +y160,Double-click on the red X location on your minimap now.,04 - Turn 6 End,Detection Assistant	

		case currentstep = 13:
			pixelgetcolor, color_, pos_mouseX, pos_mouseY, Slow RGB
			IniWrite, %pos_mouseX%, config.ini, size%size_remoteplay%, pos_t6_endX
			IniWrite, %pos_mouseY%, config.ini, size%size_remoteplay%, pos_t6_endY
			currentstep++
			Sleep(300)
			SplashImage, %A_ScriptDir%\Assets\t7start.png,+x26 +y160,Double-click on the red X location on your minimap now.,04 - Turn 7 Start,Detection Assistant	

		case currentstep = 14:
			pixelgetcolor, color_, pos_mouseX, pos_mouseY, Slow RGB
			IniWrite, %pos_mouseX%, config.ini, size%size_remoteplay%, pos_t7_startX
			IniWrite, %pos_mouseY%, config.ini, size%size_remoteplay%, pos_t7_startY
			currentstep++
			Sleep(300)
			SplashImage, %A_ScriptDir%\Assets\t7end.png,+x26 +y160,Double-click on the red X location on your minimap now.,04 - Turn 7 End,Detection Assistant	

		case currentstep = 15:
			pixelgetcolor, color_, pos_mouseX, pos_mouseY, Slow RGB
			IniWrite, %pos_mouseX%, config.ini, size%size_remoteplay%, pos_t7_endX
			IniWrite, %pos_mouseY%, config.ini, size%size_remoteplay%, pos_t7_endY
			currentstep++
			Sleep(300)
			SplashImage, %A_ScriptDir%\Assets\t8start.png,+x26 +y160,Double-click on the red X location on your minimap now.,04 - Turn 8 Start,Detection Assistant

		case currentstep = 16:
			pixelgetcolor, color_, pos_mouseX, pos_mouseY, Slow RGB
			IniWrite, %pos_mouseX%, config.ini, size%size_remoteplay%, pos_t8_startX
			IniWrite, %pos_mouseY%, config.ini, size%size_remoteplay%, pos_t8_startY
			currentstep++
			Sleep(300)
			SplashImage, %A_ScriptDir%\Assets\t8end.png,+x26 +y160,Double-click on the red X location on your minimap now.,04 - Turn 8 End,Detection Assistant	

		case currentstep = 17:
			pixelgetcolor, color_, pos_mouseX, pos_mouseY, Slow RGB
			IniWrite, %pos_mouseX%, config.ini, size%size_remoteplay%, pos_t8_endX
			IniWrite, %pos_mouseY%, config.ini, size%size_remoteplay%, pos_t8_endY
			currentstep++
			Sleep(300)
			SplashImage, %A_ScriptDir%\Assets\t9start.png,+x26 +y160,Double-click on the red player arrow on the minimap.,04 - Pit entrance,Detection Assistant	

		case currentstep = 18:
			pixelgetcolor, color_, pos_mouseX, pos_mouseY, Slow RGB
			IniWrite, %pos_mouseX%, config.ini, size%size_remoteplay%, pos_t9_startX
			IniWrite, %pos_mouseY%, config.ini, size%size_remoteplay%, pos_t9_startY
			currentstep++
			Sleep(300)
			SplashImage, %A_ScriptDir%\Assets\Tokyo_Assistant07.png,+x26 +y160,Double-click on the red player arrow on the minimap.,05 - Player Color,Detection Assistant	

		case currentstep = 19:
			pixelgetcolor, color_player, pos_mouseX, pos_mouseY, Slow RGB
			IniWrite, %color_player%, config.ini, size%size_remoteplay%, color_player
			SplashImage, %A_ScriptDir%\Assets\Tokyo_Assistant08.png,+x26 +y160, Detected:`n`nx: %pos_mouseX% | y: %pos_mouseY% `nColor: %color_player%,05 - Player Color,Detection Assistant
			currentstep++
			Sleep(2000)
			SplashImage, Off
			Read_Ini()
			Sleep(2000)
			Press_Options()
			Sleep(600)
			Press_Right()
			Sleep(600)
			Press_X()
			Sleep(3000)
			Brake_off()
			Accel_On(100)
			Sleep(4000)
			controller.Axes.LX.SetState(70)
			loop 8 {
				Press_Triangle(delay:=50)
				Sleep(200)
			}
			location := "Assistant running..."
			guicontrol,, CurrentLoop, Current Location: %location%
			CheckTokyoTurn(pos_t1_startX, pos_t1_startY)
			controller.Axes.LX.SetState(36)
			CheckTokyoTurn(pos_t1_endX, pos_t1_endY)
			controller.Axes.LX.SetState(35)
			CheckTokyoTurn(pos_t2_startX, pos_t2_startY)
			controller.Axes.LX.SetState(52)
			CheckTokyoTurn(pos_t2_endX, pos_t2_endY)
			controller.Axes.LX.SetState(40)
			CheckTokyoTurn(pos_t3_startX, pos_t3_startY)
			controller.Axes.LX.SetState(40)
			CheckTokyoTurn(pos_t3_endX, pos_t3_endY)
			controller.Axes.LX.SetState(70)
			Accel_On(85)
			CheckTokyoTurn(pos_t4_startX, pos_t4_startY)
			controller.Axes.LX.SetState(68)
			CheckTokyoTurn(pos_t4_endX, pos_t4_endY)
			controller.Axes.LX.SetState(60)
			Accel_On(70)
			CheckTokyoTurn(pos_t5_startX, pos_t5_startY)
			guicontrol,, CurrentLoop, Current Location: %location%
			controller.Axes.LX.SetState(42)
			CheckTokyoTurn(pos_t5_endX, pos_t5_endY)
			guicontrol,, CurrentLoop, Current Location: %location%
			controller.Axes.LX.SetState(63)
			CheckTokyoTurn(pos_t6_startX, pos_t6_startY)
			controller.Axes.LX.SetState(70)
			Accel_on(75)
			CheckTokyoTurn(pos_t6_endX, pos_t6_endY)
			controller.Axes.LX.SetState(40)
			Accel_On(100)
			CheckTokyoTurn(pos_t7_startX, pos_t7_startY)
			controller.Axes.LX.SetState(40)
			CheckTokyoTurn(pos_t7_endX, pos_t7_endY)
			controller.Axes.LX.SetState(70)
			CheckTokyoTurn(pos_t8_startX, pos_t8_startY)
			controller.Axes.LX.SetState(65)
			CheckTokyoTurn(pos_t8_endX, pos_t8_endY)
			controller.Axes.LX.SetState(30)
			Sleep(2500)
			Brake_on(100)
			Sleep(2200)
			Brake_off()
			Accel_On(35)
			Sleep(4500)
			Brake_on(100)
			Accel_Off()
			SplashImage, %A_ScriptDir%\Assets\Tokyo_Assistant15.png,+x26 +y160, Double-click on the yellow penalty warning part.,06 - Penalty warning,Detection Assistant	

		case currentstep = 20:
			pixelgetcolor, color_penwarn, pos_mouseX, pos_mouseY, Slow RGB
			IniWrite, %color_penwarn%, config.ini, size%size_remoteplay%, color_pitstop
			IniWrite, %pos_mouseX%, config.ini, size%size_remoteplay%, pos_penwarnX
			IniWrite, %pos_mouseY%, config.ini, size%size_remoteplay%, pos_penwarnY
			SplashImage, %A_ScriptDir%\Assets\Tokyo_Assistant16.png,+x26 +y160, Detected:`n`nx: %pos_mouseX% | y: %pos_mouseY% `nColor: %color_penwarn%, 06 - Penalty warning,Detection Assistant
			currentstep++
			Accel_On(40)
			Brake_off()
			controller.Axes.LX.SetState(30)
			SplashImage, Assets\Tokyo_Assistant09.png,+x26 +y160, Double-click on any part of the white/hard tires.,09 - Pit stop,Detection Assistant	

		case currentstep = 21:
			controller.Axes.LX.SetState(50)
			pixelgetcolor, color_pitstop, pos_mouseX, pos_mouseY, Slow RGB
			IniWrite, %color_pitstop%, config.ini, size%size_remoteplay%, color_pitstop
			IniWrite, %pos_mouseX%, config.ini, size%size_remoteplay%, pos_pitstopX
			IniWrite, %pos_mouseY%, config.ini, size%size_remoteplay%, pos_pitstopY
			SplashImage, %A_ScriptDir%\Assets\Tokyo_Assistant10.png,+x26 +y160, Detected:`n`nx: %pos_mouseX% | y: %pos_mouseY% `nColor: %color_pitstop%,09 - Pit stop,Detection Assistant
			currentstep++
			Sleep(2000)
			Press_Right()
			Sleep(400)
			Press_X()
			Sleep(400)
			Press_X()
			Sleep(12000)
			Press_Options()
			Sleep(1000)
			Press_Right()
			Sleep(600)
			Press_Right()
			Sleep(600)
			Press_Right()
			Sleep(600)
			Press_X()
			Sleep(2000)
			Press_X()
			Sleep(2000)
			Press_X()
			Sleep(3000)
			Press_Right()
			Sleep(600)
			Press_Right()
			Sleep(600)
			Press_Right()
			Sleep(2000)
			Press_X()
			Sleep(2000)
			SplashImage, %A_ScriptDir%\Assets\Tokyo_Assistant11.png,+x26 +y160,Double-click on the orange Cafè icon part.,10 - Restart,Detection Assistant

		case currentstep = 22:
			pixelgetcolor, color_restart, pos_mouseX, pos_mouseY, Slow RGB
			IniWrite, %color_restart%, config.ini, size%size_remoteplay%, color_restart
			IniWrite, %pos_mouseX%, config.ini, size%size_remoteplay%, pos_restartX
			IniWrite, %pos_mouseY%, config.ini, size%size_remoteplay%, pos_restartY
			SplashImage, %A_ScriptDir%\Assets\Tokyo_Assistant12.png,+x26 +y160,Detected:`n`nx: %pos_mouseX% | y: %pos_mouseY% `nColor: %color_restart%,10 - Restart,Detection Assistant
			Sleep(2000)
			currentstep++
			SplashImage, Assets\Tokyo_Assistant13.png,+x26 +y160,Double-click on the blue meeting place part.,11 - Safe spot,Detection Assistant

		case currentstep = 23:
			pixelgetcolor, color_lost, pos_mouseX, pos_mouseY, Slow RGB
			IniWrite, %color_lost%, config.ini, size%size_remoteplay%, color_lost
			IniWrite, %pos_mouseX%, config.ini, size%size_remoteplay%, pos_lostX
			IniWrite, %pos_mouseY%, config.ini, size%size_remoteplay%, pos_lostY
			SplashImage, %A_ScriptDir%\Assets\Tokyo_Assistant14.png,+x26 +y160,Detected:`n`nx: %pos_mouseX% | y: %pos_mouseY% `nColor: %color_lost%,11 - Safe spot,Detection Assistant
			currentstep++

			loop 6 {
				Press_Right()
				Sleep(500)
			}
			loop 3 {
				Sleep(2000)
				Press_X()
			}
			Sleep(8000)
			Press_X()
			Sleep(4000)
			Press_X()

			Sleep(4000)
			Press_Options()
			Sleep(1000)
			Press_Right()
			Sleep(1000)
			SplashImage, %A_ScriptDir%\Assets\Tokyo_Assistant21.png,+x26 +y160,`nEverything done.`n`nGLHF., Wizard completed,Detection Assistant
			Sleep(4000)
			SplashImage, off
			wizardstarted := 0
			currentstep := 0
			Reload
		}
	}
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
			MsgBox, 52, Start detection wizard?, If you start the wizard, wait until you see the "GG" popup.`nThe wizard will drive into the pit automatically and goes to the menu afterwards.
				IfMsgBox Yes
			{
				Gosub, Detectionwizard
			}
		}
	return

	RaceSettingsWindow:
		Gui, 4: Show,w639 h140, Settings: Race
	return

	NotificationsWindow:
		Gui, 5: Show,w639 h70, Settings: Notifications/API
	return

	DocumentationWindow:
		url := "./Assets/doc.html"

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
		IniWrite, %TelegramBotToken%, config.ini,API, TelegramBotToken
		IniWrite, %TelegramChatID%, config.ini,API, TelegramChatID
		;IniRead, PitstopTimings, config.ini, Vars, PitStopTimings0, 0
		;StringSplit, PitstopTimingsArray, PitstopTimings, `,
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

		IniRead, size_remoteplay, config.ini, Vars, size_remoteplay, 0

		switch size_remoteplay
		{
			case 1: WinMove, ahk_id %id%,, 0, 0, 640, 540 
			WinMove, GT7 Tokyo // by problemz,, 7, 533
			case 2: WinMove, ahk_id %id%,, 0, 0, 1024, 768 
			WinMove, GT7 Tokyo // by problemz,, 7, 762
			case 3: WinMove, ahk_id %id%,, 0, 0, 1280, 1024 
			WinMove, GT7 Tokyo // by problemz,, 1274, 791 
		}
		ControlFocus,, ahk_class %remotePlay_class%
		WinActivate, ahk_id %id%
		GetClientSize(remotePlay_id5, ps_win_width, ps_win_height)
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

				FormatTime, TGTime,, MM/dd hh:mm:ss
				FileAppend, %TGTime%: Race failed - Lap %TokyoLapCount% - %location%.`n, log.txt

				if (StrLen(TelegramBotToken) > 1)
				{
					url := "https://api.telegram.org/bot" TelegramBotToken "/sendMessage?text=" TGTime ": Race failed - Lap " TokyoLapCount " - " location ".&chat_id=" TelegramChatID
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
			return

			Race_Tokyo()
			{
				Read_Ini()
				;- VARIABLES ----------------------------------------------------------------------------
				TokyoLapCount := 1
				maxTime := 200000
				;StringSplit, PitstopTimingsArray, PitstopTimings, `,

				;- RACE START ----------------------------------------------------------------------------
				controller.Axes.LX.SetState(65)
				CheckTokyoRaceStart(pos_racestartX, pos_racestartY)
				Sleep(8400)
				SB_SetText(" Race started. Good Luck!",2)
				controller.Axes.LX.SetState(65)
				FormatTime, TGTime,, MM/dd hh:mm:ss
				FileAppend, %TGTime%: Race started.`n, log.txt
				if (StrLen(TelegramBotToken) > 1)
				{
					url := "https://api.telegram.org/bot" TelegramBotToken "/sendMessage?text=" TGTime ": Race started.&chat_id=" TelegramChatID
					hObject:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
					hObject.Open("GET",url)
					hObject.Send()
				}
				guicontrol,, CurrentLoop, Race started. Good luck!
				labellapcount := HexToDec(TokyoLapCount)
				guicontrol,, CurrentLap, Current Lap: %labellapcount%/12
				Accel_On(100)
				loop 7 {
					Press_Triangle(delay:=50)
					Sleep(200)
				}
				Sleep(800)
				controller.Axes.LX.SetState(65)
				;- 12 LAP LOOP ---------------------------------------------------------------------------
				loop 12 
				{
					Read_Ini()
					location := "Start/Finish"
					guicontrol,, CurrentLoop, Current Location: %location%
					loopStartTime := A_TickCount
					; Turn 1
					location := "T1 Start"
					CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
					CheckTokyoTurn(pos_t1_startX, pos_t1_startY)
					loop 3 {
						Press_Triangle(delay:=50)
						Sleep(200)
					}
					guicontrol,, CurrentLoop, Current Location: %location%
					controller.Axes.LX.SetState(36)
					CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
					Sleep(1000)
					location := "T1 End"
					CheckTokyoTurn(pos_t1_endX, pos_t1_endY)
					guicontrol,, CurrentLoop, Current Location: %location%
					controller.Axes.LX.SetState(35)
					Sleep(1000)
					; Turn 2
					location := "T2 Start"
					CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
					CheckTokyoTurn(pos_t2_startX, pos_t2_startY)
					guicontrol,, CurrentLoop, Current Location: %location%
					controller.Axes.LX.SetState(52)
					CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
					Sleep(1000)
					location := "T2 End"
					CheckTokyoTurn(pos_t2_endX, pos_t2_endY)
					guicontrol,, CurrentLoop, Current Location: %location%
					controller.Axes.LX.SetState(40)
					Sleep(1000)

					; Turn 3
					location := "T3 Start"
					CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
					CheckTokyoTurn(pos_t3_startX, pos_t3_startY)
					guicontrol,, CurrentLoop, Current Location: %location%
					Sleep(1000)
					controller.Axes.LX.SetState(40)
					CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)		
					location := "T3 End"
					CheckTokyoTurn(pos_t3_endX, pos_t3_endY)
					guicontrol,, CurrentLoop, Current Location: %location%
					controller.Axes.LX.SetState(70)
					Sleep(1000)
					; Turn 4
					location := "T4 Start"
					Accel_On(85)
					CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
					CheckTokyoTurn(pos_t4_startX, pos_t4_startY)
					guicontrol,, CurrentLoop, Current Location: %location%
					Sleep(1000)
					controller.Axes.LX.SetState(68)
					CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
					location := "T4 End"
					CheckTokyoTurn(pos_t4_endX, pos_t4_endY)
					guicontrol,, CurrentLoop, Current Location: %location%
					controller.Axes.LX.SetState(60)
					Accel_On(70)
					Sleep(1000)
					; Turn 5
					location := "T5 Start"
					CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
					CheckTokyoTurn(pos_t5_startX, pos_t5_startY)
					guicontrol,, CurrentLoop, Current Location: %location%
					controller.Axes.LX.SetState(42)
					Sleep(1000)
					CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
					location := "T5 End"
					CheckTokyoTurn(pos_t5_endX, pos_t5_endY)
					guicontrol,, CurrentLoop, Current Location: %location%
					controller.Axes.LX.SetState(63)
					Sleep(1000)
					; Turn 6
					location := "T6 Start"
					CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
					CheckTokyoTurn(pos_t6_startX, pos_t6_startY)
					guicontrol,, CurrentLoop, Current Location: %location%
					controller.Axes.LX.SetState(70)
					Sleep(1000)
					Accel_on(75)
					CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
					location := "T6 End"
					CheckTokyoTurn(pos_t6_endX, pos_t6_endY)
					guicontrol,, CurrentLoop, Current Location: %location%
					controller.Axes.LX.SetState(40)
					Sleep(1000)
					; Turn 7
					location := "T7 Start"
					Accel_On(100)
					CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
					CheckTokyoTurn(pos_t7_startX, pos_t7_startY)
					guicontrol,, CurrentLoop, Current Location: %location%
					controller.Axes.LX.SetState(40)
					Sleep(1000)
					CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
					location := "T7 End"
					CheckTokyoTurn(pos_t7_endX, pos_t7_endY)
					guicontrol,, CurrentLoop, Current Location: %location%
					controller.Axes.LX.SetState(70)
					Sleep(1000)
					; Turn 8
					location := "T8 Start"
					CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
					CheckTokyoTurn(pos_t8_startX, pos_t8_startY)
					guicontrol,, CurrentLoop, Current Location: %location%
					controller.Axes.LX.SetState(65)
					Sleep(1000)
					CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
					location := "T8 End"
					CheckTokyoTurn(pos_t8_endX, pos_t8_endY)
					guicontrol,, CurrentLoop, Current Location: %location%
					controller.Axes.LX.SetState(30)
					Sleep(4000)
					Brake_on(100)
					Sleep(1800)
					Brake_off()
					Accel_On(40)
					; Penalty Warning
					CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
					location := "Hairpin Entrance"
					CheckTokyoPenWarn(pos_penwarnX, pos_penwarnY)
					Accel_On(30)
					guicontrol,, CurrentLoop, Current Location: %location%

					; Hairpin exit
					Sleep(10500)
					Accel_On(60)
					loop 120 {
						Press_Triangle(delay:=50)
						Sleep(200)
					}
					if (TokyoLapCount <= 11)
					{
						guicontrol,, CurrentLoop, Current Location: %location%
						CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
						location := "Pit entrance"
						CheckTokyoTurn(pos_t9_startX, pos_t9_startY)
						controller.Axes.LX.SetState(0)
						Accel_On(55)
						CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
						location := "In pit"
						CheckTokyoPitstop(pos_pitstopX, pos_pitstopY)
						guicontrol,, CurrentLoop, Current Location: %location%
						controller.Axes.LX.SetState(50)

						if (TokyoLapCount = 1) 
						{
							SetFormat, integerfast, d
							location := "In pit."
							guicontrol,, CurrentLoop, %location%
							;Sleep (PitstopTimingsArray1)
							Press_Up()
							Sleep (100)
							Press_X()
							Sleep (100)
							Press_X()
						}
						if (TokyoLapCount = 2) 
						{
							SetFormat, integerfast, d
							location := "In pit."
							guicontrol,, CurrentLoop, %location%
							;Sleep (PitstopTimingsArray2)
							Press_Up()
							Sleep (100)
							Press_X()
							Sleep (100)
							Press_X()
						}
						if (TokyoLapCount = 3)
						{
							SetFormat, integerfast, d
							location := "In pit."
							guicontrol,, CurrentLoop, %location%
							;Sleep (PitstopTimingsArray3)
							Press_Up()
							Sleep (100)
							Press_X()
							Sleep (100)
							Press_X()
						}
						if (TokyoLapCount = 4)
						{
							SetFormat, integerfast, d
							location := "In pit."
							guicontrol,, CurrentLoop, %location%
							;Sleep (PitstopTimingsArray4)
							Press_Up()
							Sleep (100)
							Press_X()
							Sleep (100)
							Press_X()
						}
						if (TokyoLapCount = 5)
						{
							SetFormat, integerfast, d
							location := "In pit."
							guicontrol,, CurrentLoop, %location%
							;Sleep (PitstopTimingsArray5)
							Press_Up()
							Sleep (100)
							Press_X()
							Sleep (100)
							Press_X()
						}
						if (TokyoLapCount = 6)
						{
							SetFormat, integerfast, d
							location := "In pit."
							guicontrol,, CurrentLoop, %location%
							;Sleep (PitstopTimingsArray6)
							Press_Up()
							Sleep (100)
							Press_X()
						}
						if (TokyoLapCount = 7)
						{
							SetFormat, integerfast, d
							location := "In pit."
							guicontrol,, CurrentLoop, %location%
							;Sleep (PitstopTimingsArray7)
							Press_Up()
							Sleep (100)
							Press_X()
							Sleep (100)
							Press_X()
						}
						if (TokyoLapCount = 8) 
						{
							SetFormat, integerfast, d
							location := "In pit."
							guicontrol,, CurrentLoop, %location%
							;Sleep (PitstopTimingsArray8)
							Press_Up()
							Sleep (100)
							Press_X()
							Sleep (100)
							Press_X()
						}
						if (TokyoLapCount = 9) 
						{
							SetFormat, integerfast, d
							location := "In pit."
							guicontrol,, CurrentLoop, %location%
							;Sleep (PitstopTimingsArray9)
							Press_Up()
							Sleep (100)
							Press_X()
							Sleep (100)
							Press_X()
						}
						if (TokyoLapCount = 10) 
						{
							SetFormat, integerfast, d
							location := "In pit."
							guicontrol,, CurrentLoop, %location%
							;Sleep (PitstopTimingsArray10)
							Press_Up()
							Sleep (100)
							Press_X()
							Sleep (100)
							Press_X()
						}
						if (TokyoLapCount = 11) 
						{
							SetFormat, integerfast, d
							location := "In pit."
							guicontrol,, CurrentLoop, %location%
							;Sleep (PitstopTimingsArray11)
							Press_Up()
							Sleep (100)
							Press_X()
							Sleep (100)
							Press_X()
						}
						if (TokyoLapCount = 12) 
						{
							SetFormat, integerfast, d
							location := "In pit."
							guicontrol,, CurrentLoop, %location%
							;Sleep (PitstopTimingsArray12)
							Press_Up()
							Sleep (100)
							Press_X()
							Sleep (100)
							Press_X()
						}
						controller.Axes.LX.SetState(20)
						Accel_On(100)
						CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)	
						CheckTokyoPenReceived(pos_penX, pos_penY)
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
						CheckMaxTime(maxTime, loopStartTime, TokyoLapCount)
						CheckTokyoTurn(pos_t9_startX, pos_t9_startY)
						location := "Start/Finish"
						guicontrol,, CurrentLoop, Current Location: %location%
						Accel_On(100)
						controller.Axes.LX.SetState(67)
						Sleep(8000)
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
						if (StrLen(TelegramBotToken) > 1)
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
						lapcounter := 0
						ProgressRace := 0
						guicontrol,, RaceProgress, %ProgressRace%
						Sleep(12000)
						loop
						{
							restart_found := false
							c2 := BitGrab(pos_restartX,pos_restartY, 2)
							for i, c in c2
							{
								d2 := Distance(c, color_restart)
								SB_SetText(" Searching restart: " d2 " < 10",2)
								if (d2 < 10 )
								{
									SB_SetText(" Found: " d2 " < 10",2)
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
							Race_Tokyo()
						case SetEnd = 1:
							SetTimer, UpdateTimer, Off
							MsgBox GG! Set end was reached.`nPress Ok to exit the script.
							gosub, GUIClose
						case SetEnd > 2:
							SetEnd--
							guicontrol,, SetEndUD, %SetEnd%
							guicontrol,, SetEndButton, End after %SetEnd% wins
							Race_Tokyo()
						case SetEnd = 2:
							SetEnd--
							guicontrol,, SetEndUD, %SetEnd%
							guicontrol,, SetEndButton, End after next win
							Race_Tokyo()
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
					this.endX := endX
					this.endY := endY
				}
			}

			CheckTokyoRaceStart(x,y, b_size := 1)
			{
				turnStart := A_TickCount
				loop
				{
					TokyoRestartFound := false
					c2 := BitGrab(x, y, 2)
					for i, c in c2
					{
						d2 := Distance(c, color_racestart)
						SB_SetText(" Searching Race start: " d2 " < 35",2)
						if (d2 < 35 )
						{
							TokyoRestartFound := true
							break
						}
					}

					if (A_TickCount - turnStart > 12000) { 
						; we are lost, where are we?
						gosub, FindMe
					}
				} until TokyoRestartFound = true
				SB_SetText(" Found Race start: " d2 " < 35",2)
				return
			}
			FindMe:
				loop 100 {

					c2 := BitGrab(pos_lostX, pos_lostY, 2)
					for i, c in c2
					{

						d2 := Distance(c, color_lost)
						SB_SetText(d2,2)
						if (d2 < 15 )
						{
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

				CheckTokyoTurn(x,y, b_size := 1)
				{
					turnStart := A_TickCount
					TokyoTurnComplete := false
					loop {

						tc := BitGrab(x, y, b_size)
						for i, c in tc
						{
							td := Distance(c, color_player)
							SB_SetText(" Searching: " td " < 50",2)
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

				CheckTokyoPenWarn(x,y, b_size := 1)
				{
					pen1Start := A_TickCount
					TokyoPenWarn := false
					loop {

						tc := BitGrab(x, y, b_size)
						for i, c in tc
						{
							td := Distance(c, color_penwarn)
							SB_SetText(" Searching pen warning: " td " < 50",2)
							if (td < 50 ){
								SB_SetText(" Found: " td " < 50",2)
								TokyoPenWarn := true
								break
							}		
						}
						; add recovery so we don't kill run looking for Pen1. Gonna start with a high number, can adjust lower later.
						; started with 1.5 mins, i had these set to 3:33 on other file and still won.
						if (A_TickCount - pen1Start > 90000) { 
							GoSub, ResetRace
							break
						}

					} until TokyoPenWarn = true
					return
				}

				CheckTokyoPenReceived(x,y, b_size := 1)
				{
					start := A_TickCount
					TokyoPenReceived := false
					loop {

						tc := BitGrab(x, y, b_size)
						for i, c in tc
						{
							td := Distance(c, color_pen)
							SB_SetText(" Searching pen msg: " td " < 40",2)
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

					TokyoPitstopDone := false
					loop {

						tc := BitGrab(x, y, b_size)
						for i, c in tc
						{
							td := Distance(c, color_pen)
							SB_SetText(" Searching pen msg: " td " > 10",2)
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
					else if (A_TickCount - loopStartTime > maxTime+45000 AND TokyoLapCount > 10)
					{
						gosub, ResetRace
					}
				}

				CheckTokyoPitstop(x,y, b_size := 1)
				{
					pitstopStart := A_TickCount

					;color_pitstop1 := 0xFFFFFF
					;color_pitstop1 := 0x818002
					;color_pitstop1 := 0xFBFB00 ; old color
					TokyoPitstop := false
					loop {

						tc := BitGrab(x, y, b_size)
						for i, c in tc
						{
							td := Distance(c, color_pitstop)
							SB_SetText(" Searching pit menu: " td " < 10",2)
							if (td < 10 ){
								SB_SetText(" Found: " td " < 10",2)
								TokyoPitstop := true
								break
							}
						}
						; add recovery so we don't kill run sitting in pit, havent tested if press down works to get us out
						if (A_TickCount - pitstopStart > 60000) {
							Press_Down()
							Sleep(300)
							Press_X()
							Sleep(500)
							Press_X()
							Sleep(7000)
							GoSub, ResetRace
						}

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