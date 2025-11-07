// migue_admin/lib/presentation/screens/admin/admin_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migue_admin/domain/models/product.dart';
import 'package:migue_admin/presentation/providers/admin/admin_products_provider.dart';
import 'package:migue_admin/presentation/widgets/admin/product_form_modal.dart';
import 'package:intl/intl.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  // Formato para moneda local
  static final currencyFormatter = NumberFormat.currency(
    locale: 'es_AR',
    symbol: '\$',
    decimalDigits: 2,
  );

  // Muestra el formulario modal para CREAR o EDITAR
  void _showProductForm(BuildContext context, Product? product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Importante para que el teclado funcione bien
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (_) => ProductFormModal(productToEdit: product),
    );
  }
  
  // Confirma la eliminación de un producto
  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de que quieres eliminar el producto "${product.name}"? Esta acción es permanente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(adminProductsNotifierProvider.notifier).deleteProduct(
        product.id!,
        product.imageUrl, // Pasamos la URL para eliminar la imagen del storage
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(success ? 'Producto eliminado.' : 'Error al eliminar.')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(adminProductsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Catálogo', style: TextStyle(fontWeight: FontWeight.w300)),
        actions: [
          // Botón de Refrescar
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: productsState.isLoading 
              ? null 
              : ref.read(adminProductsNotifierProvider.notifier).refreshProducts,
          ),
          const SizedBox(width: 10),
        ],
      ),
      
      body: productsState.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (products) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Botón para crear un nuevo producto
              ElevatedButton.icon(
                onPressed: () => _showProductForm(context, null),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Añadir Nuevo Producto', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
              const SizedBox(height: 20),
              
              // Tabla de Productos
              SizedBox(
                width: double.infinity,
                child: PaginatedDataTable(
                  header: const Text('Productos en Catálogo'),
                  rowsPerPage: 10,
                  columns: const [
                    DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Precio', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                    DataColumn(label: Text('Stock', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                    DataColumn(label: Text('Categoría', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  source: ProductsDataSource(products, context, ref, _showProductForm, _confirmDelete),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Clase que maneja los datos y filas de la tabla
class ProductsDataSource extends DataTableSource {
  final List<Product> products;
  final BuildContext context;
  final WidgetRef ref;
  final Function(BuildContext, Product?) showForm;
  final Future<void> Function(BuildContext, WidgetRef, Product) confirmDelete;

  ProductsDataSource(this.products, this.context, this.ref, this.showForm, this.confirmDelete);

  @override
  DataRow? getRow(int index) {
    if (index >= products.length) return null;
    final product = products[index];

    return DataRow(
      cells: [
        DataCell(Text(product.id.toString())),
        DataCell(
          Row(
            children: [
              // Miniatura de la imagen (opcional)
              if (product.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.network(product.imageUrl, width: 40, height: 40, fit: BoxFit.cover)
                ),
              const SizedBox(width: 10),
              Expanded(child: Text(product.name)),
            ],
          ),
        ),
        DataCell(Text(AdminScreen.currencyFormatter.format(product.price))),
        DataCell(
          Center(
            child: Text(
              product.stock.toString(),
              style: TextStyle(color: product.stock > 0 ? Colors.green : Colors.red),
            )
          )
        ),
        DataCell(Text(product.category)),
        DataCell(
          Row(
            children: [
              // Botón de Edición
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => showForm(context, product),
                tooltip: 'Editar',
              ),
              // Botón de Eliminación
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => confirmDelete(context, ref, product),
                tooltip: 'Eliminar',
              ),
            ],
          )
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => products.length;

  @override
  int get selectedRowCount => 0;
}