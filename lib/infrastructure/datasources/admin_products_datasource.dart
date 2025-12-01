// migue_admin/lib/infrastructure/datasources/admin_products_datasource.dart

import 'dart:io';
import 'package:migue_admin/domain/models/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class AdminProductsDatasource {
  final SupabaseClient supabase;
  
  static const String _tableName = 'products'; 
  static const String _storageBucket = 'product_images'; 

  AdminProductsDatasource() : 
    supabase = Supabase.instance.client;

  // C: Crear
  Future<Product> createProduct(Product product, List<File> newImages) async {
    // 1. Subir las imágenes nuevas
    List<String> uploadedUrls = [];
    if (newImages.isNotEmpty) {
      // Si la subida falla, la excepción se capturará abajo
      uploadedUrls = await _uploadImages(newImages, product.name); 
    }

    // Combinamos con las que ya traía el objeto
    final allImages = [...product.images, ...uploadedUrls];

    final productToInsert = product.toJson();
    productToInsert['images'] = allImages;
    productToInsert['image_url'] = allImages.isNotEmpty ? allImages.first : '';

    try {
      // 2. Insertar el registro en la base de datos
      final response = await supabase
          .from(_tableName)
          .insert(productToInsert)
          .select()
          .single(); 
      return Product.fromJson(response);
    } catch (e) {
      print('--- ERROR (Datasource - DB Insert): $e'); // PRINT AGREGADO
      rethrow; // Relanza la excepción para que el Notifier la capture
    }
  }

  // R: Leer
  Future<List<Product>> getProducts() async {
    try {
      final response = await supabase
          .from(_tableName)
          .select()
          .order('id', ascending: false); 
      return (response as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      print('--- ERROR (Datasource - DB Read): $e');
      rethrow;
    }
  }
  
  // U: Actualizar
  Future<Product> updateProduct(Product product, List<File> newImages) async {
    List<String> uploadedUrls = [];
    if (newImages.isNotEmpty) {
      uploadedUrls = await _uploadImages(newImages, product.name);
    }

    final finalImages = [...product.images, ...uploadedUrls];

    final productToUpdate = product.toJson();
    productToUpdate['images'] = finalImages;
    productToUpdate['image_url'] = finalImages.isNotEmpty ? finalImages.first : '';
    
    productToUpdate.remove('id'); 

    try {
      final response = await supabase
          .from(_tableName)
          .update(productToUpdate)
          .eq('id', product.id!) 
          .select()
          .single();
      return Product.fromJson(response);
    } catch (e) {
      print('--- ERROR (Datasource - DB Update): $e'); // PRINT AGREGADO
      rethrow;
    }
  }

  // D: Eliminar
  Future<void> deleteProduct(int id) async {
    try {
      await supabase
          .from(_tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      print('--- ERROR (Datasource - DB Delete): $e');
      rethrow;
    }
  }

  // --- SUBIDA MÚLTIPLE ---
  Future<List<String>> _uploadImages(List<File> images, String productName) async {
    List<String> urls = [];
    
    for (var imageFile in images) {
      final fileName = '${productName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}_${images.indexOf(imageFile)}${p.extension(imageFile.path)}';
      final storagePath = 'public/$fileName';

      try {
        await supabase.storage.from(_storageBucket).upload(
          storagePath,
          imageFile,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );

        final publicUrl = supabase.storage.from(_storageBucket).getPublicUrl(storagePath);
        urls.add(publicUrl);
        
      } on StorageException catch (e) {
        print('--- ERROR (Datasource - Storage): Error de Supabase Storage: ${e.message}'); // PRINT CRÍTICO
        // Relanzar la excepción específica para verla en la consola
        throw Exception('Error al subir imagen al Storage: ${e.message}');
      } catch (e) {
        print('--- ERROR (Datasource - Subida General): Error desconocido: $e');
        throw Exception('Error al subir la imagen: $e');
      }
    }
    return urls;
  }
}