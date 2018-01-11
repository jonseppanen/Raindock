# Raindock

Raindock is an **interactive, real** dock/taskbar for rainmeter that uses nearly no system resources.

It is **super fast** and **super light**.

It uses **autohotkey v2** as the logical backend and task scraper, and **rainmeter** as the GUI frontend.

## Requirements

* Autohotkey V2
* [MagickMeter](https://github.com/khanhas/MagickMeter) plugin by @khanhas. Make sure that is installed properly and restart rainmeter.

## Features

### Custom config per user

Any changes you make will be saved to your profile dir in an ini file for later use, so updating the theme wont lose any changes.

### Custom Icon themes

You can use essentially any icon theme you want with raindock. Right click the dock and select "change icon theme" - this will open a 
file chooser for you to select a folder with image files.

The dock will automatically select icons that have matching names to the exe files in the dock. E.g. Microsoft Edge.exe will use Microsoft Edge.png.
You may need to rename a few image files if they dont match.

If you make any changes to icons, right click the dock and select "Reload Icons".

Note: All image types are supported.

### Automatic Icon Generation

If you don't have a matching image file, the initials for the app and the colors for the app icon will be used to generate a placeholder icon.

### Smart Hide

Like Plank on linux, if you have a maximized app open, the dock will auto hide. If not, the dock will unhide.

## Coming Soon...

* More customization
* Custom sizing
* Custom shape for autogenerated icon
