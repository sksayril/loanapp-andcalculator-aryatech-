@echo off
echo Building Release APK...
echo.

flutter clean
echo.
echo Getting dependencies...
flutter pub get
echo.
echo Building release APK...
flutter build apk --release

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo Release APK built successfully!
    echo ========================================
    echo.
    echo APK Location:
    echo build\app\outputs\flutter-apk\app-release.apk
    echo.
) else (
    echo.
    echo ========================================
    echo Build failed! Please check the errors above.
    echo ========================================
    echo.
)

pause

