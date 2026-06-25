## OnlyDits

// semua shortcut masih berantakan blm di benerin. 

// udah support invalid kode backup (belum support kalo 2stepnya dark mode)

// buy robux semua normal (support dark & light theme)

// semua automation masih versi incompatible jadinya bakalan retry terus terusan sampe berhasil login

kliknya udah bener bc retry tele;
BCWithIncompat()  // belom ada retry backup invalid

; Cek invalid
    if !WaitForInvalidBC(2000) {
        Send("{Enter}")
        Log("✅ Backup code #1 diterima")
        return
    }

bc retry tele;
BCWithIncompat