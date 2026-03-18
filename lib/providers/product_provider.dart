import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/firebase_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;
  StreamSubscription<List<Product>>? _sub;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ProductProvider() {
    _listenToProducts();
  }

  void _listenToProducts() {
    _isLoading = true;
    _sub = FirebaseService.productsStream().listen(
      (list) {
        _products = list;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void refresh() {
    _sub?.cancel();
    _listenToProducts();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
