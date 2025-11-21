# Script to check if the app is running and filter Google Play Services errors
Write-Host "Checking app status..." -ForegroundColor Green
Write-Host ""

# Check if app is installed
$appInstalled = adb shell pm list packages | Select-String "emi_calculatornew"
if ($appInstalled) {
    Write-Host "✓ App is installed" -ForegroundColor Green
} else {
    Write-Host "✗ App not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "Starting Flutter app with filtered errors..." -ForegroundColor Yellow
Write-Host "Note: Google Play Services errors will be filtered out" -ForegroundColor Cyan
Write-Host ""

# Run Flutter app and filter errors
flutter run 2>&1 | Where-Object { 
    $_ -notmatch "NetworkCapability.*out of range" -and 
    $_ -notmatch "com\.google\.android\.gms" -and 
    $_ -notmatch "PushMessagingRegistrarProxy" -and
    $_ -notmatch "FATAL EXCEPTION.*gms" -and
    $_ -notmatch "Process: com.google.android.gms"
}

