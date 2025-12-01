// migue_admin/lib/presentation/widgets/admin/product_form_modal.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:migue_admin/domain/models/product.dart';
import 'package:migue_admin/presentation/providers/admin/admin_products_provider.dart';

class ProductFormModal extends ConsumerStatefulWidget {
  final Product? productToEdit;

  const ProductFormModal({super.key, this.productToEdit});

  @override
  ConsumerState<ProductFormModal> createState() => _ProductFormModalState();
}

class _ProductFormModalState extends ConsumerState<ProductFormModal> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController nameCtrl;
  late TextEditingController descriptionCtrl;
  late TextEditingController priceCtrl;
  late TextEditingController stockCtrl;
  late TextEditingController discountCtrl;

  String _category = 'iPhones'; 
  bool _isLoading = false;

  List<String> _existingImageUrls = [];
  List<File> _newImageFiles = [];

  // 1. CONTROLADOR DE SCROLL PARA LA GALERÍA
  final ScrollController _galleryScrollController = ScrollController();

  static const Map<String, String> categoryOptions = {
    'iPhones': 'iPhones',
    'Accesorios': 'Accesorios',
    'Fundas': 'Fundas',
  };

  @override
  void initState() {
    super.initState();
    final p = widget.productToEdit;
    
    nameCtrl = TextEditingController(text: p?.name ?? '');
    descriptionCtrl = TextEditingController(text: p?.description ?? '');
    priceCtrl = TextEditingController(text: p?.price.toString() ?? '');
    stockCtrl = TextEditingController(text: p?.stock.toString() ?? '');
    discountCtrl = TextEditingController(text: p?.discount.toString() ?? '0');
    
    _category = (p?.category != null && categoryOptions.containsKey(p!.category)) 
        ? p.category 
        : 'iPhones';
    
    if (p != null) {
      _existingImageUrls = List.from(p.images);
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descriptionCtrl.dispose();
    priceCtrl.dispose();
    stockCtrl.dispose();
    discountCtrl.dispose();
    _galleryScrollController.dispose(); 
    super.dispose();
  }
  
  // Lógica para el scroll lateral
  void _scrollHorizontal(double delta) {
    if (_galleryScrollController.hasClients) {
      _galleryScrollController.animateTo(
        _galleryScrollController.offset + delta,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _scrollLeft() => _scrollHorizontal(-110.0); // Desliza hacia atrás (ancho de 1 imagen + espaciado)
  void _scrollRight() => _scrollHorizontal(110.0); // Desliza hacia adelante

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_galleryScrollController.hasClients) {
        _galleryScrollController.animateTo(
          _galleryScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _newImageFiles.addAll(pickedFiles.map((x) => File(x.path)));
      });
      _scrollToEnd(); 
    }
  }

  void _removeExistingImage(String url) {
    setState(() {
      _existingImageUrls.remove(url);
    });
  }

  void _removeNewImage(File file) {
    setState(() {
      _newImageFiles.remove(file);
    });
  }
  
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_existingImageUrls.isEmpty && _newImageFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe haber al menos una imagen del producto.')),
      );
      return;
    }
    
    setState(() => _isLoading = true);

    final isEditing = widget.productToEdit != null;
    
    final product = Product(
      id: widget.productToEdit?.id,
      name: nameCtrl.text,
      description: descriptionCtrl.text,
      price: double.tryParse(priceCtrl.text) ?? 0.0,
      stock: int.tryParse(stockCtrl.text) ?? 0,
      discount: int.tryParse(discountCtrl.text) ?? 0,
      images: _existingImageUrls,
      category: _category,
    );

    final notifier = ref.read(adminProductsNotifierProvider.notifier);
    bool success = false;

    if (isEditing) {
      success = await notifier.updateProduct(product, _newImageFiles);
    } else {
      success = await notifier.createProduct(product, _newImageFiles);
    }

    setState(() => _isLoading = false);

    if (!mounted) return;
    
    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${isEditing ? 'Actualizado' : 'Creado'} con éxito.')),
      );
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error en la operación.')),
      );
    }
  }

  // Widget helper para el botón de scroll
  Widget _buildScrollButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white10,
        padding: EdgeInsets.zero,
        minimumSize: const Size(30, 30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 30,
          right: 30,
          top: 30,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.productToEdit == null ? 'Añadir Nuevo Producto' : 'Editar Producto',
                style: theme.textTheme.headlineSmall,
              ),
              const Divider(),
              const SizedBox(height: 20),

              // 1. Nombre y Categoría
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre del Producto', border: OutlineInputBorder()),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
                      value: categoryOptions.containsKey(_category) ? _category : 'iPhones',
                      items: categoryOptions.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key, 
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) setState(() => _category = newValue);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // 2. Descripción
              TextFormField(
                controller: descriptionCtrl,
                decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),

              // 3. Precios y Stock
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: priceCtrl,
                      decoration: const InputDecoration(labelText: 'Precio', prefixText: '\$ ', border: OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                      validator: (v) => (double.tryParse(v!) ?? 0) <= 0 ? 'Inválido' : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      controller: discountCtrl,
                      decoration: const InputDecoration(labelText: 'Descuento %', suffixText: '%', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      controller: stockCtrl,
                      decoration: const InputDecoration(labelText: 'Stock', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // 4. GALERÍA DE IMÁGENES (Contenedor con Controles de Scroll)
              Text('Galería de Imágenes', style: theme.textTheme.titleMedium),
              const SizedBox(height: 10),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // FLECHA IZQUIERDA
                  _buildScrollButton(Icons.arrow_back_ios_new_rounded, _scrollLeft),
                  
                  // CONTENEDOR DE LA LISTA (Expandido)
                  Expanded(
                    child: Container(
                      height: 120,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.black12,
                      ),
                      child: ListView(
                        controller: _galleryScrollController,
                        scrollDirection: Axis.horizontal,
                        children: [
                          // Botón para agregar
                          AspectRatio(
                            aspectRatio: 1,
                            child: InkWell(
                              onTap: _pickImages,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: theme.colorScheme.primary, width: 1, style: BorderStyle.solid),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate, color: theme.colorScheme.primary),
                                    const Text('Agregar', style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Imágenes Existentes (Red)
                          ..._existingImageUrls.map((url) => _buildImageItem(
                            imageProvider: NetworkImage(url),
                            onRemove: () => _removeExistingImage(url),
                          )),

                          // Imágenes Nuevas (File)
                          ..._newImageFiles.map((file) => _buildImageItem(
                            imageProvider: FileImage(file),
                            onRemove: () => _removeNewImage(file),
                            isNew: true,
                          )),
                        ],
                      ),
                    ),
                  ),
                  
                  // FLECHA DERECHA
                  _buildScrollButton(Icons.arrow_forward_ios_rounded, _scrollRight),
                ],
              ),
              
              const SizedBox(height: 30),

              // Botón Guardar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                      : Text(
                          widget.productToEdit == null ? 'CREAR PRODUCTO' : 'GUARDAR CAMBIOS',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper para mostrar cada miniatura
  Widget _buildImageItem({required ImageProvider imageProvider, required VoidCallback onRemove, bool isNew = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: isNew ? Border.all(color: Colors.green, width: 2) : null,
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: InkWell(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
          if (isNew)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.green.withOpacity(0.8),
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: const Text('NUEVA', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            )
        ],
      ),
    );
  }
}