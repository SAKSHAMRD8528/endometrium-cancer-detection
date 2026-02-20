@echo off
setlocal enabledelayedexpansion

echo ===============================================================
echo       ENDOMETRIUM CANCER DETECTION (ECD) — Auto Setup
echo ===============================================================
echo [DEBUG] Script started. Current Dir: %CD%

:: 1. Detect Python command
set "PY_CMD="

:: Try 'python'
python --version >nul 2>&1
if !errorlevel! equ 0 (
    set "PY_CMD=python"
) else (
    :: Try 'py'
    py --version >nul 2>&1
    if !errorlevel! equ 0 set "PY_CMD=py"
)

if not defined PY_CMD (
    echo [WARNING] Python was not found on your system.
    echo.
    set /p "INSTALL_PY=Would you like to install Python 3.10 automatically using winget? (y/n): "
    if /i "!INSTALL_PY!" neq "y" (
        echo [INFO] Skipping installation. Please install Python manually from python.org
        pause
        exit /b 1
    )
    
    echo [INFO] Checking for winget...
    where winget >nul 2>&1
    if !errorlevel! neq 0 (
        echo [ERROR] winget is not available on this system. 
        echo Please install Python manually from: https://www.python.org/downloads/
        pause
        exit /b 1
    )
    
    echo [INFO] Installing Python 3.10...
    winget install --id Python.Python.3.10 --exact --silent --accept-package-agreements --accept-source-agreements
    
    if !errorlevel! neq 0 (
        echo [ERROR] Automatic installation failed.
        pause
        exit /b 1
    )
    
    echo [SUCCESS] Python installation is complete!
    echo [IMPORTANT] PLEASE RESTART THIS SCRIPT to detect the new installation.
    pause
    exit /b 0
)

echo [INFO] Using command: !PY_CMD!

:: 2. Create Virtual Environment if it doesn't exist
if not exist "venv" (
    echo [INFO] Virtual environment not found. Creating...
    !PY_CMD! -m venv venv
    if !errorlevel! neq 0 (
        echo [ERROR] Failed to create virtual environment.
        pause
        exit /b 1
    )
    echo [SUCCESS] Virtual environment created.
) else (
    echo [INFO] Virtual environment already exists.
)

:: 3. Activate Virtual Environment
echo [INFO] Activating virtual environment...
if not exist "venv\Scripts\activate.bat" (
    echo [ERROR] Virtual environment seems broken (Scripts\activate.bat missing).
    echo [INFO] Try deleting the 'venv' folder and running this again.
    pause
    exit /b 1
)
call venv\Scripts\activate
if !errorlevel! neq 0 (
    echo [ERROR] Failed to activate virtual environment.
    pause
    exit /b 1
)

:: 4. Install/Update dependencies
echo [INFO] Checking dependencies (this may take a moment)...
venv\Scripts\python.exe -m pip install --upgrade pip >nul 2>&1
venv\Scripts\pip.exe install -r requirements.txt
if !errorlevel! neq 0 (
    echo [ERROR] Failed to install dependencies.
    pause
    exit /b 1
)
echo [SUCCESS] Dependencies confirmed.

:: 5. Final Summary and Launch
cls
echo ===============================================================
echo       ENDOMETRIUM CANCER DETECTION (ECD) — System Ready
echo ===============================================================
echo.
echo   [OK] Python Detected (!PY_CMD!)
echo   [OK] Virtual Environment Ready
echo   [OK] Dependencies Installed
echo.
echo [INFO] Starting the application...
echo [INFO] Once started, go to: http://127.0.0.1:5000/
echo.
echo Press any key to launch the server...
pause >nul

if not exist "app.py" (
    echo [ERROR] app.py not found in the current directory!
    pause
    exit /b 1
)

venv\Scripts\python.exe app.py

if !errorlevel! neq 0 (
    echo.
    echo [ERROR] Application crashed or stopped unexpectedly (Code: !errorlevel!).
    pause
)

:: No deactivate here to avoid errors if it wasn't set up
echo.
echo [INFO] Session ended.
pause
