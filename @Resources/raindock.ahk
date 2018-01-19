SetTitleMatchMode "RegEx"
#Persistent
#SingleInstance force
CoordMode "Mouse", "Screen"
TraySetIcon(A_WorkingDir . "\raindock.ico")

dirTemp := EnvGet("TMP")
dirThemeTemp := dirTemp . "\raindock"
dirUser := EnvGet("USERPROFILE") . "\raindock"
iniFile := dirUser . "\raindock.ini"

spotifyWidget := []
spotifyWidget["active"] := False
if(FileExist(dirTemp . "\cover.bmp"))
{
    spotifyWidget["active"] := True
    spotifyWidget["sourceCover"] := dirTemp . "\cover.bmp"
    spotifyWidget["lastAlbum"] := ""
    spotifyWidget["renderedCover"] := dirTemp . "\smallcover.bmp"
    SetTimer "RenderSpotifyIcon", 1000
}
if(!FileExist(dirUser))
{
    DirCreate dirUser
    FileCopy A_WorkingDir . "\@Resources\default.ini", dirUser . "\raindock.ini"
    SendRainmeterCommand("[!Refresh raindock]")
}
if(!FileExist(dirThemeTemp))
{
    DirCreate dirThemeTemp
    SendRainmeterCommand("[!Refresh raindock]")
}

