class ApiConfig {
  // Base URLs for different platforms
  // Android Emulator maps 10.0.2.2 to localhost on host machine
  static const String _androidEmulatorBaseUrl = 'https://10.0.2.2:7293/api';
  // ignore: unused_field
  static const String _iosSimulatorBaseUrl = 'https://localhost:7293/api';
  // ignore: unused_field
  static const String _physicalDeviceBaseUrl =
      'https://192.168.1.100:7293/api'; // Update IP if on device

  // Default base URL
  static const String baseUrl = _androidEmulatorBaseUrl;

  // Endpoints
  static const String products = '/products';
  static const String productsByCategory = '/products/by-category';
  static const String productsBySubCategory = '/products/by-subcategory';
  static const String categories = '/categories';
  static const String subCategories = '/subcategories';
  static const String subCategoriesByCategory = '/subcategories/by-category';
  static const String offers = '/offers';
  static const String activeOffers = '/offers/active';
  static const String salesCreateOrder = '/sales/create-order';
  static const String salesOrder = '/sales/order';
  static const String salesSummary = '/sales/summary';
  static const String salesTopProducts = '/sales/top-products';
  static const String salesDaily = '/sales/daily';
  static const String salesOrders = '/sales/orders'; // New: Get all orders / Update order

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
