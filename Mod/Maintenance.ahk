GoTo EndMaintenceDef

;This will do only an oil change. will leave user at race menu to resume.
GtAutoNav:
return

DoOilChange:
    Sleep, 1000
    Press_O()
    Sleep, 8800
    loop, 2 {
        Press_Right(140)
        Sleep, 200
    }
    Press_Down()
    Sleep, 200

    Press_X()
    Sleep, 1000
    loop, 2 { ; Makes sure it gets into the oil menu regardless the cursor starting point
        Press_Left(140)
        Sleep, 200
    }
    Press_X()
    Sleep, 1000

    Sleep, 4000
    Press_Down(140)
    Sleep, 200
    loop, 2 {
        Press_X()
        Sleep, 1500
    }
    Sleep, 7000
    Press_X()
    Sleep, 500

    Press_O()
    Sleep, 200
    Sleep, 7000
    Press_Up(140)
    Sleep, 200
    Press_Left()
    Sleep, 500
    Press_Left()
    Sleep, 500
    Press_X()
    Sleep, 11800
return

;This will do complete maintenance on the car including oil, engine and body. will leave user at race menu to resume.
DoMaintenance:

EndMaintenceDef:
