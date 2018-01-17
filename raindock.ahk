SetTitleMatchMode "RegEx"
#Persistent
#SingleInstance force
CoordMode "Mouse", "Screen"

ActiveHwnd := WinExist("A",,RainmeterMeterWindow)
TaskArray := {}
SetTimer "ListTaskbarWindows", 300
SetTimer "dockStateHandler", 300

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
LastAlbum := ""
coverOut := EnvGet("TMP") . "\smallcover.bmp"
coverFile := EnvGet("TMP") . "\cover.bmp"
if(FileExist(coverFile))
{
    spotifyActive := True
    SetTimer "RenderSpotifyIcon", 1000
}

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
    Global dockAnim
    Global dockState
    Global dockMinMax
    if(dockAnim = true || dockState = "hidden" || dockMinMax = 0){
        return
    }
    dockState := "hidden"
    dockAnim := true
    Global dockHeight
    Global dockX
    Global dockY
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
    Global dockAnim
    Global dockState
    Global dockMinMax
    
    if(dockAnim = true || dockState = "visible" || dockMinMax = 2){
        return
    }
    dockState := "visible"
    dockAnim := true
    Global dockHeight
    Global dockX
    Global dockY
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
    Global dockX
    Global dockY
    Global dockHeight

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


RenderSpotifyIcon()
{
    Global coverFile
    Global LastAlbum
    Global coverOut
    currentAlbum := FileGetTime(coverFile, C)
    if(LastAlbum != currentAlbum )
    {
        LastAlbum := currentAlbum
        renderIconTheme(coverFile,coverOut) 
    }
}


