; ============================================================
;  Main.ahk  —  Sigmacro v2.1 (Modular Edition)
;  Requires AHK v2.0+
; ============================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon
DllCall("SetProcessDPIAware")

; ── COORDMODE — WAJIB sebelum semua include ───────────────
CoordMode("Mouse", "Screen")
CoordMode("Pixel", "Screen")
SendMode("Input")

; ── MODULES (urutan penting!) ──────────────────────────────
#Include shared\Constants.ahk
#Include shared\Config.ahk
#Include shared\Stats.ahk
#Include shared\Update.ahk
#Include core\Logger.ahk
#Include core\Mouse.ahk
#Include core\ImageSearch.ahk
#Include core\Logic.ahk
#Include ui\SettingsDialog.ahk

; ── INIT ───────────────────────────────────────────────────
if !A_IsAdmin {
    Run('*RunAs "' A_ScriptFullPath '"')
    ExitApp()
}

EnsureDefaultConfig()
LoadConfig()
LoadStats()

iconPath := A_MyDocuments "\..\Downloads\OnlyDits\assets\sticker.ico"
if FileExist(iconPath)
    TraySetIcon(iconPath)

; ── GLOBAL STATE ───────────────────────────────────────────
global g_IsRunning   := false
global g_TotalAttempts
global g_SuccessCount
global g_ActiveTab   := 1

; ============================================================
;  GUI
; ============================================================
global AppGui := Gui("+AlwaysOnTop", "Sigmacro v2.1")
global StatusText, EditLog, StatsText
global TabBtns := []

AppGui.BackColor := "F0F0F0"

; ── HEADER ─────────────────────────────────────────────────
AppGui.SetFont("s14 c222222 Bold", "Segoe UI")
AppGui.Add("Text", "x10 y8 w380 Center BackgroundTrans", "Sigmacro v2.1")

AppGui.SetFont("s9 c444444 Bold", "Segoe UI")
StatusText := AppGui.Add("Text", "x10 y40 w380 Center vStatusText BackgroundTrans", "Ready")

; ── TAB BUTTONS ────────────────────────────────────────────
tabLabels := ["Website", "Tele", "Backup Code", "Tools"]
tabX      := [10, 105, 200, 295]

AppGui.SetFont("s9 c000000 Norm", "Segoe UI")
loop 4 {
    i   := A_Index
    btn := AppGui.Add("Button", "x" tabX[i] " y68 w92 h24", tabLabels[i])
    btn.OnEvent("Click", TabClick.Bind(i))
    TabBtns.Push(btn)
}

; ============================================================
;  KONTEN TAB — semua dibuat sekaligus, non-aktif di-hide
; ============================================================
global TabControls := Map()

; Helper section label + separator
MakeSection(yLabel, labelText) {
    AppGui.SetFont("s8 c888888 Bold", "Segoe UI")
    lbl := AppGui.Add("Text", "x10 y" yLabel " w380 BackgroundTrans", labelText)
    sep := AppGui.Add("Text", "x10 y" (yLabel+13) " w380 h1 BackgroundTrans 0x10")
    return [lbl, sep]
}

; Helper tombol
MakeBtn(x, y, w, label) {
    AppGui.SetFont("s9 c000000 Norm", "Segoe UI")
    return AppGui.Add("Button", "x" x " y" y " w" w " h30", label)
}

