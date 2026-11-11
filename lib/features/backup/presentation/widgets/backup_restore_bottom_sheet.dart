import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/widgets/app_dialog.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/backup/data/services/backup_service.dart';
import 'package:tokona/features/backup/data/services/supabase_backup_service.dart';
import 'package:tokona/features/backup/domain/models/backup_file_model.dart';
import 'package:tokona/features/backup/domain/models/cloud_backup_model.dart';
import 'package:tokona/features/backup/presentation/widgets/cloud_backup_tab_view.dart';
import 'package:tokona/features/backup/presentation/widgets/local_backup_tab_view.dart';
import 'package:tokona/features/product/presentation/controllers/product_controller.dart';

class BackupRestoreBottomSheet extends ConsumerStatefulWidget {
  const BackupRestoreBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const BackupRestoreBottomSheet(),
    );
  }

  @override
  ConsumerState<BackupRestoreBottomSheet> createState() => _BackupRestoreBottomSheetState();
}

class _BackupRestoreBottomSheetState extends ConsumerState<BackupRestoreBottomSheet> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isLoading = true;
  bool _isProcessing = false;
  List<BackupFileModel> _localBackups = [];
  List<CloudBackupModel> _cloudBackups = [];
  Map<String, dynamic> _summary = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final locals = await BackupService.getBackupList();
      final summary = await BackupService.getStorageSummary();
      List<CloudBackupModel> clouds = [];
      final storeId = ref.read(authProvider).currentStore?.id;
      if (storeId != null) {
        try {
          clouds = await SupabaseBackupService.getCloudBackups(storeId);
        } catch (_) {}
      }
      if (mounted) {
        setState(() {
          _localBackups = locals;
          _cloudBackups = clouds;
          _summary = summary;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCreateLocal() async {
    setState(() => _isProcessing = true);
    try {
      final b = await BackupService.createBackup();
      if (mounted) {
        AppToast.showSuccess(context, 'Cadangan lokal dibuat (${b.formattedSize})');
        await _loadData();
      }
    } catch (e) {
      if (mounted) AppToast.showError(context, 'Gagal membuat cadangan lokal: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleCreateCloud() async {
    final store = ref.read(authProvider).currentStore;
    if (store == null) return;
    setState(() => _isProcessing = true);
    try {
      final b = await SupabaseBackupService.createCloudBackup(storeId: store.id, storeName: store.name);
      if (mounted) {
        AppToast.showSuccess(context, 'Cadangan berhasil disimpan ke Cloud (${b.formattedSize})');
        await _loadData();
      }
    } catch (e) {
      if (mounted) AppToast.showError(context, 'Koneksi Cloud gagal: Periksa koneksi internet ($e)');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleRestoreLocal(BackupFileModel b) async {
    final df = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    final confirm = await AppDialog.showConfirmation(
      context,
      title: 'Pulihkan Data Toko',
      message: 'Perhatian: Seluruh data saat ini akan digantikan oleh salinan lokal tanggal ${df.format(b.createdAt)}. Lanjutkan?',
      confirmText: 'Ya, Pulihkan Data',
      isDestructive: true,
      icon: Icons.restore_rounded,
    );
    if (confirm != true || !mounted) return;

    try {
      await BackupService.restoreBackup(b.path);
      final store = ref.read(authProvider).currentStore;
      if (store != null) await ref.read(productListProvider.notifier).loadProducts(store.id);
      if (mounted) {
        AppToast.showSuccess(context, 'Data toko berhasil dipulihkan dari lokal!');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) AppToast.showError(context, 'Gagal memulihkan database: $e');
    }
  }

  Future<void> _handleRestoreCloud(CloudBackupModel b) async {
    final df = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    final confirm = await AppDialog.showConfirmation(
      context,
      title: 'Pulihkan Data Cloud Supabase',
      message: 'Pulihkan ${b.totalRecords} data toko dari Cloud tanggal ${df.format(b.createdAt)}? Data lokal saat ini akan diselaraskan.',
      confirmText: 'Ya, Pulihkan dari Cloud',
      isDestructive: true,
      icon: Icons.cloud_download_rounded,
    );
    if (confirm != true || !mounted) return;

    setState(() => _isProcessing = true);
    try {
      await SupabaseBackupService.restoreCloudBackup(b.id);
      final store = ref.read(authProvider).currentStore;
      if (store != null) await ref.read(productListProvider.notifier).loadProducts(store.id);
      if (mounted) {
        AppToast.showSuccess(context, 'Data toko berhasil dipulihkan dari Cloud Supabase!');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) AppToast.showError(context, 'Gagal memulihkan dari cloud: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cadangan & Pulihkan Data', style: AppTypography.headingSmall.copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('Sinkronisasi offline lokal dan Cloud Supabase', style: AppTypography.bodySmall.copyWith(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 38,
            decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(10)),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              tabs: [
                Tab(text: 'Lokal Offline (${_localBackups.length})'),
                Tab(text: 'Cloud Supabase (${_cloudBackups.length})'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                LocalBackupTabView(
                  backups: _localBackups,
                  summary: _summary,
                  isLoading: _isLoading,
                  isProcessing: _isProcessing,
                  onCreate: _handleCreateLocal,
                  onRestore: _handleRestoreLocal,
                  onDelete: (b) async {
                    await BackupService.deleteBackup(b.path);
                    _loadData();
                  },
                ),
                CloudBackupTabView(
                  backups: _cloudBackups,
                  isLoading: _isLoading,
                  isProcessing: _isProcessing,
                  onCreate: _handleCreateCloud,
                  onRestore: _handleRestoreCloud,
                  onDelete: (b) async {
                    await SupabaseBackupService.deleteCloudBackup(b.id);
                    _loadData();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
