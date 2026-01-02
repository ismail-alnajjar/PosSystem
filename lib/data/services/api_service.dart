import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/subcategory_model.dart';
import '../models/offer_model.dart';
import '../models/order_model.dart';
import '../models/sales_model.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // Helper method for GET requests
  Future<dynamic> _get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final uriWithParams = queryParams != null 
          ? uri.replace(queryParameters: queryParams) 
          : uri;

      print('🌐 Trying to GET: $uriWithParams'); // Debug Log

      final response = await _client
          .get(uriWithParams)
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('فشل الاتصال بالخادم: ${e.toString()}');
    }
  }

  // Helper method for POST requests
  Future<dynamic> _post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('فشل الاتصال بالخادم: ${e.toString()}');
    }
  }

  // Handle HTTP responses
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw ApiException('المورد غير موجود', response.statusCode);
    } else if (response.statusCode == 500) {
      throw ApiException('خطأ في الخادم', response.statusCode);
    } else {
      throw ApiException(
        'خطأ في الطلب: ${response.statusCode}',
        response.statusCode,
      );
    }
  }

  // ==================== Products ====================

  /// Get all products
  Future<List<Product>> getProducts() async {
    final data = await _get(ApiConfig.products);
    return (data as List).map((json) => Product.fromJson(json)).toList();
  }

  /// Get product by ID
  Future<Product> getProductById(int id) async {
    final data = await _get('${ApiConfig.products}/$id');
    return Product.fromJson(data);
  }

  /// Get products by category
  Future<List<Product>> getProductsByCategory(int categoryId) async {
    final data = await _get('${ApiConfig.productsByCategory}/$categoryId');
    return (data as List).map((json) => Product.fromJson(json)).toList();
  }

  /// Get products by subcategory
  Future<List<Product>> getProductsBySubCategory(int subCategoryId) async {
    final data = await _get('${ApiConfig.productsBySubCategory}/$subCategoryId');
    return (data as List).map((json) => Product.fromJson(json)).toList();
  }

  // ==================== Categories ====================

  /// Get all categories
  Future<List<Category>> getCategories() async {
    final data = await _get(ApiConfig.categories);
    return (data as List).map((json) => Category.fromJson(json)).toList();
  }

  /// Get category by ID
  Future<Category> getCategoryById(int id) async {
    final data = await _get('${ApiConfig.categories}/$id');
    return Category.fromJson(data);
  }

  // ==================== SubCategories ====================

  /// Get all subcategories
  Future<List<SubCategory>> getSubCategories() async {
    final data = await _get(ApiConfig.subCategories);
    return (data as List).map((json) => SubCategory.fromJson(json)).toList();
  }

  /// Get subcategories by category
  Future<List<SubCategory>> getSubCategoriesByCategory(int categoryId) async {
    final data = await _get('${ApiConfig.subCategoriesByCategory}/$categoryId');
    return (data as List).map((json) => SubCategory.fromJson(json)).toList();
  }

  /// Get subcategory by ID
  Future<SubCategory> getSubCategoryById(int id) async {
    final data = await _get('${ApiConfig.subCategories}/$id');
    return SubCategory.fromJson(data);
  }

  // ==================== Offers ====================

  /// Get all offers
  Future<List<Offer>> getOffers() async {
    final data = await _get(ApiConfig.offers);
    return (data as List).map((json) => Offer.fromJson(json)).toList();
  }

  /// Get active offers only
  Future<List<Offer>> getActiveOffers() async {
    final data = await _get(ApiConfig.activeOffers);
    return (data as List).map((json) => Offer.fromJson(json)).toList();
  }

  /// Get offer by ID
  Future<Offer> getOfferById(int id) async {
    final data = await _get('${ApiConfig.offers}/$id');
    return Offer.fromJson(data);
  }

  // ==================== Sales ====================

  /// Create a new order
  Future<Order> createOrder(CreateOrderRequest request) async {
    final data = await _post(ApiConfig.salesCreateOrder, body: request.toJson());
    return Order.fromJson(data);
  }

  /// Get all orders (recent first)
  Future<List<Order>> getAllOrders() async {
    final data = await _get(ApiConfig.salesOrders);
    return (data as List).map((json) => Order.fromJson(json)).toList();
  }

  /// Update an existing order
  // Note: This assumes the backend supports PUT /sales/orders/{id}
  Future<void> updateOrder(int id, CreateOrderRequest request) async {
    // Determine the update endpoint. Some APIs use PUT /sales/orders/{id}, others might use a specific action.
    // Assuming standard RESTful convention here based on typical ASP.NET Core patterns.
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.salesOrders}/$id');
    
    try {
      final response = await _client.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      ).timeout(ApiConfig.connectionTimeout);

      _handleResponse(response);
    } catch (e) {
      throw ApiException('فشل تحديث الطلب: ${e.toString()}');
    }
  }

  /// Get order by ID
  Future<Order> getOrderById(int id) async {
    final data = await _get('${ApiConfig.salesOrder}/$id');
    return Order.fromJson(data);
  }

  /// Get sales summary
  /// [startDate] and [endDate] should be in ISO 8601 format
  /// [categoryId] is optional
  Future<SalesSummary> getSalesSummary({
    required DateTime startDate,
    required DateTime endDate,
    int? categoryId,
  }) async {
    final queryParams = {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      if (categoryId != null) 'categoryId': categoryId.toString(),
    };

    final data = await _get(ApiConfig.salesSummary, queryParams: queryParams);
    return SalesSummary.fromJson(data);
  }

  /// Get top selling products
  /// [limit] defaults to 10
  /// [categoryId] is optional
  Future<List<TopProduct>> getTopProducts({
    int limit = 10,
    int? categoryId,
  }) async {
    final queryParams = {
      'limit': limit.toString(),
      if (categoryId != null) 'categoryId': categoryId.toString(),
    };

    final data = await _get(ApiConfig.salesTopProducts, queryParams: queryParams);
    return (data as List).map((json) => TopProduct.fromJson(json)).toList();
  }

  /// Get daily sales
  /// [days] defaults to 7
  Future<List<DailySales>> getDailySales({int days = 7}) async {
    final queryParams = {'days': days.toString()};
    final data = await _get(ApiConfig.salesDaily, queryParams: queryParams);
    return (data as List).map((json) => DailySales.fromJson(json)).toList();
  }
}
