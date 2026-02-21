@echo off
:: Ultra-Stable Diagnostic Version
:: Using GOTO instead of blocks to avoid parsing errors.

echo [DEBUG] run.bat has started.
pause

echo.
echo ===============================================================
echo       ENDOMETRIUM CANCER DETECTION (ECD)
echo ===============================================================
echo.

:: 1. Detect Python
echo [INFO] Checking for Python...
python --version >nul 2>&1
if %errorlevel% equ 0 goto :PYTHON_FOUND

py --version >nul 2>&1
if %errorlevel% equ 0 goto :PY_FOUND

echo [ERROR] Python not found on this computer.
echo Please install it from https://www.python.org/
pause
exit /b 1

:PYTHON_FOUND
set PY_CMD=python
goto :PYTHON_OK

:PY_FOUND
set PY_CMD=py
goto :PYTHON_OK

:PYTHON_OK
echo [OK] Using command: %PY_CMD%

:: 2. Venv Health Check
if not exist venv\ goto :CREATE_VENV
echo [INFO] Checking venv health...
venv\Scripts\python.exe --version >nul 2>&1
if %errorlevel% equ 0 goto :VENV_OK

echo [WARNING] venv is broken (copied from another PC).
echo [INFO] Deleting and recreating...
rmdir /s /q venv
if exist venv\ (
    echo [ERROR] Could not delete venv folder. Please delete it manually.
    pause
    exit /b 1
)

:CREATE_VENV
echo [INFO] Creating virtual environment...
%PY_CMD% -m venv venv
if %errorlevel% neq 0 (
    echo [ERROR] Failed to create venv.
    pause
    exit /b 1
)
echo [OK] Virtual environment created.

:VENV_OK
echo [OK] Virtual environment is ready.

:: 3. Dependencies
echo [INFO] Ready to install/check dependencies.
pause
venv\Scripts\python.exe -m pip install --upgrade pip >nul 2>&1
echo [INFO] Installing requirements.txt...
venv\Scripts\pip.exe install -r requirements.txt
if %errorlevel% neq 0 (
    echo [WARNING] Dependency installation had issues.
    echo Press any key to try running the app anyway...
    pause
)

:: 4. Run App
echo [INFO] Starting app.py...
if not exist app.py (
    echo [ERROR] app.py missing in this folder!
    pause
    exit /b 1
)

pause
venv\Scripts\python.exe app.py
if %errorlevel% neq 0 (
    echo [ERROR] App crashed or was stopped.
    pause
)

echo [INFO] Script finished.
pause
