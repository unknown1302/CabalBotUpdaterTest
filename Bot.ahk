#Requires AutoHotkey v2

; Simple AutoUpdater for AHK v2

; CONFIG
CurrentVersion := "1.0.1"  ; Your script's current version
VersionURL := "https://raw.githubusercontent.com/unknown1302/CabalBotUpdaterTest/main/version.txt"  ; URL with just the latest version string
ScriptURL := "https://raw.githubusercontent.com/unknown1302/CabalBotUpdaterTest/main/Bot.ahk"          ; URL to the updated script file
IniFile := A_ScriptDir "\BotUpdater.ini"             ; Local INI file to store current version

CheckForUpdate()  ; Call updater at script start

return  ; End of auto-execute section

CheckForUpdate()
{
    global CurrentVersion, VersionURL, ScriptURL, IniFile

    ; Read saved version from ini file, fallback to CurrentVersion if not exist
    savedVersion := IniRead(IniFile, "Update", "CurrentVersion", CurrentVersion)

    ; Download remote version string
    remoteVersion := DownloadText(VersionURL)
    if !remoteVersion
    {
        MsgBox("Failed to check for update.")
        return
    }
    remoteVersion := StrTrim(remoteVersion)  ; remove whitespace

    if (remoteVersion > savedVersion)
    {
        MsgBox("New version " remoteVersion " found. Updating...")
        if DownloadFile(ScriptURL, A_ScriptFullPath)
        {
            ; Update the ini file with new version
            IniWrite(IniFile, "Update", "CurrentVersion", remoteVersion)
            MsgBox("Update successful! Please restart the script.")
            ExitApp()
        }
        else
        {
            MsgBox("Failed to download update.")
        }
    }
    else
    {
        MsgBox("No update available. Current version: " savedVersion)
    }
}

DownloadText(URL)
{
    req := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    req.Open("GET", URL, false)
    req.Send()
    if (req.Status != 200)
        return ""
    return req.ResponseText
}

DownloadFile(URL, LocalPath)
{
    req := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    req.Open("GET", URL, false)
    req.Send()
    if (req.Status != 200)
        return false
    file := FileOpen(LocalPath, "w")
    if !IsObject(file)
        return false
    file.Write(req.ResponseBody)
    file.Close()
    return true
}
