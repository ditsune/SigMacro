; ============================================================
;  shared/Config.ahk — Load/save settings dari sigmacro.ini
;  Edit sigmacro.ini untuk ubah timing/toleransi tanpa restart
; ============================================================

global CFG := Map()
global CFG_PATH := A_ScriptDir "\sigmacro.ini"

LoadConfig() {
    global CFG, CFG_PATH, COORD

    ; ── REGIONS (dari RegionSelector) ─────────────────────────
    CFG["region_incompat_x1"] := Integer(IniRead(CFG_PATH, "Regions", "region_incompat_x1", 953))
    CFG["region_incompat_y1"] := Integer(IniRead(CFG_PATH, "Regions", "region_incompat_y1", 0))
    CFG["region_incompat_x2"] := Integer(IniRead(CFG_PATH, "Regions", "region_incompat_x2", 1927))
    CFG["region_incompat_y2"] := Integer(IniRead(CFG_PATH, "Regions", "region_incompat_y2", 638))

    CFG["region_2fa_x1"] := Integer(IniRead(CFG_PATH, "Regions", "region_2fa_x1", 953))
    CFG["region_2fa_y1"] := Integer(IniRead(CFG_PATH, "Regions", "region_2fa_y1", 0))
    CFG["region_2fa_x2"] := Integer(IniRead(CFG_PATH, "Regions", "region_2fa_x2", 1927))
    CFG["region_2fa_y2"] := Integer(IniRead(CFG_PATH, "Regions", "region_2fa_y2", 638))

    CFG["region_pwd_x1"] := Integer(IniRead(CFG_PATH, "Regions", "region_pwd_x1", 953))
    CFG["region_pwd_y1"] := Integer(IniRead(CFG_PATH, "Regions", "region_pwd_y1", 0))
    CFG["region_pwd_x2"] := Integer(IniRead(CFG_PATH, "Regions", "region_pwd_x2", 1927))
    CFG["region_pwd_y2"] := Integer(IniRead(CFG_PATH, "Regions", "region_pwd_y2", 638))

    CFG["region_invalidbc_x1"] := Integer(IniRead(CFG_PATH, "Regions", "region_invalidbc_x1", 953))
    CFG["region_invalidbc_y1"] := Integer(IniRead(CFG_PATH, "Regions", "region_invalidbc_y1", 0))
    CFG["region_invalidbc_x2"] := Integer(IniRead(CFG_PATH, "Regions", "region_invalidbc_x2", 1927))
    CFG["region_invalidbc_y2"] := Integer(IniRead(CFG_PATH, "Regions", "region_invalidbc_y2", 638))

    CFG["region_robloxhome_x1"] := Integer(IniRead(CFG_PATH, "Regions", "region_robloxhome_x1", 0))
    CFG["region_robloxhome_y1"] := Integer(IniRead(CFG_PATH, "Regions", "region_robloxhome_y1", 0))
    CFG["region_robloxhome_x2"] := Integer(IniRead(CFG_PATH, "Regions", "region_robloxhome_x2", 1920))
    CFG["region_robloxhome_y2"] := Integer(IniRead(CFG_PATH, "Regions", "region_robloxhome_y2", 1080))

    CFG["region_80robux_x1"] := Integer(IniRead(CFG_PATH, "Regions", "region_80robux_x1", 0))
    CFG["region_80robux_y1"] := Integer(IniRead(CFG_PATH, "Regions", "region_80robux_y1", 0))
    CFG["region_80robux_x2"] := Integer(IniRead(CFG_PATH, "Regions", "region_80robux_x2", 1920))
    CFG["region_80robux_y2"] := Integer(IniRead(CFG_PATH, "Regions", "region_80robux_y2", 1080))

    CFG["region_dontbuy_x1"] := Integer(IniRead(CFG_PATH, "Regions", "region_dontbuy_x1", 0))
    CFG["region_dontbuy_y1"] := Integer(IniRead(CFG_PATH, "Regions", "region_dontbuy_y1", 0))
    CFG["region_dontbuy_x2"] := Integer(IniRead(CFG_PATH, "Regions", "region_dontbuy_x2", 1920))
    CFG["region_dontbuy_y2"] := Integer(IniRead(CFG_PATH, "Regions", "region_dontbuy_y2", 1080))

    ; ── TIMING ────────────────────────────────────────────────
    CFG["delay_min"]      := Integer(IniRead(CFG_PATH, "Timing", "DelayMin",       200))
    CFG["delay_max"]      := Integer(IniRead(CFG_PATH, "Timing", "DelayMax",       350))
    CFG["click_pre"]      := Integer(IniRead(CFG_PATH, "Timing", "ClickPre",       10))
    CFG["click_post"]     := Integer(IniRead(CFG_PATH, "Timing", "ClickPost",      15))
    CFG["submit_delay"]   := Integer(IniRead(CFG_PATH, "Timing", "SubmitDelay",    300))
    CFG["winv_delay"]     := Integer(IniRead(CFG_PATH, "Timing", "WinVDelay",      500))
    CFG["incompat_wait"]  := Integer(IniRead(CFG_PATH, "Timing", "IncompatWait",   2000))
    CFG["tfa_timeout"]    := Integer(IniRead(CFG_PATH, "Timing", "TFATimeout",     15000))

    ; ── BEZIER ────────────────────────────────────────────────
    CFG["bez_steps_min"]  := Integer(IniRead(CFG_PATH, "Bezier", "StepsMin",       8))
    CFG["bez_steps_max"]  := Integer(IniRead(CFG_PATH, "Bezier", "StepsMax",       15))
    CFG["bez_sleep_min"]  := Integer(IniRead(CFG_PATH, "Bezier", "SleepMin",       1))
    CFG["bez_sleep_max"]  := Integer(IniRead(CFG_PATH, "Bezier", "SleepMax",       4))
    CFG["bez_offset_min"] := Integer(IniRead(CFG_PATH, "Bezier", "OffsetMin",      12))
    CFG["bez_offset_max"] := Integer(IniRead(CFG_PATH, "Bezier", "OffsetMax",      28))

    ; ── IMAGE SEARCH ──────────────────────────────────────────
    CFG["img_tolerances"] := IniRead(CFG_PATH, "ImageSearch", "Tolerances", "30,50,70,90")
    CFG["img_tol_fast"]   := IniRead(CFG_PATH, "ImageSearch", "FastTolerances", "30,50,70")

    ; ── RETRY ─────────────────────────────────────────────────
    CFG["bc_max_retry"]   := Integer(IniRead(CFG_PATH, "Retry", "BCMaxRetry",      5))

    ; ── COORDS OVERRIDE (optional — override Constants.ahk via INI) ──
    ; Contoh: kalau layout Roblox berubah, tinggal edit INI tanpa edit kode
    CoordOverrides()

    Log("[Config] Loaded from " CFG_PATH)
}

