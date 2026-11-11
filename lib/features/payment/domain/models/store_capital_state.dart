import 'package:tokona/features/payment/domain/models/store_capital_model.dart';

class StoreCapitalState {
  final bool isLoading;
  final List<StoreCapitalModel> capitals;
  final String selectedType;
  final DateTime? startDate;
  final DateTime? endDate;
  final double initialCapital;
  final double addedCapital;
  final double withdrawnCapital;
  final double netCapital;
  final String? errorMessage;
  final String? successMessage;

  const StoreCapitalState({
    this.isLoading = false,
    this.capitals = const [],
    this.selectedType = 'ALL',
    this.startDate,
    this.endDate,
    this.initialCapital = 0,
    this.addedCapital = 0,
    this.withdrawnCapital = 0,
    this.netCapital = 0,
    this.errorMessage,
    this.successMessage,
  });

  StoreCapitalState copyWith({
    bool? isLoading,
    List<StoreCapitalModel>? capitals,
    String? selectedType,
    DateTime? startDate,
    DateTime? endDate,
    double? initialCapital,
    double? addedCapital,
    double? withdrawnCapital,
    double? netCapital,
    String? errorMessage,
    String? successMessage,
    bool clearDates = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return StoreCapitalState(
      isLoading: isLoading ?? this.isLoading,
      capitals: capitals ?? this.capitals,
      selectedType: selectedType ?? this.selectedType,
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
      initialCapital: initialCapital ?? this.initialCapital,
      addedCapital: addedCapital ?? this.addedCapital,
      withdrawnCapital: withdrawnCapital ?? this.withdrawnCapital,
      netCapital: netCapital ?? this.netCapital,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}
