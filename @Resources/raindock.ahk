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

#Include inc_lib.ahk
#Include inc_animations.ahk
#Include inc_magickmeter.ahk
#Include inc_menu.ahk
#Include inc_mediaplayer.ahk

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

SendRainmeterCommand("[!SetVariable AHKVersion " . A_AhkVersion . " raindock]")
SendRainmeterCommand("[!UpdateMeasure MeasureWindowMessage raindock]")

SetTimerAndFire("getWindows", 300)
SetTimerAndFire("dockStateHandler", 300)

renderMeter(currentTask,oldTask,taskNumber)
{
    if(!oldTask || oldTask["title"] != currentTask["title"] || oldTask["id"] != currentTask["id"])
    {
        SendRainmeterCommand("[!SetOption Task" . taskNumber . " MouseOverAction `"`"`"[!ShowMeterGroup groupIconLabel raindock][!SetOption iconTitle Text `"    " . currentTask["title"] . "`" raindock][!SetOption iconExe Text `"" . currentTask["exe"] . "`" raindock][!MoveMeter ([#CURRENTSECTION#:X]+(#TaskWidth#/2)+#iconTaskXPadding#) 0 iconTitle][!UpdateMeter iconExe raindock][!UpdateMeter iconTitle raindock]`"`"`" raindock]")
        Global arrayMediaPlayer

        if(!oldTask || oldTask["id"] != currentTask["id"] || (currentTask["exe"] = arrayMediaPlayer["mediaPlayer"]  && arrayMediaPlayer["active"]))
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

            if(currentTask["exe"] = arrayMediaPlayer["mediaPlayer"] && arrayMediaPlayer["active"] && currentTask["title"] != arrayMediaPlayer["mediaPlayer"])
            {
                renderedIcon := arrayMediaPlayer["renderedCover"] 
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


getWindows()
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
            renderMeter(TaskArray[TaskId],OldTaskArray[TaskId],A_Index)
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



