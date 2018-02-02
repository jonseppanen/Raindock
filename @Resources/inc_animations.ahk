OnMessage(16671, "dockHide")
dockHide()
{
    Global dockConfig

    if(dockConfig["visible"] = false || dockConfig["minMax"] = 0)
    {
        return
    }
    dockConfig["visible"] := false

    matrix := {"bottom":[0,dockConfig["edge"]],"right":[0,dockConfig["edge"]],"top":[0,-dockConfig["edge"]],"left":[-dockConfig["edge"],0]}
    MoveDock(matrix[dockConfig["position"]][1],matrix[dockConfig["position"]][2])    
}

dockShow()
{
    Global dockConfig
    
    if(dockConfig["visible"] = true || dockConfig["minMax"] = 2)
    {
        return
    }
    dockConfig["visible"] := true

    matrix := {"bottom":[0,-dockConfig["edge"]],"right":[0,-dockConfig["edge"]],"top":[0,dockConfig["edge"]],"left":[dockConfig["edge"],0]}
    MoveDock(matrix[dockConfig["position"]][1],matrix[dockConfig["position"]][2])  
}


ShiftDock(oldTaskN, newTaskN)
{
    Global dockConfig

    if(dockConfig["position"] = "bottom" || dockConfig["position"] = "top")
    {
        MoveDock((((oldTaskN - newTaskN) * dockConfig["axis"]) / 2),0)
    }    
    else
    {
        MoveDock(0,(((oldTaskN - newTaskN) * dockConfig["axis"]) / 2))
    }

}

MoveDock(moveX, moveY)
{
    Global dockConfig
    while(dockConfig["animating"] = true)
    {
        sleep 13
    }
    dockConfig["animating"] = true 
    dockConfig["x"] := dockConfig["x"] + moveX
    dockConfig["y"] := dockConfig["y"] + moveY

    SendRainmeterCommand("!SetOption MeasureAnimator AnimatorFinish `"[!Move " . (dockConfig["x"]) . " " . (dockConfig["y"]) . "][!UpdateMeasure MeasureAnimator]`" ")
    SendRainmeterCommand("!SetOption MeasureAnimator animatorMove `"`"`"[!Move `"(#CURRENTCONFIGX# + " . (moveX / 10) . ")`" `"(#CURRENTCONFIGY# + " . (moveY / 10) . ")`"][!UpdateMeasure MeasureAnimator]`"`"`" ")
    SendRainmeterCommand("!SetOption MeasureAnimator ActionList1 `"Repeat animatorMove,10,10 | Wait 10 | animatorFinish `" ")
    SendRainmeterCommand("!UpdateMeasure MeasureAnimator ")
    SendRainmeterCommand("!CommandMeasure MeasureAnimator `"Execute 1`" ")
    sleep 110
    dockConfig["animating"] = false 
}

dockStateHandler()
{
    Global dockConfig
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
        else if((dockConfig["position"] = "bottom" && ypos < (A_ScreenHeight - dockConfig["edge"])) || (dockConfig["position"] = "right" && xpos < (A_ScreenWidth - dockConfig["edge"])) || (dockConfig["position"] = "left" && xpos >  dockConfig["edge"]) || (dockConfig["position"] = "top" && ypos > dockConfig["edge"]) )
        {
            dockHide()
        } 
    }
}


