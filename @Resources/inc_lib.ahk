
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

OnMessage(16666, "taskSwitch")
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

SetTimerAndFire("getPinnedTaskbarIcons", 3000)
getPinnedTaskbarIcons()
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