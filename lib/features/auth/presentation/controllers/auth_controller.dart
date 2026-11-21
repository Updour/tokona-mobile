import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/database/app_database.dart';
import 'package:tokona/features/auth/data/repositories/auth_repository.dart';
import 'package:tokona/features/auth/domain/dtos/login_dto.dart';
import 'package:tokona/features/auth/domain/dtos/register_dto.dart';
import 'package:tokona/features/auth/domain/models/auth_state.dart';
import 'package:tokona/features/auth/domain/models/store_model.dart';
import 'package:tokona/features/settings/data/services/audit_log_service.dart';
import 'package:tokona/features/settings/domain/models/audit_log_model.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final appDatabase = ref.watch(appDatabaseProvider);
  return AuthRepository(appDatabase);
});

final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AuthState()) {
    checkInitialStatus();
  }

  Future<void> checkInitialStatus() async {
    try {
      final activeSession = await _repository.getActiveSession();
      if (activeSession != null) {
        state = state.copyWith(
          isInitialized: true,
          isAuthenticated: true,
          hasRegisteredStore: true,
          currentStore: activeSession.store,
          currentUser: activeSession.user,
        );
        return;
      }

      final hasStore = await _repository.hasRegisteredStore();
      final store = hasStore ? await _repository.getActiveStore() : null;
      state = state.copyWith(
        isInitialized: true,
        isAuthenticated: false,
        hasRegisteredStore: hasStore,
        currentStore: store,
      );
    } catch (_) {
      state = state.copyWith(
        isInitialized: true,
        isAuthenticated: false,
        hasRegisteredStore: false,
      );
    }
  }

  Future<bool> registerStoreAndOwner(RegisterDto dto) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      final result = await _repository.registerStoreAndOwner(dto);
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        hasRegisteredStore: true,
        currentStore: result.store,
        currentUser: result.user,
        successMessage: 'Toko dan akun pemilik berhasil didaftarkan',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', '').replaceFirst('StateError: ', '').replaceFirst('ArgumentError: ', ''),
      );
      return false;
    }
  }

  Future<bool> login(LoginDto dto) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      final result = await _repository.login(dto);
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        currentStore: result.store,
        currentUser: result.user,
        successMessage: 'Berhasil masuk',
      );
      AuditLogService.log(
        storeId: result.store.id,
        userId: result.user.id,
        userName: result.user.fullName,
        userRole: result.user.role.label,
        actionType: AuditActionType.auth,
        title: 'Sesi Kasir Dimulai (Login)',
        description: '${result.user.fullName} (@${result.user.username}) berhasil masuk.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', '').replaceFirst('StateError: ', '').replaceFirst('ArgumentError: ', ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.clearSession();
    state = state.copyWith(
      isAuthenticated: false,
      currentUser: null,
      clearError: true,
      clearSuccess: true,
    );
  }

  Future<bool> updateStore(StoreModel updated) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      final savedStore = await _repository.updateStore(updated);
      state = state.copyWith(
        isLoading: false,
        currentStore: savedStore,
        successMessage: 'Profil toko berhasil diperbarui',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memperbarui profil toko: $e',
      );
      return false;
    }
  }

  Future<bool> resetPassword({required String username, required String newPassword}) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      await _repository.resetPassword(username: username, newPassword: newPassword);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Kata sandi berhasil diatur ulang. Silakan login kembali.',
      );
      AuditLogService.log(
        storeId: state.currentStore?.id ?? 'default',
        userId: username,
        userName: username,
        userRole: 'Pengguna',
        actionType: AuditActionType.auth,
        title: 'Atur Ulang Kata Sandi',
        description: 'Kata sandi untuk pengguna @$username berhasil diubah.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', '').replaceFirst('StateError: ', '').replaceFirst('ArgumentError: ', ''),
      );
      return false;
    }
  }

  Future<bool> importPairingJson(String rawJson) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      final map = jsonDecode(rawJson) as Map<String, dynamic>;
      final result = await _repository.importPairingData(map);
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        hasRegisteredStore: true,
        currentStore: result.store,
        currentUser: result.user,
        successMessage: 'Perangkat berhasil terhubung dengan ${result.store.name}!',
      );
      AuditLogService.log(
        storeId: result.store.id,
        userId: result.user.id,
        userName: result.user.fullName,
        userRole: result.user.role.label,
        actionType: AuditActionType.pairing,
        title: 'Pairing Kasir Baru',
        description: 'Perangkat kasir berhasil pairing offline dengan ${result.store.name}.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal menghubungkan perangkat: $e',
      );
      return false;
    }
  }

  Future<bool> registerCashierFromInvite({
    required Map<String, dynamic> storeData,
    required String fullName,
    required String username,
    required String pin,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      final result = await _repository.registerCashierFromInvite(
        storeData: storeData, fullName: fullName, username: username, password: pin,
      );
      state = state.copyWith(
        isLoading: false, isAuthenticated: true, hasRegisteredStore: true,
        currentStore: result.store, currentUser: result.user,
        successMessage: 'Akun kasir ${result.user.fullName} berhasil dibuat & terhubung!',
      );
      AuditLogService.log(
        storeId: result.store.id, userId: result.user.id,
        userName: result.user.fullName, userRole: result.user.role.label,
        actionType: AuditActionType.pairing, title: 'Kasir Mandiri Terdaftar',
        description: 'Kasir ${result.user.fullName} (@${result.user.username}) terdaftar via scan QR Toko.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Gagal membuat akun kasir: $e');
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}
