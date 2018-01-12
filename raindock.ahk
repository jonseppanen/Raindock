SetTitleMatchMode "RegEx"
#Persistent
#SingleInstance force
CoordMode "Mouse", "Screen"

ActiveHwnd := WinExist("A",,RainmeterMeterWindow)
TaskArray := {}
SetTimer "ListTaskbarWindows", 200
tmp := EnvGet("TMP") . "\raindock"
userDir := EnvGet("USERPROFILE") . "\raindock"
if(!FileExist(userDir))
{
    DirCreate userDir
    FileCopy A_WorkingDir . "\default.ini", userDir . "\raindock.ini"
}
iniFile := userDir . "\raindock.ini"
taskmax := 16
themeLocation := IniRead(iniFile, "UserVariables", "ThemePath")
taskWidth := IniRead(iniFile, "UserVariables", "Taskwidth")
iconTaskXPadding := IniRead(iniFile, "UserVariables", "iconTaskXPadding")
iconTaskYPadding := IniRead(iniFile, "UserVariables", "iconTaskYPadding")
SendRainmeterCommand("[!SetVariable TaskWidth " . taskWidth . " raindock]")
SendRainmeterCommand("[!SetVariable iconTaskXPadding " . iconTaskXPadding . " raindock]")
SendRainmeterCommand("[!SetVariable iconTaskYPadding " . iconTaskYPadding . " raindock]")
dockHeight := (taskWidth + (iconTaskYPadding * 2)) + 70
dockY := (A_ScreenHeight - dockHeight)
dockX := 0
dockAnim := false
dockMinMax := 0
dockState := "visible"
AccentColor := SubStr(Format("{1:#x}", RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\DWM", "ColorizationColor")), 3, 6) . "FF"

SendRainmeterCommand("[!SetVariable AHKVersion " . A_AhkVersion . " raindock]")
SendRainmeterCommand("[!UpdateMeasure MeasureWindowMessage raindock]")

OnMessage(16666, "Switch")
OnMessage(16667, "dockHide")
OnMessage(16668, "clearIconCache")
OnMessage(16669, "selectIconTheme")

if(!FileExist(tmp))
{
    DirCreate tmp
}

clearIconCache()
{
    Global tmp
    FileDelete tmp . "\*.bmp"
    Sleep 1000
    SendRainmeterCommand("[!Refresh raindock]")
}

selectIconTheme()
{
    Global iniFile
    Global userDir
    IniWrite DirSelect("*" . userDir, Options, Prompt) . "\" , iniFile, "UserVariables", "ThemePath"
    clearIconCache()
}

dockHide()
{
    global dockAnim
    global dockState
    global dockMinMax
    if(dockAnim = true || dockState = "hidden" || dockMinMax = 0){
        return
    }
    dockState := "hidden"
    dockAnim := true
    global dockHeight
    global dockX
    global dockY
    dockY := A_ScreenHeight - dockHeight
    Loop (dockHeight)
    {
        dockY := dockY +1
        SendRainmeterCommand("[!Move `" " . dockX . " `" `" " . dockY . " `" `"raindock`"]")
    }
    dockAnim := false
}


dockShow()
{
    global dockAnim
    global dockState
    
    if(dockAnim = true || dockState = "visible"){
        return
    }
    dockState := "visible"
    dockAnim := true
    global dockHeight
    global dockX
    global dockY
    dockY := A_ScreenHeight
    Loop (dockHeight)
    {
        dockY := dockY -1
        SendRainmeterCommand("[!Move `" " . dockX . " `" `" " . dockY . " `" `"raindock`"]")
    }
    dockAnim := false
    
}

MoveDock(MoveX,oldPos)
{
    global dockX
    global dockY
    global dockHeight

    if(MoveX < dockX){
        step := (MoveX - oldPos)  / dockHeight
        leftRight := "moveRight"
    }
    else{
        step := (oldPos - MoveX) / dockHeight
        leftRight := "moveLeft"
    }

    Loop (dockHeight)
    {
        if(leftRight = "moveRight"){
            dockX := dockX + step
        }
        else{
            dockX := dockX - step
        }
        SendRainmeterCommand("[!Move `" " . dockX . " `" `" " . dockY . " `" `"raindock`"]")
    }

}

Switch(wParam, lParam)
{ 
    Global ActiveHwnd
    IDVar := WinGetID("ahk_id " wParam)
    minMax := WinGetMinMax("ahk_id " wParam)

    if(minMax < 0){
        WinActivate "ahk_id " wParam
        ActiveHwnd := IDVar
        return
    }
    else if(ActiveHwnd = IDVar){
        WinMinimize "ahk_id " wParam
        Sleep 30
        ActiveHwnd := WinExist("A",,RainmeterMeterWindow)
    }
    else{
        WinActivate "ahk_id " wParam
        ActiveHwnd := IDVar
    }
}

IsWindowCloaked(hwnd)
{
    static gwa := DllCall("GetProcAddress", "ptr", DllCall("LoadLibrary", "str", "dwmapi", "ptr"), "astr", "DwmGetWindowAttribute", "ptr")
    return (gwa && DllCall(gwa, "ptr", hwnd, "int", 14, "int*", cloaked, "int", 4) = 0) ? cloaked : 0
}

SendRainmeterCommand(command)
{
    Send_WM_COPYDATA(command, "ahk_class RainmeterMeterWindow")
}

Send_WM_COPYDATA(ByRef StringToSend, ByRef TargetWindowClass)  
{
    VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0) 
    SizeInBytes := (StrLen(StringToSend) + 1) * (A_IsUnicode ? 2 : 1)
    NumPut(1, CopyDataStruct) 
    NumPut(SizeInBytes, CopyDataStruct, A_PtrSize)  
    NumPut(&StringToSend, CopyDataStruct, 2*A_PtrSize) 
    SendMessage(0x4a, 0, &CopyDataStruct,, "ahk_class " TargetWindowClass)  
    return ErrorLevel  
}

SendTaskLabelInfo(newLabel,oldLabel,taskNumber)
{
    if(!oldLabel || oldLabel["title"] != newLabel["title"]){
        SendRainmeterCommand("[!SetOption Task" . taskNumber . "Label Text `"`"`"    " . newLabel["title"] . "`"`"`" raindock]")
        SendRainmeterCommand("[!UpdateMeter Task" . taskNumber . "Label raindock]")
        SendRainmeterCommand("[!ShowMeter Task" . taskNumber . "Label raindock]")
        SendRainmeterCommand("[!SetOption Task" . taskNumber . "Exe Text `"`"`"" . newLabel["exe"] . "`"`"`" raindock]")
        SendRainmeterCommand("[!UpdateMeter Task" . taskNumber . "Exe raindock]")
        SendRainmeterCommand("[!ShowMeter Task" . taskNumber . "Exe raindock]")
    }    
}

SendTaskIconInfo(newID,oldID,taskNumber)
{
    if(!oldID || oldID["id"] != newID["id"])
    {
        global tmp
        global themeLocation
        global taskWidth
        global iconTaskXPadding
        global iconTaskYPadding
        
        TmpFileLocation := tmp . "\" . newID["exe"] . ".bmp"
        SendRainmeterCommand("[!SetOption Task" . taskNumber . " LeftMouseDownAction `"`"`"[!CommandMeasure MeasureWindowMessage `"SendMessage 16666 " . newID["id"] . " 0`"]`"`"`" raindock]")
        SendRainmeterCommand("[!SetOption Task" . taskNumber . " MiddleMouseDownAction `"`"`"[explorer " . newID["path"] . "\" . newID["exe"] . ".exe" . "]`"`"`" raindock]")
        SendRainmeterCommand("[!SetOption Task" . taskNumber . " ImageName `"0.png`" raindock]")
        SendRainmeterCommand("[!UpdateMeter Task" . taskNumber . " raindock]")
        SendRainmeterCommand("[!ShowMeter Task" . taskNumber . " raindock]")

        if(!FileExist(TmpFileLocation))
        {
            SendRainmeterCommand("[!SetOption magickmeter1 ExportTo `"" . TmpFileLocation . "`" raindock]")
            if(FileExist(themeLocation . newID["exe"] . ".png"))
            {
                
                SendRainmeterCommand("[!SetOption magickmeter1 Image `"File " . themeLocation . newID["exe"] . ".png | RenderSize " . (TaskWidth) . "," . (TaskWidth) . "`" raindock]")
                SendRainmeterCommand("[!SetOption magickmeter1 Image2 `"`" raindock]")
                SendRainmeterCommand("[!SetOption magickmeter1 Image3 `"`" raindock]")
            }
            else
            {
                global tmp
                icoPath :=  tmp . "\" . newID["exe"] . ".ico"
                Initials := newID["exe"]
                Loop Parse, Initials, A_Space
                {
                    x := x SubStr(A_LoopField, "1", "1")
                    x := StrUpper(x)
                    Initials := x
                }
                Initials := StrReplace(Initials, "[", "")
                global AccentColor
                bgColor := AccentColor
                fgColor := "255,255,255,255"

                if(newID["classname"] = "ApplicationFrameWindow")
                {
                    SendRainmeterCommand("[!SetOption magickmeter1 Image `"Ellipse 1,1,1| Ignore 1 `" raindock]")
                }
                else
                {
                    Counter := 1
                    SendRainmeterCommand("[!EnableMeasure MeasureIconExe raindock]")
                    SendRainmeterCommand("[!SetOption MeasureIconExe IconPath `"" .  icoPath   . "`" raindock]")
                    SendRainmeterCommand("[!SetOption MeasureIconExe Path `"" . newID["path"] .  "`" raindock]")
                    SendRainmeterCommand("[!SetOption MeasureIconExe WildcardSearch `"" . newID["exe"] .  ".exe`" raindock]")
                    SendRainmeterCommand("[!UpdateMeasure MeasureIconExe raindock]")
                    SendRainmeterCommand("[!CommandMeasure MeasureIconExe `"Update`" raindock]")
                    While(!FileExist( icoPath ) && Counter < 200){
                        Sleep 30
                        Counter++
                    }
                    if(Counter > 199){
                        SendRainmeterCommand("[!SetOption magickmeter1 Image `"Ellipse 1,1,1| Ignore 1 `" raindock]")
                    }
                    else{
                        bgColor := "{Image:ColorBG}"
                        fgColor := "{Image:ColorFG}"
                        SendRainmeterCommand("[!SetOption magickmeter1 Image `"File " . icoPath . " | Ignore 1 | RenderSize " . TaskWidth . "," . TaskWidth . "`" raindock]")
                    }
                }
                SendRainmeterCommand("[!SetOption magickmeter1 Image2 `"Ellipse (" . (TaskWidth) . " / 2),(" . (TaskWidth) . " / 2),(" . (TaskWidth) . " / 2)| Color " . bgColor . "`" raindock]")
                SendRainmeterCommand("[!SetOption magickmeter1 Image3 `"Text " . Initials . " | Offset (" . (TaskWidth) . " / 2),(" . (TaskWidth) . " / 2) | Color " . fgColor . " | Face Segoe UI | Weight 700 | Align CenterCenter`" raindock]")
                

            }
            SendRainmeterCommand("[!UpdateMeasure magickmeter1 raindock]")       
        }
        SendRainmeterCommand("[!SetOption Task" . taskNumber . " ImageName `"" . TmpFileLocation . "`" raindock]")
        SendRainmeterCommand("[!UpdateMeter Task" . taskNumber . " raindock]")
    }
}


ListTaskbarWindows()
{
    Global TaskArray
    OldTaskArray := TaskArray
    TaskArray := {}
    TaskList := ""
    TaskCount := 0
    global dockY
    global dockX
    Global dockMinMax
    Global oldDockMinMax := dockMinMax
    Global taskmax
    Global taskwidth
    Global iconTaskXPadding
    Global iconTaskYPadding
    dockMinMax := 0
    MouseGetPos xpos, ypos 

    id := WinGetList(,, "NxDock|Program Manager|Task Switching|^$")
    Loop id.Length()
    {
      thisId := id[A_Index]
      WinGetPos(,,, Height,"ahk_id " thisId)
      minMax := WinGetMinMax("ahk_id " thisId)
      If (Height && !IsWindowCloaked(thisId) && !(WinGetExStyle("ahk_id " thisId) & 0x8000088))
      {
        If(minMax = 1){
            ;MsgBox "ahk_id " thisId
            dockMinMax := 1
        }
        TaskCount := ++TaskCount
        TaskList := Tasklist . thisId . ","
      }
    }
    TaskList := Sort(TaskList, "N D,")
    activeTask := false
    Loop Parse, TaskList, "," 
    {
        if WinActive("ahk_id " A_LoopField)
        {
            activeTask := true
            SendRainmeterCommand("[!SetOption TaskIndicator X `"[Task" . A_Index . ":X] `" raindock]")
        }
        ClassName := WinGetClass("ahk_id " A_LoopField)
        Titlevar := WinGetTitle("ahk_id " A_LoopField)
        SplitPath WinGetProcessPath("ahk_id " A_LoopField) ,, Path,, OutNameNoExt

        if(ClassName != "ApplicationFrameWindow"){
            ExeName := OutNameNoExt
        }
        else{
            TitleArray := StrSplit(Titlevar, "- ") 
            ExeName := TitleArray[TitleArray.length()]
            ;ExeName := StrReplace(WinGetText("ahk_id " A_LoopField), "`r`n", "")
        }
        
        TaskArray[A_Index,"id"] := A_LoopField 
        TaskArray[A_Index,"classname"] := ClassName
        TaskArray[A_Index,"title"] := Titlevar
        TaskArray[A_Index,"exe"] := ExeName
        TaskArray[A_Index,"path"] := Path
    }

    if(activeTask){
        SendRainmeterCommand("[!ShowMeter TaskIndicator raindock]")
    }
    else{
        SendRainmeterCommand("[!HideMeter TaskIndicator raindock]")
    }

    if(TaskArray != OldTaskArray)
    {
        if(OldTaskArray.length() != TaskArray.length())
        {
        
            if(OldTaskArray.length() > TaskArray.length())
            {
                Loop (taskmax - TaskCount)
                {
                    SendRainmeterCommand("[!SetOption Task" .  (A_Index + TaskCount) . " ImageName `"`" raindock]")
                    SendRainmeterCommand("[!HideMeter Task" .  (A_Index + TaskCount) . "Label raindock]")
                    SendRainmeterCommand("[!HideMeter Task" .  (A_Index + TaskCount) . "Exe raindock]")
                    SendRainmeterCommand("[!HideMeter Task" .  (A_Index + TaskCount) . " raindock]")
                }
            }
            MoveDock(Floor((A_ScreenWidth - ((Taskwidth + (iconTaskXPadding * 2)) * TaskCount)) / 2 ) - ((Taskwidth + (iconTaskXPadding * 2)) * 2),dockX)
        }

        For TaskId in TaskArray
        {
            if(TaskId <= TaskCount)
            {
                SendTaskLabelInfo(TaskArray[TaskId],OldTaskArray[TaskId],TaskId)
                SendTaskIconInfo(TaskArray[TaskId],OldTaskArray[TaskId],TaskId)
            }
        }
    }

    if(oldDockMinMax != dockMinMax)
    {
        if(dockMinMax != 1){
            dockShow()
            return
        }
        else{
            dockHide()
        }
    }

    if(ypos >= (A_ScreenHeight - 2))
    {
        dockShow()
    }
    
}



