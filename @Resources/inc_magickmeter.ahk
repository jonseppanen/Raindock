renderIconTheme(iconFile,renderTo,pinnedTask := 0,string := ""){

    Global dockConfig
    Global dockIndicatorRect

    SendRainmeterCommand("!SetOption magickmeter1 ExportTo `"" . renderTo . "`" ")
    SendRainmeterCommand("!SetOption magickmeter1 Image `"Rectangle 0,0,(#iconWidth# + (#iconHorizontalPadding# * 2)),(#iconHeight# + (#iconVerticalPadding# * 2) + 10)  | Color 255,255,255,1  `" ")

    if(!string)
    {
        SendRainmeterCommand("!SetOption magickmeter1 Image2 `"File " . iconFile . " | RenderSize #iconWidth#,#iconHeight# | move #iconHorizontalPadding#,#iconVerticalPadding#`" ")
        SendRainmeterCommand("!SetOption magickmeter1 Image3 `"Rectangle 0,0,(#iconWidth# + (#iconHorizontalPadding# * 2)),(#iconHeight# + (#iconVerticalPadding# * 2) + 10)  | Ignore 1 | Color 255,255,255,1  `" ")
    }
    else
    {                           
        Global iconTheme
        SendRainmeterCommand("!SetOption magickmeter1 Image2 `"Ellipse ((#iconWidth# + (#iconHorizontalPadding# * 2)) / 2),((#iconHeight# + (#iconVerticalPadding# * 2)) / 2),(#iconWidth# / 2) | Color " . iconTheme["accentColor"] . "`" ")
        SendRainmeterCommand("!SetOption magickmeter1 Image3 `"Text " . string . " | Offset ((#iconWidth# + (#iconHorizontalPadding# * 2)) / 2),((#iconHeight# + (#iconVerticalPadding# * 2)) / 2)  | Color 255,255,255 | Face Segoe UI | Weight 700 | Align CenterCenter`" ")
    }

    SendRainmeterCommand("!SetOption magickmeter1 Image4 `"Rectangle " . dockIndicatorRect[dockConfig["position"]] . "  | ignore " . pinnedTask . "| Color 200,200,200,170`" ")
    SendRainmeterCommand("!UpdateMeasure magickmeter1 ") 
    Counter := 1
    
    While(!FileExist( renderTo ) && Counter < 200){
        Sleep 30
        Counter++
    }
}
