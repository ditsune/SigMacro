; ============================================================
;  RegionSelector.ahk — Visual region picker untuk SigMacro
; ============================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
DllCall("SetProcessDPIAware")
CoordMode("Mouse", "Screen")

CFG_PATH := A_ScriptDir "\sigmacro.ini"

global g_regionKey  := ""
global g_regionName := ""

; ── GUI ──────────────────────────────────────────────────
g := Gui("+AlwaysOnTop", "Region Selector — SigMacro")
g.BackColor := "1E1E2E"
g.SetFont("s10 cCDD6F4 Bold", "Segoe UI")
g.Add("Text", "x15 y12 w350 Center", "Pilih region yang mau di-set:")
g.SetFont("s9 cA6E3A1 Norm", "Segoe UI")
g.Add("Text", "x15 y34 w350 Center", "Klik tombol → klik & drag di layar → lepas")

g.SetFont("s9 cCDD6F4 Bold", "Segoe UI")
b1 := g.Add("Button", "x15  y60 w100 h34", "Incompatible")
b2 := g.Add("Button", "x125 y60 w100 h34", "2FA Icon")
b3 := g.Add("Button", "x235 y60 w100 h34", "Password")
b4 := g.Add("Button", "x15  y104 w100 h34", "Invalid BC")
b5 := g.Add("Button", "x125 y104 w100 h34", "Roblox Home")
b6 := g.Add("Button", "x235 y104 w100 h34", "80 Robux")
b7 := g.Add("Button", "x15  y148 w100 h34", "Robux List")
b8 := g.Add("Button", "x125 y148 w100 h34", "Don't Buy")

g.SetFont("s8 cF38BA8 Norm", "Segoe UI")
statusLbl := g.Add("Text", "x15 y192 w350 Center vStatusLbl", "Belum ada region dipilih")
g.SetFont("s8 c89B4FA Norm", "Segoe UI")
coordLbl  := g.Add("Text", "x15 y208 w350 Center vCoordLbl",  "")
g.SetFont("s8 cA6E3A1 Norm", "Segoe UI")
savedLbl  := g.Add("Text", "x15 y224 w350 Center vSavedLbl",  "")
g.OnEvent("Close", (*) => ExitApp())
g.Show("w380 h255 x50 y50")

b1.OnEvent("Click", (*) => StartDrag("incompat",   "Incompatible Accounts"))
b2.OnEvent("Click", (*) => StartDrag("2fa",        "2FA Icon"))
b3.OnEvent("Click", (*) => StartDrag("pwd",        "Password Label"))
b4.OnEvent("Click", (*) => StartDrag("invalidbc",  "Invalid BC"))
b5.OnEvent("Click", (*) => StartDrag("robloxhome", "Roblox Home"))
b6.OnEvent("Click", (*) => StartDrag("80robux",    "80 Robux"))
b7.OnEvent("Click", (*) => StartDrag("robuxlist",  "Robux List"))
b8.OnEvent("Click", (*) => StartDrag("dontbuy",    "Don't Buy"))

StartDrag(regionKey, regionName) {
    global g_regionKey, g_regionName
    g_regionKey  := regionKey
    g_regionName := regionName
    g["StatusLbl"].Value := "⏳ Klik & drag di layar untuk [" regionName "]..."
    g["CoordLbl"].Value  := ""
    g["SavedLbl"].Value  := ""
    SetTimer(WaitForDrag, 50)
}

WaitForDrag() {
    if !GetKeyState("LButton", "P")
        return
    SetTimer(WaitForDrag, 0)
    DoDrag()
}

DoDrag() {
    global g_regionKey, g_regionName, CFG_PATH

    MouseGetPos(&x1, &y1)

    thick := 2

    top := MakeBar()
    bot := MakeBar()
    lft := MakeBar()
    rgt := MakeBar()

    loop {
        if !GetKeyState("LButton", "P")
            break

        MouseGetPos(&cx, &cy)
        rx := Min(x1, cx)
        ry := Min(y1, cy)
        rw := Max(Abs(cx - x1), 1)
        rh := Max(Abs(cy - y1), 1)

        top.Move(rx, ry, rw, thick)
        bot.Move(rx, ry + rh, rw, thick)
        lft.Move(rx, ry, thick, rh)
        rgt.Move(rx + rw, ry, thick, rh)

        Sleep(16)
    }

    MouseGetPos(&x2, &y2)

    top.Destroy()
    bot.Destroy()
    lft.Destroy()
    rgt.Destroy()

    rx1 := Min(x1, x2)
    ry1 := Min(y1, y2)
    rx2 := Max(x1, x2)
    ry2 := Max(y1, y2)

    if (Abs(rx2 - rx1) < 10 || Abs(ry2 - ry1) < 10) {
        g["StatusLbl"].Value := "❌ Terlalu kecil, coba lagi"
        return
    }

    key := g_regionKey
    IniWrite(rx1, CFG_PATH, "Regions", "region_" key "_x1")
    IniWrite(ry1, CFG_PATH, "Regions", "region_" key "_y1")
    IniWrite(rx2, CFG_PATH, "Regions", "region_" key "_x2")
    IniWrite(ry2, CFG_PATH, "Regions", "region_" key "_y2")

    g["StatusLbl"].Value := "✓ [" g_regionName "] tersimpan!"
    g["CoordLbl"].Value  := "x1=" rx1 "  y1=" ry1 "  x2=" rx2 "  y2=" ry2
    g["SavedLbl"].Value  := "→ Reload SigMacro untuk apply"
}

MakeBar() {
    bar := Gui("-Caption +ToolWindow +AlwaysOnTop +E0x20")
    bar.BackColor := "00FF00"
    WinSetTransparent(220, bar)
    bar.Show("x0 y0 w1 h1 NoActivate")
    return bar
}