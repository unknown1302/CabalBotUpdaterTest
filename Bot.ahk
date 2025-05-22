; Bot.ahk - Self-Updating Script for AHK v2

; CONFIGURATION
CurrentVersion := "1.0.1"
VersionURL     := "https://raw.githubusercontent.com/unknown1302/CabalBotUpdaterTest/main/version.txt"
ScriptURL      := "https://raw.githubusercontent.com/unknown1302/CabalBotUpdaterTest/main/Bot.ahk"
IniFile        := A_ScriptDir "\BotUpdater.ini"

; ========================================
; Version Comparison Helper
CompareVersions(v1, v2)
{
    v1Parts := StrSplit(v1, ".")
    v2Parts := StrSplit(v2, ".")

    Loop Max(v1Parts.Length, v2Parts.Length)
    {
        p1 := (A_Index <= v1Parts.Length) ? v1Parts[A_Index] : 0
        p2 := (A_Index <= v2Parts.Length) ? v2Parts[A_Index] : 0
        if (p1 != p2)
            return (p1 > p2) ? 1 : -1
    }
    return 0
}


; ========================================
; Download Text from URL
DownloadText(URL)
{
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


; ========================================
; Download File from URL and save to path
DownloadFile(URL, LocalPath)
{
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


; ========================================
; Update Check Logic
CheckForUpdate()
{
    global CurrentVersion, VersionURL, ScriptURL, IniFile

    ; Read saved version or fallback to CurrentVersion
    savedVersion := IniRead(IniFile, "Update", "CurrentVersion", CurrentVersion)


    ; Get latest version from GitHub
    remoteVersion := DownloadText(VersionURL)
    if !remoteVersion {
        MsgBox("Failed to check for update.")
        return
    }

    remoteVersion := Trim(remoteVersion)

    ; Compare and update if newer
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

; ========================================
; MAIN ENTRY
CheckForUpdate()

; Your bot's actual logic would go here
MsgBox("Bot is running... version " CurrentVersion)
