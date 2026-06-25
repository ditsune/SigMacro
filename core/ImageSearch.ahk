; ============================================================
;  core/ImageSearch.ahk — Image search helpers
;  Region default baca dari COORD, toleransi dari CFG
; ============================================================

FindImage(imagePath, x1, y1, x2, y2, &outX, &outY, tolerances := "") {
    global CFG
    if (tolerances = "")
        tolerances := CFG["img_tolerances"]
    if !FileExist(imagePath) {
        Log("⚠ Image tidak ada: " imagePath)
        return false
    }
    for tol in StrSplit(tolerances, ",") {
        if ImageSearch(&fx, &fy, x1, y1, x2, y2, "*" tol " " imagePath) {
            outX := Integer(fx)
            outY := Integer(fy)
            return true
        }
    }
    return false
}

FindBottomImage(imagePath, x1, y1, x2, y2, &outX, &outY, tolerances := "") {
    global CFG
    if (tolerances = "")
        tolerances := CFG["img_tolerances"]
    if !FileExist(imagePath) {
        Log("⚠ Image tidak ada: " imagePath)
        return false
    }
    found := false
    bestX := 0
    bestY := 0
    for tol in StrSplit(tolerances, ",") {
        top := y1
        Loop {
            if !ImageSearch(&fx, &fy, x1, top, x2, y2, "*" tol " " imagePath)
                break
            if (Integer(fy) > bestY) {
                bestX := Integer(fx)
                bestY := Integer(fy)
                found := true
            }
            top := Integer(fy) + 5
            if (top >= y2)
                break
        }
        if found
            break
    }
    if found {
        outX := bestX
        outY := bestY
    }
    return found
}

WaitForImage(imagePath, x1, y1, x2, y2, timeoutMs := 0, tolerances := "") {
    global CFG
    if (timeoutMs = 0)
        timeoutMs := CFG["tfa_timeout"]
    if (tolerances = "")
        tolerances := CFG["img_tol_fast"]
    elapsed := 0
    Loop {
        if FindImage(imagePath, x1, y1, x2, y2, &fx, &fy, tolerances)
            return true
        Sleep(100)
        elapsed += 100
        if (elapsed >= timeoutMs)
            return false
    }
}

; ── Region helpers (pakai COORD map) ──────────────────────────

FindInRegion(imagePath, &outX, &outY, tolerances := "") {
    global COORD
    return FindImage(imagePath,
        COORD["region_x1"], COORD["region_y1"],
        COORD["region_x2"], COORD["region_y2"],
        &outX, &outY, tolerances)
}

WaitInRegion(imagePath, timeoutMs := 0, tolerances := "") {
    global COORD
    return WaitForImage(imagePath,
        COORD["region_x1"], COORD["region_y1"],
        COORD["region_x2"], COORD["region_y2"],
        timeoutMs, tolerances)
}

CheckIncompatible() {
    global CFG
    return FindImage(A_ScriptDir "\image\incompatible.png",
        CFG["region_incompat_x1"], CFG["region_incompat_y1"],
        CFG["region_incompat_x2"], CFG["region_incompat_y2"],
        &fx, &fy, "30,50,70,90,110,130")
}

WaitForIncompatible(timeoutMs := 3000) {
    elapsed := 0
    Loop {
        if CheckIncompatible()
            return true
        Sleep(16)
        elapsed += 16
        if (elapsed >= timeoutMs)
            return false
    }
}

WaitForTwoStepPage(timeoutMs := 0) {
    global CFG
    if (timeoutMs = 0)
        timeoutMs := CFG["tfa_timeout"]
    elapsed := 0
    Loop {
        if FindImage(A_ScriptDir "\image\twostep_icon.png",
            CFG["region_2fa_x1"], CFG["region_2fa_y1"],
            CFG["region_2fa_x2"], CFG["region_2fa_y2"],
            &fx, &fy, CFG["img_tol_fast"])
            return true
        Sleep(16)
        elapsed += 16
        if (elapsed >= timeoutMs)
            return false
    }
}


FindPasswordLabel(&outX, &outY) {
    global CFG
    return FindBottomImage(A_ScriptDir "\image\label_password.png",
        CFG["region_pwd_x1"], CFG["region_pwd_y1"],
        CFG["region_pwd_x2"], CFG["region_pwd_y2"],
        &outX, &outY)
}

WaitForPasswordLabel(&outX, &outY, timeoutMs := 5000) {
    elapsed := 0
    Loop {
        if FindPasswordLabel(&outX, &outY)
            return true
        Sleep(80)
        elapsed += 80
        if (elapsed >= timeoutMs)
            return false
    }
}

; ── Invalid BC detection ──────────────────────────────────────
CheckInvalidBC() {
    global CFG
    return FindImage(A_ScriptDir "\image\invalid_bc.png",
        CFG["region_invalidbc_x1"], CFG["region_invalidbc_y1"],
        CFG["region_invalidbc_x2"], CFG["region_invalidbc_y2"],
        &fx, &fy, CFG["img_tol_fast"])
}

WaitForInvalidBC(timeoutMs := 2000) {
    elapsed := 0
    Loop {
        if CheckInvalidBC()
            return true
        Sleep(16)
        elapsed += 16
        if (elapsed >= timeoutMs)
            return false
    }
}


; ── Roblox detection ─────────────────────────────────────────
CheckRobloxHome() {
    global CFG
    return FindImage(A_ScriptDir "\image\roblox_home.png",
        CFG["region_robloxhome_x1"], CFG["region_robloxhome_y1"],
        CFG["region_robloxhome_x2"], CFG["region_robloxhome_y2"],
        &fx, &fy, CFG["img_tol_fast"])
    || FindImage(A_ScriptDir "\image\roblox_home_dark.png",
        CFG["region_robloxhome_x1"], CFG["region_robloxhome_y1"],
        CFG["region_robloxhome_x2"], CFG["region_robloxhome_y2"],
        &fx, &fy, CFG["img_tol_fast"])
}

FindRobuxItem(imageName, &outX, &outY) {
    global CFG
    ; Coba light dulu
    if FindImage(A_ScriptDir "\image\" imageName,
        CFG["region_80robux_x1"], CFG["region_80robux_y1"],
        CFG["region_80robux_x2"], CFG["region_80robux_y2"],
        &outX, &outY, "10,20,30,40,50,60,70,80,90,100,110,120,130")
        return true
    ; Coba dark
    darkName := StrReplace(imageName, ".png", "_dark.png")
    return FindImage(A_ScriptDir "\image\" darkName,
        CFG["region_80robux_x1"], CFG["region_80robux_y1"],
        CFG["region_80robux_x2"], CFG["region_80robux_y2"],
        &outX, &outY, "10,20,30,40,50,60,70,80,90,100,110,120,130")
}

CheckDontBuy() {
    global CFG
    return FindImage(A_ScriptDir "\image\dont_buy.png",
        CFG["region_dontbuy_x1"], CFG["region_dontbuy_y1"],
        CFG["region_dontbuy_x2"], CFG["region_dontbuy_y2"],
        &fx, &fy, CFG["img_tol_fast"])
}

WaitForDontBuy(timeoutMs := 5000) {
    elapsed := 0
    Loop {
        if CheckDontBuy()
            return true
        Sleep(200)
        elapsed += 200
        if (elapsed >= timeoutMs)
            return false
    }
}