global CURRENT_VERSION := "1.0.0"

#Include AutoUpdate.ahk

; Run the updater
AutoUpdate("https://raw.githubusercontent.com/unknown1302/CabalBotUpdaterTest/main/Bot.ahk")

; Your main bot code starts here
MsgBox, Hello! I am version %CURRENT_VERSION%.
