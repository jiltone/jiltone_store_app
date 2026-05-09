import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ────────────────────────────
  //  PRODUCTS (Firestore)
  // ────────────────────────────

  /// Real-time stream of all products ordered by creation date
  static Stream<List<Product>> productsStream() {
    return _db
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Product.fromMap(d.id, d.data())).toList());
  }

  /// Add a new product document to Firestore
  static Future<String> addProduct(Product product) async {
    final ref = await _db.collection('products').add(product.toMap());
    return ref.id;
  }

  /// Update an existing product document in Firestore
  static Future<void> updateProduct(Product product) async {
    await _db.collection('products').doc(product.id).update(product.toMap());
  }

  /// Delete a product document from Firestore
  static Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }
}
