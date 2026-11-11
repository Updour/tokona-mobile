import 'package:tokona/features/auth/domain/models/store_model.dart';
import 'package:tokona/features/auth/domain/models/user_model.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final bool isInitialized;
  final bool hasRegisteredStore;
  final StoreModel? currentStore;
  final UserModel? currentUser;
  final String? errorMessage;
  final String? successMessage;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.isInitialized = false,
    this.hasRegisteredStore = false,
    this.currentStore,
    this.currentUser,
    this.errorMessage,
    this.successMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    bool? isInitialized,
    bool? hasRegisteredStore,
    StoreModel? currentStore,
    UserModel? currentUser,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isInitialized: isInitialized ?? this.isInitialized,
      hasRegisteredStore: hasRegisteredStore ?? this.hasRegisteredStore,
      currentStore: currentStore ?? this.currentStore,
      currentUser: currentUser ?? this.currentUser,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}
