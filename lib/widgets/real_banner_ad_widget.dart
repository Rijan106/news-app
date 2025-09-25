import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RealBannerAdWidget extends StatefulWidget {
  const RealBannerAdWidget({super.key});

  @override
  State<RealBannerAdWidget> createState() => _RealBannerAdWidgetState();
}

class _RealBannerAdWidgetState extends State<RealBannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  // Test Ad Unit ID - Replace with your actual Ad Unit ID for production
  final String _adUnitId =
      'ca-app-pub-3940256099942544/6300978111'; // Test banner ad unit ID

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Ad failed to load: $error');
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
            });
          }
        },
        onAdOpened: (ad) {
          print('Ad opened');
        },
        onAdClosed: (ad) {
          print('Ad closed');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdLoaded && _bannerAd != null) {
      return Container(
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AdWidget(ad: _bannerAd!),
        ),
      );
    } else {
      // Show loading indicator while ad is loading
      return Container(
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).cardColor,
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
  }
}
