import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/product/data/repositories/classification_repository.dart';

final classificationRepositoryProvider = Provider<ClassificationRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ClassificationRepository(db);
});

class ClassificationState {
  final List<String> categories;
  final List<String> productTypes;
  final bool isLoading;
  final String? errorMessage;

  const ClassificationState({
    this.categories = const [],
    this.productTypes = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ClassificationState copyWith({
    List<String>? categories,
    List<String>? productTypes,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ClassificationState(
      categories: categories ?? this.categories,
      productTypes: productTypes ?? this.productTypes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final classificationProvider = StateNotifierProvider<ClassificationNotifier, ClassificationState>((ref) {
  final repo = ref.watch(classificationRepositoryProvider);
  return ClassificationNotifier(repo);
});

class ClassificationNotifier extends StateNotifier<ClassificationState> {
  final ClassificationRepository _repo;

  ClassificationNotifier(this._repo)
      : super(
          const ClassificationState(
            categories: ClassificationRepository.defaultCategories,
            productTypes: ClassificationRepository.defaultProductTypes,
          ),
        );

  Future<void> load(String storeId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final cats = await _repo.getCategories(storeId);
      final types = await _repo.getProductTypes(storeId);
      state = state.copyWith(
        categories: cats,
        productTypes: types,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> addCategory(String storeId, String name) async {
    await _repo.ensureCategory(storeId, name);
    await load(storeId);
  }

  Future<void> updateCategory(String storeId, String oldName, String newName) async {
    await _repo.updateCategory(storeId, oldName, newName);
    await load(storeId);
  }

  Future<void> deleteCategory(String storeId, String name) async {
    await _repo.deleteCategory(storeId, name);
    await load(storeId);
  }

  Future<void> addProductType(String storeId, String name) async {
    await _repo.ensureProductType(storeId, name);
    await load(storeId);
  }

  Future<void> updateProductType(String storeId, String oldName, String newName) async {
    await _repo.updateProductType(storeId, oldName, newName);
    await load(storeId);
  }

  Future<void> deleteProductType(String storeId, String name) async {
    await _repo.deleteProductType(storeId, name);
    await load(storeId);
  }
}
