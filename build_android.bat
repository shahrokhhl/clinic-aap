@echo off
echo ============================================================
echo   Building Clinic Accounting App (Android APK)
echo ============================================================
echo.

where flutter >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Flutter was not found on this system.
    pause
    exit /b 1
)

echo [1/3] Getting packages...
call flutter pub get
if errorlevel 1 (
    echo [ERROR] "flutter pub get" failed. See the message above.
    pause
    exit /b 1
)

echo.
echo [2/3] Cleaning previous build folder if present...
if exist build\app\outputs\flutter-apk rmdir /s /q build\app\outputs\flutter-apk

echo.
echo [3/3] Building the release APK...
REM این یک APK ساده و امضاشده با کلید موقت (debug key) می‌سازد که برای
REM تست و نصب مستقیم روی گوشی کافی‌ست. برای انتشار در بازار اپلیکیشن
REM (مثل کافه‌بازار)، بعداً باید یک کلید امضای اختصاصی تنظیم کنید —
REM طبق راهنمای رسمی: flutter.dev/to/reference-keystore
call flutter build apk --release
if errorlevel 1 (
    echo [ERROR] Building the APK failed. See the message above.
    echo Common cause: Android SDK is not installed. Run
    echo "flutter doctor" to check.
    pause
    exit /b 1
)

echo.
echo ============================================================
echo   Done! Your installable APK file is ready at:
echo   build\app\outputs\flutter-apk\app-release.apk
echo.
echo   Send just this one file to whoever wants to install the
echo   app on their Android phone (they may need to allow
echo   "install from unknown sources" once).
echo ============================================================
pause
