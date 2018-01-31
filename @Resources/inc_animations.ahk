OnMessage(16671, "dockHide")
dockHide()
{
    Global dockConfig

    if(dockConfig["animating"] = true || dockConfig["visible"] = false || dockConfig["minMax"] = 0)
    {
        return
    }

    dockConfig["visible"] := false

    animateDock(dockConfig["edge"], dockConfig["dockAnimationMatrix"][dockConfig["position"]][1])
}

dockShow()
{
    Global dockConfig
    
    if(dockConfig["animating"] = true || dockConfig["visible"] = true || dockConfig["minMax"] = 2)
    {
        return
    }

    dockConfig["visible"] := true

    animateDock(dockConfig["edge"], dockConfig["dockAnimationMatrix"][dockConfig["position"]][2])
}

MoveDock(oldTaskN, newTaskN)
{
    Global dockConfig
    Global iconTheme
    directionArray := []

    if(dockConfig["position"] = "bottom" || dockConfig["position"] = "top")
    {
        directionArray := ["left","right"]
        iconAxis := iconTheme["wFull"]
    }    
    else
    {
        directionArray := ["up","down"]
        iconAxis := iconTheme["hFull"]
    }

    if(oldTaskN > newTaskN)
    {
        animationDirection := directionArray[2]
        animationDistance := (((oldTaskN - newTaskN) * iconAxis) / 2)
    }
    else
    {
        animationDirection := directionArray[1]
        animationDistance := (((newTaskN - oldTaskN) * iconAxis) / 2)
    }

    animateDock(animationDistance,animationDirection)

}

animateDock(animationDistance, animationDirection)
{
    Global dockConfig
    Global dirRaindock

    dockConfig["animating"] := true

    step := animationDistance / dockConfig["animationFrames"]

    Loop (dockConfig["animationFrames"])
    {
        if(animationDirection = "left")
        {
            dockConfig["x"] := dockConfig["x"] - step
        }
        else if(animationDirection = "right")
        {
            dockConfig["x"] := dockConfig["x"] + step
        }
        else if(animationDirection = "up")
        {
            dockConfig["y"] := dockConfig["y"] - step
        }
        else
        {
            dockConfig["y"] := dockConfig["y"] + step
        }
        SendRainmeterCommand("[!Move `" " . dockConfig["x"] . " `" `" " . dockConfig["y"] . " `" " . dirRaindock . "]")
    }

    dockConfig["animating"] := false
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
        if((dockConfig["position"] = "bottom" && ypos >= (A_ScreenHeight - 2)) || (dockConfig["position"] = "right" && xpos >= (A_ScreenWidth - 2)) || (dockConfig["position"] = "left" && xpos <= 2) || (dockConfig["position"] = "top" && ypos <= 2) )
        {
            dockShow()
        } 
    }
}


