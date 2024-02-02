# ChromeCast (Cast.ahk)

## 1. How to Compile and Install

To compile and run the Cast.ahk script, you will need to install AutoHotkey, a scripting language for Windows that allows the automation of the Windows GUI and general scripting. 

### Steps:
1. **Install AutoHotkey**: You can download it from the official website (https://autohotkey.com/). Just choose the latest version and follow the installation process.
   
2. **Compile the Script**: After installing AutoHotkey, locate the `Cast.ahk` and `start_cast.ahk` files. Right-click on each of them and select "Compile Script" (provided by the AutoHotkey installation). This will generate `Cast.exe` and `start_cast.exe` respectively.

3. **Run the Compiled Executables**: You can run `Cast.exe` and `start_cast.exe` directly by double-clicking on them. They will execute the logic defined in the scripts.

4. **Set Up to Run at Startup (Optional)**: If you want the script to run automatically when you start your computer, add a shortcut to the compiled `start_cast.exe` executable to your Startup folder.

## 2. The Folder Structure

The following represents the directory structure as outlined in tree.md, showing where each file and script is located within the project folder:

```
Project Folder
├── Cast.ahk             # Main script to cast devices
├── Cast.example.ini     # Example settings file for the user to customize
├── Cast.exe             # Compiled version of the Cast.ahk script
├── Cast.ico             # Icon file used for the compiled executable
├── Cast.ini             # Configuration settings for Cast.ahk
├── Chrome.ahk           # Supporting script with Chrome related operations
├── LICENSE              # License file for the script
├── bluetooth.bat        # Batch script interfacing with Bluetooth
├── bluetooth.ps1        # PowerShell script to toggle Bluetooth status
├── bt.ahk               # AutoHotkey Bluetooth utility script
├── cast-chrome.bat      # Batch script to cast using Chrome
├── compile_Cast.bat     # Batch script to compile Cast.ahk
├── start_cast.ahk       # Script to start the casting process
└── start_cast.exe       # Compiled version of start_cast.ahk
```

The main script files `Cast.ahk` and `start_cast.ahk` are found in the root of the project directory along with their respective compiled executables. Configuration files like `Cast.ini` and `Cast.example.ini` are used to customize the behavior of the script. Utility scripts and additional resources such as icons and licensing information are also included in the root of the project directory.

There are no subdirectories within the project folder, keeping the structure flat and easy to navigate.

The main script files `Cast.ahk` and `start_cast.ahk` are found in the root of the project directory along with their respective compiled executables. Configuration files like `Cast.ini` and `Cast.example.ini` are used to customize the behavior of the script. Utility scripts and additional resources such as icons and licensing information are also included in the root of the project directory.

There are no subdirectories within the project folder, keeping the structure flat and easy to navigate.
## 3. How to Use

### Starting the Cast Session
To start casting to your Chromecast device or compatible service, run the `Cast.exe`. This main executable utilizes your `Cast.ini` configuration file to understand which device to cast to and other preferences. It will automatically handle the process of casting the desktop to the specified device.

### Using the Cast.ahk Script
If you are running the script directly from `Cast.ahk` instead of the compiled `Cast.exe`, you will need to right-click on `Cast.ahk` and select "Run Script" after installing AutoHotkey.

### Using the Start Cast Script
The `start_cast.ahk` helps in initiating the process and ensuring that any previous instances of the casting has been stopped before starting a new one. Run the `start_cast.exe` or right-click on `start_cast.ahk` and select "Run Script" to initiate the process.

### Exiting the Cast Session
To end the casting session, you can either exit the script from the system tray by right-clicking the AutoHotkey icon and selecting "Exit" or using the provided hotkey `Ctrl + Esc`.

## 4. Customizing and Hotkeys

### Customization by Editing Cast.ini
To customize options like the cast device name, Chrome data directory, and device API key, you can modify the `Cast.ini` settings file located in the project directory. 

Key settings include:
- `castName`: The name of the casting device, such as your Chromecast device name.
- `ChromeDataDirectory`: The directory where Chrome's user data is stored.
- `deviceName`: The name of the Bluetooth device you wish to control with the script.

### Using Hotkeys
The script comes with the following predefined hotkeys:
- `^Esc` (Ctrl + Esc): Exits the application.
- `&Mostrar Chrome` (Show Chrome): Restores the hidden Chrome window so you can see what is being cast.
- `&Ocultar Chrome` (Hide Chrome): Hides Chrome again while casting.

You can customize these hotkeys by modifying the `Cast.ahk` script. Search for the relevant hotkey definitions within the script (such as `^Esc::`) and change them according to your preference.

Always remember to save your changes and re-run the script for the changes to take effect.
