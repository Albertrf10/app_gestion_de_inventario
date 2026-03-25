import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/producto.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _service = FirestoreService();
  final _db = FirebaseFirestore.instance;

  static const Map<String, String> _marcaFallback = {
    'Apple': 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-15.jpg',
    'Samsung': 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-s24.jpg',
    'Xiaomi': 'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-14.jpg',
    'Google': 'https://fdn2.gsmarena.com/vv/bigpic/google-pixel-8.jpg',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Productos'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Producto>>(
        stream: _service.getProductos(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error de conexión'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final productos = snapshot.data!;
          if (productos.isEmpty) {
            return const Center(child: Text('No hay productos.'));
          }

          final ordenados = [...productos];
          ordenados.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: ordenados.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final p = ordenados[i];

              return Card(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: (p.imagenUrl != null &&
                            p.imagenUrl!.isNotEmpty)
                            ? Image.network(
                          p.imagenUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _imagenPlaceholder(),
                        )
                            : _imagenPlaceholder(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.nombre,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            Text(p.marca),
                            Text(p.descripcion),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Text('\$${p.precio.toStringAsFixed(2)}'),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () =>
                                    _mostrarFormulario(context, producto: p),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () =>
                                    _confirmarEliminar(context, p.id),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(context),
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _imagenPlaceholder() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey.shade300,
      child: const Icon(Icons.image),
    );
  }

  // ================= FORMULARIO =================

  void _mostrarFormulario(BuildContext context, {Producto? producto}) {
    final esEdicion = producto != null;

    final nombreCtrl = TextEditingController(text: producto?.nombre ?? '');
    final descCtrl = TextEditingController(text: producto?.descripcion ?? '');
    final marcaCtrl = TextEditingController(text: producto?.marca ?? '');
    final stockCtrl =
    TextEditingController(text: producto?.stock.toString() ?? '');
    final precioCtrl =
    TextEditingController(text: producto?.precio.toString() ?? '');

    File? imagenSeleccionada;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(esEdicion ? 'Editar Producto' : 'Agregar Producto'),
          insetPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(
                          source: ImageSource.gallery, imageQuality: 75);

                      if (picked != null) {
                        setStateDialog(() {
                          imagenSeleccionada = File(picked.path);
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 140,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: imagenSeleccionada != null
                          ? Image.file(imagenSeleccionada!,
                          fit: BoxFit.cover)
                          : (producto?.imagenUrl != null &&
                          producto!.imagenUrl!.isNotEmpty)
                          ? Image.network(producto!.imagenUrl!,
                          fit: BoxFit.cover)
                          : const Center(child: Icon(Icons.image)),
                    ),
                  ),

                  const SizedBox(height: 10),

                  _input(nombreCtrl, 'Nombre'),
                  _input(descCtrl, 'Descripción'),
                  _input(marcaCtrl, 'Marca'),
                  _input(stockCtrl, 'Stock',
                      tipo: TextInputType.number),
                  _input(precioCtrl, 'Precio',
                      tipo: TextInputType.number),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                String? imagenUrl = producto?.imagenUrl;
                final id = producto?.id ??
                    _db.collection('products').doc().id;

                if (imagenSeleccionada != null) {
                  imagenUrl = await _service.subirImagen(
                      imagenSeleccionada!, id);
                }

                final p = Producto(
                  id: id,
                  nombre: nombreCtrl.text,
                  descripcion: descCtrl.text,
                  marca: marcaCtrl.text,
                  stock: int.tryParse(stockCtrl.text) ?? 0,
                  precio: double.tryParse(precioCtrl.text) ?? 0.0,
                  imagenUrl: imagenUrl,
                  createdAt: producto?.createdAt ?? DateTime.now(),
                );

                if (esEdicion) {
                  await _service.editarProducto(p);
                } else {
                  await _service.agregarProducto(p);
                }

                if (context.mounted) Navigator.pop(context);
              },
              child: Text(esEdicion ? 'Guardar' : 'Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(TextEditingController controller, String label,
      {TextInputType tipo = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: tipo,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar'),
        content: const Text('¿Seguro?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await _service.eliminarProducto(id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          )
        ],
      ),
    );
  }
}