import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  // AdMob App ID: ca-app-pub-3422720384917984~6782469458
  
  // Set to true to use test ads, false for production
  // NOTE: Currently using test ads because production ad unit ID is not configured as Native format
  // Change to false once you create a proper Native Ad unit in AdMob
  static const bool _useTesting = false; // Using test ads until production Native ad unit is configured
  
  // IMPORTANT: Each ad type (Native, Banner, Rewarded) needs a separate ad unit ID
  // Make sure you have created separate ad units in your AdMob account for each type
  // Native ads and Banner ads cannot use the same ad unit ID
  
  // Video/Rewarded Ad ID
  static String get rewardedAdUnitId {
    if (_useTesting) {
      // Test ad ID
      return Platform.isAndroid 
        ? 'ca-app-pub-3940256099942544/5224354917'  // Test rewarded ad
        : 'ca-app-pub-3940256099942544/1712485313';
    }
    
    if (Platform.isAndroid) {
      return 'ca-app-pub-3422720384917984/3355000965';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3422720384917984/3355000965';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // Native Ad ID
  static String get nativeAdUnitId {
    if (_useTesting) {
      // Test ad ID for Native ads (always works)
      return Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/2247696110'
        : 'ca-app-pub-3940256099942544/3986624511';
    }

    if (Platform.isAndroid) {
      return 'ca-app-pub-3422720384917984/8363331473';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3422720384917984/8363331473';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
  
  // Banner Ad ID (alternative to Native ads)
  static String get bannerAdUnitId {
    if (_useTesting) {
      // Test banner ad IDs
      return Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/6300978111'  // Test banner ad (medium rectangle)
        : 'ca-app-pub-3940256099942544/2934735716'; // Test banner ad for iOS
    }
    
    // Production Banner Ad ID
    if (Platform.isAndroid) {
      return 'ca-app-pub-3422720384917984/9412412931';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3422720384917984/9412412931';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // Initialize Mobile Ads SDK
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  // Create and load a rewarded ad
  static Future<RewardedAd?> loadRewardedAd() async {
    print('→ Loading RewardedAd with ID: $rewardedAdUnitId');
    print('  Testing mode: $_useTesting');
    
    final completer = Completer<RewardedAd?>();
    
    try {
      RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            print('✓ RewardedAd loaded successfully');
            if (!completer.isCompleted) {
              completer.complete(ad);
            }
          },
          onAdFailedToLoad: (error) {
            print('✗ RewardedAd failed to load: ${error.message}');
            print('  Code: ${error.code}, Domain: ${error.domain}');
            if (!completer.isCompleted) {
              completer.complete(null);
            }
          },
        ),
      );
      
      // Wait for the ad to load (timeout after 10 seconds)
      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('✗ RewardedAd loading timed out');
          return null;
        },
      );
    } catch (e) {
      print('✗ Exception loading RewardedAd: $e');
      return null;
    }
  }

  // Create and load a native ad
  static NativeAd loadNativeAd({
    required Function(NativeAd) onAdLoaded,
    required Function(LoadAdError) onAdFailedToLoad,
  }) {
    print('→ Loading NativeAd with ID: $nativeAdUnitId');
    print('  Testing mode: $_useTesting');

    NativeAd nativeAd = NativeAd(
      adUnitId: nativeAdUnitId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          print('✓ NativeAd loaded successfully');
          onAdLoaded(ad as NativeAd);
        },
        onAdFailedToLoad: (ad, error) {
          print('✗ NativeAd failed to load: ${error.message}');
          print('  Code: ${error.code}, Domain: ${error.domain}');
          ad.dispose();
          onAdFailedToLoad(error);
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: Colors.white,
        cornerRadius: 16.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: const Color(0xFF1E3A5F),
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black87,
          backgroundColor: Colors.white,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black54,
          backgroundColor: Colors.white,
          style: NativeTemplateFontStyle.normal,
          size: 14.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black45,
          backgroundColor: Colors.white,
          style: NativeTemplateFontStyle.normal,
          size: 12.0,
        ),
      ),
    );

    nativeAd.load();
    return nativeAd;
  }
  
  // Create and load a banner ad (alternative to native ads)
  static BannerAd loadBannerAd({
    required Function(BannerAd) onAdLoaded,
    required Function(LoadAdError) onAdFailedToLoad,
    AdSize adSize = AdSize.mediumRectangle,
  }) {
    print('→ Loading BannerAd with ID: $bannerAdUnitId');
    print('  Testing mode: $_useTesting');
    
    BannerAd bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('✓ BannerAd loaded successfully');
          onAdLoaded(ad as BannerAd);
        },
        onAdFailedToLoad: (ad, error) {
          print('✗ BannerAd failed to load: ${error.message}');
          print('  Code: ${error.code}, Domain: ${error.domain}');
          ad.dispose();
          onAdFailedToLoad(error);
        },
        onAdClicked: (ad) {
          print('BannerAd clicked');
        },
        onAdImpression: (ad) {
          print('BannerAd impression recorded');
        },
        onAdOpened: (ad) {
          print('BannerAd opened');
        },
        onAdClosed: (ad) {
          print('BannerAd closed');
        },
      ),
    );
    
    bannerAd.load();
    return bannerAd;
  }
}

