// migue_admin/lib/infrastructure/datasources/admin_products_datasource.dart (CORREGIDO)

import 'dart:io';
import 'package:migue_admin/domain/models/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class AdminProductsDatasource {
  final SupabaseClient supabase;
  
  static const String _tableName = 'products'; 
  static const String _storageBucket = 'product_images'; // Nombre del bucket en Supabase

  AdminProductsDatasource() : 
    supabase = Supabase.instance.client; // Usa la instancia inicializada en main

  // -------------------------------------------------------------
  // OPERACIONES CRUD
  // -------------------------------------------------------------

  // C: Crear Producto
  Future<Product> createProduct(Product product, File? imageFile) async {
    // 1. Subir la imagen al Storage
    final String imageUrl = imageFile != null 
        ? await _uploadImage(imageFile, product.name) 
        : product.imageUrl; // Si no hay archivo nuevo, usamos la URL existente o default.

    final productToInsert = product.toJson();
    productToInsert['image_url'] = imageUrl;

    // 2. Insertar el registro en la base de datos
    final response = await supabase
        .from(_tableName)
        .insert(productToInsert)
        .select()
        .single(); // Devuelve el objeto insertado

    return Product.fromJson(response);
  }

  // R: Leer Productos (misma lógica que la web)
  Future<List<Product>> getProducts() async {
    final response = await supabase
        .from(_tableName)
        .select()
        .order('name', ascending: true);

    return (response as List).map((json) => Product.fromJson(json)).toList();
  }
  
  // U: Actualizar Producto
  Future<Product> updateProduct(Product product, File? newImageFile) async {
    String imageUrl = product.imageUrl;

    // 1. Si hay una nueva imagen, subirla y obtener la nueva URL
    if (newImageFile != null) {
      // Opcional: Eliminar la imagen antigua si es diferente a la URL por defecto
      // await _deleteImage(product.imageUrl); 
      imageUrl = await _uploadImage(newImageFile, product.name);
    }

    final productToUpdate = product.toJson();
    productToUpdate['image_url'] = imageUrl;
    
    // Asegúrate de que el ID no se incluya en el payload JSON para update si estás usando RLS estricto, 
    // pero lo necesitamos para el `eq` (where)
    final response = await supabase
        .from(_tableName)
        .update(productToUpdate) // El payload sin ID es más limpio
        
        // CORRECCIÓN: Usamos '!' para asegurar que 'id' no es nulo
        .eq('id', product.id!) 
        
        .select()
        .single();

    return Product.fromJson(response);
  }

  // D: Eliminar Producto
  Future<void> deleteProduct(int id, String imageUrl) async {
    // 1. Eliminar la imagen del Storage (opcional, dependiendo de si quieres conservar backups)
    // await _deleteImage(imageUrl);

    // 2. Eliminar el registro de la base de datos
    await supabase
        .from(_tableName)
        .delete()
        .eq('id', id);
  }

  // -------------------------------------------------------------
  // LÓGICA DE SUBIDA DE IMAGEN
  // -------------------------------------------------------------

  Future<String> _uploadImage(File imageFile, String productName) async {
    final fileName = '${productName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}${p.extension(imageFile.path)}';
    final storagePath = 'public/$fileName'; // La carpeta 'public' es accesible por la web

    try {
      await supabase.storage
          .from(_storageBucket)
          .upload(
            storagePath,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true, // Reemplazar si existe
            ),
          );

      // Obtener la URL pública para guardarla en la tabla 'products'
      final publicUrl = supabase.storage
          .from(_storageBucket)
          .getPublicUrl(storagePath);
          
      return publicUrl;
      
    } on StorageException catch (e) {
      throw Exception('Error de Storage de Supabase: ${e.message}');
    } catch (e) {
      throw Exception('Error al subir la imagen: $e');
    }
  }

  /* Lógica de Eliminación (no usada por defecto para no eliminar assets esenciales)
  Future<void> _deleteImage(String imageUrl) async {
    try {
      if (imageUrl.contains(_storageBucket)) {
        // Extraer el path del archivo desde la URL pública
        final uri = Uri.parse(imageUrl);
        final pathSegments = uri.pathSegments;
        // El path es todo lo que viene después del nombre del bucket
        final storagePath = pathSegments.sublist(pathSegments.indexOf(_storageBucket) + 1).join('/');

        // Supabase solo necesita el path relativo dentro del bucket
        await supabase.storage.from(_storageBucket).remove([storagePath]);
      }
    } catch (e) {
      // Ignoramos la excepción para que el producto se elimine de la DB incluso si falla el Storage.
      print('Advertencia: No se pudo eliminar la imagen del storage: $e');
    }
  }
  */
}