; ── TAB 1 — WEBSITE ────────────────────────────────────────
{
    c := []
    c.Push(MakeSection(98,  "LOGIN (WEB)")*)
    c.Push(MakeBtn(22,  118, 178, "Login Website"))   ; idx 3
    c.Push(MakeBtn(206, 118, 178, "Clipboard Login Web"))     ; idx 4
    c.Push(MakeBtn(22,  154, 178, "PW Web"))            ; idx 5
    c.Push(MakeBtn(206, 154, 178, "Login di Web"))     ; idx 6


    c.Push(MakeSection(194, "BACKUP CODE (WEB)")*)
    c.Push(MakeBtn(22,  214, 178, "BC Email Web"))      ; idx 9
    c.Push(MakeBtn(206, 214, 178, "BC Retry Web"))      ; idx 10
    c.Push(MakeBtn(22,  250, 178, "BC Authen Web"))     ; idx 11
    c.Push(MakeBtn(206, 250, 178, "Copy BC Web"))       ; idx 12

    c.Push(MakeSection(290, "ROBUX PURCHASE")*)
    c.Push(MakeBtn(22,  310,  86, "Buy 80R"))           ; idx 15
    c.Push(MakeBtn(114, 310,  86, "Buy 500R"))          ; idx 16
    c.Push(MakeBtn(206, 310,  86, "Buy 1000R"))         ; idx 17
    c.Push(MakeBtn(298, 310,  86, "Buy 2000R"))         ; idx 18

    c.Push(MakeSection(350, "TOOLS")*)
    c.Push(MakeBtn(22,  370,  86, "↺ Reload"))          ; idx 21
    c.Push(MakeBtn(114, 370,  86, "✕ Exit"))            ; idx 22
    c.Push(MakeBtn(206, 370, 178, "⚙ Settings"))        ; idx 23

    c[3].OnEvent("Click",  (*) => GuiAction("Login Website", DoLoginWebsite))
    c[4].OnEvent("Click",  (*) => GuiAction("Clipboard Login Web", DoLoginClipboardWeb))
    c[5].OnEvent("Click",  (*) => GuiAction("PW Web",          PastePwClipboardWeb))
    c[6].OnEvent("Click",  (*) => GuiAction("Login di Web",    LoginWebRoblox))
    c[9].OnEvent("Click",  (*) => GuiAction("BC Email Web",   DoProsesBC1Web))
    c[10].OnEvent("Click",  (*) => GuiAction("BC Retry Web",   BCWithIncompatWeb))
    c[11].OnEvent("Click", (*) => GuiAction("BC Authen Web",  BCAuthenWeb))
    c[12].OnEvent("Click", (*) => GuiAction("Copy BC Web",    CopyBCWebsite))
    c[15].OnEvent("Click", (*) => GuiAction("Buy 80 Robux",  Beli80Robux))
    c[16].OnEvent("Click", (*) => GuiAction("Buy 500 Robux", Beli500Robux))
    c[17].OnEvent("Click", (*) => GuiAction("Buy 1000 Robux", Beli1000Robux))
    c[18].OnEvent("Click", (*) => GuiAction("Buy 2000 Robux", Beli2000Robux))
    c[21].OnEvent("Click", (*) => Reload())
    c[22].OnEvent("Click", (*) => ExitApp())
    c[23].OnEvent("Click", (*) => ShowSettingsDialog())

    TabControls[1] := c
}

