@echo off
setlocal enabledelayedexpansion

:: This script automates the setup and running of the Endometrium Cancer Detection system.

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
    echo [ERROR] Python was not found on your system.
    echo Please install Python 3.9+ from https://www.python.org/
    echo.
    echo If you just installed it, you may need to restart your computer.
    pause
    exit /b 1
)

:: Get Python version for info/warning
for /f "tokens=2" %%v in ('%PY_CMD% --version') do set "PY_VER=%%v"
echo [OK] Python detected: !PY_CMD! (Version !PY_VER!)

:: Warning for Python 3.11+
for /f "tokens=1,2 delims=." %%a in ("!PY_VER!") do (
    if %%a geq 3 if %%b geq 11 (
        echo.
        echo [WARNING] You are using Python !PY_VER!.
        echo TensorFlow 2.11 works best on Python 3.9 or 3.10.
        echo You might encounter errors during installation or runtime.
        echo.
    )
)

:: 2. Create Virtual Environment
set "NEW_VENV=0"
if not exist "venv\" (
    echo [INFO] Virtual environment not found. Creating 'venv' folder...
    !PY_CMD! -m venv venv
    if errorlevel 1 (
        echo [ERROR] Failed to create virtual environment.
        pause
        exit /b 1
    )
    echo [SUCCESS] Virtual environment created.
    set "NEW_VENV=1"
)

:: 3. Install Dependencies
if "!NEW_VENV!"=="1" (
    echo [INFO] Installing dependencies (this may take a minute)...
    venv\Scripts\python.exe -m pip install --upgrade pip >nul 2>&1
    venv\Scripts\pip.exe install -r requirements.txt
    if errorlevel 1 (
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
    echo [INFO] Virtual environment already exists. 
    set /p "UPDATE_DEP=Do you want to re-check/update dependencies? (y/n): "
    if /i "!UPDATE_DEP!"=="y" (
        venv\Scripts\python.exe -m pip install --upgrade pip >nul 2>&1
        venv\Scripts\pip.exe install -r requirements.txt
        if errorlevel 1 (
            echo [WARNING] Dependency update had some issues.
            pause
        ) else (
            echo [SUCCESS] All dependencies are ready.
        )
    )
)

:: 4. Launch Application
echo.
echo ===============================================================
echo       SYSTEM READY — Launching Application
echo ===============================================================
echo.
echo [INFO] The app will be available at: http://127.0.0.1:5000/
echo.
echo Press any key to start the server...
pause >nul

if not exist "app.py" (
    echo [ERROR] File 'app.py' not found in this folder.
    pause
    exit /b 1
)

venv\Scripts\python.exe app.py

if errorlevel 1 (
    echo.
    echo [ERROR] Application stopped or crashed unexpectedly.
    pause
)

echo.
echo [INFO] Script finished.
pause