CoordOverrides() {
    global COORD, CFG_PATH
    ; Baca semua key dari section [Coords] di INI, override COORD map
    try {
        raw := IniRead(CFG_PATH, "Coords")
        for line in StrSplit(raw, "`n") {
            parts := StrSplit(line, "=")
            if parts.Length = 2 {
                key := Trim(parts[1])
                val := Integer(Trim(parts[2]))
                if COORD.Has(key)
                    COORD[key] := val
            }
        }
    }
    ; Section Coords kosong = tidak ada override, skip
}

SaveConfig() {
    global CFG, CFG_PATH
    IniWrite(CFG["delay_min"],     CFG_PATH, "Timing", "DelayMin")
    IniWrite(CFG["delay_max"],     CFG_PATH, "Timing", "DelayMax")
    IniWrite(CFG["tfa_timeout"],   CFG_PATH, "Timing", "TFATimeout")
    IniWrite(CFG["bc_max_retry"],  CFG_PATH, "Retry",  "BCMaxRetry")
    Log("[Config] Saved to " CFG_PATH)
}

; Buat default INI kalau belum ada
EnsureDefaultConfig() {
    global CFG_PATH
    if FileExist(CFG_PATH)
        return

    IniWrite("200",         CFG_PATH, "Timing",      "DelayMin")
    IniWrite("350",         CFG_PATH, "Timing",      "DelayMax")
    IniWrite("10",          CFG_PATH, "Timing",      "ClickPre")
    IniWrite("15",          CFG_PATH, "Timing",      "ClickPost")
    IniWrite("300",         CFG_PATH, "Timing",      "SubmitDelay")
    IniWrite("500",         CFG_PATH, "Timing",      "WinVDelay")
    IniWrite("2000",        CFG_PATH, "Timing",      "IncompatWait")
    IniWrite("15000",       CFG_PATH, "Timing",      "TFATimeout")
    IniWrite("8",           CFG_PATH, "Bezier",      "StepsMin")
    IniWrite("15",          CFG_PATH, "Bezier",      "StepsMax")
    IniWrite("1",           CFG_PATH, "Bezier",      "SleepMin")
    IniWrite("4",           CFG_PATH, "Bezier",      "SleepMax")
    IniWrite("12",          CFG_PATH, "Bezier",      "OffsetMin")
    IniWrite("28",          CFG_PATH, "Bezier",      "OffsetMax")
    IniWrite("30,50,70,90", CFG_PATH, "ImageSearch", "Tolerances")
    IniWrite("30,50,70",    CFG_PATH, "ImageSearch", "FastTolerances")
    IniWrite("5",           CFG_PATH, "Retry",       "BCMaxRetry")
    IniWrite("; Contoh override: bc_code1_x=1677", CFG_PATH, "Coords", "; Instruksi")

    Log("[Config] Default config dibuat: " CFG_PATH)
}
