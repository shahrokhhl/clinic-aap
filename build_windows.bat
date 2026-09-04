@echo off
echo ============================================================
echo   Building Clinic Accounting App (Windows exe)
echo ============================================================
echo.

where flutter >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Flutter was not found on this system.
    echo Please install Flutter first and make sure "flutter" is
    echo added to your PATH ^(see README-فارسی.md^).
    pause
    exit /b 1
)

echo [1/4] Getting packages...
call flutter pub get
if errorlevel 1 (
    echo [ERROR] "flutter pub get" failed. See the message above.
    pause
    exit /b 1
)

echo.
echo [2/4] Enabling Windows desktop support...
call flutter config --enable-windows-desktop >nul 2>nul

echo.
echo [3/4] Cleaning previous build folder if present...
if exist build\windows rmdir /s /q build\windows

echo.
echo [4/4] Building the release exe...
call flutter build windows --release
if errorlevel 1 (
    echo [ERROR] Building the exe failed. See the message above.
    echo Common cause: Visual Studio with the "Desktop development
    echo with C++" workload is not installed. Run "flutter doctor"
    echo to check.
    pause
    exit /b 1
)

echo.
echo ============================================================
echo   Done! Your app files are ready in:
echo   build\windows\x64\runner\Release\
echo.
echo   Give that whole folder to the clinic, OR (recommended)
echo   open installer.iss with Inno Setup and click Compile to
echo   get a single ClinicAccounting-Setup.exe file to hand out.
echo ============================================================
pause
