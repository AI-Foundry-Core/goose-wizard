@echo off
REM ============================================================
REM  RILGoose Installer - Windows
REM  Double-click this file to install and configure Goose.
REM ============================================================
REM
REM This wrapper invokes setup-goose.ps1 with the correct
REM execution policy so it can run by double-click. The .ps1
REM does the real work: installs prerequisites if missing,
REM configures Goose, patches the ACP adapter, and seeds state.
REM ============================================================

setlocal

REM Move to the directory where this .bat lives
cd /d "%~dp0"

REM Warn the user before starting so they can cancel if they
REM double-clicked by accident.
echo.
echo ========================================================
echo   RILGoose Installer
echo ========================================================
echo.
echo This installer will:
echo   - Install Git for Windows if missing (via winget; Claude Code needs Git Bash)
echo   - Install Node.js if missing (via winget; needed for the ACP adapter)
echo   - Install Goose CLI + desktop app if missing (from block/goose releases)
echo   - Install Claude CLI if missing (via Anthropic native installer, npm fallback)
echo   - Install the Claude ACP adapter if missing (via npm)
echo   - Point Claude Code at Git Bash (CLAUDE_CODE_GIT_BASH_PATH setting)
echo   - Run 'claude doctor' to verify the install
echo   - Configure Goose for RILGoose training recipes
echo   - Patch the ACP adapter for clean recipe execution
echo.
echo You will be prompted to log in to Claude (browser opens)
echo during setup. A Claude Max subscription is required.
echo.
echo Press Ctrl+C to cancel, or
pause

REM Run the engine with bypass so unsigned script can execute
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-goose.ps1" %*
set EXITCODE=%ERRORLEVEL%

echo.
if %EXITCODE% NEQ 0 (
    echo ========================================================
    echo   Installation reported errors ^(exit code %EXITCODE%^)
    echo ========================================================
    echo Scroll up to see what failed. If you need help, share
    echo the full output above with the RILGoose team.
) else (
    echo ========================================================
    echo   Installation complete.
    echo ========================================================
    echo Open a NEW terminal in the RILGoose folder and run:
    echo    goose run --recipe 00-start-here --interactive
    echo.
    echo Training runs from the CLI. The desktop app is just for
    echo browsing recipe YAML files - do not run recipes from it.
)
echo.
pause
endlocal
exit /b %EXITCODE%
