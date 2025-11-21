# Run Flutter app with filtered Google Play Services errors
# This filters out the NetworkCapability errors that don't affect your app

Write-Host "Starting Flutter app..." -ForegroundColor Green
Write-Host "Note: Google Play Services errors will be filtered out" -ForegroundColor Yellow

flutter run 2>&1 | Where-Object { 
    $_ -notmatch "NetworkCapability.*out of range" -and 
    $_ -notmatch "com\.google\.android\.gms" -and 
    $_ -notmatch "PushMessagingRegistrarProxy" -and
    $_ -notmatch "FATAL EXCEPTION.*gms"
}

