; Simple AutoUpdater for AHK v2

; CONFIG
CurrentVersion := "1.0.1"  ; Your script's current version
VersionURL := "https://raw.githubusercontent.com/unknown1302/CabalBotUpdaterTest/main/version.txt"
ScriptURL := "https://raw.githubusercontent.com/unknown1302/CabalBotUpdaterTest/main/Bot.ahk"
IniFile := A_ScriptDir "\BotUpdater.ini"

CheckForUpdate()
{
    global CurrentVersion, VersionURL, ScriptURL, IniFile

    ; Read saved version from ini file
    savedVersion := IniRead(IniFile, "Update", "CurrentVersion", CurrentVersion)

    remoteVersion := DownloadText(VersionURL)
    if !remoteVersion {
        MsgBox "Failed to check for update."
        return
    }
    remoteVersion := Trim(remoteVersion)

    if (remoteVersion > savedVersion) {
        MsgBox "New version " remoteVersion " found. Updating..."
        if DownloadFile(ScriptURL, A_ScriptFullPath) {
            IniWrite(remoteVersion, IniFile, "Update", "CurrentVersion")
            MsgBox "Update successful! Please restart the script."
            ExitApp
        } else {
            MsgBox "Failed to download update."
        }
    } else {
        MsgBox "No update available. Current version: " savedVersion
    }
}


DownloadText(URL)
{
    try {
        http := ComObject("WinHttp.WinHttpRequest.5.1")
        http.Open("GET", URL, false)
        http.Send()
        if (http.Status != 200)
            return ""
        return http.ResponseText
    } catch Error as err {
        MsgBox "Error downloading text: " err.Message
        return ""
    }
}


DownloadFile(URL, LocalPath)
{
    try {
        http := ComObject("WinHttp.WinHttpRequest.5.1")
        http.Open("GET", URL, false)
        http.Send()
        if (http.Status != 200)
            return false
        file := FileOpen(LocalPath, "w")
        if !IsObject(file)
            return false
        file.Write(http.ResponseText)
        file.Close()
        return true
    } catch Error as err {
        MsgBox "Error downloading file: " err.Message
        return false
    }
}

; Run the updater check at script start
CheckForUpdate()
