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
  
  // Controladores de Texto
  late TextEditingController nameCtrl;
  late TextEditingController descriptionCtrl;
  late TextEditingController priceCtrl;
  late TextEditingController stockCtrl;

  // Estado del formulario
  String _category = 'iphone'; // Valor por defecto
  File? _selectedImageFile;
  bool _isLoading = false;

  // Opciones de categoría
  static const List<String> categories = ['iphone', 'accessory', 'case'];


  @override
  void initState() {
    super.initState();
    final p = widget.productToEdit;
    
    // Inicializar controladores con valores existentes si estamos editando
    nameCtrl = TextEditingController(text: p?.name ?? '');
    descriptionCtrl = TextEditingController(text: p?.description ?? '');
    // Los números deben convertirse a String para el TextEditingController
    priceCtrl = TextEditingController(text: p?.price.toString() ?? '');
    stockCtrl = TextEditingController(text: p?.stock.toString() ?? '');
    _category = p?.category ?? categories.first;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descriptionCtrl.dispose();
    priceCtrl.dispose();
    stockCtrl.dispose();
    super.dispose();
  }
  
  // Lógica para seleccionar una imagen desde la computadora
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    // Usamos `pickImage` con source Gallery para abrir el selector de archivos
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImageFile = File(pickedFile.path);
      });
    }
  }
  
  // Lógica para enviar el formulario (Crear o Editar)
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Si estamos creando y no se selecciona una imagen
    if (widget.productToEdit == null && _selectedImageFile == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar una imagen para un nuevo producto.')),
      );
      return;
    }
    
    setState(() => _isLoading = true);

    final isEditing = widget.productToEdit != null;
    
    // Crear el objeto Product
    final product = Product(
      id: widget.productToEdit?.id,
      name: nameCtrl.text,
      description: descriptionCtrl.text,
      price: double.tryParse(priceCtrl.text) ?? 0.0,
      stock: int.tryParse(stockCtrl.text) ?? 0,
      imageUrl: widget.productToEdit?.imageUrl ?? '', // Se actualizará en el datasource si hay imagen
      category: _category,
    );

    final notifier = ref.read(adminProductsNotifierProvider.notifier);
    bool success = false;

    if (isEditing) {
      success = await notifier.updateProduct(product, _selectedImageFile);
    } else {
      success = await notifier.createProduct(product, _selectedImageFile);
    }

    setState(() => _isLoading = false);

    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${isEditing ? 'Actualizado' : 'Creado'} con éxito.')),
      );
      Navigator.of(context).pop(); // Cerrar modal al finalizar
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error en la operación. Revisar logs.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
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
                widget.productToEdit == null ? 'Añadir Nuevo Producto' : 'Editar Producto #${widget.productToEdit!.id}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Divider(),
              const SizedBox(height: 20),

              // Nombre
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre del Producto'),
                validator: (value) => value!.isEmpty ? 'Ingrese un nombre' : null,
              ),
              const SizedBox(height: 15),

              // Descripción
              TextFormField(
                controller: descriptionCtrl,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Ingrese una descripción' : null,
              ),
              const SizedBox(height: 15),

              // Precio y Stock
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: priceCtrl,
                      decoration: const InputDecoration(labelText: 'Precio (\$)', prefixText: '\$'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                      validator: (value) => (double.tryParse(value!) ?? 0.0) <= 0 ? 'Precio inválido' : null,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: TextFormField(
                      controller: stockCtrl,
                      decoration: const InputDecoration(labelText: 'Stock'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) => (int.tryParse(value!) ?? 0) < 0 ? 'Stock inválido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Categoría y Selector de Imagen
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoría
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      value: _category,
                      items: categories.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() => _category = newValue);
                        }
                      },
                      validator: (value) => value == null ? 'Seleccione categoría' : null,
                    ),
                  ),
                  const SizedBox(width: 20),
                  
                  // Selector de Imagen
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Imagen', style: TextStyle(fontSize: 12, color: Colors.white70)),
                        OutlinedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image),
                          label: Text(_selectedImageFile == null ? 'Seleccionar Imagen' : 'Imagen Seleccionada'),
                        ),
                        // Previsualización de la imagen
                        if (_selectedImageFile != null)
                          Image.file(_selectedImageFile!, height: 100)
                        else if (widget.productToEdit?.imageUrl != null && widget.productToEdit!.imageUrl.isNotEmpty)
                          Image.network(widget.productToEdit!.imageUrl, height: 100)
                        else
                          const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Botón de Envío
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          widget.productToEdit == null ? 'CREAR PRODUCTO' : 'GUARDAR CAMBIOS',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
}