; ── TAB 2 — TELE ───────────────────────────────────────────
{
    c := []
    c.Push(MakeSection(98,  "LOGIN (TELE)")*)
    c.Push(MakeBtn(22,  118, 178, "Clipboard Login Tele"))   ; idx 3
    c.Push(MakeBtn(206, 118, 178, "PW Tele"))           ; idx 4

    c.Push(MakeSection(158, "BACKUP CODE (TELE)")*)
    c.Push(MakeBtn(22,  178, 178, "BC Email Tele"))     ; idx 7
    c.Push(MakeBtn(206, 178, 178, "BC Retry Tele"))     ; idx 8
    c.Push(MakeBtn(22,  214, 178, "BC Authen Tele"))         ; idx 9
    c.Push(MakeBtn(206, 214, 178, "Copy BC"))           ; idx 10

    c.Push(MakeSection(254, "ROBUX PURCHASE")*)
    c.Push(MakeBtn(22,  274,  86, "Buy 80R"))           ; idx 13
    c.Push(MakeBtn(114, 274,  86, "Buy 500R"))          ; idx 14
    c.Push(MakeBtn(206, 274,  86, "Buy 1000R"))         ; idx 15
    c.Push(MakeBtn(298, 274,  86, "Buy 2000R"))         ; idx 16

    c.Push(MakeSection(314, "TOOLS")*)
    c.Push(MakeBtn(22,  334,  86, "↺ Reload"))          ; idx 19
    c.Push(MakeBtn(114, 334,  86, "✕ Exit"))            ; idx 20
    c.Push(MakeBtn(206, 334, 178, "⚙ Settings"))        ; idx 21

    c[3].OnEvent("Click",  (*) => GuiAction("Clipboard Login Tele", DoLoginClipboard))
    c[4].OnEvent("Click",  (*) => GuiAction("PW Tele",         PwdThenBC))
    c[7].OnEvent("Click",  (*) => GuiAction("BC Email Tele",   DoProsesBC1))
    c[8].OnEvent("Click",  (*) => GuiAction("BC Retry Tele",   BCWithIncompat))
    c[9].OnEvent("Click",  (*) => GuiAction("BC Authen Tele",  BCAuthen))
    c[10].OnEvent("Click", (*) => GuiAction("Copy BC Tele",    CopyBackupCodes))
    c[13].OnEvent("Click", (*) => GuiAction("Buy 80 Robux",  Beli80Robux))
    c[14].OnEvent("Click", (*) => GuiAction("Buy 500 Robux", Beli500Robux))
    c[15].OnEvent("Click", (*) => GuiAction("Buy 1000 Robux", Beli1000Robux))
    c[16].OnEvent("Click", (*) => GuiAction("Buy 2000 Robux", Beli2000Robux))
    c[19].OnEvent("Click", (*) => Reload())
    c[20].OnEvent("Click", (*) => ExitApp())
    c[21].OnEvent("Click", (*) => ShowSettingsDialog())

    TabControls[2] := c
}

; ── TAB 3 — BACKUP CODE ────────────────────────────────────
{
    c := []
    c.Push(MakeSection(98,  "LOGIN")*)
    c.Push(MakeBtn(22,  118, 178, "Login Clipboard Tele"))   ; idx 3
    c.Push(MakeBtn(206, 118, 178, "Login Website"))     ; idx 4

    c.Push(MakeSection(158, "BACKUP CODE (TELE)")*)
    c.Push(MakeBtn(22,  178, 178, "BC Email"))          ; idx 7
    c.Push(MakeBtn(206, 178, 178, "BC Retry"))          ; idx 8
    c.Push(MakeBtn(22,  214, 178, "BC Authen Tele"))         ; idx 9
    c.Push(MakeBtn(206, 214, 178, "Copy BC"))           ; idx 10

    c.Push(MakeSection(248, "BACKUP CODE (WEB)")*)       ; ← 258 → 248
    c.Push(MakeBtn(22,  268, 178, "BC Email Web"))      ; ← 278 → 268
    c.Push(MakeBtn(206, 268, 178, "BC Retry Web"))      ; ← 278 → 268
    c.Push(MakeBtn(22,  304, 178, "BC Authen Web"))     ; ← 314 → 304
    c.Push(MakeBtn(206, 304, 178, "Copy BC Web"))       ; ← 314 → 304

    c.Push(MakeSection(338, "TOOLS")*)                   ; ← 358 → 338
    c.Push(MakeBtn(22,  358,  86, "↺ Reload"))          ; ← 378 → 358
    c.Push(MakeBtn(114, 358,  86, "✕ Exit"))            ; ← 378 → 358
    c.Push(MakeBtn(206, 358, 178, "⚙ Settings"))        ; ← 378 → 358

    c[3].OnEvent("Click",  (*) => GuiAction("Login Clipboard Tele", DoLoginClipboard))
    c[4].OnEvent("Click",  (*) => GuiAction("Login Website",   DoLoginWebsite))
    c[7].OnEvent("Click",  (*) => GuiAction("BC Email Tele",   DoProsesBC1))
    c[8].OnEvent("Click",  (*) => GuiAction("BC Retry Tele",   BCWithIncompat))
    c[9].OnEvent("Click",  (*) => GuiAction("BC Authen Tele",  BCAuthen))
    c[10].OnEvent("Click", (*) => GuiAction("Copy BC Tele",    CopyBackupCodes))
    c[13].OnEvent("Click", (*) => GuiAction("BC Email Web",    DoProsesBC1Web))
    c[14].OnEvent("Click", (*) => GuiAction("BC Retry Web",    BCWithIncompatWeb))
    c[15].OnEvent("Click", (*) => GuiAction("BC Authen Web",   BCAuthenWeb))
    c[16].OnEvent("Click", (*) => GuiAction("Copy BC Web",     CopyBCWebsite))
    c[19].OnEvent("Click", (*) => Reload())
    c[20].OnEvent("Click", (*) => ExitApp())
    c[21].OnEvent("Click", (*) => ShowSettingsDialog())

    TabControls[3] := c
}

