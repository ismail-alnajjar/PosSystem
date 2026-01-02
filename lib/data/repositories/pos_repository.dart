import '../models/category_model.dart';
import '../models/subcategory_model.dart';
import '../models/product_model.dart';
import '../models/offer_model.dart';
import '../models/order_model.dart';
import '../models/sales_model.dart';
import '../services/api_service.dart';

class PosRepository {
  final ApiService _apiService;

  PosRepository({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();

  // ==================== Categories ====================

  Future<List<Category>> getCategories() async {
    try {
      return await _apiService.getCategories();
    } catch (e) {
      throw Exception('فشل في جلب الفئات: ${e.toString()}');
    }
  }

  Future<Category> getCategoryById(int id) async {
    try {
      return await _apiService.getCategoryById(id);
    } catch (e) {
      throw Exception('فشل في جلب الفئة: ${e.toString()}');
    }
  }

  // ==================== SubCategories ====================

  Future<List<SubCategory>> getSubCategories() async {
    try {
      return await _apiService.getSubCategories();
    } catch (e) {
      throw Exception('فشل في جلب الفئات الفرعية: ${e.toString()}');
    }
  }

  Future<List<SubCategory>> getSubCategoriesByCategory(int categoryId) async {
    try {
      return await _apiService.getSubCategoriesByCategory(categoryId);
    } catch (e) {
      throw Exception('فشل في جلب الفئات الفرعية: ${e.toString()}');
    }
  }

  Future<SubCategory> getSubCategoryById(int id) async {
    try {
      return await _apiService.getSubCategoryById(id);
    } catch (e) {
      throw Exception('فشل في جلب الفئة الفرعية: ${e.toString()}');
    }
  }

  // ==================== Products ====================

  Future<List<Product>> getProducts() async {
    try {
      return await _apiService.getProducts();
    } catch (e) {
      throw Exception('فشل في جلب المنتجات: ${e.toString()}');
    }
  }

  Future<Product> getProductById(int id) async {
    try {
      return await _apiService.getProductById(id);
    } catch (e) {
      throw Exception('فشل في جلب المنتج: ${e.toString()}');
    }
  }

  Future<List<Product>> getProductsByCategory(int categoryId) async {
    try {
      return await _apiService.getProductsByCategory(categoryId);
    } catch (e) {
      throw Exception('فشل في جلب المنتجات: ${e.toString()}');
    }
  }

  Future<List<Product>> getProductsBySubCategory(int subCategoryId) async {
    try {
      return await _apiService.getProductsBySubCategory(subCategoryId);
    } catch (e) {
      throw Exception('فشل في جلب المنتجات: ${e.toString()}');
    }
  }

  // ==================== Offers ====================

  Future<List<Offer>> getOffers() async {
    try {
      return await _apiService.getOffers();
    } catch (e) {
      throw Exception('فشل في جلب العروض: ${e.toString()}');
    }
  }

  Future<List<Offer>> getActiveOffers() async {
    try {
      return await _apiService.getActiveOffers();
    } catch (e) {
      throw Exception('فشل في جلب العروض النشطة: ${e.toString()}');
    }
  }

  Future<Offer> getOfferById(int id) async {
    try {
      return await _apiService.getOfferById(id);
    } catch (e) {
      throw Exception('فشل في جلب العرض: ${e.toString()}');
    }
  }

  // ==================== Sales ====================

  Future<Order> createOrder(CreateOrderRequest request) async {
    try {
      return await _apiService.createOrder(request);
    } catch (e) {
      throw Exception('فشل في إنشاء الطلب: ${e.toString()}');
    }
  }

  Future<Order> getOrderById(int id) async {
    try {
      return await _apiService.getOrderById(id);
    } catch (e) {
      throw Exception('فشل في جلب الطلب: ${e.toString()}');
    }
  }

  Future<List<Order>> getAllOrders() async {
    try {
      return await _apiService.getAllOrders();
    } catch (e) {
      throw Exception('فشل في جلب سجل الطلبات: ${e.toString()}');
    }
  }

  Future<void> updateOrder(int id, CreateOrderRequest request) async {
    try {
      await _apiService.updateOrder(id, request);
    } catch (e) {
      throw Exception('فشل في تحديث الطلب: ${e.toString()}');
    }
  }

  Future<SalesSummary> getSalesSummary({
    required DateTime startDate,
    required DateTime endDate,
    int? categoryId,
  }) async {
    try {
      return await _apiService.getSalesSummary(
        startDate: startDate,
        endDate: endDate,
        categoryId: categoryId,
      );
    } catch (e) {
      throw Exception('فشل في جلب ملخص المبيعات: ${e.toString()}');
    }
  }

  Future<List<TopProduct>> getTopProducts({
    int limit = 10,
    int? categoryId,
  }) async {
    try {
      return await _apiService.getTopProducts(
        limit: limit,
        categoryId: categoryId,
      );
    } catch (e) {
      throw Exception('فشل في جلب أكثر المنتجات مبيعاً: ${e.toString()}');
    }
  }

  Future<List<DailySales>> getDailySales({int days = 7}) async {
    try {
      return await _apiService.getDailySales(days: days);
    } catch (e) {
      throw Exception('فشل في جلب المبيعات اليومية: ${e.toString()}');
    }
  }
}

