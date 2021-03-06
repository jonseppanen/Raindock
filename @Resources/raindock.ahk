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
dirRaindock := getThisDirName()
arrayTasks := {}
csvPinnedItems := ""
ActiveHwnd := WinExist("A",,RainmeterMeterWindow)

iniFile := dirUser . "\raindock.ini"
iconTheme := {}
dockConfig := {}
iconTheme["location"] := StrReplace(IniRead(iniFile, "Variables", "ThemePath"), "#@#", A_WorkingDir)
iconTheme["w"] := IniRead(iniFile, "Variables", "iconWidth")
iconTheme["h"] := IniRead(iniFile, "Variables", "iconHeight")
iconTheme["paddingX"] := IniRead(iniFile, "Variables", "iconHorizontalPadding")
iconTheme["paddingY"] := IniRead(iniFile, "Variables", "iconVerticalPadding")
dockConfig["position"] := IniRead(iniFile, "Variables", "screenPosition")
dockConfig["autohide"] := IniRead(iniFile, "Variables", "autohide")
checkIniFile()

iconTheme["wFull"] := (iconTheme["w"] + (iconTheme["paddingX"] * 2))
iconTheme["hFull"] := (iconTheme["h"] + (iconTheme["paddingY"] * 2))
iconTheme["accentColor"] := SubStr(Format("{1:#x}", RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\DWM", "ColorizationColor")), 3, 6) . "FF"
dockConfig["animating"] := false
dockConfig["minMax"] := 0
dockConfig["visible"] := true
dockConfig["animationFrames"] := 300
dockIndicatorRect := {"bottom":"#iconHorizontalPadding#,(#iconWidth# + (#iconVerticalPadding# * 2) - 2),#iconWidth#,2","top":"#iconHorizontalPadding#,0,#iconWidth#,2","left":"0,#iconVerticalPadding#,2,#iconHeight#","right":"(#iconWidth# + (#iconHorizontalPadding# * 2) - 2),#iconVerticalPadding#,2,#iconHeight#"}



if(dockConfig["position"] = "left")
{
    dockConfig["edge"] := (iconTheme["wFull"])
    dockConfig["axis"] := (iconTheme["hFull"])
    dockConfig["y"] := ((A_ScreenHeight / 2) - (iconTheme["hFull"] * 5))
    dockConfig["x"] := 0
}  
else if(dockConfig["position"] = "bottom")
{   
    dockConfig["edge"] := (iconTheme["hFull"])
    dockConfig["axis"] := (iconTheme["wFull"])
    dockConfig["y"] := (A_ScreenHeight - (iconTheme["hFull"] * 5))
    dockConfig["x"] := ((A_ScreenWidth / 2) - (iconTheme["wFull"] * 5))
}
else if(dockConfig["position"] = "right")
{
    dockConfig["edge"] := (iconTheme["wFull"])
    dockConfig["axis"] := (iconTheme["hFull"])
    dockConfig["y"] := ((A_ScreenHeight / 2) - (iconTheme["hFull"] * 5))
    dockConfig["x"] := A_ScreenWidth - (iconTheme["wFull"] * 5)
}  
else
{
    dockConfig["edge"] := (iconTheme["hFull"])
    dockConfig["axis"] := (iconTheme["wFull"])
    dockConfig["y"] := -(iconTheme["hFull"] * 0)
    dockConfig["x"] := ((A_ScreenWidth / 2) - (iconTheme["wFull"] * 5))
}  

SendRainmeterCommand("!Move " . dockConfig["x"] . " " . dockConfig["y"] . " ")

#Include inc_lib.ahk
#Include inc_renderer.ahk
#Include inc_menu.ahk
#Include inc_animations.ahk
#Include inc_magickmeter.ahk
#Include inc_mediaplayer.ahk

SendRainmeterCommand("!SetVariable AHKVersion " . A_AhkVersion . " ")
SendRainmeterCommand("!UpdateMeasure MeasureWindowMessage")

OnMessage(16666, "taskSwitch")
SetTimerAndFire("getPinnedTaskbarIcons", 3000)
SetTimerAndFire("getWindows", 300)
SetTimer("dockStateHandler", 300)


createTaskObject(taskRef, targetArray)
{
    if (A_LoopField is "digit")
    {
        fullPath := WinGetProcessPath("ahk_id " A_LoopField)
        SplitPath fullPath , OutFileName, OutDir, OutExtension, OutNameNoExt

        targetArray[A_Index,"id"] := A_LoopField
        targetArray[A_Index,"classname"] := WinGetClass("ahk_id " A_LoopField)
        targetArray[A_Index,"title"] := WinGetTitle("ahk_id " A_LoopField)

        if(OutNameNoExt = "ApplicationFrameHost")
        {
            TitleArray := StrSplit(targetArray[A_Index,"title"], "- ") 
            Initials := TitleArray[TitleArray.length()]
            OutNameNoExt := Initials
            Loop Parse, Initials, A_Space
            {
                x := x SubStr(A_LoopField, "1", "1")
                x := StrUpper(x)
                Initials := x
            }
            Initials := StrReplace(Initials, "[", "")
            targetArray[A_Index,"initials"] := Initials
        }
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
    Global ActiveIndicator
    Global dirRaindock
    ActiveIndicatorCheck := false
    arrayTasksCheck := {}


    csvTaskList := csvPinnedItems
    ActiveHwnd := WinExist("A",,RainmeterMeterWindow)
    
    
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
            ActiveIndicatorCheck := TaskId
        }
    }
    
    if(ActiveIndicatorCheck != ActiveIndicator)
    { 
        ActiveIndicator := ActiveIndicatorCheck
        if(ActiveIndicatorCheck)
        { 
            SendRainmeterCommand("!SetOption TaskIndicator X `"[Task" . ActiveIndicatorCheck . ":X] `" ")
            SendRainmeterCommand("!SetOption TaskIndicator Y `"[Task" . ActiveIndicatorCheck . ":Y] `" ")
            SendRainmeterCommand("!ShowMeter TaskIndicator ")
        }
        else
        { 
            SendRainmeterCommand("!HideMeter TaskIndicator ")
        }
    }

    if(arrayTasks.length() != arrayTasksCheck.length())
    {
        if(arrayTasks.length() > arrayTasksCheck.length())
        {
            Loop (arrayTasks.length() - arrayTasksCheck.length())
            {
                SendRainmeterCommand("!SetOption Task" .  (A_Index + arrayTasksCheck.length()) . " ImageName `"`" ")
                SendRainmeterCommand("!HideMeter Task" .  (A_Index + arrayTasksCheck.length()) . " ")
            }
        }
        ShiftDock(arrayTasks.length(),arrayTasksCheck.length())
    }

    arrayTasks := arrayTasksCheck
}