; ── TAB 4 — TOOLS ──────────────────────────────────────────
{
    c := []
    c.Push(MakeSection(98,  "TOOLS")*)
    c.Push(MakeBtn(22,  118,  86, "↺ Reload"))          ; idx 3
    c.Push(MakeBtn(114, 118,  86, "✕ Exit"))            ; idx 4
    c.Push(MakeBtn(206, 118,  86, "⏸ Pause"))           ; idx 5
    c.Push(MakeBtn(298, 118,  86, "⚙ Settings"))        ; idx 6

    c.Push(MakeSection(158, "ROBUX PURCHASE")*)
    c.Push(MakeBtn(22,  178,  86, "Buy 80R"))           ; idx 9
    c.Push(MakeBtn(114, 178,  86, "Buy 500R"))          ; idx 10
    c.Push(MakeBtn(206, 178,  86, "Buy 1000R"))         ; idx 11
    c.Push(MakeBtn(298, 178,  86, "Buy 2000R"))         ; idx 12

    c.Push(MakeSection(218, "DEBUG")*)
    c.Push(MakeBtn(22,  238,  86, "Mouse Pos"))         ; idx 15
    c.Push(MakeBtn(114, 238,  86, "Find 2FA"))          ; idx 16
    c.Push(MakeBtn(206, 238,  86, "Win Pos"))           ; idx 17
    c.Push(MakeBtn(298, 238,  86, "Incompat"))          ; idx 18

    c.Push(MakeSection(278, "SHEET")*)
    c.Push(MakeBtn(22,  298,  86, "Sheet Done"))        ; idx 21 
    c.Push(MakeBtn(114, 298,  86, "Sheet Belom"))       ; idx 22
    c.Push(MakeBtn(205, 298,  86, "Login di Web"))       ; idx 23

    c[3].OnEvent("Click",  (*) => Reload())
    c[4].OnEvent("Click",  (*) => ExitApp())
    c[5].OnEvent("Click",  (*) => TogglePause())
    c[6].OnEvent("Click",  (*) => ShowSettingsDialog())
    c[9].OnEvent("Click",  (*) => GuiAction("Buy 80 Robux",  Beli80Robux))
    c[10].OnEvent("Click", (*) => GuiAction("Buy 500 Robux", Beli500Robux))
    c[11].OnEvent("Click", (*) => GuiAction("Buy 1000 Robux", Beli1000Robux))
    c[12].OnEvent("Click", (*) => GuiAction("Buy 2000 Robux", Beli2000Robux))
    c[15].OnEvent("Click", (*) => ShowMousePos())
    c[16].OnEvent("Click", (*) => DebugFind2FA())
    c[17].OnEvent("Click", (*) => DebugWinPos())
    c[18].OnEvent("Click", (*) => MsgBox(CheckIncompatible() ? "Incompatible KEDETECT" : "Tidak kedetect", "Debug"))
    c[21].OnEvent("Click", (*) => HotkeySheetDone())    ; Sheet Done
    c[22].OnEvent("Click", (*) => HotkeySheetBelom())   ; Sheet Belom
    c[23].OnEvent("Click", (*) => HotkeyAction("Login di Web", LoginWebRoblox))   ; Web Roblox

    TabControls[4] := c
}

; ── LOG ────────────────────────────────────────────────────
AppGui.SetFont("s9 c444444 Bold", "Segoe UI")
AppGui.Add("GroupBox", "x10 y395 w380 h90", "LOG")        ; ← 369 → 395

