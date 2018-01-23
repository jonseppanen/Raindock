arrayMediaPlayer := []

arrayMediaPlayer["sourceCover"] := IniRead(iniFile, "Variables", "fileCoverArt")
arrayMediaPlayer["mediaPlayer"] := IniRead(iniFile, "Variables", "mediaPlayer")

if(arrayMediaPlayer["sourceCover"] = "default")
{
    arrayMediaPlayer["sourceCover"] :=  dirTemp . "\cover.bmp"
}

arrayMediaPlayer["active"] := False

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
    currentAlbum := FileGetTime(arrayMediaPlayer["sourceCover"], C)

    if(arrayMediaPlayer["lastAlbum"] != currentAlbum )
    {
        arrayMediaPlayer["lastAlbum"] := currentAlbum
        SendRainmeterCommand("[!SetOption magickmeter1 ExportTo `"" . arrayMediaPlayer["renderedCover"] . "`" raindock]")
        SendRainmeterCommand("[!SetOption magickmeter1 Image `"Rectangle 0,0,(#TaskWidth# + (#iconTaskXPadding# * 2)),(#TaskWidth# + (#iconTaskYPadding# * 2) + 10)  | Color 255,255,255,1  `" raindock]")
        SendRainmeterCommand("[!SetOption magickmeter1 Image2 `"File " . arrayMediaPlayer["sourceCover"] . " | RenderSize #TaskWidth#,(#TaskWidth#) | Move #iconTaskXPadding#,#iconTaskYPadding# | Perspective *,*,(#TaskWidth# - 10),15,(#TaskWidth# - 10),(#TaskWidth# - 20),*,*`" raindock]")
        SendRainmeterCommand("[!SetOption magickmeter1 Image3 `"File " . iconTheme["location"] . arrayMediaPlayer["mediaPlayer"] . ".png | RenderSize (#TaskWidth#/2),(#TaskWidth#/2) | move ((#TaskWidth#/2) + #iconTaskXPadding#) ,((#TaskWidth#/2) + #iconTaskYPadding#)`" raindock]")
        SendRainmeterCommand("[!SetOption magickmeter1 Image4 `"Rectangle #iconTaskXPadding#,(#TaskWidth# + (#iconTaskYPadding# * 2) + 8),#TaskWidth#,2  | ignore 0| Color 200,200,200,170`" raindock]")
        SendRainmeterCommand("[!UpdateMeasure magickmeter1 raindock]") 
    }
}