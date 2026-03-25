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
    'Apple':     'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-15.jpg',
    'Samsung':   'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-s24.jpg',
    'Xiaomi':    'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-14.jpg',
    'Google':    'https://fdn2.gsmarena.com/vv/bigpic/google-pixel-8.jpg',
    'Motorola':  'https://fdn2.gsmarena.com/vv/bigpic/motorola-edge-50-fusion.jpg',
    'Realme':    'https://fdn2.gsmarena.com/vv/bigpic/realme-12-pro-plus.jpg',
    'OnePlus':   'https://fdn2.gsmarena.com/vv/bigpic/oneplus-12.jpg',
    'Sony':      'https://fdn2.gsmarena.com/vv/bigpic/sony-xperia-1-vi.jpg',
    'Oppo':      'https://fdn2.gsmarena.com/vv/bigpic/oppo-reno12-pro.jpg',
    'Nothing':   'https://fdn2.gsmarena.com/vv/bigpic/nothing-phone-2.jpg',
    'Huawei':    'https://fdn2.gsmarena.com/vv/bigpic/huawei-mate-60-pro.jpg',
    'Honor':     'https://fdn2.gsmarena.com/vv/bigpic/honor-magic6-pro.jpg',
    'Asus':      'https://fdn2.gsmarena.com/vv/bigpic/asus-zenfone-11-ultra.jpg',
    'Nokia':     'https://fdn2.gsmarena.com/vv/bigpic/nokia-g42.jpg',
    'ZTE':       'https://fdn2.gsmarena.com/vv/bigpic/zte-axon-50-ultra.jpg',
    'Vivo':      'https://fdn2.gsmarena.com/vv/bigpic/vivo-x100-pro.jpg',
    'TCL':       'https://fdn2.gsmarena.com/vv/bigpic/tcl-50-pro.jpg',
    'Nubia':     'https://fdn2.gsmarena.com/vv/bigpic/nubia-redmagic-9-pro.jpg',
    'Fairphone': 'https://fdn2.gsmarena.com/vv/bigpic/fairphone-5.jpg',
    'Blackview': 'https://fdn2.gsmarena.com/vv/bigpic/blackview-bv9900-pro.jpg',
    'Ulefone':   'https://fdn2.gsmarena.com/vv/bigpic/ulefone-armor-25t-pro.jpg',
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
          if (snapshot.hasError) return const Center(child: Text('Error de conexión'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final productos = snapshot.data!;
          if (productos.isEmpty) return const Center(child: Text('No hay productos.'));

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: productos.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final p = productos[i];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      // Imagen del producto
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: p.imagenUrl != null
                            ? Image.network(
                                p.imagenUrl!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) {
                                  final fallback = _marcaFallback[p.marca];
                                  if (fallback != null) {
                                    return Image.network(
                                      fallback,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _imagenPlaceholder(),
                                    );
                                  }
                                  return _imagenPlaceholder();
                                },
                              )
                            : _imagenPlaceholder(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(p.marca, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            const SizedBox(height: 4),
                            Text(p.descripcion, style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\$${p.precio.toStringAsFixed(2)}',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blue.shade700)),
                          const SizedBox(height: 6),
                          _celdaStock(p.stock),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              InkWell(
                                onTap: () => _mostrarFormulario(context, producto: p),
                                child: const Icon(Icons.edit, color: Colors.blue, size: 20),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => _confirmarEliminar(context, p.id),
                                child: const Icon(Icons.delete, color: Colors.red, size: 20),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormulario(context),
        backgroundColor: Colors.blue.shade700,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Agregar', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _imagenPlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.image, color: Colors.grey.shade400, size: 30),
    );
  }

  Widget _celdaStock(int stock) {
    final color = stock == 0 ? Colors.red : stock < 5 ? Colors.orange : Colors.green;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Text(
          '$stock',
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _mostrarFormulario(BuildContext context, {Producto? producto}) {
    final esEdicion = producto != null;
    final nombreCtrl = TextEditingController(text: producto?.nombre ?? '');
    final descCtrl = TextEditingController(text: producto?.descripcion ?? '');
    final marcaCtrl = TextEditingController(text: producto?.marca ?? '');
    final stockCtrl = TextEditingController(text: producto?.stock.toString() ?? '');
    final precioCtrl = TextEditingController(text: producto?.precio.toString() ?? '');
    File? imagenSeleccionada;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(esEdicion ? 'Editar Producto' : 'Agregar Producto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Selector de imagen
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
                    if (picked != null) {
                      setStateDialog(() => imagenSeleccionada = File(picked.path));
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: imagenSeleccionada != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(imagenSeleccionada!, fit: BoxFit.cover),
                          )
                        : producto?.imagenUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(producto!.imagenUrl!, fit: BoxFit.cover),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey.shade400),
                                  const SizedBox(height: 6),
                                  Text('Añadir imagen', style: TextStyle(color: Colors.grey.shade500)),
                                ],
                              ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción')),
                TextField(controller: marcaCtrl, decoration: const InputDecoration(labelText: 'Marca')),
                TextField(controller: stockCtrl, decoration: const InputDecoration(labelText: 'Stock'), keyboardType: TextInputType.number),
                TextField(controller: precioCtrl, decoration: const InputDecoration(labelText: 'Precio'), keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                String? imagenUrl = producto?.imagenUrl;
                final id = producto?.id ?? _db.collection('products').doc().id;

                if (imagenSeleccionada != null) {
                  imagenUrl = await _service.subirImagen(imagenSeleccionada!, id);
                }

                final p = Producto(
                  id: id,
                  nombre: nombreCtrl.text,
                  descripcion: descCtrl.text,
                  marca: marcaCtrl.text,
                  stock: int.tryParse(stockCtrl.text) ?? 0,
                  precio: double.tryParse(precioCtrl.text) ?? 0.0,
                  imagenUrl: imagenUrl,
                );
                esEdicion ? await _service.editarProducto(p) : await _service.agregarProducto(p);
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(esEdicion ? 'Guardar' : 'Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: const Text('¿Estás seguro de que quieres eliminar este producto?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _service.eliminarProducto(id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}