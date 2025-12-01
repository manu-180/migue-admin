// migue_admin/lib/domain/models/product.dart

class Product {
  final int? id;
  final String name;
  final String description;
  final double price;
  final List<String> images; // CAMBIO: Ahora es una lista
  final String category;
  final int stock;
  final int discount; // NUEVO CAMPO

  // Getter para compatibilidad (toma la primera imagen o vacío)
  String get mainImage => images.isNotEmpty ? images.first : '';

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.images,
    required this.category,
    required this.stock,
    this.discount = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Lógica para leer el array de imágenes de Postgres
    List<String> parsedImages = [];
    if (json['images'] != null) {
      parsedImages = List<String>.from(json['images']);
    } 
    // Fallback: si images está vacío pero image_url tiene algo (migración)
    if (parsedImages.isEmpty && json['image_url'] != null && json['image_url'] != '') {
      parsedImages.add(json['image_url'] as String);
    }

    return Product(
      id: json['id'],
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      images: parsedImages,
      category: json['category'] as String,
      stock: json['stock'] as int,
      discount: (json['discount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonMap = {
      'name': name,
      'description': description,
      'price': price,
      'images': images, // Enviamos la lista
      'image_url': mainImage, // Mantenemos compatibilidad hacia atrás
      'category': category,
      'stock': stock,
      'discount': discount,
    };
    
    if (id != null) {
      jsonMap['id'] = id;
    }
    return jsonMap;
  }
}