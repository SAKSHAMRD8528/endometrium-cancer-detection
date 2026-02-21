@echo off
setlocal enabledelayedexpansion

:: This script automates the setup and running of the Endometrium Cancer Detection system.
:: It handles Python detection, virtual environment creation, and dependency installation.

echo ===============================================================
echo       ENDOMETRIUM CANCER DETECTION (ECD) — Auto Setup
echo ===============================================================
echo.

:: 1. Detect Python
set "PY_CMD="
python --version >nul 2>&1 && set "PY_CMD=python"
if not defined PY_CMD (
    py --version >nul 2>&1 && set "PY_CMD=py"
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

:: Get Python version
for /f "tokens=2" %%v in ('!PY_CMD! --version') do set "PY_VER=%%v"
echo [OK] Python detected: !PY_CMD! (Version !PY_VER!)

:: 2. Virtual Environment Health Check
if exist "venv\" (
    echo [INFO] Checking virtual environment health...
    venv\Scripts\python.exe --version >nul 2>&1
    if !errorlevel! neq 0 (
        echo.
        echo [WARNING] Your virtual environment (venv) appears to be BROKEN.
        echo This usually happens if the project was COPIED from another computer.
        echo Virtual environments are not portable and must be created locally.
        echo.
        set /p "FIX_VENV=Would you like to delete and RECREATE the venv? (y/n): "
        if /i "!FIX_VENV!"=="y" (
            echo [INFO] Deleting broken venv...
            rmdir /s /q venv
            echo [SUCCESS] Broken venv removed.
        ) else (
            echo [ERROR] Cannot proceed with a broken environment.
            pause
            exit /b 1
        )
    ) else (
        echo [OK] Virtual environment is healthy.
    )
)

:: 3. Create Virtual Environment if missing
set "NEW_VENV=0"
if not exist "venv\" (
    echo [INFO] Creating new virtual environment...
    !PY_CMD! -m venv venv
    if !errorlevel! neq 0 (
        echo [ERROR] Failed to create virtual environment.
        pause
        exit /b 1
    )
    echo [SUCCESS] Virtual environment created.
    set "NEW_VENV=1"
)

:: 4. Install Dependencies
if "!NEW_VENV!"=="1" (
    echo [INFO] Installing individual dependencies (this may take a minute)...
    venv\Scripts\python.exe -m pip install --upgrade pip >nul 2>&1
    venv\Scripts\pip.exe install -r requirements.txt
    if !errorlevel! neq 0 (
        echo.
        echo [WARNING] Some dependencies failed to install.
        set /p "PROCEED=Would you like to try running the application anyway? (y/n): "
        if /i "!PROCEED!" neq "y" (
            echo [INFO] Exiting...
            pause
            exit /b 1
        )
    ) else (
        echo [SUCCESS] All dependencies are ready.
    )
) else (
    set /p "UPDATE_DEP=Do you want to check for dependency updates? (y/n): "
    if /i "!UPDATE_DEP!"=="y" (
        echo [INFO] Updating dependencies...
        venv\Scripts\python.exe -m pip install --upgrade pip >nul 2>&1
        venv\Scripts\pip.exe install -r requirements.txt
        if !errorlevel! neq 0 (
            echo [WARNING] Dependency update had some issues.
            pause
        ) else (
            echo [SUCCESS] Dependencies updated.
        )
    )
)

:: 5. Final Summary and Launch
cls
echo ===============================================================
echo       ENDOMETRIUM CANCER DETECTION (ECD) — System Ready
echo ===============================================================
echo.
echo   [OK] Python Detected (!PY_CMD!)
echo   [OK] Virtual Environment Ready
echo   [OK] Dependencies Checked
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

echo.
echo [INFO] Session ended.
pause
