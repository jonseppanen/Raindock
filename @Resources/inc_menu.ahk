OnMessage(16667, "taskManage")
taskManage(wParam, lParam)
{
    Global arrayTasks
    Global selectedTask
    Global dirPinnedItems
    Global dirCustomIcons
    Global dirThemeTemp
    Global iniFile

    if(wParam = "minimize")
    {
        WinMinimize "ahk_id " arrayTasks[selectedTask]["id"]
    }
    else if(wParam = "open")
    {
        run arrayTasks[selectedTask]["fullpath"]
    }
    else if(wParam = "maximize")
    {
        WinMaximize "ahk_id " arrayTasks[selectedTask]["id"]
    }
    else if(wParam = "properties")
    {
        Run "properties " . arrayTasks[selectedTask]["fullpath"]
    }
    else if(wParam = "close")
    {
        WinClose "ahk_id " arrayTasks[selectedTask]["id"]
    }
    else if(wParam = "unpin from dock")
    {
        FileDelete dirPinnedItems . "\" . arrayTasks[selectedTask]["exe"] . ".lnk"
        getPinnedTaskbarIcons()
    }
    else if(wParam = "pin to dock")
    {
        FileCreateShortcut arrayTasks[selectedTask]["fullpath"],  dirPinnedItems . "\" . arrayTasks[selectedTask]["exe"] . ".lnk"
        getPinnedTaskbarIcons()
    }
    else if(wParam = "change icon")
    {   
        newIcon := FileSelect(,,, "Image Files (*.png)")
        if(newIcon)
        {
            newCustomIconFile := dirCustomIcons . "\" . arrayTasks[selectedTask]["exe"] . ".png"
            FileCopy newIcon, newCustomIconFile
            renderIconTheme(newCustomIconFile,dirThemeTemp . "\" . arrayTasks[selectedTask]["exe"] . ".bmp" ,0)
            renderIconTheme(newCustomIconFile,dirThemeTemp . "\" . arrayTasks[selectedTask]["exe"] . "_pin.bmp" ,1)
        }
    }
    else if(wParam = "reload icon")
    {   
        fileIcon := dirThemeTemp . "\" . arrayTasks[selectedTask]["exe"] . ".bmp"
        filePinIcon := dirThemeTemp . "\" . arrayTasks[selectedTask]["exe"] . "_pin.bmp"
        if(FileExist(fileIcon))
        {
            FileDelete fileIcon
        }
        if(FileExist(filePinIcon))
        {
            FileDelete filePinIcon
        }
        SendRainmeterCommand("!Refresh ")
    }
    else if(wParam = "restore original")
    {   
        fileIcon := dirThemeTemp . "\" . arrayTasks[selectedTask]["exe"] . ".bmp"
        filePinIcon := dirThemeTemp . "\" . arrayTasks[selectedTask]["exe"] . "_pin.bmp"
        customFileIcon := dirCustomIcons . "\" . arrayTasks[selectedTask]["exe"] . ".png"
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
        SendRainmeterCommand("!Refresh ")
    }
    else if(wParam = "refresh dock")
    {
        SendRainmeterCommand("!Refresh ")
    }
    else if(wParam = "Rainmeter Menu")
    {
        SendRainmeterCommand("!Skinmenu ")
    }
    else if(wParam = "Resize Icon Horizontal Width")
    {
        UserInput := InputBox("Please select a new Horizontal icon width", "Phone Number")
        if(UserInput)
        {
            IniWrite UserInput , iniFile, "Variables", "iconWidth"
            SendRainmeterCommand("!Refresh ")
        }
    }
    else if(wParam = "Resize Icon Vertical Width")
    {
        UserInput := InputBox("Please select a new Vertical icon width", "Phone Number")
        if(UserInput)
        {
            IniWrite UserInput , iniFile, "Variables", "iconHeight"
            SendRainmeterCommand("!Refresh ")
        }
    }
    else if(wParam = "Move dock to Top")
    {
        IniWrite "top" , iniFile, "Variables", "screenPosition"
        SendRainmeterCommand("!Refresh ")
    }
    else if(wParam = "Move dock to Left")
    {
        IniWrite "left" , iniFile, "Variables", "screenPosition"
        SendRainmeterCommand("!Refresh ")
    }
    else if(wParam = "Move dock to Right")
    {
        IniWrite "right" , iniFile, "Variables", "screenPosition"
        SendRainmeterCommand("!Refresh ")
    }
    else if(wParam = "Move dock to Bottom")
    {
        IniWrite "bottom" , iniFile, "Variables", "screenPosition"
        SendRainmeterCommand("!Refresh ")
    }
}

OnMessage(16665, "taskItemMenu")
taskItemMenu(wParam, lParam)
{
    Global arrayTasks
    Global dockConfig
    Global selectedTask := wParam
    Global csvPinnedItems
    Global dirPinnedItems

    menuTaskItem := MenuCreate()

    if (arrayTasks[selectedTask]["id"] is "digit") 
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

    if(InStr(csvPinnedItems, arrayTasks[selectedTask]["fullPath"]))
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
    if(dockConfig["position"] != "top")
    {
        subMenuDock.Add("Move dock to Top", "taskManage")
    }
    if(dockConfig["position"] != "bottom")
    {
        subMenuDock.Add("Move dock to Bottom", "taskManage")
    }
    if(dockConfig["position"] != "left")
    {
        subMenuDock.Add("Move dock to Left", "taskManage")
    }
    if(dockConfig["position"] != "right")
    {
        subMenuDock.Add("Move dock to Right", "taskManage")
    }
    subMenuDock.Add "Resize Icon Horizontal Width", "taskManage"
    subMenuDock.Add "Resize Icon Vertical Width", "taskManage"
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
    Global dirTemp
    FileDelete dirThemeTemp . "\*.bmp"
    if(FileExist(dirTemp . "\smallcover.bmp"))
    {
        FileDelete dirTemp . "\smallcover.bmp"
    }
    Sleep 1000
    SendRainmeterCommand("!Refresh ")
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
