// migue_admin/lib/infrastructure/repositories/admin_products_repository_impl.dart

import 'dart:io';
import 'package:migue_admin/domain/models/product.dart';
import 'package:migue_admin/domain/repositories/admin_products_repository.dart';
import 'package:migue_admin/infrastructure/datasources/admin_products_datasource.dart';

class AdminProductsRepositoryImpl implements AdminProductsRepository {
  final AdminProductsDatasource datasource;

  AdminProductsRepositoryImpl({AdminProductsDatasource? datasource}) 
    : datasource = datasource ?? AdminProductsDatasource();

  @override
  Future<Product> createProduct(Product product, List<File> newImages) {
    return datasource.createProduct(product, newImages);
  }

  @override
  Future<void> deleteProduct(int id) {
    return datasource.deleteProduct(id);
  }

  @override
  Future<List<Product>> getProducts() {
    return datasource.getProducts();
  }

  @override
  Future<Product> updateProduct(Product product, List<File> newImages) {
    return datasource.updateProduct(product, newImages);
  }
}