// migue_admin/lib/presentation/providers/admin/admin_products_notifier.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migue_admin/domain/models/product.dart';
import 'package:migue_admin/domain/repositories/admin_products_repository.dart';
import 'package:migue_admin/infrastructure/repositories/admin_products_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'admin_products_provider.g.dart';

@Riverpod(keepAlive: true)
AdminProductsRepository adminProductsRepository(AdminProductsRepositoryRef ref) {
  return AdminProductsRepositoryImpl();
}

@riverpod
class AdminProductsNotifier extends _$AdminProductsNotifier {
  @override
  FutureOr<List<Product>> build() {
    return _loadProducts();
  }

  Future<List<Product>> _loadProducts() async {
    final repository = ref.read(adminProductsRepositoryProvider);
    return repository.getProducts();
  }
  
  // Create
  Future<bool> createProduct(Product product, List<File> newImages) async {
    try {
      final repository = ref.read(adminProductsRepositoryProvider);
      final newProduct = await repository.createProduct(product, newImages);
      state = AsyncData([newProduct, ...state.value ?? []]); 
      return true;
    } catch (e) {
      print('>>> ERROR CRÍTICO (Notifier - Create): Falló al crear el producto. $e'); // PRINT AGREGADO
      return false;
    }
  }

  // Update
  Future<bool> updateProduct(Product product, List<File> newImages) async {
    try {
      if (product.id == null) return false;
      final repository = ref.read(adminProductsRepositoryProvider);
      final updatedProduct = await repository.updateProduct(product, newImages);
      
      state = AsyncData(
        state.value!.map((p) => p.id == updatedProduct.id ? updatedProduct : p).toList(),
      );
      return true;
    } catch (e) {
      print('>>> ERROR CRÍTICO (Notifier - Update): Falló al actualizar el producto. $e'); // PRINT AGREGADO
      return false;
    }
  }

  // Delete
  Future<bool> deleteProduct(int id) async {
    try {
      final repository = ref.read(adminProductsRepositoryProvider);
      await repository.deleteProduct(id);
      
      state = AsyncData(state.value!.where((p) => p.id != id).toList());
      return true;
    } catch (e) {
      print('>>> ERROR CRÍTICO (Notifier - Delete): Falló al eliminar. $e'); // PRINT AGREGADO
      return false;
    }
  }

  void refreshProducts() {
    state = const AsyncValue.loading();
    ref.invalidateSelf();
  }
}