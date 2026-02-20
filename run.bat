@echo off
setlocal enabledelayedexpansion

echo ===============================================================
echo       ENDOMETRIUM CANCER DETECTION (ECD) — Auto Setup
echo ===============================================================

:: 1. Detect Python command
set PY_CMD=
python --version >nul 2>&1 && set PY_CMD=python
if not defined PY_CMD (
    py --version >nul 2>&1 && set PY_CMD=py
)

if not defined PY_CMD (
    echo [WARNING] Python was not found on your system.
    set /p "INSTALL_PY=Would you like to install Python 3.10 automatically? (y/n): "
    if /i "!INSTALL_PY!" neq "y" (
        echo [INFO] Skipping installation. Please install Python manually.
        pause
        exit /b 1
    )
    
    echo [INFO] Checking for winget...
    winget --version >nul 2>&1
    if %errorlevel% neq 0 (
        echo [ERROR] winget is not available on this system. 
        echo Please install Python manually from: https://www.python.org/downloads/
        pause
        exit /b 1
    )
    
    echo [INFO] Installing Python 3.10 (this may take a few minutes)...
    winget install --id Python.Python.3.10 --exact --silent --accept-package-agreements --accept-source-agreements
    
    if %errorlevel% neq 0 (
        echo [ERROR] Automatic installation failed.
        pause
        exit /b 1
    )
    
    echo [SUCCESS] Python installation is complete!
    echo [IMPORTANT] YOU MUST CLOSE THIS WINDOW AND OPEN run.bat AGAIN 
    echo             to refresh the system environment variables.
    pause
    exit /b 0
)

echo [INFO] Using command: %PY_CMD%

:: 2. Create Virtual Environment if it doesn't exist
if not exist "venv" (
    echo [INFO] Virtual environment not found. Creating...
    %PY_CMD% -m venv venv
    if %errorlevel% neq 0 (
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
call venv\Scripts\activate
if %errorlevel% neq 0 (
    echo [ERROR] Failed to activate virtual environment.
    pause
    exit /b 1
)

:: 4. Install/Update dependencies
echo [INFO] Checking dependencies (this may take a moment)...
venv\Scripts\python.exe -m pip install --upgrade pip >nul 2>&1
venv\Scripts\pip.exe install -r requirements.txt
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install dependencies.
    pause
    exit /b 1
)
echo [SUCCESS] Dependencies are confirmed.

:: 5. Final Summary and Launch
cls
echo ===============================================================
echo       ENDOMETRIUM CANCER DETECTION (ECD) — System Ready
echo ===============================================================
echo.
echo   [OK] Python Detected (%PY_CMD%)
echo   [OK] Virtual Environment Ready
echo   [OK] Dependencies Installed
echo.
echo [INFO] Starting the application...
echo [INFO] Once started, go to: http://127.0.0.1:5000/
echo.
echo Press any key to launch the server...
pause >nul

venv\Scripts\python.exe app.py

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Application crashed or stopped unexpectedly (Code: %errorlevel%).
    pause
)

deactivate
echo.
echo [INFO] Session ended.
pause