renderIconTheme(iconFile,renderTo,string := ""){

    if(string){
        Global AccentColor
        MM1 := "Text " . string . " | Offset (#Taskwidth# / 2),(#Taskwidth# / 2) | ignore 1  | Color " . iconFile . " | Face Segoe UI | Weight 700 | Align CenterCenter"
        MM2 := AccentColor
    }
    else{
        MM1 := "File " . iconFile . " | ignore 1 | RenderSize #TaskWidth#,#TaskWidth#"
        MM2 := "{Image:ColorBG}"
    }

    SendRainmeterCommand("[!SetOption magickmeter1 ExportTo `"" . renderTo . "`" raindock]")
    SendRainmeterCommand("[!SetOption magickmeter1 Image `" " . MM1 . " `" raindock]")
    SendRainmeterCommand("[!SetOption magickmeter1 Image2 `"Rectangle 0,0,#TaskWidth#,#TaskWidth#  | Color " . MM2 . "  `" raindock]")
    SendRainmeterCommand("[!SetOption magickmeter1 Image3 `"Clone Image`" raindock]")
    SendRainmeterCommand("[!UpdateMeasure magickmeter1 raindock]") 
    Counter := 1
    
    While(!FileExist( renderTo ) && Counter < 200){
        Sleep 30
        Counter++
    }
}

SendTaskIconInfo(currentTask,oldTask,taskNumber)
{
    if(!oldTask || oldTask["title"] != currentTask["title"])
    {
        SendRainmeterCommand("[!SetOption Task" . taskNumber . " MouseOverAction `"`"`"[!ShowMeterGroup groupIconLabel raindock][!SetOption iconTitle Text `"    " . currentTask["title"] . "`" raindock][!SetOption iconExe Text `"" . currentTask["exe"] . "`" raindock][!MoveMeter ([#CURRENTSECTION#:X]+(#TaskWidth#/2)+#iconTaskXPadding#) 0 iconTitle][!UpdateMeter iconExe raindock][!UpdateMeter iconTitle raindock]`"`"`" raindock]")
       
        Global spotifyActive

        if(!oldTask || oldTask["id"] != currentTask["id"] || (currentTask["exe"] = "Spotify" && currentTask["title"] != "Spotify" && spotifyActive))
        {
            Global tmp
            Global themeLocation
            Global taskWidth
            Global iconTaskXPadding
            Global iconTaskYPadding
            
            TmpFileLocation := tmp . "\" . currentTask["exe"] . ".bmp"
            
            SendRainmeterCommand("[!SetOption Task" . taskNumber . " LeftMouseDownAction `"`"`"[!CommandMeasure MeasureWindowMessage `"SendMessage 16666 " . currentTask["id"] . " 0`"]`"`"`" raindock]")
            SendRainmeterCommand("[!SetOption Task" . taskNumber . " MiddleMouseDownAction `"`"`"[explorer " . currentTask["path"] . "\" . currentTask["exe"] . ".exe" . "]`"`"`" raindock]")
            SendRainmeterCommand("[!SetOption Task" . taskNumber . " ImageName `"0.png`" raindock]")
            SendRainmeterCommand("[!UpdateMeter Task" . taskNumber . " raindock]")
            SendRainmeterCommand("[!ShowMeter Task" . taskNumber . " raindock]")

            if(currentTask["exe"] = "Spotify")
            {
                Global coverOut
                TmpFileLocation := coverOut 
            }
            else if(!FileExist(TmpFileLocation))
            {
                if(FileExist(themeLocation . currentTask["exe"] . ".png"))
                {    
                    renderIconTheme(themeLocation . currentTask["exe"] . ".png",TmpFileLocation)          
                }
                else
                {
                    Global tmp
                    icoPath :=  tmp . "\" . currentTask["exe"] . ".ico"
                    icoFile := currentTask["path"]
                    Initials := currentTask["exe"]
                    Loop Parse, Initials, A_Space
                    {
                        x := x SubStr(A_LoopField, "1", "1")
                        x := StrUpper(x)
                        Initials := x
                    }
                    Initials := StrReplace(Initials, "[", "")

                    if(currentTask["classname"] = "ApplicationFrameWindow")
                    {
                        
                        renderIconTheme("255,255,255,255",TmpFileLocation,Initials)
                    }
                    else{
                        Counter := 1
                        SendRainmeterCommand("[!EnableMeasure MeasureIconExe raindock]")
                        SendRainmeterCommand("[!SetOption MeasureIconExe IconPath `"" .  icoPath   . "`" raindock]")
                        SendRainmeterCommand("[!SetOption MeasureIconExe Path `"" . icoFile .  "`" raindock]")
                        SendRainmeterCommand("[!SetOption MeasureIconExe WildcardSearch `"" . currentTask["exe"] .  ".exe`" raindock]")
                        SendRainmeterCommand("[!UpdateMeasure MeasureIconExe raindock]")
                        SendRainmeterCommand("[!CommandMeasure MeasureIconExe `"Update`" raindock]")
                        While(!FileExist( icoPath ) && Counter < 200){
                            Sleep 30
                            Counter++
                        }

                        if(Counter > 199){
                            renderIconTheme("255,255,255,255",TmpFileLocation,Initials)
                        }
                        else{
                            renderIconTheme(icoPath,TmpFileLocation)
                        }
                    }
                }
            }

            SendRainmeterCommand("[!SetOption Task" . taskNumber . " ImageName `"" . TmpFileLocation . "`" raindock]")
            SendRainmeterCommand("[!UpdateMeter Task" . taskNumber . " raindock]")
        }
    } 
}

ListTaskbarWindows()
{
    Global TaskArray
    OldTaskArray := TaskArray
    TaskArray := {}
    TaskList := ""
    TaskCount := 0
    Global dockY
    Global dockX
    Global taskmax
    Global taskwidth
    Global iconTaskXPadding
    Global iconTaskYPadding
    Global ActiveHwnd

    id := WinGetList(,, "NxDock|Program Manager|Task Switching|^$")
    Loop id.Length()
    {
      thisId := id[A_Index]
      WinGetPos(,,, Height,"ahk_id " thisId)
      ClassName := WinGetClass("ahk_id " thisId)
      If (Height && !IsWindowCloaked(thisId) && !(WinGetExStyle("ahk_id " thisId) & 0x8000088))
      {
        TaskCount := ++TaskCount
        TaskList := Tasklist . "{{{" . ClassName . "}}}" . thisId . ","
      }
    }
    TaskList := Sort(TaskList, "D,")
    TaskList := RegExReplace(TaskList, "{{{.*?}}}")
    activeTask := false
    ActiveHwnd := WinExist("A",,RainmeterMeterWindow)
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
                    SendRainmeterCommand("[!HideMeter Task" .  (A_Index + TaskCount) . " raindock]")
                }
            }
            MoveDock(Floor((A_ScreenWidth - ((Taskwidth + (iconTaskXPadding * 2)) * TaskCount)) / 2 ) - ((Taskwidth + (iconTaskXPadding * 2)) * 2),dockX)
        }

        For TaskId in TaskArray
        {
            if(TaskId <= TaskCount)
            {
                SendTaskIconInfo(TaskArray[TaskId],OldTaskArray[TaskId],TaskId)
            }
        }
    }
}

dockStateHandler()
{
    Global dockMinMax
    Global oldDockMinMax := dockMinMax
    Global TaskWidth
    Global iconTaskYPadding
    MouseGetPos xpos, ypos 
    WinGetPos(,,CurrentWinWidth, CurrentWinHeight,"A")

    if(CurrentWinWidth = A_ScreenWidth && CurrentWinHeight = A_ScreenHeight)
    {
        dockMinMax := 2
    }
    else if(WinGetMinMax("A"))
    {
        dockMinMax := 1
    }
    else
    {
        dockMinMax := 0
    }
    ;MsgBox dockMinMax
    if(oldDockMinMax != dockMinMax)
    {
        if(dockMinMax < 1){
            dockShow()
            return
        }
        else{
            dockHide()
        }
    }

    if(dockMinMax = 1)
    {
        if(ypos >= (A_ScreenHeight - 2))
        {
            dockShow()
        }
        else if(ypos <= (A_ScreenHeight - (TaskWidth + (iconTaskYPadding * 2)))){
            dockHide()
        }
    }
}


