; ============================================================
;  core/Logic.ahk — Semua aksi utama
;  Semua koordinat baca dari COORD map (shared/Constants.ahk)
;  Semua timing baca dari CFG map (shared/Config.ahk)
; ============================================================

; ini adalah ctrl + i
CopyBackupCodes() {
    global COORD, CFG

    ; ── Copy BC Code 1 ──────────────────────────────────────
    A_Clipboard := ""
    DirectDoubleClick(COORD["bc_code1_x"], COORD["bc_code1_y"])
    Sleep(400)
    Send("^c")
    ClipWait(2)
    bc1 := A_Clipboard
    Sleep(300)

    ; ── Copy BC Code 2 ──────────────────────────────────────
    A_Clipboard := ""
    DirectDoubleClick(COORD["bc_code2_x"], COORD["bc_code2_y"])
    Sleep(400)
    Send("^c")
    ClipWait(2)
    bc2 := A_Clipboard
    Sleep(300)

    ; ── Copy BC Code 3 ──────────────────────────────────────
    A_Clipboard := ""
    DirectDoubleClick(COORD["bc_code3_x"], COORD["bc_code3_y"])
    Sleep(400)
    Send("^c")
    ClipWait(2)
    bc3 := A_Clipboard
    Sleep(300)
}


; ── FILL BACKUP CODE WITH INVALID BC DETECTION ────────────
FillBackupCodeOnly() {
    global COORD, CFG

    ; ── Step 1: Buka Win+V & klik BC ke-3 ──────────────────
    HumanClick(COORD["winv_focus_x"],     COORD["winv_focus_y"])
    Delay()
    HumanClick(COORD["bc_input_focus_x"], COORD["bc_input_focus_y"])
    Delay()
    HumanClick(COORD["bc_input_x"],       COORD["bc_input_y"])
    Delay()
    Send("#v")
    Sleep(CFG["winv_delay"])
    DirectClick(COORD["bc_random1_x"], COORD["bc_random1_y"])
    Sleep(CFG["winv_delay"])
    Send("{Enter}")

    ; Cek invalid
    if !WaitForInvalidBC(2000) {
        Send("{Enter}")
        Log("✅ Backup code #1 diterima")
        return
    }
    Log("⚠️ Backup code #1 invalid, coba #2...")

    ; ── Step 2: Clear & klik BC ke-1 ────────────────────────
    HumanDoubleClick(COORD["invalidbcform_x"], COORD["invalidbcform_y"], 2)
    Sleep(200)
    Send("#v")
    Sleep(CFG["winv_delay"])
    DirectClick(COORD["bc_random2_x"], COORD["bc_random2_y"])
    Sleep(CFG["winv_delay"])
    Send("{Enter}")

    ; Cek invalid
    if !WaitForInvalidBC(2000) {
        Send("{Enter}")
        Log("✅ Backup code #2 diterima")
        return
    }
    Log("⚠️ Backup code #2 invalid, coba #3...")

    ; ── Step 3: Clear & klik BC ke-2 ────────────────────────
    HumanDoubleClick(COORD["invalidbcform_x"], COORD["invalidbcform_y"], 2)
    Sleep(200)
    Send("#v")
    Sleep(CFG["winv_delay"])
    DirectClick(COORD["bc_random3_x"], COORD["bc_random3_y"])
    Sleep(CFG["winv_delay"])
    Send("{Enter}")

    Send("{Enter}")
    if WaitForInvalidBC(2000)
        Log("❌ Semua backup code invalid!")
    else
        Log("✅ Backup code #3 diterima")
}

