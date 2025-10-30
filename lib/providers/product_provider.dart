import 'package:flutter/foundation.dart';
import 'package:foodiehub/models/product.dart';
import 'package:foodiehub/utils/constants.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = List.from(sampleProducts);

  List<Product> get products => _products;

  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }

  void updateProduct(Product updatedProduct) {
    final index = _products.indexWhere((p) => p.id == updatedProduct.id);
    if (index >= 0) {
      _products[index] = updatedProduct;
      notifyListeners();
    }
  }

  void deleteProduct(int productId) {
    _products.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  Product? getProductById(int id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  int get nextProductId {
    if (_products.isEmpty) return 1;
    return _products.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
  }
}
