
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

IsWindowCloaked(hwnd)
{
    static gwa := DllCall("GetProcAddress", "ptr", DllCall("LoadLibrary", "str", "dwmapi", "ptr"), "astr", "DwmGetWindowAttribute", "ptr")
    return (gwa && DllCall(gwa, "ptr", hwnd, "int", 14, "int*", cloaked, "int", 4) = 0) ? cloaked : 0
}

SendRainmeterCommand(command)
{
    Global dirRaindock
    
    commandWrap :=  "[" . command . " " . dirRaindock . "]"
    
    if(Send_WM_COPYDATA(commandWrap, "ahk_class RainmeterMeterWindow") = 1){
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


getArraysIdentical(firstArray,SecondArray)
{
    if(firstArray.length() != SecondArray.length())
    {
        return false
    }

    For arrKey in firstArray
    {
        if(firstArray[arrKey] is "object")
        {
            if(!getArraysIdentical(firstArray[arrKey],SecondArray[arrKey]))
            {
                return false
            }
        }
        else
        {
            if(firstArray[arrKey] != SecondArray[arrKey])
            {
                return false
            }
        }
    }    

    return true
}

getPinnedTaskbarIcons()
{
    Global dirPinnedItems
    Global csvPinnedItems
    csvPinnedItemsCheck := ""

    Loop Files, dirPinnedItems . "\*.lnk" ,F
    {
        FileGetShortcut A_LoopFilePath, OutTarget, OutDir
        if(!OutTarget)
        {
            continue
        }
        SplitPath OutTarget , OutFileName
        constructedPinTarget := OutTarget
        if(OutDir)
        {
            constructedPinTarget := OutDir . "\" . OutFileName
        }
        
        csvPinnedItemsCheck := csvPinnedItemsCheck . "{{{111" . OutFileName . "}}}" . constructedPinTarget . ","
    }

    if(csvPinnedItemsCheck != csvPinnedItems)
    {  
        csvPinnedItems := csvPinnedItemsCheck 
    }  
}

AutoSort(Arr) 
{
    t:=Object()
    for k, v in Arr
        t[RegExReplace(v,"\s")]:=v
    for k, v in t
        Arr[A_Index]:=v
    return Arr
}

getThisDirName()
{
    SplitPath A_ScriptDir , , ResourcesDir
    SplitPath ResourcesDir , OutFileName2
    return OutFileName2
}

checkIniFile()
{
    Global dirUser
    Global dirCustomIcons
    Global dirThemeTemp
    Global iniFile
    Global iconTheme
    Global dockConfig
    Global arrayMediaPlayer
    iniCheck := true
    
    if(!FileExist(dirUser))
    {
        DirCreate dirUser
        FileCopy(A_WorkingDir . "\default.ini", dirUser . "\raindock.ini",1)
        iniCheck := false
    }
    if(!FileExist(dirCustomIcons))
    {
        DirCreate dirCustomIcons
        iniCheck := false
    }
    if(!FileExist(dirThemeTemp))
    {
        DirCreate dirThemeTemp
        iniCheck := false
    }

    if(!iconTheme["location"])
    {
        IniWrite(A_WorkingDir . "\Loglyphs",iniFile, "Variables", "ThemePath")
        iniCheck := false
    }

    if(!iconTheme["w"])
    {
        IniWrite(64,iniFile, "Variables", "iconWidth")
        iniCheck := false
    }
    if(!iconTheme["h"])
    {
        IniWrite(64,iniFile, "Variables", "iconHeight")
        iniCheck := false
    }

    if(!iconTheme["paddingX"])
    {
        IniWrite(12,iniFile, "Variables", "iconHorizontalPadding")
        iniCheck := false
    }

    if(!iconTheme["paddingY"])
    {
        IniWrite(10,iniFile, "Variables", "iconVerticalPadding")
        iniCheck := false
    }

    if(!dockConfig["position"])
    {
        IniWrite("bottom",iniFile, "Variables", "screenPosition")
        iniCheck := false
    }

    if(iniCheck = false)
    {
        SendRainmeterCommand("!Refresh ")
    }

}