AmbilPasswordDanPaste() {
    global COORD, CFG
    DirectClick(COORD["pwd_scroll1_x"], COORD["pwd_scroll1_y"])
    Sleep(200)
    DirectClick(COORD["pwd_scroll1_x"], COORD["pwd_scroll1_y"])
    Sleep(300)

    if !WaitForPasswordLabel(&lx, &ly, 5000) {
        Log("❌ Label password tidak ditemukan")
        return false
    }

    DirectClick(1626, ly + 9)
    Delay()
    HumanClick(COORD["winv_focus_x"],  COORD["winv_focus_y"])
    Delay()
    HumanClick(COORD["login_pass2_x"], COORD["login_pass2_y"])
    Delay()
    HumanClick(COORD["login_pass3_x"], COORD["login_pass3_y"])
    Delay()
    HumanDoubleClick(COORD["login_pass_x"], COORD["login_pass_y"], 2)
    Sleep(200)
    Send("^v")
    Delay()
    Send("{Enter}")
    Log("✅ Password dipaste")
    return true
}

ProsesBackupCode(maxRetry := 0) {
    global CFG
    if (maxRetry = 0)
        maxRetry := CFG["bc_max_retry"]
    loop maxRetry {
        FillBackupCodeOnly()
        if !WaitForIncompatible(3000) {
            Log("✅ Selesai, tidak ada incompatible")
            break
        }
        Log("⚠️ Incompatible, retry " A_Index "/" maxRetry)
        if !AmbilPasswordDanPaste() {
            Log("❌ Gagal ambil password")
            break
        }
        if !WaitForTwoStepPage() {
            Log("❌ 2FA tidak muncul")
            break
        }
        Delay()
    }
}

ProsesBackupCodeWeb(maxRetry := 0) {
    global CFG
    if (maxRetry = 0)
        maxRetry := CFG["bc_max_retry"]
    loop maxRetry {
        FillBackupCodeOnly()
        if !WaitForIncompatible(3000) {
            Log("✅ Selesai, tidak ada incompatible")
            break
        }
        Log("⚠️ Incompatible, retry " A_Index "/" maxRetry)
        PastePwClipboard()
        if !WaitForTwoStepPage() {
            Log("❌ 2FA tidak muncul")
            break
        }
        Delay()
    }
}

BCAuthen() {
    global COORD, CFG
    CopyBackupCodes()
    HumanClick(COORD["authen_alt_x"],   COORD["authen_alt_y"])
    Delay()
    HumanClick(COORD["authen_bc_opt_x"], COORD["authen_bc_opt_y"])
    Delay()
    FillBackupCodeOnly()                              ; ← ganti dari manual Send/Win+V/klik
    Log("🔄 Backup code diisi via Authen")
    Sleep(CFG["incompat_wait"])
    if CheckIncompatible() {
        Log("⚠️ Incompatible terdeteksi")
        if AmbilPasswordDanPaste() {
            if WaitForTwoStepPage() {
                Delay()
                ProsesBackupCode()
            } else
                Log("❌ 2FA tidak terdeteksi")
        } else
            Log("❌ Gagal ambil password")
    } else
        Log("✅ Selesai")
}

DoLoginClipboard() {
    global COORD, CFG
    HumanClick(COORD["login_focus_x"], COORD["login_focus_y"])
    Delay()
    HumanClick(COORD["login_pass_x"],  COORD["login_pass_y"])
    RandSleep(350, 450)
    HumanClick(COORD["login_user_x"],  COORD["login_user_y"])
    RandSleep(200, 250)
    HumanDoubleClick(COORD["login_user_x"], COORD["login_user_y"], 2)
    Sleep(200)
    Send("^a")
    Sleep(200)
    Send("{Backspace}")
    Delay()
    Send("#v")
    Sleep(CFG["winv_delay"])
    DirectClick(COORD["login_submit1_x"], COORD["login_submit1_y"])
    Delay()
    HumanClick(COORD["login_pass_x"],  COORD["login_pass_y"])
    RandSleep(100, 150)
    HumanDoubleClick(COORD["login_pass_x"], COORD["login_pass_y"], 2)
    Sleep(200)
    Send("^a")
    Sleep(200)
    Send("{Backspace}")
    Delay()
    Send("#v")
    Sleep(CFG["winv_delay"])
    DirectClick(COORD["login_submit2_x"], COORD["login_submit2_y"])
    RandSleep(CFG["submit_delay"], CFG["submit_delay"] + 100)
    Send("{Enter}")
    Log("🚀 Login clipboard dikirim")
    CopyBackupCodes()
    if WaitForTwoStepPage() {
        Delay()
        ProsesBackupCode()
    } else
        Log("❌ 2FA tidak terdeteksi")
}

