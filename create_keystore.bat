@echo off
echo ========================================
echo Creating Android Keystore (JKS)
echo ========================================
echo.

REM Set your keystore details here
set KEYSTORE_NAME=upload-keystore.jks
set KEY_ALIAS=upload
set VALIDITY_YEARS=25

echo This script will create a new keystore file.
echo.
echo IMPORTANT: You will be prompted to enter:
echo   1. A password for the keystore (store password)
echo   2. The same password again to confirm
echo   3. A password for the key (key password) - can be same as keystore
echo   4. Your name and organization details
echo.
echo Press any key to continue or Ctrl+C to cancel...
pause >nul
echo.

REM Navigate to android directory
cd android

REM Generate the keystore
echo Generating keystore...
keytool -genkey -v -keystore %KEYSTORE_NAME% -alias %KEY_ALIAS% -keyalg RSA -keysize 2048 -validity %VALIDITY_YEARS%000

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo Keystore created successfully!
    echo ========================================
    echo.
    echo File location: android\%KEYSTORE_NAME%
    echo Key alias: %KEY_ALIAS%
    echo.
    echo IMPORTANT: 
    echo - Save your passwords securely!
    echo - Update android/key.properties with your new passwords
    echo - Never commit the keystore file to version control
    echo.
) else (
    echo.
    echo ========================================
    echo Failed to create keystore!
    echo ========================================
    echo.
    echo Make sure Java JDK is installed and keytool is in your PATH.
    echo.
)

cd ..
pause




