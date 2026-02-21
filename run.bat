@echo off
:: Diagnostic start
echo [DEBUG] run.bat started.
pause

echo ===============================================================
echo       ENDOMETRIUM CANCER DETECTION (ECD)
echo ===============================================================

:: 1. Detect Python
set PY_CMD=
python --version >nul 2>&1
if %errorlevel% equ 0 (
    set PY_CMD=python
) else (
    py --version >nul 2>&1
    if %errorlevel% equ 0 (
        set PY_CMD=py
    )
)

if "%PY_CMD%"=="" (
    echo [ERROR] Python not found.
    pause
    exit /b 1
)

echo [OK] Using Python command: %PY_CMD%

:: 2. Venv Health Check
if exist venv\ (
    echo [INFO] Checking venv health...
    venv\Scripts\python.exe --version >nul 2>&1
    if %errorlevel% neq 0 (
        echo [WARNING] venv is broken (probably copied from another PC).
        echo [INFO] Deleting broken venv...
        rmdir /s /q venv
    )
)

:: 3. Create Venv
if not exist venv\ (
    echo [INFO] Creating venv...
    %PY_CMD% -m venv venv
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to create venv.
        pause
        exit /b 1
    )
)

:: 4. Dependencies
echo [INFO] Checking dependencies...
venv\Scripts\python.exe -m pip install --upgrade pip >nul 2>&1
venv\Scripts\pip.exe install -r requirements.txt
if %errorlevel% neq 0 (
    echo [WARNING] Some dependencies failed. App might still run.
    pause
)

:: 5. Run
echo [INFO] Starting app.py...
if not exist app.py (
    echo [ERROR] app.py missing!
    pause
    exit /b 1
)

venv\Scripts\python.exe app.py
if %errorlevel% neq 0 (
    echo [ERROR] App crashed.
    pause
)

echo [INFO] Done.
pause
