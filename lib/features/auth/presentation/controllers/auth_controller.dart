import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/database/app_database.dart';
import 'package:tokona/features/auth/data/repositories/auth_repository.dart';
import 'package:tokona/features/auth/domain/dtos/login_dto.dart';
import 'package:tokona/features/auth/domain/dtos/register_dto.dart';
import 'package:tokona/features/auth/domain/models/auth_state.dart';
import 'package:tokona/features/auth/domain/models/store_model.dart';

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

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}
