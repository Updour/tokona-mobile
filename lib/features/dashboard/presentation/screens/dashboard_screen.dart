import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/dashboard/presentation/widgets/akun_tab_view.dart';
import 'package:tokona/features/dashboard/presentation/widgets/beranda_tab_view.dart';
import 'package:tokona/features/dashboard/presentation/widgets/custom_floating_bottom_nav.dart';
import 'package:tokona/features/dashboard/presentation/widgets/kasir_tab_view.dart';
import 'package:tokona/features/dashboard/presentation/widgets/laporan_tab_view.dart';
import 'package:tokona/features/dashboard/presentation/widgets/produk_tab_view.dart';
import 'package:tokona/features/pos/presentation/controllers/sale_history_controller.dart';
import 'package:tokona/features/product/presentation/controllers/product_controller.dart';
import 'package:tokona/features/report/presentation/controllers/report_controller.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;
  final List<int> _tabHistory = [];
  DateTime? _lastBackPressTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storeId = ref.read(authProvider).currentStore?.id;
      if (storeId != null) {
        ref.read(productListProvider.notifier).loadProducts(storeId);
        ref.read(reportControllerProvider.notifier).loadReport(storeId);
        ref.read(saleHistoryControllerProvider.notifier).loadSales(storeId);
      }
    });
  }

  void _onSelectTab(int index) {
    if (_currentIndex != index) {
      setState(() {
        _tabHistory.remove(index);
        _tabHistory.add(_currentIndex);
        _currentIndex = index;
      });
    }
  }

  void _handlePopInvoked(bool didPop) {
    if (didPop) return;

    // 1. Navigasi mundur sesuai histori klik tab
    if (_tabHistory.isNotEmpty) {
      final prevTab = _tabHistory.removeLast();
      setState(() => _currentIndex = prevTab);
      return;
    }

    // 2. Jika bukan di Beranda, kembali ke Beranda (tab 0)
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      return;
    }

    // 3. Jika sudah di Beranda, tekan 2x berturut-turut untuk keluar aplikasi
    final now = DateTime.now();
    if (_lastBackPressTime == null || now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      HapticFeedback.lightImpact();
      AppToast.showInfo(context, 'Tekan sekali lagi untuk keluar dari Tokona');
      return;
    }

    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider.select((s) => s.currentStore?.id), (prev, next) {
      if (next != null && next != prev) {
        ref.read(productListProvider.notifier).loadProducts(next);
        ref.read(reportControllerProvider.notifier).loadReport(next);
        ref.read(saleHistoryControllerProvider.notifier).loadSales(next);
      }
    });

    final authState = ref.watch(authProvider);
    final user = authState.currentUser;
    final store = authState.currentStore;

    final List<Widget> pages = [
      BerandaTabView(
        store: store,
        user: user,
        onNavigateTab: _onSelectTab,
      ),
      const ProdukTabView(),
      const KasirTabView(),
      const LaporanTabView(),
      AkunTabView(store: store, user: user),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) => _handlePopInvoked(didPop),
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: IndexedStack(
              index: _currentIndex,
              children: pages,
            ),
          ),
          bottomNavigationBar: CustomFloatingBottomNav(
            currentIndex: _currentIndex,
            onTap: _onSelectTab,
          ),
        ),
      ),
    );
  }
}
