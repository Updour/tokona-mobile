class DatabaseTables {
  DatabaseTables._();

  static const String stores = 'stores';
  static const String users = 'users';
  static const String products = 'products';
  static const String productUnits = 'product_units';
  static const String productCategories = 'product_categories';
  static const String productTypes = 'product_types';
  static const String productPriceTiers = 'product_price_tiers';
  static const String suppliers = 'suppliers';
  static const String customers = 'customers';
  static const String appSettings = 'app_settings';

  static const String columnId = 'id';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';
  static const String columnSyncedAt = 'synced_at';

  static const String columnStoreName = 'name';
  static const String columnStoreAddress = 'address';
  static const String columnStorePhone = 'phone';

  static const String columnUserStoreId = 'store_id';
  static const String columnUserUsername = 'username';
  static const String columnUserFullName = 'full_name';
  static const String columnUserPasswordHash = 'password_hash';
  static const String columnUserSalt = 'salt';
  static const String columnUserRole = 'role';
  static const String columnUserIsActive = 'is_active';

  static const String columnProductStoreId = 'store_id';
  static const String columnProductSku = 'sku';
  static const String columnProductName = 'name';
  static const String columnProductCategory = 'category';
  static const String columnProductBaseUnit = 'base_unit';
  static const String columnProductStockBase = 'stock_base';
  static const String columnProductMinStockAlert = 'min_stock_alert';
  static const String columnProductBaseCostPrice = 'base_cost_price';
  static const String columnProductBaseSellingPrice = 'base_selling_price';
  static const String columnProductType = 'product_type';
  static const String columnProductImagePath = 'image_path';
  static const String columnProductExpiredAt = 'expired_at';
  static const String columnProductDeviceTag = 'device_tag';

  static const String columnUnitProductId = 'product_id';
  static const String columnUnitName = 'unit_name';
  static const String columnUnitConversionFactor = 'conversion_factor';
  static const String columnUnitCostPrice = 'cost_price';
  static const String columnUnitSellingPrice = 'selling_price';
  static const String columnUnitBarcode = 'barcode';

  static const String columnTierProductId = 'product_id';
  static const String columnTierUnitName = 'unit_name';
  static const String columnTierMinQuantity = 'min_quantity';
  static const String columnTierPrice = 'price';

  static const String columnSupplierStoreId = 'store_id';
  static const String columnSupplierName = 'name';
  static const String columnSupplierType = 'type';
  static const String columnSupplierPlatform = 'platform';
  static const String columnSupplierContactName = 'contact_name';
  static const String columnSupplierPhone = 'phone';
  static const String columnSupplierAddress = 'address';
  static const String columnSupplierNotes = 'notes';

  static const String columnCustomerStoreId = 'store_id';
  static const String columnCustomerName = 'name';
  static const String columnCustomerPhone = 'phone';
  static const String columnCustomerAddress = 'address';
  static const String columnCustomerType = 'customer_type';
  static const String columnCustomerNotes = 'notes';
  static const String columnCustomerReceivableBalance = 'receivable_balance';

  static const String columnSettingKey = 'key';
  static const String columnSettingValue = 'value';

  static const String devices = 'devices';
  static const String columnDeviceStoreId = 'store_id';
  static const String columnDeviceName = 'name';

  static const String paymentAccounts = 'payment_accounts';
  static const String columnAccountStoreId = 'store_id';
  static const String columnAccountName = 'name';
  static const String columnAccountType = 'type';
  static const String columnAccountNumber = 'account_number';
  static const String columnAccountHolderName = 'holder_name';
  static const String columnAccountInitialBalance = 'initial_balance';
  static const String columnAccountCurrentBalance = 'current_balance';
  static const String columnAccountIsActive = 'is_active';

  static const String purchases = 'purchases';
  static const String purchaseItems = 'purchase_items';

  static const String columnPurchaseStoreId = 'store_id';
  static const String columnPurchaseUserId = 'user_id';
  static const String columnPurchaseSupplierId = 'supplier_id';
  static const String columnPurchaseInvoiceNumber = 'invoice_number';
  static const String columnPurchaseSupplierName = 'supplier_name';
  static const String columnPurchaseType = 'purchase_type';
  static const String columnPurchasePlatform = 'platform';
  static const String columnPurchaseDeviceTag = 'device_tag';
  static const String columnPurchasePaymentAccount = 'payment_account';
  static const String columnPurchaseServiceFee = 'service_fee';
  static const String columnPurchaseShippingFee = 'shipping_fee';
  static const String columnPurchaseStatus = 'status';
  static const String columnPurchasePoDays = 'po_days';
  static const String columnPurchaseEstimatedArrival = 'estimated_arrival';
  static const String columnPurchaseRefundStatus = 'refund_status';
  static const String columnPurchaseTotalAmount = 'total_amount';
  static const String columnPurchaseNotes = 'notes';
  static const String columnPurchaseImagePath = 'image_path';
  static const String columnPurchaseTrackingNumber = 'tracking_number';

  static const String columnPurchaseItemPurchaseId = 'purchase_id';
  static const String columnPurchaseItemProductId = 'product_id';
  static const String columnPurchaseItemUnitId = 'unit_id';
  static const String columnPurchaseItemUnitName = 'unit_name';
  static const String columnPurchaseItemQuantity = 'quantity';
  static const String columnPurchaseItemConversionFactor = 'conversion_factor';
  static const String columnPurchaseItemUnitCost = 'unit_cost';
  static const String columnPurchaseItemSubtotal = 'subtotal';

  static const String sales = 'sales';
  static const String saleItems = 'sale_items';

  static const String columnSaleStoreId = 'store_id';
  static const String columnSaleUserId = 'user_id';
  static const String columnSaleCustomerId = 'customer_id';
  static const String columnSaleInvoiceNumber = 'invoice_number';
  static const String columnSaleCustomerName = 'customer_name';
  static const String columnSaleTotalAmount = 'total_amount';
  static const String columnSaleDiscountAmount = 'discount_amount';
  static const String columnSaleFinalAmount = 'final_amount';
  static const String columnSaleCashPaid = 'cash_paid';
  static const String columnSaleChangeAmount = 'change_amount';
  static const String columnSalePaymentMethod = 'payment_method';
  static const String columnSaleStatus = 'status';
  static const String columnSaleNotes = 'notes';
  static const String columnSaleDueDate = 'due_date';
  static const String columnSaleImagePath = 'image_path';

  static const String columnSaleItemSaleId = 'sale_id';
  static const String columnSaleItemProductId = 'product_id';
  static const String columnSaleItemUnitId = 'unit_id';
  static const String columnSaleItemUnitName = 'unit_name';
  static const String columnSaleItemQuantity = 'quantity';
  static const String columnSaleItemConversionFactor = 'conversion_factor';
  static const String columnSaleItemSellingPrice = 'selling_price';
  static const String columnSaleItemCostPrice = 'cost_price';
  static const String columnSaleItemSubtotal = 'subtotal';

  static const String stockMutations = 'stock_mutations';
  static const String columnMutationStoreId = 'store_id';
  static const String columnMutationProductId = 'product_id';
  static const String columnMutationType = 'type';
  static const String columnMutationQuantity = 'quantity';
  static const String columnMutationPreviousStock = 'previous_stock';
  static const String columnMutationCurrentStock = 'current_stock';
  static const String columnMutationReason = 'reason';
  static const String columnMutationReferenceId = 'reference_id';
  static const String columnMutationNotes = 'notes';

  static const String storeCapitals = 'store_capitals';
  static const String columnCapitalStoreId = 'store_id';
  static const String columnCapitalAmount = 'amount';
  static const String columnCapitalType = 'type';
  static const String columnCapitalDate = 'capital_date';
  static const String columnCapitalAccountId = 'account_id';
  static const String columnCapitalAccountName = 'account_name';
  static const String columnCapitalSource = 'source';
  static const String columnCapitalNotes = 'notes';

  static const String customerReceivablePayments = 'customer_receivable_payments';
  static const String columnPaymentCustomerId = 'customer_id';
  static const String columnPaymentCustomerName = 'customer_name';
  static const String columnPaymentStoreId = 'store_id';
  static const String columnPaymentAmount = 'amount';
  static const String columnPaymentDate = 'payment_date';
  static const String columnPaymentAccountId = 'account_id';
  static const String columnPaymentAccountName = 'account_name';
  static const String columnPaymentNotes = 'notes';
}
