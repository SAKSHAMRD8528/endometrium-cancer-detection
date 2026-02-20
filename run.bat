@echo off
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

echo [OK] Python detected: %PY_CMD%

:: 2. Create Virtual Environment
if not exist "venv\" (
    echo [INFO] Virtual environment not found. Creating 'venv' folder...
    %PY_CMD% -m venv venv
    if errorlevel 1 (
        echo [ERROR] Failed to create virtual environment.
        pause
        exit /b 1
    )
    echo [SUCCESS] Virtual environment created.
)

:: 3. Install Dependencies
echo [INFO] Checking dependencies (this may take a minute)...
venv\Scripts\python.exe -m pip install --upgrade pip >nul 2>&1
venv\Scripts\pip.exe install -r requirements.txt
if errorlevel 1 (
    echo [ERROR] Failed to install dependencies.
    pause
    exit /b 1
)
echo [SUCCESS] All dependencies are ready.

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
