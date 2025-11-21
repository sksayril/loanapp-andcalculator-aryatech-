# PowerShell script to run Flutter app and filter out Google Play Services errors
flutter run 2>&1 | Where-Object { 
    $_ -notmatch "NetworkCapability.*out of range" -and 
    $_ -notmatch "com\.google\.android\.gms" -and 
    $_ -notmatch "PushMessagingRegistrarProxy"
}

