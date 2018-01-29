renderIconTheme(iconFile,renderTo,pinnedTask := 0,string := ""){

    SendRainmeterCommand("[!SetOption magickmeter1 ExportTo `"" . renderTo . "`" raindock]")
    SendRainmeterCommand("[!SetOption magickmeter1 Image `"Rectangle 0,0,(#TaskWidth# + (#iconHorizontalPadding# * 2)),(#TaskWidth# + (#iconVerticalPadding# * 2) + 10)  | Color 255,255,255,1  `" raindock]")

    if(!string)
    {
        SendRainmeterCommand("[!SetOption magickmeter1 Image2 `"File " . iconFile . " | RenderSize #TaskWidth#,#TaskWidth# | move #iconHorizontalPadding#,#iconVerticalPadding#`" raindock]")
        SendRainmeterCommand("[!SetOption magickmeter1 Image3 `"Rectangle 0,0,(#TaskWidth# + (#iconHorizontalPadding# * 2)),(#TaskWidth# + (#iconVerticalPadding# * 2) + 10)  | Ignore 1 | Color 255,255,255,1  `" raindock]")
    }
    else
    {                           
        Global iconTheme
        SendRainmeterCommand("[!SetOption magickmeter1 Image2 `"Ellipse ((#TaskWidth# + (#iconHorizontalPadding# * 2)) / 2),((#TaskWidth# + (#iconVerticalPadding# * 2)) / 2),(#TaskWidth# / 2) | Color " . iconTheme["accentColor"] . "`" raindock]")
        SendRainmeterCommand("[!SetOption magickmeter1 Image3 `"Text " . string . " | Offset ((#TaskWidth# + (#iconHorizontalPadding# * 2)) / 2),((#TaskWidth# + (#iconVerticalPadding# * 2)) / 2)  | Color 255,255,255 | Face Segoe UI | Weight 700 | Align CenterCenter`" raindock]")
    }

    SendRainmeterCommand("[!SetOption magickmeter1 Image4 `"Rectangle #iconHorizontalPadding#,(#TaskWidth# + (#iconVerticalPadding# * 2) + 8),#TaskWidth#,2  | ignore " . pinnedTask . "| Color 200,200,200,170`" raindock]")
    SendRainmeterCommand("[!UpdateMeasure magickmeter1 raindock]") 
    Counter := 1
    
    While(!FileExist( renderTo ) && Counter < 200){
        Sleep 30
        Counter++
    }
}
