; ============================================================
;  shared/Constants.ahk — Named constants untuk semua koordinat & timing
;  Semua hardcoded coords dipindah ke sini. Edit di satu tempat.
; ============================================================

global COORD := Map(
    ; ── BACKUP CODES ──────────────────────────────────────────
    "bc_code1_x",       1677,
    "bc_code1_y",       1008,
    "bc_code2_x",       1607,
    "bc_code2_y",       1007,
    "bc_code3_x",       1550,
    "bc_code3_y",       1009,

     ; ── CLIPBOARD CLICK LOGIN PAGE ──────────────────────────────────────────
    "clipboard_1_x",       1441,
    "clipboard_1_y",       547,
    "clipboard_2_x",       1435,
    "clipboard_2_y",       638,
    "clipboard_3_x",       1440,
    "clipboard_3_y",       720,

    ; ── LOGIN FIELDS ──────────────────────────────────────────
    "login_focus_x",    1689,
    "login_focus_y",    377,
    "login_user_x",     1407,
    "login_user_y",     343,
    "login_pass_x",     1434,
    "login_pass_y",     411,
    "login_pass2_x",    1441,
    "login_pass2_y",    403,
    "login_pass3_x",    1490,
    "login_pass3_y",    412,
    "login_submit1_x",  1425, ; klik ke item ke 3 di clipboard
    "login_submit1_y",  718, ; klik ke item ke 3 di clipboard
    "login_submit2_x",  1433, ; klik ke item ke 2 di clipboard
    "login_submit2_y",  709, ; klik ke item ke 2 di clipboard

    ; ── CLIPBOARD / WIN+V ─────────────────────────────────────
    "winv_focus_x",     1720,
    "winv_focus_y",     376,

    ; ── 2FA / BC FLOW ─────────────────────────────────────────
    "bc_input_focus_x", 1437,
    "bc_input_focus_y", 579,
    "retrybc_input_x",     1389,
    "retrybc_input_y",     409,
    "bc_input_x",       1458,
    "bc_input_y",       470,
    "bc_random1_x",     1401,
    "bc_random1_y",     588,
    "bc_random2_x",     1380,
    "bc_random2_y",     675,
    "bc_random3_x",     1318,
    "bc_random3_y",     762,

    ; ── INVALID BC FORM ──────────────────────────────────────
    "invalidbcform_x",      1203,
    "invalidbcform_y",      405,

    ; ── BC AUTHEN FLOW ────────────────────────────────────────
    "authen_alt_x",     1436,
    "authen_alt_y",     508,
    "authen_bc_opt_x",  1399,
    "authen_bc_opt_y",  472,

    ; ── BC WITH INCOMPAT FLOW ─────────────────────────────────
    "incompat_focus_x", 1455,
    "incompat_focus_y", 505,
    "incompat_bc_x",    1433,
    "incompat_bc_y",    470,

    ; ── PASSWORD LABEL OFFSET ─────────────────────────────────
    "pwd_scroll1_x",    1814,
    "pwd_scroll1_y",    803,

    ; ── WEBSITE LOGIN (BROWSER CLICKS) ────────────────────────
    "web_tab1_x",       356,
    "web_tab1_y",       327,
    "web_tab2_x",       575,
    "web_tab2_y",       329,
    "web_tab3_x",       647,
    "web_tab3_y",       384,

    ; ── KLIK BC DI WEBSITE  ────────────────────────
    "web_bc1_x",        312,
    "web_bc1_y",        386,
    "web_bc2_x",        473,
    "web_bc2_y",        389,
    "web_bc3_x",        629,
    "web_bc3_y",        389,

    ; ── TELEGRAM FLOW ─────────────────────────────────────────
    "tele_click1_x",    671,
    "tele_click1_y",    358,
    "tele_click2_x",    556,
    "tele_click2_y",    323,

    ; ── PURCHASE ROBUX ─────────────────────────────────────────
    "robux_logo_x",   1828,
    "robux_logo_y",   105,

    ; ── IMAGE SEARCH REGION (monitor 2) ───────────────────────
    "region_x1",        953,
    "region_y1",        0,
    "region_x2",        1927,
    "region_y2",        638
)

; Shorthand helper: ambil coord pair sebagai Array [x, y]
GetCoord(name) {
    return [COORD[name "_x"], COORD[name "_y"]]
}