iconTheme := []
iconTheme["location"] := StrReplace(IniRead(iniFile, "Variables", "ThemePath"), "#@#", A_WorkingDir)
iconTheme["w"] := IniRead(iniFile, "Variables", "Taskwidth")
iconTheme["paddingX"] := IniRead(iniFile, "Variables", "iconTaskXPadding")
iconTheme["paddingY"] := IniRead(iniFile, "Variables", "iconTaskYPadding")
iconTheme["accentColor"] := SubStr(Format("{1:#x}", RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\DWM", "ColorizationColor")), 3, 6) . "FF"

dockConfig := []
dockConfig["h"] := (iconTheme["w"] + (iconTheme["paddingY"] * 2)) + 70
dockConfig["x"] := 0
dockConfig["y"] := (A_ScreenHeight - dockConfig["h"])
dockConfig["animating"] := false
dockConfig["minMax"] := 0
dockConfig["visible"] := true

TaskArray := {}
taskmax := 16
ActiveHwnd := WinExist("A",,RainmeterMeterWindow)

SendRainmeterCommand("[!SetVariable AHKVersion " . A_AhkVersion . " raindock]")
SendRainmeterCommand("[!UpdateMeasure MeasureWindowMessage raindock]")

OnMessage(16666, "taskSwitch")
OnMessage(16668, "clearIconCache")
OnMessage(16669, "selectIconTheme")

SetTimer "ListTaskbarWindows", 300
SetTimer "dockStateHandler", 300

clearIconCache()
{
    Global dirThemeTemp
    FileDelete dirThemeTemp . "\*.bmp"
    Sleep 1000
    SendRainmeterCommand("[!Refresh raindock]")
}

selectIconTheme()
{
    Global iniFile
    Global dirUser
    IniWrite DirSelect("*" . dirUser, Options, Prompt) . "\" , iniFile, "Variables", "ThemePath"
    clearIconCache()
}

dockHide()
{
    Global dockConfig

    if(dockConfig["animating"] = true || dockConfig["visible"] = false || dockConfig["minMax"] = 0){
        return
    }
    dockConfig["visible"] := false
    dockConfig["animating"] := true
    dockConfig["y"] := A_ScreenHeight - dockConfig["h"]
    Loop (dockConfig["h"])
    {
        dockConfig["y"] := dockConfig["y"] +1
        SendRainmeterCommand("[!Move `" " . dockConfig["x"] . " `" `" " . dockConfig["y"] . " `" `"raindock`"]")
    }
    dockConfig["animating"] := false
}

dockShow()
{
    Global dockConfig
    
    if(dockConfig["animating"] = true || dockConfig["visible"] = true || dockConfig["minMax"] = 2){
        return
    }
    dockConfig["visible"] := true
    dockConfig["animating"] := true
    dockConfig["y"] := A_ScreenHeight
    Loop (dockConfig["h"])
    {
        dockConfig["y"] := dockConfig["y"] -1
        SendRainmeterCommand("[!Move `" " . dockConfig["x"] . " `" `" " . dockConfig["y"] . " `" `"raindock`"]")
    }
    dockConfig["animating"] := false
}

MoveDock(MoveX,oldPos)
{
    Global dockConfig

    if(MoveX < dockConfig["x"]){
        step := (MoveX - oldPos)  / dockConfig["h"]
        leftRight := "moveRight"
    }
    else{
        step := (oldPos - MoveX) / dockConfig["h"]
        leftRight := "moveLeft"
    }

    Loop (dockConfig["h"])
    {
        if(leftRight = "moveRight"){
            dockConfig["x"] := dockConfig["x"] + step
        }
        else{
            dockConfig["x"] := dockConfig["x"] - step
        }
        SendRainmeterCommand("[!Move `" " . dockConfig["x"] . " `" `" " . dockConfig["y"] . " `" `"raindock`"]")
    }

}

taskSwitch(wParam, lParam)
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
    if(Send_WM_COPYDATA(command, "ahk_class RainmeterMeterWindow") = 1){
        ExitApp
    }
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
    Global spotifyWidget
    currentAlbum := FileGetTime(spotifyWidget["sourceCover"], C)

    if(spotifyWidget["lastAlbum"] != currentAlbum )
    {
        spotifyWidget["lastAlbum"] := currentAlbum
        renderIconTheme(spotifyWidget["sourceCover"],spotifyWidget["renderedCover"]) 
    }
}


renderIconTheme(iconFile,renderTo,string := ""){

    if(string){
        Global iconTheme
        MM1 := "Text " . string . " | Offset (#Taskwidth# / 2),(#Taskwidth# / 2) | ignore 1  | Color " . iconFile . " | Face Segoe UI | Weight 700 | Align CenterCenter"
        MM2 := iconTheme["accentColor"]
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
       
        Global spotifyWidget

        if(!oldTask || oldTask["id"] != currentTask["id"] || (currentTask["exe"] = "Spotify"  && spotifyWidget["active"]))
        {
            Global dirThemeTemp
            Global iconTheme            
            renderedIcon := dirThemeTemp . "\" . currentTask["exe"] . ".bmp"
            
            SendRainmeterCommand("[!SetOption Task" . taskNumber . " LeftMouseDownAction `"`"`"[!CommandMeasure MeasureWindowMessage `"SendMessage 16666 " . currentTask["id"] . " 0`"]`"`"`" raindock]")
            SendRainmeterCommand("[!SetOption Task" . taskNumber . " MiddleMouseDownAction `"`"`"[explorer " . currentTask["path"] . "\" . currentTask["exe"] . ".exe" . "]`"`"`" raindock]")
            SendRainmeterCommand("[!SetOption Task" . taskNumber . " ImageName `"0.png`" raindock]")
            SendRainmeterCommand("[!UpdateMeter Task" . taskNumber . " raindock]")
            SendRainmeterCommand("[!ShowMeter Task" . taskNumber . " raindock]")

            if(currentTask["exe"] = "Spotify" && spotifyWidget["active"] && currentTask["title"] != "Spotify")
            {
                renderedIcon := spotifyWidget["renderedCover"] 
            }
            else if(!FileExist(renderedIcon))
            {
                if(FileExist(iconTheme["location"] . currentTask["exe"] . ".png"))
                {    
                    renderIconTheme(iconTheme["location"] . currentTask["exe"] . ".png",renderedIcon)          
                }
                else
                {
                    iconExtracted :=  dirThemeTemp . "\" . currentTask["exe"] . ".ico"
                    extractExe := currentTask["path"]
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
                        
                        renderIconTheme("255,255,255,255",renderedIcon,Initials)
                    }
                    else{
                        Counter := 1
                        SendRainmeterCommand("[!EnableMeasure MeasureIconExe raindock]")
                        SendRainmeterCommand("[!SetOption MeasureIconExe IconPath `"" .  iconExtracted   . "`" raindock]")
                        SendRainmeterCommand("[!SetOption MeasureIconExe Path `"" . extractExe .  "`" raindock]")
                        SendRainmeterCommand("[!SetOption MeasureIconExe WildcardSearch `"" . currentTask["exe"] .  ".exe`" raindock]")
                        SendRainmeterCommand("[!UpdateMeasure MeasureIconExe raindock]")
                        SendRainmeterCommand("[!CommandMeasure MeasureIconExe `"Update`" raindock]")
                        While(!FileExist( iconExtracted ) && Counter < 200){
                            Sleep 30
                            Counter++
                        }

                        if(Counter > 199){
                            renderIconTheme("255,255,255,255",renderedIcon,Initials)
                        }
                        else{
                            renderIconTheme(iconExtracted,renderedIcon)
                        }
                    }
                }
            }
            SendRainmeterCommand("[!SetOption Task" . taskNumber . " ImageName `"" . renderedIcon . "`" raindock]")
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
    Global dockConfig
    Global iconTheme
    Global taskmax
    Global ActiveHwnd

    id := WinGetList(,, "NxDock|Program Manager|Task Switching|^$")
    Loop id.Length()
    {
      thisId := id[A_Index]
      WinGetPos(,,, Height,"ahk_id " thisId)
      SplitPath WinGetProcessPath("ahk_id " thisId) ,, Path,, SortName
      If (Height && !IsWindowCloaked(thisId) && !(WinGetExStyle("ahk_id " thisId) & 0x8000088))
      {
        TaskCount := ++TaskCount
        TaskList := Tasklist . "{{{" . SortName . "}}}" . thisId . ","
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
            MoveDock(Floor((A_ScreenWidth - ((iconTheme["w"] + (iconTheme["paddingX"] * 2)) * TaskCount)) / 2 ) - ((iconTheme["w"] + (iconTheme["paddingX"] * 2)) * 2),dockConfig["x"])
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
    Global dockConfig
    Global iconTheme
    Global oldDockMinMax := dockConfig["minMax"]
    MouseGetPos xpos, ypos 
    WinGetPos(,,CurrentWinWidth, CurrentWinHeight,"A")

    if(CurrentWinWidth = A_ScreenWidth && CurrentWinHeight = A_ScreenHeight)
    {
        dockConfig["minMax"] := 2
    }
    else if(WinGetMinMax("A"))
    {
        dockConfig["minMax"] := 1
    }
    else
    {
        dockConfig["minMax"] := 0
    }
    if(oldDockMinMax != dockConfig["minMax"])
    {
        if(dockConfig["minMax"] < 1){
            dockShow()
            return
        }
        else{
            dockHide()
        }
    }

    if(dockConfig["minMax"] = 1)
    {
        if(ypos >= (A_ScreenHeight - 2))
        {
            dockShow()
        }
        else if(ypos <= (A_ScreenHeight - (iconTheme["w"] + (iconTheme["paddingY"] * 2)))){
            dockHide()
        }
    }
}


