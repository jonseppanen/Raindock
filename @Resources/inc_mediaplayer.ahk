arrayMediaPlayer := []
arrayMediaPlayer["mediaPlayer"] := IniRead(iniFile, "Variables", "mediaPlayer")
arrayMediaPlayer["sourceCover"] := IniRead(iniFile, "Variables", "fileCoverArt")
arrayMediaPlayer["active"] := False
mediaCheck := true
if(!arrayMediaPlayer["mediaPlayer"])
{
    IniWrite("spotify",iniFile, "Variables", "mediaPlayer")
    mediaCheck := false
}

if(!arrayMediaPlayer["sourceCover"])
{
    IniWrite("default",iniFile, "Variables", "fileCoverArt")
    mediaCheck := false
}

if(mediaCheck = false)
{
    SendRainmeterCommand("!Refresh ")
}


if(arrayMediaPlayer["sourceCover"] = "default")
{
    arrayMediaPlayer["sourceCover"] :=  dirTemp . "\cover.bmp"
}
if(FileExist(arrayMediaPlayer["sourceCover"]))
{
    arrayMediaPlayer["active"] := True
    arrayMediaPlayer["lastAlbum"] := ""
    arrayMediaPlayer["renderedCover"] := dirTemp . "\smallcover.bmp"
    SetTimerandFire("renderMediaPlayerIcon", 1000)
}

renderMediaPlayerIcon()
{
    Global arrayMediaPlayer
    Global iconTheme
    Global dockConfig
    Global dockIndicatorRect

    currentAlbum := FileGetTime(arrayMediaPlayer["sourceCover"], C)

    if(arrayMediaPlayer["lastAlbum"] != currentAlbum )
    {
        arrayMediaPlayer["lastAlbum"] := currentAlbum
        SendRainmeterCommand("!SetOption magickmeter1 ExportTo `"" . arrayMediaPlayer["renderedCover"] . "`" ")
        SendRainmeterCommand("!SetOption magickmeter1 Image `"Rectangle 0,0,(#iconWidth# + (#iconHorizontalPadding# * 2)),(#iconHeight# + (#iconVerticalPadding# * 2) + 10)  | Color 255,255,255,1  `" ")
        SendRainmeterCommand("!SetOption magickmeter1 Image2 `"File " . arrayMediaPlayer["sourceCover"] . " | RenderSize #iconWidth#,#iconHeight# | Move #iconHorizontalPadding#,#iconVerticalPadding# | Perspective *,*,(#iconWidth#),15,(#iconWidth#),(#iconHeight#),*,*`" ")
        SendRainmeterCommand("!SetOption magickmeter1 Image3 `"File " . iconTheme["location"] . "\" . arrayMediaPlayer["mediaPlayer"] . ".png | RenderSize (#iconWidth#/2),(#iconHeight#/2) | move ((#iconWidth#/2) + #iconHorizontalPadding#) ,((#iconHeight#/2) + #iconVerticalPadding#)`" ")
        SendRainmeterCommand("!SetOption magickmeter1 Image4 `"Rectangle " . dockIndicatorRect[dockConfig["position"]] . "  | ignore " . pinnedTask . "| Color 200,200,200,170`" ")
        SendRainmeterCommand("!UpdateMeasure magickmeter1 ") 
    }
}