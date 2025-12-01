// migue_admin/lib/domain/repositories/admin_products_repository.dart

import 'dart:io';
import 'package:migue_admin/domain/models/product.dart';

abstract class AdminProductsRepository {
  Future<List<Product>> getProducts();
  
  // Ahora aceptan List<File> para subir múltiples de una vez
  Future<Product> createProduct(Product product, List<File> newImages);
  
  Future<Product> updateProduct(Product product, List<File> newImages);
  
  Future<void> deleteProduct(int id);
}