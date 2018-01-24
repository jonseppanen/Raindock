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
iconTheme := {}
iconTheme["location"] := StrReplace(IniRead(iniFile, "Variables", "ThemePath"), "#@#", A_WorkingDir)
iconTheme["w"] := IniRead(iniFile, "Variables", "Taskwidth")
iconTheme["paddingX"] := IniRead(iniFile, "Variables", "iconTaskXPadding")
iconTheme["paddingY"] := IniRead(iniFile, "Variables", "iconTaskYPadding")
iconTheme["accentColor"] := SubStr(Format("{1:#x}", RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\DWM", "ColorizationColor")), 3, 6) . "FF"
dockConfig := {}
dockConfig["h"] := (iconTheme["w"] + (iconTheme["paddingY"] * 2)) + 95
dockConfig["x"] := 0
dockConfig["y"] := (A_ScreenHeight - dockConfig["h"])
dockConfig["animating"] := false
dockConfig["minMax"] := 0
dockConfig["visible"] := true
arrayTasks := {}
ActiveHwnd := WinExist("A",,RainmeterMeterWindow)

#Include inc_lib.ahk
#Include inc_renderer.ahk
#Include inc_menu.ahk
#Include inc_animations.ahk
#Include inc_magickmeter.ahk
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
    FileCopy(A_WorkingDir . "\default.ini", dirUser . "\raindock.ini", 1)
    SendRainmeterCommand("[!Refresh raindock]")
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

createTaskObject(taskRef, targetArray)
{
    if (A_LoopField is "digit")
    {
        fullPath := WinGetProcessPath("ahk_id " A_LoopField)
        SplitPath fullPath , OutFileName, OutDir, OutExtension, OutNameNoExt
        targetArray[A_Index,"id"] := A_LoopField
        targetArray[A_Index,"classname"] := WinGetClass("ahk_id " A_LoopField)
        targetArray[A_Index,"title"] := WinGetTitle("ahk_id " A_LoopField)
    }
    else
    {
        fullPath := A_LoopField
        SplitPath fullPath , OutFileName, OutDir, OutExtension, OutNameNoExt
        targetArray[A_Index,"id"] := OutNameNoExt
        targetArray[A_Index,"classname"] := OutNameNoExt
        targetArray[A_Index,"title"] := OutNameNoExt
    }
    targetArray[A_Index,"fullPath"] := fullPath
    targetArray[A_Index,"exe"] := OutNameNoExt
    targetArray[A_Index,"ext"] := OutExtension
    targetArray[A_Index,"exeext"] := OutFileName
    targetArray[A_Index,"path"] := OutDir
}

getWindows()
{
    Global csvPinnedItems
    Global dockConfig
    Global iconTheme
    Global ActiveHwnd
    Global arrayTasks
    Global arrayMediaPlayer
    arrayTasksCheck := {}

    csvTaskList := csvPinnedItems
    ActiveHwnd := WinExist("A",,RainmeterMeterWindow)
    ActiveIndicator := false
    
    id := WinGetList(,, "NxDock|Program Manager|Task Switching|^$")
    Loop id.Length()
    {
        thisId := id[A_Index]
        WinGetPos(,,, Height,"ahk_id " thisId)

        if ((WinGetExStyle("ahk_id " thisId) & 0x8000088) || !Height || IsWindowCloaked(thisId))
        {
            continue
        }

        taskExeName := WinGetProcessName("ahk_id " thisId)
        taskExePath := WinGetProcessPath("ahk_id " thisId)
        pinnedQuery := "{{{111" . taskExeName . "}}}"

        if(InStr(csvTaskList, pinnedQuery))
        {
            if(InStr(csvTaskList, pinnedQuery . taskExePath))
            {
                csvTaskList := StrReplace(csvTaskList, pinnedQuery . taskExePath, "{{{111" . taskExeName . "}}}" . thisId)
            }
            else
            {
                csvTaskList := csvTaskList . "{{{111" . taskExeName . "}}}" . thisId . ","
            }   
        }
        else
        {
            csvTaskList := csvTaskList . "{{{" . taskExeName . "}}}" . thisId . ","
        }
    }

    csvTaskList := Sort(csvTaskList, "D,")
    csvTaskList := RegExReplace(csvTaskList, "{{{.*?}}}")
    csvTaskList := RegExReplace(csvTaskList, ",$" )

    Loop Parse, csvTaskList, "," 
    {
        createTaskObject(A_LoopField,arrayTasksCheck)
    }
    
    SendRainmeterCommand("[!HideMeter TaskIndicator raindock]")
                
    For TaskId in arrayTasksCheck
    {
        if(!arrayTasks || arrayTasksCheck[TaskId,"title"] != arrayTasks[TaskId,"title"] )
        {
            renderTooltip(arrayTasksCheck[TaskId],A_Index)
        }
        if(!arrayTasks || arrayTasksCheck[TaskId,"id"] != arrayTasks[TaskId,"id"] || (arrayTasks[TaskId,"exe"] = arrayMediaPlayer["mediaPlayer"] && arrayTasksCheck[TaskId,"title"] != arrayTasks[TaskId,"title"]))
        {
            renderMeter(arrayTasksCheck[TaskId],A_Index)
        }
        
        if WinActive("ahk_id " arrayTasksCheck[TaskId,"id"])
        {
            ActiveIndicator := true
            SendRainmeterCommand("[!SetOption TaskIndicator X `"[Task" . TaskId . ":X] `" raindock]")
            SendRainmeterCommand("[!ShowMeter TaskIndicator raindock]")
        }
    }
    
    if(!ActiveIndicator)
    { 
        SendRainmeterCommand("[!HideMeter TaskIndicator raindock]")
    }

    if(arrayTasks.length() != arrayTasksCheck.length())
    {
        if(arrayTasks.length() > arrayTasksCheck.length())
        {
            Loop (arrayTasks.length() - arrayTasksCheck.length())
            {
                SendRainmeterCommand("[!SetOption Task" .  (A_Index + arrayTasksCheck.length()) . " ImageName `"`" raindock]")
                SendRainmeterCommand("[!HideMeter Task" .  (A_Index + arrayTasksCheck.length()) . " raindock]")
            }
        }
        MoveDock(Floor((A_ScreenWidth - ((iconTheme["w"] + (iconTheme["paddingX"] * 2)) * arrayTasksCheck.length())) / 2 ) - ((iconTheme["w"] + (iconTheme["paddingX"] * 2)) * 2),dockConfig["x"])
    }

    arrayTasks := arrayTasksCheck
}



