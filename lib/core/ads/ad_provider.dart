import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdProvider extends ChangeNotifier {
  bool _rewardedLoaded = false;
  bool _bannerLoaded = false;
  bool _nativeLoaded = false;

  bool _nativeRequested = false;

  //Ads ids
  static const String _rewardAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _bannerAdUnitId =
      'ca-app-pub-3940256099942544/9214589741';
  static const String _nativeAdUnitId =
      'ca-app-pub-3940256099942544/2247696110';
  //Ads
  RewardedAd? _rewardedAd;
  BannerAd? _bannerAd;
  NativeAd? _nativeAd;

  // Getters
  bool get isRewardedLoaded => _rewardedLoaded;
  bool get isBannerLoaded => _bannerLoaded;
  bool get isNativeLoaded => _nativeLoaded;
  RewardedAd? get getRewardedAd => _rewardedAd;
  BannerAd? get getBannerAd => _bannerAd;
  NativeAd? get getNativeAd => _nativeAd;

  //Functions

  //Load Rewarded Ad
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardAdUnitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _rewardedLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (LoadAdError error) {
          _rewardedLoaded = false;
          notifyListeners();
        },
      ),
    );
  }

  //Load Banner Ad
  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          _bannerLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          _bannerLoaded = false;
          ad.dispose();
          notifyListeners();
        },
      ),
    )..load();
  }

  //Load Native Ad
  void loadNativeAd() {
    if (_nativeRequested) return;
    _nativeRequested = true;
    _nativeAd = NativeAd(
      adUnitId: _nativeAdUnitId,
      request: AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
      ),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          _nativeLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          _nativeLoaded = false;
          ad.dispose();
          notifyListeners();
        },
      ),
    )..load();
  }

  //Widgets for ad display
  Widget getBannerWidget(bool isPremium) {
    if (!isPremium && isBannerLoaded) {
      return Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: getBannerAd!.size.height.toDouble(),
          width: getBannerAd!.size.width.toDouble(),
          child: AdWidget(ad: getBannerAd!),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget getRewardedWidget(bool isPremium, VoidCallback onAdEarned) {
    if (!isPremium) {
      if (isRewardedLoaded && getRewardedAd != null) {
        getRewardedAd!.show(
          onUserEarnedReward: (ad, reward) {
            onAdEarned();
          },
        );
        return SizedBox.shrink();
      }
      return SizedBox.shrink();
    } else {
      onAdEarned();
      return SizedBox.shrink();
    }
  }

  Widget getNativeWidget(bool isPremium) {
    if (isPremium) return const SizedBox.shrink();
    if (!_nativeLoaded || _nativeAd == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(height: 320, child: AdWidget(ad: _nativeAd!));
  }

  //Dispose ads
  @override
  void dispose() {
    _rewardedAd?.dispose();
    _bannerAd?.dispose();
    _nativeAd?.dispose();
    super.dispose();
  }
}
