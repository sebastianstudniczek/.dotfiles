#Requires AutoHotkey v2.0
; recommended for performance and compatibility with future autohotkey releases.
#UseHook
#SingleInstance force

SendMode "Input"

;; deactivate capslock completely
SetCapslockState("AlwaysOff")

;; Emulate hyper key
CapsLock::
{
    Send("{Ctrl DownTemp}{Shift DownTemp}{Alt DownTemp}{LWin DownTemp}")
    KeyWait("CapsLock")
    Send("{Ctrl Up}{Shift Up}{Alt Up}{LWin Up}")
    if (A_PriorKey = "CapsLock") {
        Send "{Esc}"
    }
}

; Apps
CapsLock & t::LaunchOrFocus("WindowsTerminal.exe")  ; Hyper + t -> Terminal
CapsLock & b::LaunchOrFocus("msedge.exe")           ; Hyper + b -> Browser

LaunchOrFocus(exe)
{
    if WinExist("ahk_exe " exe)
        WinActivate()
    else 
        Run(exe)
}

#`:: Send("{Alt Down}{Tab Down}{Tab Up}{Alt Up}") ; Win + ` -> Previous window

; Windows snapping
CapsLock & h::Send("#{Left}")                       ; Hyper + h -> Snap Left
CapsLock & l::Send("#{Right}")                      ; Hyper + l -> Snap right