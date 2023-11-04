# AutoHotKey Project Repository

Hello and welcome to my **AutoHotKey** project repository!

This repository contains a collection of my personal projects that I have created using the **AutoHotKey** scripting language. **AutoHotKey** is a powerful tool that allows you to automate repetitive tasks, remap keyboard keys, create macros, and much more.

Each project in this repository has its own folder and is well-documented with comments explaining how the code works. Feel free to browse through the projects and use them as inspiration for your own projects.

If you're looking for pre-compiled executables, you can check out the [releases page](https://github.com/lynnhanananer/AHK/releases/) to download them.

To contribue, you'll need to have **AutoHotKey v1.1** installed on your computer. You can download v1.1 for free from the [official AutoHotKey website](https://www.autohotkey.com/download/).

Please make sure you're using AutoHotkey v1.1 to avoid any compatibility issues with these projects.

If you have any questions, comments, or suggestions for improvement, please don't hesitate to open an issue or pull request. I'm always looking for ways to improve my code and make it more useful for others.

Thank you for visiting my repository, and happy scripting!

## Genshin Pickup Tool

### Turbo Pickup Mode
Press and hold the interact key (F) to quickly repeat the interact key to pick up nearby resources or skip through dialog.

### Turbo Pickup Toggle
Press the Ctrl key to enable and disable the turbo pickup toggle. This quickly repeats the interact key (F) and is great for picking up nearby resources without needing to physically press the interact key (F). You cannot enable the Turbo Pickup Toggle while the cursor is present and it will be automatically be disabled when a cursor is present to prevent getting trapped in dialog or other interactions.

### Intelligent Dialog Skip
Double press the interact key (F) during dialog to quickly skip through dialog using the left mouse button (LMB) and interact key. This will also select dialog options when your cursor is positioned over a dialog option. This feature will detect if your cursor is present to begin skipping dialog, and suspend pressing keys once the dialog ends/cursor is not present.
Dialog skipping can be cancelled by pressing the Turbo Pickup Toggle key (Ctrl).

### Re-mapping Hotkeys
Double click on the Genshin Pickup Tool item in the Windows application tray to change the default hotkeys and keybinds. These hotkeys and keybinds will be stored in a file called hotkeyconfig.ini.

### Restarting the Application
Press the F1 to restart the application. Mutli-threading is hard, sometimes the application can get into unusual states.
