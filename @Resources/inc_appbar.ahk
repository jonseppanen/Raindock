
uEdge := 3 ; left=0,top=1,right=2,bottom=3
uAppHeight := 120 ; "ideal" height when horizonal

;SysGet, Mon1, MonitorWorkArea
;ScreenWidth := Mon1Right - Mon1Left
;ScreenHeight := Mon1Bottom - Mon1Top
GX := 0
GY := 1440 - uAppHeight
GW := 3440
GH := uAppHeight

;WinSet, Region, W%GW% H26 0-0, ahk_id %hAB%
ABM := DllCall( "RegisterWindowMessage", Str,"AppBarMsg" )
    
; APPBARDATA : http://msdn2.microsoft.com/en-us/library/ms538008.aspx
APPBARDATA := ""
Off := ""
VarSetCapacity(APPBARDATA,36,0)
Off := NumPut(36,APPBARDATA) ; cbSize
Off := NumPut(hAB, Off+0 ) ; hWnd
Off := NumPut(ABM, Off+0 ) ; uCallbackMessage
Off := NumPut(uEdge, Off+0 ) ; uEdge: left=0,top=1,right=2,bottom=3
Off := NumPut(GX, Off+0 ) ; rc.left
Off := NumPut(GY, Off+0 ) ; rc.top
Off := NumPut(GW, Off+0 ) ; rc.right
Off := NumPut(GH, Off+0 ) ; rc.bottom
Off := NumPut(1, Off+0 ) ; lParam
Result := DllCall("Shell32.dll\SHAppBarMessage",UInt,(ABM_NEW:=0x0),UInt,&APPBARDATA)
Result := DllCall("Shell32.dll\SHAppBarMessage",UInt,(ABM_QUERYPOS:=0x2),UInt,&APPBARDATA)
Result := DllCall("Shell32.dll\SHAppBarMessage",UInt,(ABM_SETPOS:=0x3),UInt,&APPBARDATA)
MsgBox Result
;Return
    
;OnExit DllCall("Shell32.dll\SHAppBarMessage",UInt,(ABM_REMOVE := 0x1),UInt,&APPBARDATA)
;ExitApp
    
;ABM_Callback( wParam, LParam, Msg, HWnd ) {
; When Taskbar settings are changed, wParam is 1, otherwise it's 2.
; I'll probably add code to handle this later.
;}