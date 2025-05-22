#Requires AutoHotkey v2.0
#SingleInstance Off
#MaxThreadsPerHotkey 2

; --- Auto Update Configuration ---
CurrentVersion := "1.0.1"
VersionURL     := "https://raw.githubusercontent.com/unknown1302/CabalBotUpdaterTest/main/version.txt"
ScriptURL      := "https://raw.githubusercontent.com/unknown1302/CabalBotUpdaterTest/main/MixUpdate.ahk"
IniFile        := A_ScriptDir "\versions.ini"

CompareVersions(v1, v2) {
    v1Parts := StrSplit(v1, ".")
    v2Parts := StrSplit(v2, ".")
    Loop Max(v1Parts.Length, v2Parts.Length) {
        p1 := (A_Index <= v1Parts.Length) ? v1Parts[A_Index] : 0
        p2 := (A_Index <= v2Parts.Length) ? v2Parts[A_Index] : 0
        if (p1 != p2)
            return (p1 > p2) ? 1 : -1
    }
    return 0
}

DownloadText(URL) {
    try {
        http := ComObject("WinHttp.WinHttpRequest.5.1")
        http.Open("GET", URL, false)
        http.Send()
        if (http.Status != 200)
            return ""
        return http.ResponseText
    } catch {
        MsgBox("Error downloading text.")
        return ""
    }
}

DownloadFile(URL, LocalPath) {
    try {
        http := ComObject("WinHttp.WinHttpRequest.5.1")
        http.Open("GET", URL, false)
        http.Send()
        if (http.Status != 200)
            return false
        file := FileOpen(LocalPath, "w")
        if !file
            return false
        file.Write(http.ResponseText)
        file.Close()
        return true
    } catch {
        MsgBox("Error downloading file.")
        return false
    }
}

CheckForUpdate() {
    global CurrentVersion, VersionURL, ScriptURL, IniFile
    savedVersion := IniRead(IniFile, "Update", "CurrentVersion", CurrentVersion)
    remoteVersion := DownloadText(VersionURL)
    if !remoteVersion {
        MsgBox("Failed to check for update.")
        return
    }
    remoteVersion := Trim(remoteVersion)
    if (CompareVersions(remoteVersion, savedVersion) > 0) {
        MsgBox("New version " remoteVersion " found. Updating...")
        if DownloadFile(ScriptURL, A_ScriptFullPath) {
            IniWrite(remoteVersion, IniFile, "Update", "CurrentVersion")
            MsgBox("Update successful! Please restart the script.")
            ExitApp
        } else {
            MsgBox("Failed to download update.")
        }
    } else {
        MsgBox("No update available. Current version: " savedVersion)
    }
}

; --- Run Updater ---
CheckForUpdate()

; --- Macro Logic (merged from Macro1.ahk) ---
Target_Window := ""
AttackCTR := 0
RetargetCTR := 0
Started_Attack := false
Started_Retarget := false

mainGui := Gui("+AlwaysOnTop", "Macro")
mainGui.SetFont("s10", "Candara")
mainGui.Add("GroupBox", "x5 w250 h90 center cBlue", "CABAL Set Window")
mainGui.Add("Button", "x12 y25 w230 h30", "Set Window").OnEvent("Click", (*) => Set_Location(mainGui))
mainGui.Add("Edit", "x10 y60 w235 h25 ReadOnly center vTarget_Window", Target_Window)

mainGui.Add("GroupBox", "x5 y100 w250 h90 center cGreen", "CABAL Controls")
mainGui.SetFont("s10", "Candara")
btnRetarget := mainGui.Add("Button", "x12 y120 w235 h30 vTheRetarget", "Start Retarget")
btnRetarget.OnEvent("Click", (*) => RETARGET(btnRetarget))
btnAttack := mainGui.Add("Button", "x12 y155 w235 h30 vTheAttack", "Start Attack")
btnAttack.OnEvent("Click", (*) => ATTACK(btnAttack))

mainGui.Add("GroupBox", "x5 y195 w250 h90 center cRed", "CABAL Settings Guide")
mainGui.SetFont("s10 underline", "Candara")
mainGui.Add("Text", "x67 y220 w200 h30 c0000cc", "(Game Settings Setup)").OnEvent("Click", (*) => Run("Bin\\guideSettings.png"))
mainGui.Add("Text", "x71 y250 w200 h30 c0000cc", "(Skills/Looting Setup)").OnEvent("Click", (*) => Run("Bin\\guideSkills.png"))

mainGui.SetFont("s12 underline", "Candara")
mainGui.Add("Text", "x215 y282 w130 h20 cGreen", "v" CurrentVersion)


mainGui.OnEvent("Close", (*) => ExitApp())
mainGui.Show("w258 h303")

; --- Macro Core Functions ---
Set_Location(guiRef) {
    global Target_Window
    Target_Window := Set_Window()
    if !WinExist(Target_Window) {
        MsgBox("Target window not found: " Target_Window)
        return
    }
    guiRef["Target_Window"].Value := Target_Window
}

Set_Window() {
    isPressed := false, i := 0
    loop {
        if !GetKeyState("RButton") && !isPressed
            isPressed := true
        else if GetKeyState("RButton") && isPressed {
            i += 1, isPressed := false
            if i >= 2 {
                winTitle := WinGetTitle("A")
                ToolTip()
                return winTitle
            }
        }
        tempWindow := WinGetTitle("A")
        ToolTip("Right Click on the target window twice to set`n`nCurrent Window: " tempWindow)
        Sleep 50
    }
}

GetWindowHwnd(winTitle) {
    return WinExist(winTitle)
}

SendRightClick(hwnd, x, y) {
    lParam := (y << 16) | (x & 0xFFFF)
    PostMessage(0x204, 1, lParam, , hwnd)
    Sleep(10)
    PostMessage(0x205, 0, lParam, , hwnd)
}

SendMiddleClick(hwnd, x, y) {
    lParam := (y << 16) | (x & 0xFFFF)
    PostMessage(0x207, 1, lParam, , hwnd)
    Sleep(10)
    PostMessage(0x208, 0, lParam, , hwnd)
}

ATTACK(btn) {
    global Started_Attack
    Started_Attack := !Started_Attack
    btn.Text := Started_Attack ? "Stop Attacking" : "Start Attack"
    SetTimer ATTACKREF, Started_Attack ? 100 : 0
}

RETARGET(btn) {
    global Started_Retarget
    Started_Retarget := !Started_Retarget
    btn.Text := Started_Retarget ? "Stop Retarget" : "Start Retarget"
    SetTimer RETARGETREF, Started_Retarget ? 1000 : 0
}

ATTACKREF() {
    global AttackCTR, Target_Window
    hwnd := GetWindowHwnd(Target_Window)
    if !hwnd
        return
    AttackCTR++
    if AttackCTR = 1 {
        coords := [[203,578],[234,573],[268,576],[292,579],[320,573],
                   [348,574],[381,573],[414,575],[438,574],[474,573],
                   [500,575],[526,573]]
        for xy in coords {
            x := xy[1], y := xy[2]
            SendRightClick(hwnd, x, y)
            Sleep(30)
        }
        AttackCTR := 0
    }
}

RETARGETREF() {
    global RetargetCTR, Target_Window
    hwnd := GetWindowHwnd(Target_Window)
    if !hwnd
        return
    RetargetCTR++
    if RetargetCTR = 1 {
        SendMiddleClick(hwnd, 0, 0)
        RetargetCTR := 0
    }
}

; --- Emergency Exit Hotkeys ---
`::ExitApp
Esc::ExitApp
