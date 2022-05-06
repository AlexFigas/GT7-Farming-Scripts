
; https://github.com/berban/Gdip

#HotkeyInterval 99000000
#KeyHistory 0
#MaxHotkeysPerInterval 99000000
#NoEnv
#Persistent
#SingleInstance Force
#Include Lib\Gdip.ahk
#Include Lib\AHK-ViGEm-Bus.ahk

CoordMode, Pixel, Client
CoordMode, ToolTip, Client
DetectHiddenWindows, On
ListLines Off
Process, priority, , High
SendMode Input
SetBatchLines, -1
SetDefaultMouseSpeed, 0
SetFormat, Float, 0.2
; SetFormat, IntegerFast, Hex
SetKeyDelay, 50
SetMouseDelay, -1
SetWorkingDir %A_ScriptDir%

; Variables
races_clean := 0
races_clean_percent := 0
races_completed := 0
races_completed_check := 0
credits_total := 0
credits_average := 0

time_start := A_TickCount
time_current := A_TickCount

window_width := 640
window_height := 360

; Create a new controller controller
controller := new ViGEmDS4()

; Menu
Menu, Tray, Icon, clubman.ico
Menu, tray, Tip, ClubmanPlus

; GUI
Gui, New, -MaximizeBox -Resize, ClubmanPlus 0.8
Gui, Font, S10
Gui, Add, Text, w300 vStatRace, Race Counts: %races_completed%
Gui, Add, Text, y+0 w300 vCleanRace, Clean Races: %races_clean%
Gui, Add, Text, y+0 w300 vCleanRate, Average Clean Runs: %races_clean_percent%`%
Gui, Add, Text, y+0 w300 vEarnings, Earnings: %credits_total%M
Gui, Add, Text, y+0 w300 vEarningsRate, Earnings Rate: %credits_average%M/hr
Gui, Add, Text, y+0 w300 vRunningTime, Running Time: 00:00:00
Gui, Add, Button, w150 h40 Default gStart, Start
Gui, Add, Button, w150 h40 x+10 gReset, Reset
Gui, Show
return

; GUI events
GuiClose:
    Gosub, Release_All
    SetTimer, Health, Off
    SetTimer, Summary, Off
    OutputDebug % "Clubman> Terminated"
ExitApp

; GUI controls
Stats:
    format_avg_clean_race := Format("{1:0.2f}", races_clean_percent)
    format_earnings := Format("{1:0.2f}", credits_total)
    format_earnings_rate := Format("{1:0.2f}", credits_average)
    format_time := MillisecToTime(time_current - time_start)

    GuiControl,,StatRace, Race Counts: %races_completed%
    GuiControl,,CleanRace, Clean Races: %races_clean%
    GuiControl,,CleanRate, Average Clean Runs: %format_avg_clean_race%`%
    GuiControl,,Earnings, Earnings: %format_earnings%M
    GuiControl,,EarningsRate, Earnings Rate: %format_earnings_rate%M/hr
    GuiControl,,RunningTime, Running Time: %format_time%
Return

Start:
    hwnd := 0

    Gosub, Release_All
    Gosub, GrabWindow

    if (hwnd = 0) {
        MsgBox, % "PS Remote Play not found"
        Return
    }

    SetTimer, Health, 600000
    SetTimer, Summary, 3600000
    time_start := A_TickCount

    ; ** AFK Loop
    Gosub, Press_X

    Loop {

        ; ** RACE
        OutputDebug % "Clubman> Race: Waiting for tire indicator to show"
        while (!IsColor(hwnd, 0xFFFFFF, 218, 490, 6, 50)) { ; top-right tire wear indicator
            Gosub, Press_X
            Sleep, 500
        }
        OutputDebug % "Clubman> Race: Starting race"
        Gosub, Hold_X
        ; Gosub, Hold_Down
        race_loop := 0
        Loop {
            while (IsColor(hwnd, 0xFFFFFF, 218, 490, 6, 50)) { ; top-right tire wear indicator
                race_loop := 7
            }

            if (race_loop == 0) {
                OutputDebug % "Clubman> Race: Race ended, releasing all buttons"
                Gosub, Release_All
                Sleep, 500
                Gosub, Press_X
                break
            } else {
                race_loop--
            }
            OutputDebug % "Clubman> Race: Indicator not found, checking " race_loop " more time(s)"
            Sleep, 1000
        }

        ; ** LEADERBOARD
        OutputDebug % "Clubman> Leaderboard: Checking positions"
        Loop {
            if (IsColor(hwnd, 0xBADD3E, 671, 124, 10, 50)) { ; venom green on the leaderboard
                OutputDebug % "Clubman> Leaderboard: 1st position"
                Gosub, Press_X
                break
            }
            else if (IsColor(hwnd, 0xBADD3E, 671, 153, 10, 50)) { ; venom green on the leaderboard
                OutputDebug % "Clubman> Leaderboard: 2nd position"
                Gosub, Press_X
                break
            }
            else if (IsColor(hwnd, 0xBADD3E, 671, 182, 10, 50)) { ; venom green on the leaderboard
                OutputDebug % "Clubman> Leaderboard: 3rd position"
                Gosub, Press_X
                break
            }
            else if (IsColor(hwnd, 0xBADD3E, 671, 211, 10, 50)) { ; venom green on the leaderboard
                OutputDebug % "Clubman> Leaderboard: 4th position"
                Gosub, Press_X
                break
            }
            else if (IsColor(hwnd, 0xBADD3E, 671, 240, 10, 50)) { ; venom green on the leaderboard
                OutputDebug % "Clubman> Leaderboard: 5th position"
                Gosub, Press_X
                break
            }
            else {
                Sleep, 500
            }
        }

        ; ** REWARDS
        OutputDebug % "Clubman> Rewards: Waiting for Rewards screen to load (checking money earnt)"
        while (!IsColor(hwnd, 0xBE140F, 848, 192, 6, 100)) { ; money earn, the red text
            Gosub, Press_X
            Sleep, 500
        }
        OutputDebug % "Clubman> Rewards: Found Rewards screen"
        races_completed++

        Loop 100 {
            if (IsColor(hwnd, 0x5C90FB, 451, 260, 10, 50)) { ; the 'R' in Clean Race Bonus
                OutputDebug % "Clubman> Rewards: Clean bonus"
                races_clean++
                break
            }

            if (A_Index == 100) {
                OutputDebug % "Clubman> Rewards: No clean bonus"
            }
        }

        ; ** REPLAY
        OutputDebug % "Clubman> Replay: Waiting for Replay screen to load"
        while (!IsColor(hwnd, 0xFFFFFF, 911, 510, 4, 50)) { ; the cursor on top the exit button
            Gosub, Press_X
            Sleep, 500
        }
        OutputDebug % "Clubman> Replay: Pressing the Exit button"
        while (IsColor(hwnd, 0xFFFFFF, 911, 510, 4, 50)) { ; the cursor on top the exit button
            Gosub, Press_X
            Sleep, 500
        }
        OutputDebug % "Clubman> Replay: Leaving the Replay screen"

        ; ** RACE RESULTS
        OutputDebug % "Clubman> Race Result: Waiting for Race Result screen to load (checking cursor)"
        while (!IsColor(hwnd, 0xBE1E1C, 651, 497, 6, 50)) { ; the exit button
            Sleep, 500
        }
        OutputDebug % "Clubman> Race Result: Moving cursor to the Retry button"
        while (!IsColor(hwnd, 0xFFFFFF, 514, 504, 6, 50)) { ; cursor on top the retry button
            Gosub, Press_Right
            Sleep, 500
        }
        OutputDebug % "Clubman> Race Result: Pressing the Retry button"
        while (IsColor(hwnd, 0xFFFFFF, 514, 504, 6, 50)) { ; cursor on top the retry button
            Gosub, Press_X
            Sleep, 500
        }

        ; ** RACE START
        OutputDebug % "Clubman> Race Start: Waiting for Race Start screen to load (checking cursor)"
        while (!IsColor(hwnd, 0xFFFFFF, 287, 504, 4, 50)) { ; cursor on top the start button
            Sleep, 500
        }
        OutputDebug % "Clubman> Race Start: Pressing the Start button"
        while (IsColor(hwnd, 0xFFFFFF, 287, 504, 4, 50)) { ; cursor on top the start button
            Gosub, Press_X
            Sleep, 500
        }

        OutputDebug % "--- Summary ---"
        credits_total := (races_completed * 0.07 + races_clean * 0.035)
        races_clean_percent := (races_clean / races_completed) * 100
        time_current := A_TickCount
        credits_average := credits_total / (time_current - time_start) * 3600000

        Gosub, Stats

        OutputDebug % "Clubman> Summary: Races " races_completed
        OutputDebug % "Clubman> Summary: Races Clean " races_clean
        OutputDebug % "Clubman> Summary: Races Clean Rate " races_clean_percent "%"
        OutputDebug % "Clubman> Summary: Earnings " credits_total "M"
        OutputDebug % "Clubman> Summary: Earnings Rate " credits_average "M/Hr"
        OutputDebug % "Clubman> Summary: Running Time " MillisecToTime(time_current - time_start)
        OutputDebug % "---------------"
    }
return

Reset:
    OutputDebug % "Clubman> Reloading"
    Gosub, Release_All
    SetTimer, Health, Off
    SetTimer, Summary, Off
    Reload

    Gosub, GrabWindow
    OutputDebug % "Clubman> is color? " IsColor(hwnd, 0xFFFFFF, 218, 490, 6, 20)
    PixelSearch(218, 490, 10, hwnd, "debug")
return

; -------------------
; Health Check
; -------------------
Health:
    FormatTime, current_date,, % "yyMMdd-HHmm-ss"
    OutputDebug % "Clubman> Health: Checking health at " current_date
    OutputDebug % "Clubman> Health: Races completed " races_completed
    OutputDebug % "Clubman> Health: Races completed last time " races_completed_check

    if (races_completed_check >= races_completed) {
        OutputDebug % "Clubman> Health: Error dectected, sending notification"
        SendNotification("ClubmanPlus", "Something went wrong", 2, "persistent")
    } else {
        OutputDebug % "Clubman> Health: Running healthy"
        races_completed_check := races_completed
    }
Return

; -------------------
; Summary Check
; -------------------
Summary:
    OutputDebug % "Clubman> Summary: Sending summary notification"
    message := ""
    message := message "Races " races_clean " / " races_completed " (" races_clean_percent ")`n"
    message := message "Earnings " credits_total "M (" credits_average "M/Hr)"
    SendNotification("ClubmanPlus", message, 0, "cashregister")
Return

; -------------------
; Send Notification
; -------------------
SendNotification(title, message, level, sound) {

    IniRead, token, %A_ScriptDir%\clubman.ini, pushover, token
    IniRead, user, %A_ScriptDir%\clubman.ini, pushover, user_key

    retries := 60
    expires := 3600

    url := "https://api.pushover.net/1/messages.json"
    param := "token=" token "&user=" user "&title=" title "&message=" message "&sound=" sound "&priority=" level

    if (level == 2) {
        param := param "&retry=" retries "&expire=" expires
    }

    WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    WebRequest.Open("POST", url)
    WebRequest.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    WebRequest.Send(param)
Return
}

; -------------------
; Grab Window
; -------------------
GrabWindow:
    OutputDebug % "Clubman> Looking for window"
    hwnd := WinExist("PS Remote Play")

    if (hwnd > 0) {
        OutputDebug % "Clubman> Window found: " hwnd
        WinMove, ahk_id %hwnd%,,,, %window_width%, %window_height%
        WinActivate, ahk_id %hwnd%
        WinSet, Style, -0x40000, ahk_id %hwnd%
    }
