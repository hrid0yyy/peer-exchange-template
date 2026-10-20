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

echo Installing Peer Exchange to "%TARGET%"...

REM Shared agent-skill standard: picked up by OpenCode, Antigravity, and Claude Code
xcopy /E /I /Y "%SCRIPT_DIR%.agents" "%TARGET%\.agents" >nul

if exist "%TARGET%\PEER_EXCHANGE.md" (
    echo PEER_EXCHANGE.md already exists in target - keeping existing file.
) else (
    copy /Y "%SCRIPT_DIR%PEER_EXCHANGE.md" "%TARGET%\PEER_EXCHANGE.md" >nul
    echo Created PEER_EXCHANGE.md in target project.
)

echo.
echo ========================================================
echo [SUCCESS] Peer Exchange installed to "%TARGET%"!
echo Run the OpenCode / Antigravity ^<-> Claude loop in that project.
echo ========================================================
echo.
pause
