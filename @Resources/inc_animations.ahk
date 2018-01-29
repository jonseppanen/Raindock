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
        dockConfig["y"] := dockConfig["y"] + 1
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

MoveDock(MoveX)
{
    Global dockConfig
    oldPos := dockConfig["x"]

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
