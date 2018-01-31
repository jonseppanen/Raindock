renderTooltip(currentTask,taskNumber)
{
     global dockConfig
     Global dirRaindock

     if(dockConfig["position"] = "bottom")
     {  
         labelPosition := "([#CURRENTSECTION#:X]+(#iconWidth#/2)+#iconHorizontalPadding#) ((#iconHeight#+(#iconVerticalPadding#*2))*1.5)"
     }
     else if(dockConfig["position"] = "top")
     {
         labelPosition := "([#CURRENTSECTION#:X]+(#iconWidth#/2)+#iconHorizontalPadding#) ((#iconHeight#+(#iconVerticalPadding#*2))*3.5)"
     }
     else if(dockConfig["position"] = "left")
     {
         labelPosition := "((#iconWidth#+(#iconHorizontalPadding#*2))*1.25) ([#CURRENTSECTION#:Y]+(#iconHeight#/2)+#iconVerticalPadding#)"
     }
     else
     {
         labelPosition := "((#iconWidth#+(#iconHorizontalPadding#*2))*3.75) ([#CURRENTSECTION#:Y]+(#iconHeight#/2)+#iconVerticalPadding#)"
     }
     
     SendRainmeterCommand("[!SetOption Task" . taskNumber . " MouseOverAction `"`"`"[!ShowMeterGroup groupIconLabel " . dirRaindock . "][!SetOption iconTitle Text `"    " . currentTask["title"] . "`" " . dirRaindock . "][!SetOption iconExe Text `"" . currentTask["exe"] . "`" " . dirRaindock . "][!MoveMeter " . labelPosition . " iconTitle][!UpdateMeter iconExe " . dirRaindock . "][!UpdateMeter iconTitle " . dirRaindock . "]`"`"`" " . dirRaindock . "]")
}

renderMeter(currentTask,taskNumber)
{
    Global arrayMediaPlayer
    Global dirThemeTemp
    Global iconTheme            
    Global dirCustomIcons
    Global dockConfig
    Global dirRaindock

    pinnedTask := 0
    pinnedExt := ""

    if (currentTask["id"] is "digit") 
    {
        SendRainmeterCommand("[!SetOption Task" . taskNumber . " LeftMouseDownAction `"`"`"[!CommandMeasure MeasureWindowMessage `"SendMessage 16666 " . currentTask["id"] . " 0`"]`"`"`" " . dirRaindock . "]")
        SendRainmeterCommand("[!SetOption Task" . taskNumber . " MiddleMouseDownAction `"`"`"[explorer " . currentTask["fullPath"] . "]`"`"`" " . dirRaindock . "]")
    }
    else
    {
        pinnedTask := 1
        pinnedExt := "_pin"
        SendRainmeterCommand("[!SetOption Task" . taskNumber . " LeftMouseDownAction `"`"`"[explorer " . currentTask["fullPath"] . "]`"`"`" " . dirRaindock . "]")
        SendRainmeterCommand("[!SetOption Task" . taskNumber . " MiddleMouseDownAction `"`"`"[explorer " . currentTask["fullPath"] . "]`"`"`" " . dirRaindock . "]")
    }

    renderedIcon := dirThemeTemp . "\" . currentTask["exe"] . "_" . dockConfig["position"] .  pinnedExt . ".bmp"

    SendRainmeterCommand("[!SetOption Task" . taskNumber . " RightMouseUpAction `"`"`"[!CommandMeasure MeasureWindowMessage `"SendMessage 16665 " . taskNumber . " 0`"]`"`"`" " . dirRaindock . "]")
    SendRainmeterCommand("[!ShowMeter Task" . taskNumber . " " . dirRaindock . "]")

    if(currentTask["exe"] = arrayMediaPlayer["mediaPlayer"] && arrayMediaPlayer["active"] && currentTask["title"] != arrayMediaPlayer["mediaPlayer"])
    {
        renderedIcon := arrayMediaPlayer["renderedCover"] 
    }
    else if(!FileExist(renderedIcon))
    { 
        if(FileExist(dirCustomIcons . "\" . currentTask["exe"] . ".png"))
        {    
            renderIconTheme(dirCustomIcons . "\" . currentTask["exe"] . ".png",renderedIcon,pinnedTask)    
            
        }
        else if(FileExist(iconTheme["location"] . "\" . currentTask["exe"] . ".png"))
        {    
            
            renderIconTheme(iconTheme["location"] . "\" . currentTask["exe"] . ".png",renderedIcon,pinnedTask)          
        }
        else
        {
            iconExtracted :=  dirThemeTemp . "\" . currentTask["exe"] . ".ico"
            extractExe := currentTask["path"]
            Initials := currentTask["exe"]
            Loop Parse, Initials, A_Space
            {
                x := x SubStr(A_LoopField, "1", "1")
                x := StrUpper(x)
                Initials := x
            }
            Initials := StrReplace(Initials, "[", "")

            if(currentTask["classname"] = "ApplicationFrameWindow")
            {
                renderIconTheme("255,255,255,255",renderedIcon,pinnedTask,Initials)
            }
            else{
                Counter := 1
                SendRainmeterCommand("[!EnableMeasure MeasureIconExe " . dirRaindock . "]")
                SendRainmeterCommand("[!SetOption MeasureIconExe IconPath `"" .  iconExtracted   . "`" " . dirRaindock . "]")
                SendRainmeterCommand("[!SetOption MeasureIconExe Path `"" . extractExe .  "`" " . dirRaindock . "]")
                SendRainmeterCommand("[!SetOption MeasureIconExe WildcardSearch `"" . currentTask["exe"] .  "." . currentTask["ext"] . "`" " . dirRaindock . "]")
                SendRainmeterCommand("[!UpdateMeasure MeasureIconExe " . dirRaindock . "]")
                SendRainmeterCommand("[!CommandMeasure MeasureIconExe `"Update`" " . dirRaindock . "]")
                While(!FileExist( iconExtracted ) && Counter < 200){
                    Sleep 30
                    Counter++
                }

                if(Counter > 199){
                    renderIconTheme("255,255,255,255",renderedIcon,pinnedTask,Initials)
                }
                else{
                    renderIconTheme(iconExtracted,renderedIcon,pinnedTask)
                }
            }
        }
    }
    SendRainmeterCommand("[!SetOption Task" . taskNumber . " ImageName `"" . renderedIcon . "`" " . dirRaindock . "]")
    SendRainmeterCommand("[!UpdateMeter Task" . taskNumber . " " . dirRaindock . "]")
}
