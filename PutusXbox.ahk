; ============================================================
;  Tools.ahk  —  Dev Console + Xbox Logout Tools
;  Requires AHK v2.0+
; ============================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

CoordMode("Mouse", "Screen")
SendMode("Input")

; Icon
iconPath := A_MyDocuments "\..\Downloads\onlydits\assets\mamayo.ico"
if FileExist(iconPath)
    TraySetIcon(iconPath)

if !A_IsAdmin {
    Run('*RunAs "' A_ScriptFullPath '"')
    ExitApp()
}

; ────────────────────────────────────────────────────────────
;  UTIL (sama kaya Core-Logic)
; ────────────────────────────────────────────────────────────
RandInt(lo, hi) {
    return Integer(Round(Random(lo, hi)))
}

RandOff(base, variance) {
    return Integer(Round(base + Random(-variance, variance)))
}

RandSleep(lo, hi) {
    Sleep(RandInt(lo, hi))
}

; ────────────────────────────────────────────────────────────
;  BEZIER MOVEMENT (MEDIUM-SLOW)
; ────────────────────────────────────────────────────────────
BezierMove(x1, y1, x2, y2, steps, sleepMs) {
    offX := RandInt(18, 40)
    offY := RandInt(18, 40)
    mx := Integer(Round((x1+x2)/2)) + RandInt(-offX, offX)
    my := Integer(Round((y1+y2)/2)) + RandInt(-offY, offY)
    Loop steps {
        t  := A_Index / steps
        cx := Integer(Round((1-t)**2 * x1 + 2*(1-t)*t * mx + t**2 * x2)) + RandInt(-1, 1)
        cy := Integer(Round((1-t)**2 * y1 + 2*(1-t)*t * my + t**2 * y2)) + RandInt(-1, 1)
        MouseMove(cx, cy, 0)
        Sleep(sleepMs)
    }
    MouseMove(x2, y2, 0)
    Sleep(10)
}

HumanClickMedSlow(x, y, variance := 10) {
    MouseGetPos(&sx, &sy)
    tx := RandOff(x, variance)
    ty := RandOff(y, variance)
    
    BezierMove(Integer(sx), Integer(sy), tx, ty, RandInt(12, 22), RandInt(2, 6))
    
    Sleep(RandInt(18, 45))
    
    Send("{LButton down}")
    Sleep(RandInt(12, 35))
    Send("{LButton up}")
    
    Sleep(RandInt(25, 70))
}

directClick(x, y, variance := 3) {
    tx := RandOff(x, variance)
    ty := RandOff(y, variance)
    MouseMove(tx, ty, 0)
    Sleep(RandInt(8, 20))
    Send("{LButton down}")
    Sleep(RandInt(8, 18))
    Send("{LButton up}")
    Sleep(RandInt(10, 30))
}

; ────────────────────────────────────────────────────────────
;  CTRL+G — RUN SNIPPET (Dev Console)
; ────────────────────────────────────────────────────────────
^g:: {
    ; Buka Dev Console
    Send("^+i")
    RandSleep(450, 700)
    
    ; Klik area text editor (double click)
    HumanClickMedSlow(1049, 188, 11)
    RandSleep(60, 140)
    HumanClickMedSlow(1049, 188, 11)
    RandSleep(300, 550)
    
    ; Run snippet (double Ctrl+Enter)
    Send("^{Enter}")
    Sleep(100)
    Send("^{Enter}")
    RandSleep(350, 450)
    
    ; Klik btn di script
    HumanClickMedSlow(1832, 113, 9)  ; klik putus xbox
    RandSleep(1100, 1500)
    HumanClickMedSlow(985, 45, 9)
    RandSleep(70, 180)
    HumanClickMedSlow(997, 238, 9)
}

; ────────────────────────────────────────────────────────────
;  CTRL+L — LOGOUT XBOX
; ────────────────────────────────────────────────────────────
^l:: {
    RandSleep(220, 500)
    
    HumanClickMedSlow(985, 45, 9)
    RandSleep(70, 180)
    
    HumanClickMedSlow(1001, 367, 9)
    RandSleep(60, 140)
    HumanClickMedSlow(1001, 367, 9)
    RandSleep(70, 200)
    
    HumanClickMedSlow(1047, 365, 11)
    RandSleep(70, 200)
    
    ; Scroll ke bawah
    scrollCount := RandInt(7, 13)
    Loop scrollCount {
        Send("{WheelDown}")
        Sleep(RandInt(18, 40))
    }
    
    RandSleep(120, 280)
    
    HumanClickMedSlow(1451, 410, 9)
    RandSleep(60, 140)
    HumanClickMedSlow(1451, 410, 9)
    RandSleep(70, 200)
    
    HumanClickMedSlow(1494, 377, 9)
    RandSleep(60, 140)
    HumanClickMedSlow(1494, 377, 9)

    Sleep(150)
    directClick(1352, 806)
    Sleep(150)
    Send("^v")
    Sleep(400)
    Send("^a")
    Sleep(350)
    Send("{Backspace}")
    Sleep(350)
    Send("{Enter}")
    


}

; ────────────────────────────────────────────────────────────
;  EXIT
; ────────────────────────────────────────────────────────────
^Esc:: ExitApp()