return

; -------------------
; Is Color
; -------------------
IsColor(hwnd, target_color, x, y, b, tolerance) {
    for i, c in PixelSearch(x, y, b, hwnd) {
        if (ColorDistance(c, target_color) <= tolerance) {
            Return True
        }
    }
Return False
}

; -------------------
; Color Distance
; -------------------
ColorDistance( c1, c2 ) {
    r1 := c1 >> 16
    g1 := c1 >> 8 & 255
    b1 := c1 & 255
    r2 := c2 >> 16
    g2 := c2 >> 8 & 255
    b2 := c2 & 255
return Sqrt( (r1-r2)**2 + (g1-g2)**2 + (b1-b2)**2 )
}

; -------------------
; Pixel Search
; -------------------
PixelSearch(x, y, b, hwnd, debugsave := "" ) {
    ; Get ratio of coordinates taken on a 150% scaling display
    x := (960 / x) ; 960 = 640 * 150
    y := (540 / y) ; 540 = 360 * 150

    ; Get current client coordinates from the ratio
    VarSetCapacity(rect, 16)
    DllCall("GetClientRect", "ptr", hwnd, "ptr", &rect)
    x := floor(NumGet(rect, 8, "int") // x)
    y := floor(NumGet(rect, 12, "int") // y)
    b := floor((b * NumGet(rect, 8, "int")) / 960)

    ; Get client area
    If !pToken := Gdip_Startup() {
        MsgBox, 48, % "ClubmanPlus: Error", % "Gdiplus failed to start. Please ensure you have gdiplus on your system"
        ExitApp
    }
    hBitmap := BitmapFromHwnd(hwnd, True, [x-b, y-b, b*2, b*2])
    pBitmap := Gdip_CreateBitmapFromHBITMAP(hBitmap)

    ; Get pixels
    pixels := []
    Loop % Gdip_GetImageWidth(pBitmap) {
        i := A_Index - 1
        Loop % Gdip_GetImageHeight(pBitmap) {
            j := A_Index - 1
            pixels.Push(Gdip_GetPixel(pBitmap, i, j) & 0x00FFFFFF)
        }
    }

    ; Save for debug purposes
    if (debugsave != "") {
        Gdip_SaveBitmapToFile(pBitmap, A_ScriptDir . "\" . CurrentDate() . "-" . debugsave . ".bmp")
    }

    ; Clean up
    DllCall("DeleteObject", A_PtrSize ? "UPtr" : "UInt", hBitmap)
    Gdip_DisposeImage(pBitmap)
    Gdip_Shutdown(pToken)
Return pixels
}

BitmapFromHwnd(hWnd:=-1, Client:=0, A:="", C:="" ) {
    A := IsObject(A) ? A : StrLen(A) ? StrSplit( A, ",", A_Space ) : {}, A.tBM := 0
    Client := ( ( A.FS := hWnd=-1 ) ? False : !!Client ), A.DrawCursor := "DrawCursor"
    hWnd := ( A.FS ? DllCall( "GetDesktopWindow", "UPtr" ) : WinExist( "ahk_id" . hWnd ) )

    A.SetCapacity( "WINDOWINFO", 62 ), A.Ptr := A.GetAddress( "WINDOWINFO" )
    A.RECT := NumPut( 62, A.Ptr, "UInt" ) + ( Client*16 )

    If (DllCall( "GetWindowInfo", "Ptr",hWnd, "Ptr",A.Ptr ) && DllCall( "IsWindowVisible", "Ptr",hWnd ) && DllCall( "IsIconic", "Ptr",hWnd ) = 0) {
        A.L := NumGet( A.RECT+ 0, "Int" ), A.X := ( A.1 <> "" ? A.1 : (A.FS ? A.L : 0) )
        A.T := NumGet( A.RECT+ 4, "Int" ), A.Y := ( A.2 <> "" ? A.2 : (A.FS ? A.T : 0 ))
        A.R := NumGet( A.RECT+ 8, "Int" ), A.W := ( A.3 > 0 ? A.3 : (A.R - A.L - Round(A.1)) )
        A.B := NumGet( A.RECT+12, "Int" ), A.H := ( A.4 > 0 ? A.4 : (A.B - A.T - Round(A.2)) )

        A.sDC := DllCall( Client ? "GetDC" : "GetWindowDC", "Ptr",hWnd, "UPtr" )
        A.mDC := DllCall( "CreateCompatibleDC", "Ptr",A.sDC, "UPtr")
        A.tBM := DllCall( "CreateCompatibleBitmap", "Ptr",A.sDC, "Int",A.W, "Int",A.H, "UPtr" )

        DllCall( "SaveDC", "Ptr",A.mDC )
        DllCall( "SelectObject", "Ptr",A.mDC, "Ptr",A.tBM )
        DllCall( "BitBlt", "Ptr",A.mDC, "Int",0, "Int",0, "Int",A.W, "Int",A.H, "Ptr",A.sDC, "Int",A.X, "Int",A.Y, "UInt",0x40CC0020 )

        A.R := ( IsObject(C) || StrLen(C) ) && IsFunc( A.DrawCursor ) ? A.DrawCursor( A.mDC, C ) : 0
        DllCall( "RestoreDC", "Ptr",A.mDC, "Int",-1 )
        DllCall( "DeleteDC", "Ptr",A.mDC )
        DllCall( "ReleaseDC", "Ptr",hWnd, "Ptr",A.sDC )
    }
Return A.tBM
}

; -------------------
; Time
; -------------------
MillisecToTime(msec) {
    secs := floor(mod((msec / 1000),60))
    mins := floor(mod((msec / (1000 * 60)), 60) )
    hour := floor(mod((msec / (1000 * 60 * 60)) , 24))
return Format("{:02}:{:02}:{:02}",hour,mins,secs)
}

CurrentDate(format := "") {
    FormatTime, out,, % "yyMMdd-HHmm-ss"
Return out
}

; -------------------
; Release All
; -------------------
Release_All:
    Gosub, Release_X
    Gosub, Release_O
    Gosub, Release_Right
    Gosub, Release_Left
    Gosub, Release_Up
    Gosub, Release_Down
return

; -------------------
; Press x
; -------------------
Press_X:
    Gosub, Hold_X
    Sleep, 50
    Gosub, Release_x
return

Hold_X:
    controller.Buttons.Cross.SetState(true)
return

Release_X:
    controller.Buttons.Cross.SetState(false)
return

; -------------------
; Press O
; -------------------
Press_O:
    Gosub, Hold_O
    Sleep, 50
    Gosub, Release_O
return

Hold_O:
    controller.Buttons.Circle.SetState(true)
return

Release_O:
    controller.Buttons.Circle.SetState(false)
return

; -------------------
; Press Right
; -------------------
Press_Right:
    Gosub, Hold_Right
    Sleep, 50
    Gosub, Release_Right
return

Hold_Right:
    controller.Dpad.SetState("Right")
return

Release_Right:
    controller.Dpad.SetState("None")
return

; -------------------
; Press Left
; -------------------
Press_Left:
    Gosub, Hold_Left
    Sleep, 50
    Gosub, Release_Left
return

Hold_Left:
    controller.Dpad.SetState("Left")
return

Release_Left:
    controller.Dpad.SetState("None")
return

; -------------------
; Press Up
; -------------------
Press_Up:
    Gosub, Hold_Up
    Sleep, 50
    Gosub, Release_Up
return

Hold_Up:
    controller.Dpad.SetState("Up")
return

Release_Up:
    controller.Dpad.SetState("None")
return

; -------------------
; Press Down
; -------------------
Press_Down:
    Gosub, Hold_Down
    Sleep, 50
    Gosub, Release_Down
return

Hold_Down:
    controller.Dpad.SetState("Down")
return

Release_Down:
    controller.Dpad.SetState("None")
return

; Hotkeys
^Esc::ExitApp