DoLoginWebsite() {
    global COORD, CFG
    DirectClick(COORD["web_tab1_x"], COORD["web_tab1_y"])
    Sleep(350)
    DirectClick(COORD["web_tab2_x"], COORD["web_tab2_y"])
    Sleep(350)
    DirectClick(COORD["web_tab3_x"], COORD["web_tab3_y"])
    Sleep(350)
    HumanClick(COORD["login_focus_x"], COORD["login_focus_y"])
    Delay()
    HumanClick(COORD["login_pass_x"],  COORD["login_pass_y"])
    RandSleep(350, 450)
    HumanClick(COORD["login_user_x"],  COORD["login_user_y"])
    RandSleep(150, 200)
    HumanDoubleClick(COORD["login_user_x"], COORD["login_user_y"], 2)
    Sleep(200)
    Send("^a")
    Sleep(200)
    Send("{Backspace}")
    Delay()
    Send("#v")
    Sleep(CFG["winv_delay"])
    DirectClick(COORD["login_submit1_x"], COORD["login_submit1_y"])
    Delay()
    HumanClick(COORD["login_pass_x"],  COORD["login_pass_y"])
    RandSleep(100, 150)
    HumanDoubleClick(COORD["login_pass_x"], COORD["login_pass_y"], 2)
    Sleep(200)
    Send("^a")
    Sleep(200)
    Send("{Backspace}")
    Delay()
    Send("#v")
    Sleep(CFG["winv_delay"])
    DirectClick(COORD["login_submit2_x"], COORD["login_submit2_y"])
    RandSleep(CFG["submit_delay"], CFG["submit_delay"] + 100)
    Send("{Enter}")
    CopyBCWebsite()
    Log("🚀 Login website dikirim")
    if WaitForTwoStepPage() {
        Delay()
        ProsesBackupCodeWeb()
    } else if CheckIncompatible() {
        Log("⚠️ Incompatible terdeteksi, jalankan PW Web...")
        PastePwClipboard()
    } else {
        Log("❌ 2FA tidak terdeteksi")
    }
}

PastePwClipboardWeb() {
    global COORD, CFG
    DirectClick(578, 333)
    Sleep(200)
    HumanClick(COORD["winv_focus_x"],  COORD["winv_focus_y"])
    Delay()
    HumanClick(COORD["login_pass2_x"], COORD["login_pass2_y"])
    Delay()
    HumanClick(COORD["login_pass3_x"], COORD["login_pass3_y"])
    Delay()
    HumanDoubleClick(COORD["login_pass_x"], COORD["login_pass_y"], 2)
    Sleep(200)
    Send("^v")
    Delay()
    Send("{Enter}")
    Log("🚀 Paste PW Web selesai")
    CopyBCWebsite()
    if !WaitForTwoStepPage() {
        Log("❌ 2FA tidak terdeteksi")
        return
    }
    Delay()
    ProsesBackupCodeWeb()
}



CopyBCWebsite() {
    global COORD
    DirectClick(COORD["web_bc1_x"], COORD["web_bc1_y"])
    Sleep(350)
    DirectClick(COORD["web_bc2_x"], COORD["web_bc2_y"])
    Sleep(350)
    DirectClick(COORD["web_bc3_x"], COORD["web_bc3_y"])
    Sleep(350)
    Log("🔄 BC Website diklik")
}

PastePwClipboard() {
    global COORD, CFG
    DirectClick(578, 333)
    Sleep(200)
    HumanClick(COORD["winv_focus_x"],  COORD["winv_focus_y"])
    Delay()
    HumanClick(COORD["login_pass2_x"], COORD["login_pass2_y"])
    Delay()
    HumanClick(COORD["login_pass3_x"], COORD["login_pass3_y"])
    Delay()
    HumanDoubleClick(COORD["login_pass_x"], COORD["login_pass_y"], 2)
    Sleep(200)
    Send("^v")
    Delay()
    Send("{Enter}")
    Log("🚀 Paste PW selesai")
    CopyBCWebsite()
    if !WaitForTwoStepPage() {
        Log("❌ 2FA tidak terdeteksi")
        return
    }
    Delay()
    ProsesBackupCodeWeb()                  ; ← pakai Web (Ctrl+Q saat incompatible)
}

