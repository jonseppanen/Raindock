# Raindock

Raindock is an **interactive, real** dock/taskbar for rainmeter that uses nearly no system resources.

It is **super fast** and **super light**.

It uses **autohotkey v2** as the logical backend and task scraper, and **rainmeter** as the GUI frontend.

## Requirements

* If you don't have imagemagick installed, it will automatically download when you load the dock. Run the installer and **Quit and restart rainmeter**
* I advise using my other theme [WWing](https://github.com/jonseppanen/wwing) with this theme, as it goes nicely together.

## Features

### Place dock on any side of the screen

Added in version 0.2.0

### Change autohide settings between smart, never, and always

This allows for your dock to always hide, never hide, or only hide when you are working with a maximized app. 
Docks will always hide for a fullscreen app.

### Custom config per user

Any changes you make will be saved to your profile dir in an ini file for later use, so updating the theme wont lose any changes.

### Custom Icon themes

You can use essentially any icon theme you want with raindock. Right click the dock and select "change icon theme" - this will open a 
file chooser for you to select a folder with image files.

The dock will automatically select icons that have matching names to the exe files in the dock. E.g. Microsoft Edge.exe will use Microsoft Edge.png.
You may need to rename a few image files if they dont match.

If you make any changes to an icon theme, right click the dock and select "Reload Icons".

You can also **individually change icons** by right clicking the icon itself.

Note: Only PNG is supported for now.

### Pinned Tasks

Might not seem like a big deal, but your pinned taskbar items will be loaded in and work as normal. This took... much code.

### Automatic Icon Generation

If you don't have a matching image file, the largest ico file for the exe will be loaded. If it is a metro app, the initials of the app will load. Because there is no standard for their icons.

## Coming Soon...

* More customization
* Custom shape for autogenerated icon
