@echo off
setlocal

set "SCRIPT_DIR=%~dp0"

if "%~1"=="" (
    set /p "TARGET=Enter target project path: "
) else (
    set "TARGET=%~1"
)

if not exist "%TARGET%" (
    echo Error: Target directory "%TARGET%" does not exist.
    pause
    exit /b 1
)

set "SKILL_SRC=%SCRIPT_DIR%.agents\skills\peer-exchange\SKILL.md"

REM Update the project skill if it already exists (never touch PEER_EXCHANGE.md / tasks)
set "SKILL_DIR=%TARGET%\.agents\skills\peer-exchange"
set "SKILL_DST=%SKILL_DIR%\SKILL.md"
if not exist "%SKILL_DIR%" (
    xcopy /E /I /Y "%SCRIPT_DIR%.agents\skills\peer-exchange" "%SKILL_DIR%" >nul
    echo Created peer-exchange skill in target project.
) else (
    if exist "%SKILL_SRC%" (
        copy /Y "%SKILL_SRC%" "%SKILL_DST%" >nul
        echo Updated SKILL.md in target project.
    ) else (
        echo Warning: source SKILL.md not found; skipping.
    )
)

echo.
echo ========================================================
echo [DONE] Peer Exchange skill updated. PEER_EXCHANGE.md and existing tasks were NOT modified.
echo ========================================================
echo.
pause
