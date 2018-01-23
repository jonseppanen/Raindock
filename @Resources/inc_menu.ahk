OnMessage(16667, "taskManage")
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
        getPinnedTaskbarIcons()
    }
    else if(wParam = "pin to dock")
    {
        FileCreateShortcut TaskArray[selectedTask]["fullpath"],  dirPinnedItems . "\" . TaskArray[selectedTask]["exe"] . ".lnk"
        getPinnedTaskbarIcons()
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

OnMessage(16665, "taskItemMenu")
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
