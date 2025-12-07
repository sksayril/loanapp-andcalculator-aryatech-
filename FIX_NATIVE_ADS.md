# 🚨 URGENT: Fix Native Ads Configuration

## Problem
Your Native Ad ID `ca-app-pub-3422720384917984/8363331473` is **NOT configured as a Native Ad** in AdMob.

**Error:** `Ad unit doesn't match format (Error Code 3)`

## Quick Fix Steps

### Step 1: Create a New Native Ad Unit in AdMob

1. **Go to AdMob Console**: https://apps.admob.com/
2. **Select your app** (Loan Trix)
3. **Click "Ad units"** → **"Add ad unit"**
4. **IMPORTANT: Select "Native"** (NOT Banner, NOT Interstitial, NOT Rewarded)
5. **Configure:**
   - Name: "Native Ad - CIBIL Screen"
   - Format: Native (Medium template)
6. **Click "Create ad unit"**
7. **Copy the NEW Ad Unit ID** (will look like: `ca-app-pub-3422720384917984/XXXXXXXXXX`)

### Step 2: Update Code

1. **Open**: `lib/services/ad_helper.dart`
2. **Find** the `nativeAdUnitId` getter (around line 35)
3. **Replace** the production ID with your NEW Native ad ID:
   ```dart
   if (Platform.isAndroid) {
     return 'YOUR-NEW-NATIVE-AD-ID-HERE'; // ← Paste your new ID here
   } else if (Platform.isIOS) {
     return 'YOUR-NEW-NATIVE-AD-ID-HERE'; // ← Paste your new ID here
   }
   ```
4. **Change** `_useTesting` to `false`:
   ```dart
   static const bool _useTesting = false; // Production mode
   ```

### Step 3: Test

1. **Run the app**
2. **Go to CIBIL Score screen**
3. **Native ads should now load** (may take a few minutes for new ad units to activate)

## Current Status

- ✅ **Rewarded Ads**: Working perfectly
- ❌ **Native Ads**: Using test ads (production ID is wrong format)
- ⏳ **Action Required**: Create new Native ad unit in AdMob

## Why This Happened

The ad unit ID `8363331473` was created as a **Banner** or **Interstitial** ad, not a **Native** ad. AdMob doesn't allow converting ad unit types - you must create a new one.

## Test Mode (Temporary)

Currently using test ads so the app works. Once you create the proper Native ad unit, switch back to production mode.

---

**Need Help?** Check the full guide in `ADMOB_SETUP_GUIDE.md`

