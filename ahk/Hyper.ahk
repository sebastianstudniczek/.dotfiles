#Requires AutoHotkey v2.0
#UseHook
#SingleInstance force

SendMode "Input"

; Global variables
global Layer := ""
global LAYER_TIMEOUT := 3000 ; 3 seconds

global AppLayer := Map(
    "t", (*) => LaunchOrFocus("wt"),
    "b", (*) => LaunchOrFocus("msedge"),
    "s", (*) => LaunchOrFocus("Slack"),
    "o", (*) => LaunchOrFocus("Obsidian"),
    "e", (*) => LaunchOrFocus("explorer"),
    "p", (*) => LaunchOrFocus("Postman"),
    "i", (*) => LaunchOrFocus("rider64"),
    "j", (*) => SwitchBrowserTab(1), ; Jira (Tab 1)
    "g", (*) => SwitchBrowserTab(2), ; GitHub (Tab 2)
)

; ============================================================================
; FUNCTION DEFINITIONS
; ============================================================================

EnterLayer(subLayer) {
    global Layer
    Layer := subLayer
    SetTimer(() => ExitLayer(), -LAYER_TIMEOUT) ; Auto-exit after configured time
}

ExitLayer() {
    global Layer
    Layer := ""
}

SwitchBrowserTab(tabNumber) {
    LaunchOrFocus("msedge")
    Sleep(100)
    Send("^" . tabNumber)
    ; ExitLayer()
}

LaunchOrFocus(exe) {
    ; Handle both exe names with and without .exe extension
    exeName := InStr(exe, ".exe") ? exe : exe . ".exe"
    
    if WinExist("ahk_exe " . exeName)
        WinActivate()
    else 
        Run(exeName)
}

InitializeHotkeys() {
    global AppLayer
    for key, action in AppLayer {
        Hotkey("F24 & " . key, action) ; F24 as hyper key
    }
}

InitializeHotkeys()
