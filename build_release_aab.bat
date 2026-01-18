@echo off
echo Building Release AAB for Play Store...
echo.

echo Cleaning project...
flutter clean
echo.

echo Getting dependencies...
flutter pub get
echo.

echo Building release AAB (Android App Bundle)...
flutter build appbundle --release

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo Release AAB built successfully!
    echo ========================================
    echo.
    echo AAB Location:
    echo build\app\outputs\bundle\release\app-release.aab
    echo.
    echo Package Name: com.loansathi.app
    echo Version: 1.0.2 (Version Code: 3)
    echo.
    echo Ready for Play Store upload!
    echo ========================================
    echo.
) else (
    echo.
    echo ========================================
    echo Build failed! Please check the errors above.
    echo ========================================
    echo.
)

pause