PastePwTelegram() {
    global COORD, CFG
    DirectClick(COORD["tele_click1_x"], COORD["tele_click1_y"])
    Sleep(200)
    DirectClick(COORD["tele_click2_x"], COORD["tele_click2_y"])
    Delay()
    HumanClick(COORD["winv_focus_x"],  COORD["winv_focus_y"])
    Delay()
    HumanClick(COORD["login_pass2_x"], COORD["login_pass2_y"])
    Delay()
    HumanClick(COORD["login_pass3_x"], COORD["login_pass3_y"])
    Delay()
    HumanDoubleClick(COORD["login_pass_x"], COORD["login_pass_y"], 2)
    Sleep(200)
    Send("^v")
    Delay()
    Send("{Enter}")
    Log("🚀 Paste PW Telegram selesai")
    if WaitForTwoStepPage() {
        Delay()
        ProsesBackupCode()
    } else
        Log("❌ 2FA tidak terdeteksi")
}

PwdThenBC() {
    if AmbilPasswordDanPaste() {
        CopyBackupCodes()
        if WaitForTwoStepPage() {
            Delay()
            ProsesBackupCode()
        } else
            Log("❌ 2FA tidak muncul")
    }
}

BCWithIncompat() {
    global COORD, CFG
    CopyBackupCodes()
    HumanClick(COORD["winv_focus_x"],     COORD["winv_focus_y"])
    Delay()
    HumanClick(COORD["incompat_focus_x"], COORD["incompat_focus_y"])
    Delay()
    HumanClick(COORD["incompat_bc_x"],    COORD["incompat_bc_y"])
    Delay()
    FillBackupCodeOnly()                              ; ← ganti dari manual Send/WinV/klik
    if !WaitForIncompatible(3000) {
        Log("✅ Selesai, tidak ada incompatible")
        return
    }
    Log("⚠️ Incompatible terdeteksi")
    if !AmbilPasswordDanPaste() {
        Log("❌ Gagal ambil password")
        return
    }
    CopyBackupCodes()
    if !WaitForTwoStepPage() {
        Log("❌ 2FA tidak terdeteksi")
        return
    }
    Delay()
    ProsesBackupCode()
}

DoProsesBC1() {
    CopyBackupCodes()
    ProsesBackupCode()
}

; ── WEBSITE VARIANTS (pakai CopyBCWebsite) ────────────────

DoProsesBC1Web() {
    CopyBCWebsite()
    ProsesBackupCodeWeb()
}

BCWithIncompatWeb() {
    global COORD, CFG
    CopyBCWebsite()
    HumanClick(COORD["winv_focus_x"],     COORD["winv_focus_y"])
    Delay()
    HumanClick(COORD["incompat_focus_x"], COORD["incompat_focus_y"])
    Delay()
    HumanClick(COORD["incompat_bc_x"],    COORD["incompat_bc_y"])
    Delay()
    FillBackupCodeOnly()                              ; ← ganti dari manual
    if !WaitForIncompatible(3000) {
        Log("✅ Selesai, tidak ada incompatible")
        return
    }
    Log("⚠️ Incompatible terdeteksi")
    PastePwClipboard()
    CopyBCWebsite()
    if !WaitForTwoStepPage() {
        Log("❌ 2FA tidak terdeteksi")
        return
    }
    Delay()
    ProsesBackupCodeWeb()
}

