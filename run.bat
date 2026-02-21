@echo off
:: Diagnostic startup
echo [DEBUG] Script is starting...
pause

echo ===============================================================
echo       ENDOMETRIUM CANCER DETECTION (ECD) — Auto Setup
echo ===============================================================

:: 1. Simple Python Check
echo [INFO] Checking for Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo [INFO] 'python' not found, trying 'py'...
    py --version >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Python not found. Please install it from python.org
        pause
        exit /b 1
    )
    set PY_CMD=py
) else (
    set PY_CMD=python
)

echo [OK] Python detected: %PY_CMD%
%PY_CMD% --version

:: 2. Virtual Environment
if not exist venv\ (
    echo [INFO] Creating virtual environment...
    %PY_CMD% -m venv venv
    if errorlevel 1 (
        echo [ERROR] Failed to create venv.
        pause
        exit /b 1
    )
)
echo [OK] Virtual environment is ready.

:: 3. Dependencies
echo [INFO] If you want to skip installation, press Ctrl+C, otherwise...
pause
echo [INFO] Installing/Updating dependencies...
venv\Scripts\python.exe -m pip install --upgrade pip
venv\Scripts\pip.exe install -r requirements.txt
if errorlevel 1 (
    echo [WARNING] Some dependencies failed. The app might still work.
    pause
)

:: 4. Run
echo [INFO] Launching app.py...
pause
if not exist app.py (
    echo [ERROR] app.py not found!
    pause
    exit /b 1
)

venv\Scripts\python.exe app.py
if errorlevel 1 (
    echo [ERROR] App crashed.
    pause
)

echo [INFO] Done.
pause
