// migue_admin/lib/presentation/providers/admin/admin_products_provider.dart

import 'dart:io';
import 'package:migue_admin/domain/models/product.dart';
import 'package:migue_admin/domain/repositories/admin_products_repository.dart';
import 'package:migue_admin/infrastructure/repositories/admin_products_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'admin_products_provider.g.dart';

// 1. Proveedor del Repositorio
@Riverpod(keepAlive: true)
AdminProductsRepository adminProductsRepository(AdminProductsRepositoryRef ref) {
  return AdminProductsRepositoryImpl();
}

// 2. Notifier para la gestión de productos (CRUD)
@riverpod
class AdminProductsNotifier extends _$AdminProductsNotifier {
  // Estado inicial: carga los productos al inicio.
  @override
  FutureOr<List<Product>> build() {
    return _loadProducts();
  }

  // Carga inicial y refresco
  Future<List<Product>> _loadProducts() async {
    final repository = ref.read(adminProductsRepositoryProvider);
    return repository.getProducts();
  }
  
  // -------------------------------------------------------------
  // OPERACIONES CRUD
  // -------------------------------------------------------------

  // C: Crear Producto
  Future<bool> createProduct(Product product, File? imageFile) async {
    try {
      final repository = ref.read(adminProductsRepositoryProvider);
      // La creación devuelve el producto con el ID generado por la DB
      final newProduct = await repository.createProduct(product, imageFile);
      
      // Actualizar el estado (añadir el nuevo producto a la lista local)
      state = AsyncData([...state.value ?? [], newProduct]);
      return true;
      
    } catch (e) {
      // Manejar el error y mantener el estado actual
      print('Error al crear producto: $e');
      return false;
    }
  }

  // U: Actualizar Producto
  Future<bool> updateProduct(Product product, File? newImageFile) async {
    try {
      if (product.id == null) return false; // El ID es obligatorio para actualizar

      final repository = ref.read(adminProductsRepositoryProvider);
      final updatedProduct = await repository.updateProduct(product, newImageFile);
      
      // Actualizar el estado (reemplazar el producto en la lista local)
      state = AsyncData(
        state.value!.map((p) => p.id == updatedProduct.id ? updatedProduct : p).toList(),
      );
      return true;
      
    } catch (e) {
      print('Error al actualizar producto: $e');
      return false;
    }
  }

  // D: Eliminar Producto
  Future<bool> deleteProduct(int id, String imageUrl) async {
    try {
      final repository = ref.read(adminProductsRepositoryProvider);
      await repository.deleteProduct(id, imageUrl);
      
      // Actualizar el estado (filtrar el producto eliminado de la lista local)
      state = AsyncData(
        state.value!.where((p) => p.id != id).toList(),
      );
      return true;
      
    } catch (e) {
      print('Error al eliminar producto: $e');
      return false;
    }
  }

  // Refrescar la lista de productos (útil después de una operación o error)
  void refreshProducts() {
    state = const AsyncValue.loading();
    ref.invalidateSelf(); // Vuelve a ejecutar el método build()
  }
}