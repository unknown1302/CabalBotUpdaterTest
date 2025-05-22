global CURRENT_VERSION := "1.0.1"
#Include AutoUpdate.ahk
AutoUpdate("https://raw.githubusercontent.com/yourname/repo/main/Bot.ahk")
MsgBox, Hello! This is version %CURRENT_VERSION%.