AppGui.SetFont("s8 c222222 Norm", "Consolas")
EditLog := AppGui.Add("Edit", "x20 y413 w362 h62 vEditLog ReadOnly -VScroll")  ; ← 387 → 413

; ── FOOTER ─────────────────────────────────────────────────
AppGui.SetFont("s7 c888888 Norm", "Segoe UI")
StatsText := AppGui.Add("Text", "x12 y493 w220 vStatsText BackgroundTrans",
    "Sessions: 0 success / 0 total  (0%)")

AppGui.SetFont("s7 cAAAAAA Norm", "Segoe UI")
AppGui.Add("Text", "x190 y493 w200 BackgroundTrans Right",
    "Ctrl+B Reload | Ctrl+Esc Exit | Ctrl+F12 Pause")

AppGui.OnEvent("Close", (*) => ExitApp())

; ── HIDE semua tab non-aktif saat startup ──────────────────
loop 4 {
    if (A_Index != 1) {
        for ctrl in TabControls[A_Index]
            ctrl.Visible := false
    }
}

; ============================================================
;  TAB SWITCHING
; ============================================================
TabClick(tabIndex, *) {
    SwitchTab(tabIndex)
}

SwitchTab(tabIndex) {
    global g_ActiveTab, TabControls
    for ctrl in TabControls[g_ActiveTab]
        ctrl.Visible := false
    for ctrl in TabControls[tabIndex]
        ctrl.Visible := true
    g_ActiveTab := tabIndex
}

; ============================================================
;  START
; ============================================================
SetLogCallback(UILog)
EnableFileLog(false)
UpdateStats()
AppGui.Show("x50 y50 w400 h515")
UILog("[" FormatTime(, "HH:mm:ss") "] Hotkeys enabled — Sigmacro v2.1 ready")

SetTimer(() => CheckForUpdate(true), -3000)

; ── HOTKEYS ────────────────────────────────────────────────
; TELE
^!u:: HotkeyAction("Login Clipboard",  DoLoginClipboard)
^!p:: HotkeyAction("PW Tele",          PwdThenBC)
^!o:: HotkeyAction("BC Email",         DoProsesBC1)
^!e:: HotkeyAction("BC Retry",         BCWithIncompat)
^!k:: HotkeyAction("BC Authen",        BCAuthen)
^!i:: HotkeyAction("Copy BC",          CopyBackupCodes)

; WEB
^!+u:: HotkeyAction("Login Clipboard Web", DoLoginClipboardWeb)
^!m:: HotkeyAction("Login Website",        DoLoginWebsite)
^!q:: HotkeyAction("PW Web",               PastePwClipboard)
^!+o:: HotkeyAction("BC Email Web",        DoProsesBC1Web)
^!+e:: HotkeyAction("BC Retry Web",        BCWithIncompatWeb)
^!+k:: HotkeyAction("BC Authen Web",       BCAuthenWeb)
^!1:: HotkeyAction("Copy BC Web",          CopyBCWebsite)

; ROBLOX
^!r:: HotkeyAction("Buy 80 Robux",   Beli80Robux)
^!5:: HotkeyAction("Buy 500 Robux",  Beli500Robux)
^!2:: HotkeyAction("Buy 1000 Robux", Beli1000Robux)
^!3:: HotkeyAction("Buy 2000 Robux", Beli2000Robux)
^+l:: HotkeyAction("Login di Web", LoginWebRoblox)

; SHEET
$^e:: HotkeyAction("Sheet Done", HotkeySheetDone)
^q:: HotkeyAction("Sheet Belom", HotkeySheetBelom)

; SYSTEM (tetap)
F12:: Reload()
^Esc:: ExitApp()
^B:: TogglePause()

; DEBUG
^!j:: ShowMousePos()
^!t:: DebugFind2FA()
^!y:: DebugWinPos()
^!0:: DebugIncompatible()
^j:: DebugCoorPixel()

; ============================================================
;  PAUSE
; ============================================================
global _paused := false

