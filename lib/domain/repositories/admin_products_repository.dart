// migue_admin/lib/domain/repositories/admin_products_repository.dart

import 'dart:io';
import 'package:migue_admin/domain/models/product.dart';

// Definición del Contrato del Repositorio de Administración
abstract class AdminProductsRepository {
  // R
  Future<List<Product>> getProducts();
  
  // C (File? para la imagen)
  Future<Product> createProduct(Product product, File? imageFile);
  
  // U (File? para la imagen que podría cambiar)
  Future<Product> updateProduct(Product product, File? newImageFile);
  
  // D (Necesita el ID y la URL de la imagen para eliminarla del storage)
  Future<void> deleteProduct(int id, String imageUrl);
}