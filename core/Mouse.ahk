; ============================================================
;  core/Mouse.ahk — Human-like mouse movement
;  FIX: Click() harus pakai koordinat eksplisit di AHK v2
;       Click() kosong = klik di posisi mouse saat itu,
;       tapi ada race condition dengan MouseMove speed=0.
;       Solusi: selalu pass x,y ke Click langsung.
; ============================================================

RandInt(lo, hi) {
    return Integer(Round(Random(lo, hi)))
}

RandOff(base, variance) {
    return Integer(Round(base + Random(-variance, variance)))
}

RandSleep(lo, hi) {
    Sleep(RandInt(lo, hi))
}

Delay() {
    global CFG
    RandSleep(CFG["delay_min"], CFG["delay_max"])
}

BezierMove(x1, y1, x2, y2, steps, sleepMs) {
    global CFG
    offX := RandInt(CFG["bez_offset_min"], CFG["bez_offset_max"])
    offY := RandInt(CFG["bez_offset_min"], CFG["bez_offset_max"])
    mx   := Integer(Round((x1+x2)/2)) + RandInt(-offX, offX)
    my   := Integer(Round((y1+y2)/2)) + RandInt(-offY, offY)
    Loop steps {
        t  := A_Index / steps
        cx := Integer(Round((1-t)**2 * x1 + 2*(1-t)*t * mx + t**2 * x2)) + RandInt(-1, 1)
        cy := Integer(Round((1-t)**2 * y1 + 2*(1-t)*t * my + t**2 * y2)) + RandInt(-1, 1)
        MouseMove(cx, cy, 0)
        Sleep(sleepMs)
    }
    ; Pastikan mouse tepat di target sebelum klik
    MouseMove(x2, y2, 0)
    Sleep(15)  ; sedikit settle time — cukup untuk OS flush mouse event
}

; ── FIX UTAMA: pass tx/ty langsung ke Click ──────────────────
HumanClick(x, y, variance := 8) {
    global CFG
    MouseGetPos(&sx, &sy)
    tx := RandOff(x, variance)
    ty := RandOff(y, variance)
    BezierMove(Integer(sx), Integer(sy), tx, ty,
               RandInt(CFG["bez_steps_min"], CFG["bez_steps_max"]),
               RandInt(CFG["bez_sleep_min"], CFG["bez_sleep_max"]))
    Sleep(RandInt(CFG["click_pre"], CFG["click_pre"] + 15))
    ; FIX: koordinat eksplisit, bukan Click() kosong
    Click(tx " " ty)
    Sleep(RandInt(CFG["click_post"], CFG["click_post"] + 25))
}

HumanDoubleClick(x, y, variance := 8) {
    global CFG
    MouseGetPos(&sx, &sy)
    tx := RandOff(x, variance)
    ty := RandOff(y, variance)
    BezierMove(Integer(sx), Integer(sy), tx, ty,
               RandInt(CFG["bez_steps_min"], CFG["bez_steps_max"]),
               RandInt(CFG["bez_sleep_min"], CFG["bez_sleep_max"]))
    Sleep(RandInt(CFG["click_pre"], CFG["click_pre"] + 15))
    ; FIX: koordinat eksplisit
    Click(tx " " ty " 2")
    Sleep(RandInt(CFG["click_post"], CFG["click_post"] + 25))
}

; DirectClick: tanpa bezier, langsung ke koordinat
; Tetap pakai koordinat eksplisit
DirectClick(x, y) {
    ix := Integer(x)
    iy := Integer(y)
    MouseMove(ix, iy, 0)
    Sleep(20)
    Click(ix " " iy)
    Sleep(30)
}

DirectDoubleClick(x, y) {
    ix := Integer(x)
    iy := Integer(y)
    MouseMove(ix, iy, 0)
    Sleep(20)
    Click(ix " " iy " 2")
    Sleep(30)
}
