# PowerShell script to filter out Google Play Services errors from logcat
adb logcat | Select-String -Pattern "NetworkCapability|com.google.android.gms|PushMessagingRegistrarProxy" -NotMatch

