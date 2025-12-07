# AdMob Integration Guide - CIBIL Score Screen

## ✅ What Has Been Implemented

1. **Google Mobile Ads SDK** integrated
2. **Rewarded Video Ads** - Shows before checking CIBIL score
3. **Native Ads** - Displays in the form (with Banner fallback)
4. **Banner Ads** - Automatic fallback if Native ads fail

## 🔑 Your Ad IDs

- **App ID**: `ca-app-pub-3422720384917984~2891620741`
- **Rewarded Video ID**: `ca-app-pub-3422720384917984/2899235896` ✅ **WORKING**
- **Native Ads ID**: `ca-app-pub-3422720384917984/8363331473` ❌ **NOT CONFIGURED FOR NATIVE FORMAT**

## ⚠️ Current Issue - URGENT FIX NEEDED

The Native Ad ID `ca-app-pub-3422720384917984/8363331473` is returning:
```
Error Code 3: Ad unit doesn't match format
```

**This means the ad unit in your AdMob console is NOT configured as a Native Ad format.**

The ad unit `8363331473` is likely configured as:
- ❌ Banner ad (wrong format)
- ❌ Interstitial ad (wrong format)  
- ❌ Rewarded ad (wrong format)
- ✅ Should be: **Native ad** format

**Currently using test ads** - Native ads will work with test IDs, but you need to fix the production ad unit.

## 🔧 How to Fix

### Option 1: Configure Existing Ad Unit as Native Ad (Recommended)

1. Go to [Google AdMob Console](https://apps.admob.com/)
2. Select your app "Loan Trix"
3. Go to **Ad units**
4. Find the ad unit with ID ending in `8363331473`
5. **Check its format** - if it's not "Native", you need to create a new one

### Option 2: Create a New Native Ad Unit (RECOMMENDED)

**⚠️ IMPORTANT: You MUST create a NEW Native ad unit. The existing one (`8363331473`) cannot be converted.**

1. Go to [Google AdMob Console](https://apps.admob.com/)
2. Select your app "Loan Trix" (or your app name)
3. Click **"Ad units"** → **"Add ad unit"**
4. **Select "Native"** (NOT Banner, Interstitial, or Rewarded)
5. Configure the ad unit:
   - **Name**: "CIBIL Screen Native Ad" (or any descriptive name)
   - **Ad format**: Native (Medium template recommended)
   - **Ad settings**: Use default template
6. Click **"Create ad unit"**
7. **Copy the NEW Ad Unit ID** (it will be different from `8363331473`)
8. Update the ID in `lib/services/ad_helper.dart`:
   ```dart
   // Native Ad ID
   static String get nativeAdUnitId {
     if (_useTesting) {
       return Platform.isAndroid
         ? 'ca-app-pub-3940256099942544/2247696110'  // Test native ad
         : 'ca-app-pub-3940256099942544/3986624511';
     }
     
     if (Platform.isAndroid) {
       return 'YOUR-NEW-NATIVE-AD-ID-HERE'; // ← Replace with your new Native ad ID
     } else if (Platform.isIOS) {
       return 'YOUR-NEW-NATIVE-AD-ID-HERE'; // ← Replace with your new Native ad ID
     }
   }
   ```
9. Change `_useTesting` back to `false` in `ad_helper.dart`

### Option 3: Use Test Ads (For Development)

In `lib/services/ad_helper.dart`, change:
```dart
static const bool _useTesting = false;
```
To:
```dart
static const bool _useTesting = true;
```

This will use Google's test ad IDs that always work.

## 📱 Current Ad Placements

### 1. **Rewarded Video Ad** ✅ Working
- **Trigger**: When user clicks "Check Score" button
- **Behavior**: Must watch ad to see CIBIL score
- **Status**: Loading successfully!

### 2. **Native/Banner Ad** (Below form)
- **Location**: After "Check Score" button, before loading screen
- **Fallback**: If Native ad fails, shows Banner ad instead
- **Status**: Currently failing (needs proper Native ad ID)

### 3. **Native/Banner Ad** (After results)
- **Location**: After loan eligibility section
- **Shows**: Only when eligibility results are displayed
- **Status**: Currently failing (same issue as above)

## 🧪 Testing Instructions

1. **Enable Test Mode** (Recommended for development):
   - Open `lib/services/ad_helper.dart`
   - Change `_useTesting` to `true`
   - Run the app - you should see test ads

2. **Test Rewarded Ad**:
   - Fill in the CIBIL form
   - Click "Check Score"
   - Watch the rewarded video ad
   - See your score after watching

3. **Production Mode**:
   - Once you've configured proper Native ad ID in AdMob
   - Change `_useTesting` back to `false`
   - Update the Native ad ID if you created a new one
   - Test thoroughly before releasing

## 📝 Files Modified

- `pubspec.yaml` - Added google_mobile_ads dependency
- `android/app/src/main/AndroidManifest.xml` - Added AdMob App ID
- `lib/main.dart` - Initialize MobileAds SDK
- `lib/services/ad_helper.dart` - Ad management helper class
- `lib/cibil_score_screen.dart` - Integrated ads into UI

## 🚀 Next Steps

1. **Fix Native Ad Issue**:
   - Check AdMob console
   - Either reconfigure existing ad unit or create new Native ad unit
   - Update the ad ID in code if needed

2. **Test Thoroughly**:
   - Use test mode first
   - Then switch to production IDs
   - Test on real device

3. **Monitor Performance**:
   - Check AdMob dashboard for ad impressions
   - Monitor fill rates
   - Track revenue

## 💡 Tips

- **Test ads always work** - Use them during development
- **Real ads require approval** - May take time to show initially
- **Native ads need proper setup** - Most common error is format mismatch
- **Rewarded ads work best** - They're already working in your app!

## 🆘 Support

If ads still don't show:
1. Verify AdMob app is approved
2. Check ad unit types match (Native = Native, Rewarded = Rewarded)
3. Wait 24 hours for new ad units to activate
4. Use test mode to verify implementation is correct

