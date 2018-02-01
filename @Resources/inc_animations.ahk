OnMessage(16671, "dockHide")
dockHide()
{
    Global dockConfig
    Global iconTheme
    Global dirRaindock

    if(dockConfig["visible"] = false || dockConfig["minMax"] = 0)
    {
        return
    }
    dockConfig["visible"] := false

    if(dockConfig["position"] = "bottom" || dockConfig["position"] = "right" )
    {
        dockEdge := dockConfig["edge"]
        
    }   
    else
    {
        dockEdge := (-dockConfig["edge"])
    }

    if(dockConfig["position"] = "bottom" || dockConfig["position"] = "top" )
    {
        MoveDock(0,dockEdge)
    }
    else
    {
        MoveDock(dockEdge,0)
    }   
    
}

dockShow()
{
    Global dockConfig
    Global dirRaindock
    Global iconTheme
    
    if(dockConfig["visible"] = true || dockConfig["minMax"] = 2)
    {
        return
    }
    dockConfig["visible"] := true

    if(dockConfig["position"] = "bottom" || dockConfig["position"] = "right" )
    {
        dockEdge := (-dockConfig["edge"])
    }   
    else
    {
        dockEdge := dockConfig["edge"]
    }

    if(dockConfig["position"] = "bottom" || dockConfig["position"] = "top" )
    {
        MoveDock(0,dockEdge)
    }
    else
    {
        MoveDock(dockEdge,0)
    }    
}


ShiftDock(oldTaskN, newTaskN)
{
    Global dockConfig
    Global iconTheme

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
    Global iconTheme
    Global dirRaindock
    dockConfig["x"] := dockConfig["x"] + moveX
    dockConfig["y"] := dockConfig["y"] + moveY

    SendRainmeterCommand("[!SetOption MeasureAnimator AnimatorFinish `"[!Move " . (dockConfig["x"]) . " " . (dockConfig["y"]) . "][!UpdateMeasure MeasureAnimator]`" " . dirRaindock . "]")
    SendRainmeterCommand("[!SetOption MeasureAnimator animatorMove `"`"`"[!Move `"(#CURRENTCONFIGX# + " . (moveX / 10) . ")`" `"(#CURRENTCONFIGY# + " . (moveY / 10) . ")`"][!UpdateMeasure MeasureAnimator]`"`"`" " . dirRaindock . "]")
    SendRainmeterCommand("[!SetOption MeasureAnimator ActionList1 `"Repeat animatorMove,10,10 | Wait 10 | animatorFinish `" " . dirRaindock . "]")
    SendRainmeterCommand("[!UpdateMeasure MeasureAnimator " . dirRaindock . "]")
    SendRainmeterCommand("[!CommandMeasure MeasureAnimator `"Execute 1`" " . dirRaindock . "]")
    sleep 110
    dockConfig["animating"] = false 
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
        else if((dockConfig["position"] = "bottom" && ypos < (A_ScreenHeight - dockConfig["edge"])) || (dockConfig["position"] = "right" && xpos < (A_ScreenWidth - dockConfig["edge"])) || (dockConfig["position"] = "left" && xpos >  dockConfig["edge"]) || (dockConfig["position"] = "top" && ypos > dockConfig["edge"]) )
        {
            dockHide()
        } 
    }
}