BCAuthenWeb() {
    global COORD, CFG
    CopyBCWebsite()
    HumanClick(COORD["authen_alt_x"],   COORD["authen_alt_y"])
    Delay()
    HumanClick(COORD["authen_bc_opt_x"], COORD["authen_bc_opt_y"])
    Delay()
    FillBackupCodeOnly()                              ; ← ganti dari manual
    Log("🔄 Backup code diisi via Authen (Web)")
    Sleep(CFG["incompat_wait"])
    if CheckIncompatible() {
        Log("⚠️ Incompatible terdeteksi")
        PastePwClipboard()
        if WaitForTwoStepPage() {
            Delay()
            ProsesBackupCodeWeb()
        } else
            Log("❌ 2FA tidak terdeteksi")
    } else
        Log("✅ Selesai")
}


DoLoginClipboardWeb() {
    global COORD, CFG
    HumanClick(COORD["login_focus_x"], COORD["login_focus_y"])
    Delay()
    HumanClick(COORD["login_pass_x"],  COORD["login_pass_y"])
    RandSleep(350, 450)
    HumanClick(COORD["login_user_x"],  COORD["login_user_y"])
    RandSleep(200, 250)
    HumanDoubleClick(COORD["login_user_x"], COORD["login_user_y"], 2)
    Sleep(200)
    Send("^a")
    Sleep(200)
    Send("{Backspace}")
    Delay()
    Send("#v")
    Sleep(CFG["winv_delay"])
    DirectClick(COORD["login_submit1_x"], COORD["login_submit1_y"])
    Delay()
    HumanClick(COORD["login_pass_x"],  COORD["login_pass_y"])
    RandSleep(200, 250)
    HumanDoubleClick(COORD["login_pass_x"], COORD["login_pass_y"], 2)
    Sleep(200)
    Send("^a")
    Sleep(200)
    Send("{Backspace}")
    Delay()
    Send("#v")
    Sleep(CFG["winv_delay"])
    DirectClick(COORD["login_submit2_x"], COORD["login_submit2_y"])
    RandSleep(CFG["submit_delay"], CFG["submit_delay"] + 100)
    Send("{Enter}")
    CopyBCWebsite()
    Log("🚀 Login clipboard (Web) dikirim")
    if WaitForTwoStepPage() {
        Delay()
        ProsesBackupCodeWeb()
    } else if CheckIncompatible() {
        Log("⚠️ Incompatible terdeteksi, jalankan PW Web...")
        PastePwClipboard()
    } else
        Log("❌ 2FA tidak terdeteksi")
}

; ── ROBLOX ──────────────────────────────────────────────────
BeliRobux(imageName, label) {
    global COORD, CFG

    ; Step 1: Cek Roblox Home
    if !CheckRobloxHome() {
        Log("❌ Roblox Home tidak terdeteksi")
        return false
    }
    Log("✅ Roblox Home terdeteksi")

    ; Step 2: Double klik logo Robux
    DirectClick(COORD["robux_logo_x"], COORD["robux_logo_y"])
    Sleep(200)
    DirectClick(COORD["robux_logo_x"], COORD["robux_logo_y"])
    Sleep(2000)

    ; Step 3: Cari item dengan scroll
    maxScroll := 3
    loop maxScroll {
        if FindRobuxItem(imageName, &ix, &iy) {
            Log("✅ " label " ditemukan di " ix ", " iy)
            HumanClick(ix + 577, iy + 22)
            Log("🛒 Klik Purchase " label)

                        ; Step 4: Cek popup Don't Buy (tunggu sampai 5 detik)
            if WaitForDontBuy(5000) {
                Log("⚠️ Berhasil tidak mempurchase, silakan review manual")
            } else {
                Log("ℹ️ Pop-up tidak terdeteksi, tidak ada pembelian terjadi")
            }
            return true
        }
        Log("🔍 " label " belum ketemu, scroll... (" A_Index "/" maxScroll ")")
        Send("{WheelDown 3}")
        Sleep(500)
    }

    Log("❌ " label " tidak ditemukan setelah " maxScroll " scroll")
    return false
}

Beli80Robux() {
    return BeliRobux("80robux.png", "80 Robux")
}

Beli500Robux() {
    return BeliRobux("500robux.png", "500 Robux")
}

Beli1000Robux() {
    return BeliRobux("1000robux.png", "1000 Robux")
}

Beli2000Robux() {
    return BeliRobux("2000robux.png", "2000 Robux")
}