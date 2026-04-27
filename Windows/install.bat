@echo off
title Social Downloader - Windows Installer
color 0B

echo.
echo ================================================================
echo     Social Downloader - Windows Installer
echo     Developed by Praveen Singh
echo ================================================================
echo.

set "SOURCE=%~dp0Resolve-Social-Downloader-Win.lua"
set "DEST=C:\ProgramData\Blackmagic Design\DaVinci Resolve\Fusion\Scripts\Utility"

:: Check if source file exists
if not exist "%SOURCE%" (
    echo [ERROR] Resolve-Social-Downloader-Win.lua not found!
    echo         Make sure install.bat is in the same folder as the .lua file
    echo.
    pause
    exit /b 1
)

:: Check if DaVinci Resolve folder exists
if not exist "C:\ProgramData\Blackmagic Design\DaVinci Resolve" (
    echo [ERROR] DaVinci Resolve not found!
    echo         Please install DaVinci Resolve first.
    echo.
    pause
    exit /b 1
)

:: Create destination folder if needed
if not exist "%DEST%" mkdir "%DEST%"

:: Copy script
copy /Y "%SOURCE%" "%DEST%\" >nul

if %errorlevel%==0 (
    echo [SUCCESS] Script installed successfully!
    echo.
    echo Installed to:
    echo    %DEST%
    echo.
    echo How to run:
    echo    1. Open DaVinci Resolve
    echo    2. Go to: Workspace ^> Scripts ^> Utility
    echo    3. Click: Resolve-Social-Downloader-Win
    echo.
) else (
    echo [ERROR] Installation failed!
    echo         Try running as Administrator.
    echo         Right-click install.bat ^> Run as administrator
    echo.
    pause
    exit /b 1
)

:: Check dependencies
echo Checking dependencies...
echo.

where yt-dlp >nul 2>nul
if %errorlevel%==0 (
    echo    [OK] yt-dlp: installed
) else (
    echo    [MISSING] yt-dlp: NOT FOUND
    echo              Install: winget install yt-dlp
    echo              Or: https://github.com/yt-dlp/yt-dlp/releases
)

where ffmpeg >nul 2>nul
if %errorlevel%==0 (
    echo    [OK] ffmpeg: installed
) else (
    echo    [MISSING] ffmpeg: NOT FOUND
    echo              Install: winget install ffmpeg
    echo              Or: https://ffmpeg.org/download.html
)

echo.

:: Ask to install dependencies
where yt-dlp >nul 2>nul
if %errorlevel% neq 0 goto :ask_install
where ffmpeg >nul 2>nul
if %errorlevel% neq 0 goto :ask_install
goto :done

:ask_install
echo.
set /p INSTALL="Do you want to install missing dependencies? (y/n): "
if /i "%INSTALL%"=="y" (
    echo.
    echo Installing yt-dlp...
    winget install yt-dlp --accept-package-agreements --accept-source-agreements 2>nul
    if %errorlevel% neq 0 (
        echo    Trying pip...
        pip install yt-dlp 2>nul
    )
    echo Installing ffmpeg...
    winget install ffmpeg --accept-package-agreements --accept-source-agreements 2>nul
    echo.
    echo Dependencies installation attempted.
    echo Please restart your terminal/command prompt.
)

:done
echo.
echo ================================================================
echo    Done! Open DaVinci Resolve and enjoy!
echo ================================================================
echo.
pause
