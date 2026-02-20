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
    echo [ERROR] Python is not installed or not in PATH.
    echo Please install Python 3.9+ from python.org and try again.
    pause
    exit /b 1
)

echo [INFO] Using command: %PY_CMD%

:: 2. Create Virtual Environment if it doesn't exist
if not exist "venv" (
    echo [INFO] Creating virtual environment...
    %PY_CMD% -m venv venv
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to create virtual environment.
        pause
        exit /b 1
    )
    echo [SUCCESS] Virtual environment created.
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
echo [INFO] Checking/Installing dependencies...
venv\Scripts\python.exe -m pip install --upgrade pip
venv\Scripts\pip.exe install -r requirements.txt
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install dependencies.
    pause
    exit /b 1
)
echo [SUCCESS] Dependencies are ready.

:: 5. Run the application
echo [INFO] Starting Endometrium Cancer Detection system...
echo [INFO] The app will be available at: http://127.0.0.1:5000/
echo.
venv\Scripts\python.exe app.py

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Application crashed or stopped unexpectedly.
    pause
)

deactivate
pause
