import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/widgets/app_loading_overlay.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/auth/presentation/widgets/auth_header_widget.dart';
import 'package:tokona/features/auth/presentation/widgets/cashier_scan_invite_banner.dart';
import 'package:tokona/features/auth/presentation/widgets/login_form_widget.dart';
import 'package:tokona/features/auth/presentation/widgets/register_form_widget.dart';
import 'package:tokona/features/dashboard/presentation/screens/dashboard_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with SingleTickerProviderStateMixin {
  bool? _isRegisterModeOverride;
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    _fadeAnimation = CurvedAnimation(parent: _entranceController, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    ref.listen(authProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        AppToast.showError(context, next.errorMessage!);
      }
      if (next.successMessage != null && next.successMessage != previous?.successMessage) {
        AppToast.showSuccess(context, next.successMessage!);
      }
    });

    ref.listen(authProvider.select((s) => s.isAuthenticated), (prev, next) async {
      if (next == true && prev != true) {
        await AppLoadingOverlay.show(
          context,
          title: 'Sebentar ya...',
          subtitle: 'Menyiapkan data tokomu',
          icon: Icons.storefront_rounded,
          duration: const Duration(milliseconds: 1800),
        );
        if (!context.mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const DashboardScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 350),
          ),
          (route) => false,
        );
      }
    });

    final bool isRegisterMode = _isRegisterModeOverride ?? (!authState.hasRegisteredStore);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Stack(
          children: [
            _buildAmbientBackground(),
            SafeArea(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                behavior: HitTestBehavior.translucent,
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight - 32, maxWidth: 460),
                      child: Center(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const AuthHeaderWidget(),
                                const SizedBox(height: 22),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.08), blurRadius: 42, offset: const Offset(0, 18)),
                                      BoxShadow(color: const Color(0xFF0D9488).withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 6)),
                                    ],
                                  ),
                                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            isRegisterMode ? 'Daftar Akun' : 'Selamat Datang',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.textPrimary,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            isRegisterMode
                                                ? 'Isi data singkat untuk mulai'
                                                : 'Masuk ke akun tokomu',
                                            style: const TextStyle(
                                              fontSize: 12.5,
                                              color: Color(0xFF64748B),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 18),
                                      _buildModeSelector(isRegisterMode),
                                      const SizedBox(height: 20),
                                      AnimatedCrossFade(
                                        firstChild: LoginFormWidget(
                                          isLoading: authState.isLoading,
                                          onSubmit: (dto) => authNotifier.login(dto),
                                          onSwitchToRegister: () {
                                            HapticFeedback.selectionClick();
                                            setState(() => _isRegisterModeOverride = true);
                                          },
                                        ),
                                        secondChild: RegisterFormWidget(
                                          isLoading: authState.isLoading,
                                          onSubmit: (dto) => authNotifier.registerStoreAndOwner(dto),
                                          onSwitchToLogin: () {
                                            HapticFeedback.selectionClick();
                                            setState(() => _isRegisterModeOverride = false);
                                          },
                                        ),
                                        crossFadeState: isRegisterMode ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                        duration: const Duration(milliseconds: 260),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const CashierScanInviteBanner(),
                                const SizedBox(height: 16),
                                _buildFooter(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmbientBackground() {
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFECFDF5), Color(0xFFF8FAFC), Color(0xFFEFF6FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(top: -110, left: -90, child: _glowCircle(360, const Color(0xFF0D9488), 0.18)),
              Positioned(bottom: -130, right: -90, child: _glowCircle(380, const Color(0xFF06B6D4), 0.14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glowCircle(double size, Color color, double alpha) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color.withValues(alpha: alpha), Colors.transparent]),
      ),
    );
  }

  Widget _buildModeSelector(bool isRegisterMode) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Expanded(
            child: _buildSelectorTab('Masuk', Icons.login_rounded, !isRegisterMode, () {
              HapticFeedback.selectionClick();
              setState(() => _isRegisterModeOverride = false);
            }),
          ),
          Expanded(
            child: _buildSelectorTab('Daftar', Icons.person_add_alt_1_rounded, isRegisterMode, () {
              HapticFeedback.selectionClick();
              setState(() => _isRegisterModeOverride = true);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorTab(String title, IconData icon, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow: isSelected
              ? [BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: isSelected ? AppColors.primary : const Color(0xFF64748B)),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.primary : const Color(0xFF64748B),
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.verified_user_outlined, size: 13, color: Color(0xFF10B981)),
        SizedBox(width: 6),
        Text('Bisa dipakai offline • Data aman', style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
      ],
    );
  }
}