TogglePause() {
    global _paused
    _paused := !_paused
    if _paused {
        UpdateStatus("Paused")
        UILog("[" FormatTime(, "HH:mm:ss") "] [PAUSE] Script paused")
        Pause(true)
    } else {
        UpdateStatus("Ready")
        UILog("[" FormatTime(, "HH:mm:ss") "] [RESUME] Script resumed")
        Pause(false)
    }
}

; ============================================================
;  DEBUG
; ============================================================
ShowMousePos() {
    MouseGetPos(&mx, &my)
    UILog("[DEBUG] Mouse: " mx ", " my)
    MsgBox("Posisi Mouse: " mx ", " my, "Debug")
}

DebugFind2FA() {
    if WaitForTwoStepPage(3000) {
        UILog("[DEBUG] 2FA terdeteksi!")
        MsgBox("2FA kedetect!", "Find 2FA")
    } else {
        UILog("[DEBUG] 2FA tidak terdeteksi")
        MsgBox("2FA TIDAK kedetect", "Find 2FA")
    }
}

DebugWinPos() {
    WinGetPos(&tx, &ty, &tw, &th, "A")
    title := WinGetTitle("A")  ; tanpa &, langsung return string
    UILog("[DEBUG] Window: " SubStr(title, 1, 30) " | " tw "x" th)
    MsgBox("Window: " title "`nX: " tx " Y: " ty " W: " tw " H: " th, "Window Pos")
}

DebugCoorPixel() {
    MouseGetPos(&mx, &my)
    col := PixelGetColor(mx, my, "RGB")
    hex := Format("0x{:06X}", col)
    UILog("[PIXEL] x=" mx " y=" my " color=" hex)
    MsgBox("X: " mx "`nY: " my "`nColor: " hex, "PixelGetColor Debug")
    A_Clipboard := hex
}

DebugIncompatible() {
    MsgBox(CheckIncompatible() ? "Incompatible KEDETECT" : "Tidak kedetect", "Debug")
}

; ============================================================
;  UI HELPERS
; ============================================================
GuiAction(name, fn) {
    global g_IsRunning
    if (g_IsRunning)
        return
    g_IsRunning := true
    UpdateStatus("Running")
    UILog("[" FormatTime(, "HH:mm:ss") "] [START] " name)
    success := false
    try {
        fn.Call()
        success := true
        UILog("[" FormatTime(, "HH:mm:ss") "] [OK] " name " selesai")
        UpdateStatus("Ready")
    } catch as e {
        UILog("[" FormatTime(, "HH:mm:ss") "] [ERROR] " e.Message)
        UpdateStatus("Error")
        Sleep(2000)
        UpdateStatus("Ready")
    }
    RecordSession(success)
    g_IsRunning := false
}

HotkeyAction(name, fn) {
    global g_IsRunning
    if (g_IsRunning)
        return
    g_IsRunning := true
    UpdateStatus("Running")
    UILog("[" FormatTime(, "HH:mm:ss") "] [START] " name)
    success := false
    try {
        fn.Call()
        success := true
        UILog("[" FormatTime(, "HH:mm:ss") "] [OK] " name " selesai")
        UpdateStatus("Ready")
    } catch as e {
        UILog("[" FormatTime(, "HH:mm:ss") "] [ERROR] " e.Message)
        UpdateStatus("Error")
        Sleep(2000)
        UpdateStatus("Ready")
    }
    RecordSession(success)
    g_IsRunning := false
}

UpdateStatus(status) {
    if (status = "Running")
        StatusText.Text := "⌛ Processing..."
    else if (status = "Error")
        StatusText.Text := "✗ Error"
    else if (status = "Paused")
        StatusText.Text := "⏸ Paused"
    else
        StatusText.Text := "Ready"
}

UILog(line) {
    current := EditLog.Value
    newText  := current . (current = "" ? "" : "`n") . line
    EditLog.Value := newText
    SendMessage(0x115, 7, 0, EditLog)
}

UpdateStats() {
    global g_SuccessCount, g_TotalAttempts
    StatsText.Text := "Sessions: " g_SuccessCount " success / " g_TotalAttempts " total"
        . "  (" GetSuccessRate() ")"
}