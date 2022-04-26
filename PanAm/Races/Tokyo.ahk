GoTo EndRace_Tokyo_Def
Race_Tokyo()
{
	pitlap := 99 ; x = end of lap x
	tires := 0 ; 0 = racing hard / 1 = intermediates

	;-------------------------------------------------------------------------------------------------------
	; no touchy touchy code from here on - only commented lines, starting with "BETA TESTER - "
	;-------------------------------------------------------------------------------------------------------
	lapcounter := 0
	outlap := 0
	color_player := 0xDE6E70
	color_pen := 0xFFC10B
	hairpin_complete := false
	hairpinX := 506
	hairpinY := 72
	hairpin2X := 360
	hairpin2Y := 154
	hairpin3X := 408
	hairpin3Y := 154
	hairpinCount := 0
	hairpinTolerance := 10

	loop 12 {
		if (lapcounter = 0) {
			Sleep(2000)
			loop 4 {
				Press_Up(delay:=200)
				Sleep(200)
			}
			Sleep(5000)
			Accel_On(100)
			loop 3 {
				Press_Triangle(delay:=50)
				Sleep(650)
			}
			Turn_Left(500,20) ; BETA TESTER - decrease "20" if you dont get the pen on start // temp solution until turn detection
			Turn_Left(33000,36) ; BETA TESTER - from straight to after t1 - adjust if you hit with a bad angle // temp solution until turn detection
			Turn_Right(27000,70) ; BETA TESTER - from chicane to hairpin entrance // temp solution until turn detection
		}
		if (lapcounter >= 1) and (outlap = 0) {
			Turn_Left(26000,36) ; BETA TESTER - from straight to after t1 - adjust if you hit with a bad angle // temp solution until turn detection
			Turn_Right(22000,68) ; BETA TESTER - from chicane to hairpin entrance // temp solution until turn detection
		}
		if (outlap = 1) {
			Turn_Left(34000,36) ; BETA TESTER - IF WE NEED A PITSTOP, GET TIMINGS (from straight to after t1) // temp solution until turn detection
			Turn_Right(35000,72) ; BETA TESTER - IF WE NEED A PITSTOP, GET TIMINGS (from chicane to hairpin entrance) // temp solution until turn detection
			outlap := 0
		}
		loop
		{
			tc := BitGrab(hairpinX, hairpinY,2)
			for i, c in tc
			{
				td := Distance(c, color_player)
				if (td < 30 ){
					hairpin_complete := false
					hairpinCount += 1
					break
				}
			}
			if( hairpinCount = 1 )
				break
			Sleep(100)
		}
		controller.Axes.LX.SetState(70)
		Sleep(2700)
		Brake_On(100)
		controller.Axes.LX.SetState(65)
		loop 4 {
			Press_Square(delay:=200)
			Sleep(200)
		}
		Sleep(2000)
		Brake_Off()

		controller.Axes.LX.SetState(86)
		loop
		{
			tc := BitGrab(hairpin2X, hairpin2Y,2)
			for i, c in tc
			{
				td := Distance(c, color_pen)
				if (td < 40 ){
					hairpin_complete := false
					hairpinCount += 1
					break
				}
			}
			if( hairpinCount = 2 )
				break
		}
		loop 1 {
			Press_Triangle(delay:=50)
			Sleep(30)
		}
		controller.Axes.LX.SetState(60) 

		if (lapcounter = 0){
			Sleep(3700) ; BETA TESTER - time before turning right for hairpin
		}
		if (lapcounter >= 1){
			Sleep(3650) ; BETA TESTER - time before turning right for hairpin
		}

		Accel_Off()
		controller.Axes.LX.SetState(100) ; BETA TESTER - increase for harder right, decrease for softer

		Sleep(6400) ; BETA TESTER - how long we hold hard right
		Accel_On(89) ; BETA TESTER - how fast we accelerate until serving pen, faster is not better - longer braking distance, bad for pen trigger
		controller.Axes.LX.SetState(77) ; BETA TESTER - how hard we hug the wall until pen
		loop 3 {
			Press_Triangle(delay:=100)
			Sleep(50)
		}

		loop
		{
			tc := BitGrab(hairpin3X, hairpin3Y,2)
			for i, c in tc
			{
				td := Distance(c, color_pen)
				if (td > 60 ){
					hairpin_complete := true
					hairpinCount += 1
					break
				}
			}
			if( hairpinCount = 3 )
				break
		}
		hairpinCount := 0
		if (pitlap = lapcounter){
			Turn_Left(1000, 40)
			controller.Axes.LX.SetState(35)
			Turn_Right(1000, 60)
			controller.Axes.LX.SetState(40)
			Sleep (5000)
			controller.Axes.LX.SetState(0)
			Sleep (20000)
			Press_Up()
			Sleep (100)
			if (tires = 0) {
				loop, 5 {
					Press_Left()
				}
			}
			if (tires = 1) {
				Press_Right()
			}
			Press_X()
			Press_Down()
			Press_X()
			controller.Axes.LX.SetState(50)
			Sleep, 7000
			Turn_Left(3500,0)
			controller.Axes.LX.SetState(20)
			loop 4 {
				Press_X(delay:=200)
				sleep, 200
			}
			outlap := 1
		}
		else {
			if(lapcounter < 11)
			{
				Brake_on(100)
				Turn_Left(400, 30)
				Turn_Right(600, 60)
				Sleep(4000)
				Brake_off()
				Accel_On(100)
				controller.Axes.LX.SetState(57)
				Sleep(3000)
				Turn_Right(5000, 70)
				Turn_Right(7000, 65)
			}
			if (lapcounter = 11)
				Turn_Right(30000, 75)
		}
		lapcounter++
	}
}
EndRace_Tokyo_Def: