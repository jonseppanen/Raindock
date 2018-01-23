SetTitleMatchMode "RegEx"
#Persistent
#SingleInstance force
CoordMode "Mouse", "Screen"
TraySetIcon(A_WorkingDir . "\raindock.ico")

dirTemp := EnvGet("TMP")
dirThemeTemp := dirTemp . "\raindock"
dirUser := EnvGet("USERPROFILE") . "\raindock"
dirCustomIcons := dirUser . "\customIcons"
dirPinnedItems := EnvGet("USERPROFILE") . "\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
iniFile := dirUser . "\raindock.ini"

iconTheme := []
iconTheme["location"] := StrReplace(IniRead(iniFile, "Variables", "ThemePath"), "#@#", A_WorkingDir)
iconTheme["w"] := IniRead(iniFile, "Variables", "Taskwidth")
iconTheme["paddingX"] := IniRead(iniFile, "Variables", "iconTaskXPadding")
iconTheme["paddingY"] := IniRead(iniFile, "Variables", "iconTaskYPadding")
iconTheme["accentColor"] := SubStr(Format("{1:#x}", RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\DWM", "ColorizationColor")), 3, 6) . "FF"

spotifyWidget := []
spotifyWidget["active"] := False
if(FileExist(dirTemp . "\cover.bmp"))
{
    spotifyWidget["active"] := True
    spotifyWidget["sourceCover"] := dirTemp . "\cover.bmp"
    spotifyWidget["lastAlbum"] := ""
    spotifyWidget["renderedCover"] := dirTemp . "\smallcover.bmp"
    SetTimerandFire("RenderSpotifyIcon", 1000)
}
if(!FileExist(dirUser))
{
    DirCreate dirUser
    
    FileCopy A_WorkingDir . "\default.ini", dirUser . "\raindock.ini"
    SendRainmeterCommand("[!Refresh raindock]")
}
if(!FileExist(dirCustomIcons))
{
    DirCreate dirCustomIcons
}
if(!FileExist(dirThemeTemp))
{
    DirCreate dirThemeTemp
    SendRainmeterCommand("[!Refresh raindock]")
}

dockConfig := []
dockConfig["h"] := (iconTheme["w"] + (iconTheme["paddingY"] * 2)) + 95
dockConfig["x"] := 0
dockConfig["y"] := (A_ScreenHeight - dockConfig["h"])
dockConfig["animating"] := false
dockConfig["minMax"] := 0
dockConfig["visible"] := true

arrayPinnedItems := []
TaskArray := {}
ActiveHwnd := WinExist("A",,RainmeterMeterWindow)

SendRainmeterCommand("[!SetVariable AHKVersion " . A_AhkVersion . " raindock]")
SendRainmeterCommand("[!UpdateMeasure MeasureWindowMessage raindock]")

OnMessage(16665, "taskItemMenu")
OnMessage(16666, "taskSwitch")
OnMessage(16667, "taskManage")
OnMessage(16668, "clearIconCache")
OnMessage(16669, "selectIconTheme")

SetTimerAndFire("enumeratedPinnedItems", 3000)
SetTimerAndFire("ListTaskbarWindows", 300)
SetTimerAndFire("dockStateHandler", 300)

SetTimerAndFire(timedFunction, timedDuration)
{
    %timedFunction%()
    SetTimer timedFunction, timedDuration
}

hasValue(haystack, needle) 
{
    if(!isObject(haystack))
        return false
    if(haystack.Length()==0)
        return false
    for k,v in haystack
        if(v==needle)
            return true
    return false
}

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
    newTheme := DirSelect("*" . dirUser, Options, Prompt)
    if(newTheme)
    {   
        IniWrite newTheme . "\" , iniFile, "Variables", "ThemePath"
        clearIconCache()
    }
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
        else if(ypos <= (A_ScreenHeight - (iconTheme["w"] + (iconTheme["paddingY"] * 2) + 10))){
            dockHide()
        }
    }
}

getArraysIdentical(firstArray,SecondArray)
{
    if(firstArray.length() != SecondArray.length())
    {
        return false
    }

    For arrKey in firstArray
    {
        if(firstArray[arrKey] != SecondArray[arrKey])
        {
            return false
        }
    }

    return true
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

taskManage(wParam, lParam)
{
    Global TaskArray
    Global selectedTask
    Global dirPinnedItems
    Global dirCustomIcons
    Global dirThemeTemp

    if(wParam = "minimize")
    {
        WinMinimize "ahk_id " TaskArray[selectedTask]["id"]
    }
    else if(wParam = "open")
    {
        run TaskArray[selectedTask]["fullpath"]
    }
    else if(wParam = "maximize")
    {
        WinMaximize "ahk_id " TaskArray[selectedTask]["id"]
    }
    else if(wParam = "properties")
    {
        Run "properties " . TaskArray[selectedTask]["fullpath"]
    }
    else if(wParam = "close")
    {
        WinClose "ahk_id " TaskArray[selectedTask]["id"]
    }
    else if(wParam = "unpin from dock")
    {
        FileDelete dirPinnedItems . "\" . TaskArray[selectedTask]["exe"] . ".lnk"
    }
    else if(wParam = "pin to dock")
    {
        FileCreateShortcut TaskArray[selectedTask]["fullpath"],  dirPinnedItems . "\" . TaskArray[selectedTask]["exe"] . ".lnk"
    }
    else if(wParam = "change icon")
    {   
        newIcon := FileSelect(,,, "Image Files (*.png)")
        if(newIcon)
        {
            newCustomIconFile := dirCustomIcons . "\" . TaskArray[selectedTask]["exe"] . ".png"
            FileCopy newIcon, newCustomIconFile
            renderIconTheme(newCustomIconFile,dirThemeTemp . "\" . TaskArray[selectedTask]["exe"] . ".bmp" ,0)
            renderIconTheme(newCustomIconFile,dirThemeTemp . "\" . TaskArray[selectedTask]["exe"] . "_pin.bmp" ,1)
        }
    }
    else if(wParam = "reload icon")
    {   
        fileIcon := dirThemeTemp . "\" . TaskArray[selectedTask]["exe"] . ".bmp"
        filePinIcon := dirThemeTemp . "\" . TaskArray[selectedTask]["exe"] . "_pin.bmp"
        if(FileExist(fileIcon))
        {
            FileDelete fileIcon
        }
        if(FileExist(filePinIcon))
        {
            FileDelete filePinIcon
        }
        SendRainmeterCommand("[!Refresh raindock]")
    }
    else if(wParam = "restore original")
    {   
        fileIcon := dirThemeTemp . "\" . TaskArray[selectedTask]["exe"] . ".bmp"
        filePinIcon := dirThemeTemp . "\" . TaskArray[selectedTask]["exe"] . "_pin.bmp"
        customFileIcon := dirCustomIcons . "\" . TaskArray[selectedTask]["exe"] . ".png"
        if(FileExist(fileIcon))
        {
            FileDelete fileIcon
        }
        if(FileExist(filePinIcon))
        {
            FileDelete filePinIcon
        }
        if(FileExist(customFileIcon))
        {
            FileDelete customFileIcon
        }
        SendRainmeterCommand("[!Refresh raindock]")
    }
    else if(wParam = "refresh dock")
    {
        SendRainmeterCommand("[!Refresh raindock]")
    }
    else if(wParam = "Rainmeter Menu")
    {
        SendRainmeterCommand("[!Skinmenu raindock]")
    }
}

taskItemMenu(wParam, lParam)
{
    Global TaskArray
    Global selectedTask := wParam
    Global arrayPinnedItems
    Global dirPinnedItems

    menuTaskItem := MenuCreate()

    if (TaskArray[selectedTask]["id"] is "digit") 
    {
        menuTaskItem.Add "Minimize", "taskManage"
        menuTaskItem.Add "Maximize", "taskManage"
        menuTaskItem.Add "Close", "taskManage"
        menuTaskItem.Add  ; Add a separator line.
        menuTaskItem.Add "Properties", "taskManage"
    }
    else
    {
        menuTaskItem.Add "Open", "taskManage"
        menuTaskItem.Add "Properties", "taskManage"
    }

    if(hasValue(arrayPinnedItems,TaskArray[selectedTask]["fullpath"]))
    {
        menuTaskItem.Add "Unpin from Dock", "taskManage"
    }
    else
    {
        menuTaskItem.Add "Pin to Dock", "taskManage"
    }

    subMenuIcon := MenuCreate()
    subMenuIcon.Add "Change Icon", "taskManage"
    subMenuIcon.Add "Reload Icon", "taskManage"
    subMenuIcon.Add "Restore Original", "taskManage"

    menuTaskItem.Add "Icon", subMenuIcon

    menuTaskItem.Add  ; Add a separator line.

    subMenuDock := MenuCreate()
    subMenuDock.Add "Change Icon Theme", "selectIconTheme"
    subMenuDock.Add "Redraw All Icons", "clearIconCache"
    subMenuDock.Add "Refresh Dock", "taskManage"
    subMenuDock.Add "Rainmeter Menu", "taskManage"

    menuTaskItem.Add "Raindock", subMenuDock

    menuTaskItem.Show
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
    Global iconTheme
    currentAlbum := FileGetTime(spotifyWidget["sourceCover"], C)

    if(spotifyWidget["lastAlbum"] != currentAlbum )
    {
        spotifyWidget["lastAlbum"] := currentAlbum
        SendRainmeterCommand("[!SetOption magickmeter1 ExportTo `"" . spotifyWidget["renderedCover"] . "`" raindock]")
        SendRainmeterCommand("[!SetOption magickmeter1 Image `"Rectangle 0,0,(#TaskWidth# + (#iconTaskXPadding# * 2)),(#TaskWidth# + (#iconTaskYPadding# * 2) + 10)  | Color 255,255,255,1  `" raindock]")
        SendRainmeterCommand("[!SetOption magickmeter1 Image2 `"File " . spotifyWidget["sourceCover"] . " | RenderSize #TaskWidth#,(#TaskWidth#) | Move #iconTaskXPadding#,#iconTaskYPadding# | Perspective *,*,(#TaskWidth# - 10),15,(#TaskWidth# - 10),(#TaskWidth# - 20),*,*`" raindock]")
        SendRainmeterCommand("[!SetOption magickmeter1 Image3 `"File " . iconTheme["location"] . "spotify.png | RenderSize (#TaskWidth#/2),(#TaskWidth#/2) | move ((#TaskWidth#/2) + #iconTaskXPadding#) ,((#TaskWidth#/2) + #iconTaskYPadding#)`" raindock]")
        SendRainmeterCommand("[!SetOption magickmeter1 Image4 `"Rectangle #iconTaskXPadding#,(#TaskWidth# + (#iconTaskYPadding# * 2) + 8),#TaskWidth#,2  | ignore 0| Color 200,200,200,170`" raindock]")
        SendRainmeterCommand("[!UpdateMeasure magickmeter1 raindock]") 
    }
}

renderIconTheme(iconFile,renderTo,pinnedTask := 0,string := ""){

    SendRainmeterCommand("[!SetOption magickmeter1 ExportTo `"" . renderTo . "`" raindock]")
    SendRainmeterCommand("[!SetOption magickmeter1 Image `"Rectangle 0,0,(#TaskWidth# + (#iconTaskXPadding# * 2)),(#TaskWidth# + (#iconTaskYPadding# * 2) + 10)  | Color 255,255,255,1  `" raindock]")

    if(!string)
    {
        SendRainmeterCommand("[!SetOption magickmeter1 Image2 `"File " . iconFile . " | RenderSize #TaskWidth#,#TaskWidth# | move #iconTaskXPadding#,#iconTaskYPadding#`" raindock]")
        SendRainmeterCommand("[!SetOption magickmeter1 Image3 `"Rectangle 0,0,(#TaskWidth# + (#iconTaskXPadding# * 2)),(#TaskWidth# + (#iconTaskYPadding# * 2) + 10)  | Ignore 1 | Color 255,255,255,1  `" raindock]")
    }
    else
    {                           
        Global iconTheme
        SendRainmeterCommand("[!SetOption magickmeter1 Image2 `"Ellipse ((#TaskWidth# + (#iconTaskXPadding# * 2)) / 2),((#TaskWidth# + (#iconTaskYPadding# * 2)) / 2),(#TaskWidth# / 2) | Color " . iconTheme["accentColor"] . "`" raindock]")
        SendRainmeterCommand("[!SetOption magickmeter1 Image3 `"Text " . string . " | Offset ((#TaskWidth# + (#iconTaskXPadding# * 2)) / 2),((#TaskWidth# + (#iconTaskYPadding# * 2)) / 2)  | Color 255,255,255 | Face Segoe UI | Weight 700 | Align CenterCenter`" raindock]")
    }

    SendRainmeterCommand("[!SetOption magickmeter1 Image4 `"Rectangle #iconTaskXPadding#,(#TaskWidth# + (#iconTaskYPadding# * 2) + 8),#TaskWidth#,2  | ignore " . pinnedTask . "| Color 200,200,200,170`" raindock]")
    SendRainmeterCommand("[!UpdateMeasure magickmeter1 raindock]") 
    Counter := 1
    
    While(!FileExist( renderTo ) && Counter < 200){
        Sleep 30
        Counter++
    }
}

SendTaskIconInfo(currentTask,oldTask,taskNumber)
{
    if(!oldTask || oldTask["title"] != currentTask["title"] || oldTask["id"] != currentTask["id"])
    {
        SendRainmeterCommand("[!SetOption Task" . taskNumber . " MouseOverAction `"`"`"[!ShowMeterGroup groupIconLabel raindock][!SetOption iconTitle Text `"    " . currentTask["title"] . "`" raindock][!SetOption iconExe Text `"" . currentTask["exe"] . "`" raindock][!MoveMeter ([#CURRENTSECTION#:X]+(#TaskWidth#/2)+#iconTaskXPadding#) 0 iconTitle][!UpdateMeter iconExe raindock][!UpdateMeter iconTitle raindock]`"`"`" raindock]")
        Global spotifyWidget

        if(!oldTask || oldTask["id"] != currentTask["id"] || (currentTask["exe"] = "Spotify"  && spotifyWidget["active"]))
        {
            Global dirThemeTemp
            Global iconTheme            
            Global dirCustomIcons
            
            pinnedTask := 0
            pinnedExt := ""

            if (currentTask["id"] is "digit") 
            {
                SendRainmeterCommand("[!SetOption Task" . taskNumber . " LeftMouseDownAction `"`"`"[!CommandMeasure MeasureWindowMessage `"SendMessage 16666 " . currentTask["id"] . " 0`"]`"`"`" raindock]")
                SendRainmeterCommand("[!SetOption Task" . taskNumber . " MiddleMouseDownAction `"`"`"[explorer " . currentTask["fullPath"] . "]`"`"`" raindock]")
            }
            else
            {
                pinnedTask := 1
                pinnedExt := "_pin"
                SendRainmeterCommand("[!SetOption Task" . taskNumber . " LeftMouseDownAction `"`"`"[explorer " . currentTask["fullPath"] . "]`"`"`" raindock]")
                SendRainmeterCommand("[!SetOption Task" . taskNumber . " MiddleMouseDownAction `"`"`"[explorer " . currentTask["fullPath"] . "]`"`"`" raindock]")
            }
            
            renderedIcon := dirThemeTemp . "\" . currentTask["exe"] . pinnedExt . ".bmp"

            SendRainmeterCommand("[!SetOption Task" . taskNumber . " RightMouseUpAction `"`"`"[!CommandMeasure MeasureWindowMessage `"SendMessage 16665 " . taskNumber . " 0`"]`"`"`" raindock]")
            SendRainmeterCommand("[!ShowMeter Task" . taskNumber . " raindock]")

            if(currentTask["exe"] = "Spotify" && spotifyWidget["active"] && currentTask["title"] != "Spotify")
            {
                renderedIcon := spotifyWidget["renderedCover"] 
            }
            else if(!FileExist(renderedIcon))
            { 
                if(FileExist(dirCustomIcons . "\" . currentTask["exe"] . ".png"))
                {    
                    renderIconTheme(dirCustomIcons . "\" . currentTask["exe"] . ".png",renderedIcon,pinnedTask)          
                }
                else if(FileExist(iconTheme["location"] . currentTask["exe"] . ".png"))
                {    
                    renderIconTheme(iconTheme["location"] . currentTask["exe"] . ".png",renderedIcon,pinnedTask)          
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
                        
                        renderIconTheme("255,255,255,255",renderedIcon,pinnedTask,Initials)
                    }
                    else{
                        Counter := 1
                        SendRainmeterCommand("[!EnableMeasure MeasureIconExe raindock]")
                        SendRainmeterCommand("[!SetOption MeasureIconExe IconPath `"" .  iconExtracted   . "`" raindock]")
                        SendRainmeterCommand("[!SetOption MeasureIconExe Path `"" . extractExe .  "`" raindock]")
                        SendRainmeterCommand("[!SetOption MeasureIconExe WildcardSearch `"" . currentTask["exe"] .  "." . currentTask["ext"] . "`" raindock]")
                        SendRainmeterCommand("[!UpdateMeasure MeasureIconExe raindock]")
                        SendRainmeterCommand("[!CommandMeasure MeasureIconExe `"Update`" raindock]")
                        While(!FileExist( iconExtracted ) && Counter < 200){
                            Sleep 30
                            Counter++
                        }

                        if(Counter > 199){
                            renderIconTheme("255,255,255,255",renderedIcon,pinnedTask,Initials)
                        }
                        else{
                            renderIconTheme(iconExtracted,renderedIcon,pinnedTask)
                        }
                    }
                }
            }
            SendRainmeterCommand("[!SetOption Task" . taskNumber . " ImageName `"" . renderedIcon . "`" raindock]")
            SendRainmeterCommand("[!UpdateMeter Task" . taskNumber . " raindock]")
        }
    } 
}

enumeratedPinnedItems()
{
    Global dirPinnedItems
    Global arrayPinnedItems
    newArrayPinnedItems := []

    Loop Files, dirPinnedItems . "\*.lnk" 
    {
        FileGetShortcut A_LoopFilePath, OutTarget
        if (OutTarget)
        {
            newArrayPinnedItems.push(OutTarget)
        }
    }

    if(!getArraysIdentical(arrayPinnedItems,newArrayPinnedItems))
    {
        arrayPinnedItems := newArrayPinnedItems
    }  
}

ListTaskbarWindows()
{
    Global TaskArray
    Global arrayPinnedItems
    Global dockConfig
    Global iconTheme
    Global ActiveHwnd

    tablePinnedTasks := {}
    OldTaskArray := TaskArray
    TaskArray := []
    TaskList := ""

    For pinnedItem in arrayPinnedItems
    {
        SplitPath arrayPinnedItems[pinnedItem] ,OutFileName,Path,OutExtension,OutNameNoExt
        tablePinnedTasks[OutNameNoExt] := arrayPinnedItems[pinnedItem]
        TaskList := Tasklist . "{{{111" . OutNameNoExt . "}}}" . OutNameNoExt . ","
    }
    
    id := WinGetList(,, "NxDock|Program Manager|Task Switching|^$")
    Loop id.Length()
    {
        thisId := id[A_Index]
        if (WinGetExStyle("ahk_id " thisId) & 0x8000088)
        {
            continue
        }
        WinGetPos(,,, Height,"ahk_id " thisId)
        SplitPath WinGetProcessPath("ahk_id " thisId) ,, Path,, SortName
        if(InStr(TaskList, "{{{111" . SortName . "}}}"))
        {
            if(tablePinnedTasks[SortName])
            {   
                
                TaskList := StrReplace(TaskList, "{{{111" . SortName . "}}}" . SortName . ",", "")
                tablePinnedTasks.delete(SortName)
            }
            SortName := "111" . SortName
        }

        If (Height && !IsWindowCloaked(thisId))
        {
            TaskList := Tasklist . "{{{" . SortName . "}}}" . thisId . ","
        }
    }

    TaskList := Sort(TaskList, "D,")
    TaskList := RegExReplace(TaskList, "{{{.*?}}}")
    TaskList := RegExReplace(TaskList, ",$" )

    activeTask := false
    ActiveHwnd := WinExist("A",,RainmeterMeterWindow)

    Loop Parse, TaskList, "," 
    {
        if !(A_LoopField is "digit") 
        {
            fullPath := tablePinnedTasks[A_LoopField]
            ClassName := A_LoopField
            Titlevar := A_LoopField
        }
        else
        {
            fullPath := WinGetProcessPath("ahk_id " A_LoopField)
            ClassName := WinGetClass("ahk_id " A_LoopField)
            Titlevar := WinGetTitle("ahk_id " A_LoopField)
        }
        
        SplitPath fullPath ,, Path,OutExtension,OutNameNoExt    

        if(ClassName != "ApplicationFrameWindow")
        {
            ExeName := OutNameNoExt
        }
        else
        {
            TitleArray := StrSplit(Titlevar, "- ") 
            ExeName := TitleArray[TitleArray.length()]
        }
        TaskArray[A_Index,"id"] := A_LoopField 
        TaskArray[A_Index,"classname"] := ClassName
        TaskArray[A_Index,"title"] := Titlevar
        TaskArray[A_Index,"exe"] := ExeName
        TaskArray[A_Index,"ext"] := OutExtension
        TaskArray[A_Index,"path"] := Path
        TaskArray[A_Index,"fullPath"] := fullPath

        if WinActive("ahk_id " A_LoopField)
        {
            activeTask := true
            SendRainmeterCommand("[!SetOption TaskIndicator X `"[Task" . A_Index . ":X] `" raindock]")
            SendRainmeterCommand("[!ShowMeter TaskIndicator raindock]")
        }
    }

    if(!activeTask)
    {
        SendRainmeterCommand("[!HideMeter TaskIndicator raindock]")
    }

    For TaskId in TaskArray
    {
        if(TaskArray[TaskId,"id"] . TaskArray[TaskId,"title"] != OldTaskArray[TaskId,"id"] . OldTaskArray[TaskId,"title"] )
        {
            SendTaskIconInfo(TaskArray[TaskId],OldTaskArray[TaskId],A_Index)
        }
    }

    if(OldTaskArray.length() != TaskArray.length())
    {
        if(OldTaskArray.length() > TaskArray.length())
        {
            Loop (OldTaskArray.length() - TaskArray.length())
            {
                SendRainmeterCommand("[!SetOption Task" .  (A_Index + TaskArray.length()) . " ImageName `"`" raindock]")
                SendRainmeterCommand("[!HideMeter Task" .  (A_Index + TaskArray.length()) . " raindock]")
            }
        }
        MoveDock(Floor((A_ScreenWidth - ((iconTheme["w"] + (iconTheme["paddingX"] * 2)) * TaskArray.length())) / 2 ) - ((iconTheme["w"] + (iconTheme["paddingX"] * 2)) * 2),dockConfig["x"])
    }
}



