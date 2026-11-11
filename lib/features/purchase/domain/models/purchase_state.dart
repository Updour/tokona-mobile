import 'package:tokona/features/purchase/domain/models/purchase_model.dart';

class PurchaseState {
  final bool isLoading;
  final List<PurchaseModel> purchases;
  final String? errorMessage;
  final String? successMessage;

  const PurchaseState({
    this.isLoading = false,
    this.purchases = const [],
    this.errorMessage,
    this.successMessage,
  });

  PurchaseState copyWith({
    bool? isLoading,
    List<PurchaseModel>? purchases,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return PurchaseState(
      isLoading: isLoading ?? this.isLoading,
      purchases: purchases ?? this.purchases,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }
}
