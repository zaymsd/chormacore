import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/text_styles.dart';
import '../../../core/routes/app_routes.dart';

/// Splash screen with Lottie animation
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _lottieController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _taglineFadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Lottie animation controller
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    
    // Fade animation controller for text
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    // Brand name fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    // Tagline fade animation (delayed)
    _taglineFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
    
    // Start animations
    _lottieController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _fadeController.forward();
    });
    
    // Navigate to home after animation completes
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.guestBrowse);
      }
    });
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
              AppColors.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // Lottie Animation
              SizedBox(
                width: 200,
                height: 200,
                child: Lottie.asset(
                  'assets/animations/shopping_cart.json',
                  controller: _lottieController,
                  fit: BoxFit.contain,
                  onLoaded: (composition) {
                    _lottieController.duration = composition.duration;
                  },
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Brand Name with fade animation
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  'ChormaCore',
                  style: TextStyles.h2.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 36,
                    letterSpacing: 2,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Tagline with delayed fade animation
              AnimatedBuilder(
                animation: _taglineFadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _taglineFadeAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, 15 * (1 - _taglineFadeAnimation.value)),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  'Klik, Bayar, Sampai!',
                  style: TextStyles.bodyLarge.copyWith(
                    color: AppColors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
              ),
              
              const Spacer(flex: 3),
              
              // Loading indicator
              AnimatedBuilder(
                animation: _taglineFadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _taglineFadeAnimation.value,
                    child: child,
                  );
                },
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
