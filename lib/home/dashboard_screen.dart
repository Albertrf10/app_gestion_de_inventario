import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/product.dart';
import '../screens/busqueda/busqueda_screen.dart';
import 'package:flutter/foundation.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _service = FirestoreService();

  static const Map<String, String> _marcaFallback = {
    'Apple': 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-15.jpg',
    'Samsung': 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-s24.jpg',
    'Xiaomi': 'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-14.jpg',
    'Google': 'https://fdn2.gsmarena.com/vv/bigpic/google-pixel-8.jpg',
    'Motorola':
        'https://fdn2.gsmarena.com/vv/bigpic/motorola-edge-50-fusion.jpg',
    'OnePlus': 'https://fdn2.gsmarena.com/vv/bigpic/oneplus-12.jpg',
    'Sony': 'https://fdn2.gsmarena.com/vv/bigpic/sony-xperia-1-vi.jpg',
    'Oppo': 'https://fdn2.gsmarena.com/vv/bigpic/oppo-reno12-pro.jpg',
    'Huawei': 'https://fdn2.gsmarena.com/vv/bigpic/huawei-mate-60-pro.jpg',
    'Nothing': 'https://fdn2.gsmarena.com/vv/bigpic/nothing-phone-2.jpg',
    'Asus': 'https://fdn2.gsmarena.com/vv/bigpic/asus-zenfone-11-ultra.jpg',
    'Nokia': 'https://fdn2.gsmarena.com/vv/bigpic/nokia-g42.jpg',
  };

  Stream<List<Producto>> get _productosStream {
    return FirebaseFirestore.instance
        .collection('products')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Producto.fromFirestore(doc)).toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final email = auth.currentUser?.email ?? '';
    final nombre = email.contains('@') ? email.split('@')[0] : 'Usuario';

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: StreamBuilder<List<Producto>>(
              stream: _productosStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFa855f7)),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error al cargar datos',
                      style: TextStyle(color: Colors.white.withOpacity(0.5)),
                    ),
                  );
                }

                final productos = snapshot.data ?? [];

                final totalProductos = productos.length;
                final valorTotal = productos.fold<double>(
                  0,
                  (sum, p) => sum + (p.precio * p.stock),
                );
                final stockBajo = productos.where((p) => p.stockBajo).length;
                final sinStock = productos.where((p) => p.sinStock).length;

                final ultimosTres = productos.take(3).toList();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final productosStockBajo = productos
                      .where((p) => p.stockBajo && !p.sinStock)
                      .toList()
                    ..sort((a, b) => a.stock.compareTo(b.stock));

                  if (productosStockBajo.isNotEmpty) {
                    final p = productosStockBajo.first;
                    _mostrarAlertaStockBajo(context, p.nombre, p.stock);
                  }
                });

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, auth, nombre),
                      const SizedBox(height: 24),
                      _buildKPIs(
                        totalProductos: totalProductos,
                        valorTotal: valorTotal,
                        stockBajo: stockBajo,
                        sinStock: sinStock,
                      ),
                      const SizedBox(height: 24),
                      _buildRecentProducts(ultimosTres, context),
                      const SizedBox(height: 80),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormulario(context),
        backgroundColor: const Color(0xFFa855f7),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Agregar', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // ---------------- Background ----------------
  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1a0a2e), Color(0xFF0d0520), Color(0xFF1a0a2e)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: _blob(350, const Color(0xFF7c3aed), 0.5),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: _blob(250, const Color(0xFF6d28d9), 0.4),
          ),
        ],
      ),
    );
  }

  Widget _blob(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(opacity), Colors.transparent],
        ),
      ),
    );
  }

  // ---------------- Header ----------------
  Widget _buildHeader(BuildContext context, AuthService auth, String nombre) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenido de nuevo',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$nombre 👋',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BusquedaScreen()),
              ),
              child: _iconButton(Icons.search),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () async => await auth.logout(),
              child: _iconButton(Icons.logout),
            ),
          ],
        ),
      ],
    );
  }

  Widget _iconButton(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Icon(icon, color: Colors.white70, size: 20),
    );
  }

  // ---------------- KPI ----------------
  Widget _buildKPIs({
    required int totalProductos,
    required double valorTotal,
    required int stockBajo,
    required int sinStock,
  }) {
    final valorFormateado = valorTotal >= 1000
        ? '€${(valorTotal / 1000).toStringAsFixed(1)}k'
        : '€${valorTotal.toStringAsFixed(0)}';

    return GridView.count(
      crossAxisCount: kIsWeb ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: kIsWeb ? 1.8 : 1.3,
      children: [
        _kpiCard(
          'Total productos',
          '$totalProductos',
          Icons.smartphone,
          const Color(0xFFa855f7),
        ),
        _kpiCard(
          'Valor total',
          valorFormateado,
          Icons.euro_outlined,
          const Color(0xFF22c55e),
        ),
        _kpiCard(
          'Stock bajo',
          '$stockBajo',
          Icons.warning_amber_outlined,
          const Color(0xFFfb923c),
        ),
        _kpiCard(
          'Sin stock',
          '$sinStock',
          Icons.remove_circle_outline,
          const Color(0xFFef4444),
        ),
      ],
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const Spacer(),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 11,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Productos recientes ----------------
  Widget _buildRecentProducts(List<Producto> productos, BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Productos recientes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BusquedaScreen()),
                    ),
                    child: const Text(
                      'Ver todos',
                      style: TextStyle(color: Color(0xFFa855f7), fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (productos.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No hay productos todavía',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 13,
                    ),
                  ),
                )
              else
                Column(
                  children: productos.map((p) => _productCard(p)).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _productCard(Producto producto) {
    final Color stockColor = producto.sinStock
        ? const Color(0xFFef4444)
        : producto.stockBajo
        ? const Color(0xFFfb923c)
        : const Color(0xFF22c55e);

    final String stockLabel = producto.sinStock
        ? 'Sin stock'
        : producto.stockBajo
        ? '${producto.stock} uds ⚠'
        : '${producto.stock} uds';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _productImage(producto),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  producto.marca,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '€${producto.precio.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: stockColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  stockLabel,
                  style: TextStyle(color: stockColor, fontSize: 10),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  IconButton(
                    onPressed: () =>
                        _mostrarFormulario(context, producto: producto),
                    icon: const Icon(
                      Icons.edit,
                      size: 18,
                      color: Colors.white70,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _confirmarEliminar(context, producto.id),
                    icon: const Icon(
                      Icons.delete,
                      size: 18,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _productImage(Producto producto) {
    final url = producto.imagenUrl ?? _marcaFallback[producto.marca];
    if (url == null) {
      return Container(
        width: 40,
        height: 40,
        color: Colors.white24,
        child: const Icon(Icons.image, color: Colors.white),
      );
    }
    return Image.network(
      url,
      width: 40,
      height: 40,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: 40,
        height: 40,
        color: Colors.white24,
        child: const Icon(Icons.image, color: Colors.white),
      ),
    );
  }

  void _mostrarAlertaStockBajo(BuildContext context, String nombre, int stock) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '⚠️ Stock bajo: "$nombre" solo tiene $stock unidad${stock == 1 ? "" : "es"}.',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFfb923c),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
  // ================= FORMULARIO =================

  void _mostrarFormulario(BuildContext context, {Producto? producto}) async {
    final esEdicion = producto != null;

    final nombreCtrl = TextEditingController(text: producto?.nombre ?? '');
    final descCtrl = TextEditingController(text: producto?.descripcion ?? '');
    final marcaCtrl = TextEditingController(text: producto?.marca ?? '');
    final stockCtrl = TextEditingController(
      text: producto?.stock.toString() ?? '',
    );
    final precioCtrl = TextEditingController(
      text: producto?.precio.toString() ?? '',
    );

    File? imagenSeleccionada;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: const Color(0xFF1a0a2e),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.12)),
          ),
          title: Text(
            esEdicion ? 'Editar Producto' : 'Agregar Producto',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 75,
                      );
                      if (picked != null) {
                        setStateDialog(() {
                          imagenSeleccionada = File(picked.path);
                        });
                      }
                    },
                    child: Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          border: Border.all(color: Colors.white.withOpacity(0.15)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: imagenSeleccionada != null
                            ? Image.file(imagenSeleccionada!, fit: BoxFit.cover)
                            : (producto?.imagenUrl != null &&
                                  producto!.imagenUrl!.isNotEmpty)
                            ? Image.network(
                                producto!.imagenUrl!,
                                fit: BoxFit.cover,
                              )
                            : Center(
                                child: Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: Colors.white.withOpacity(0.4),
                                  size: 30,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _input(nombreCtrl, 'Nombre'),
                  _input(descCtrl, 'Descripción'),
                  _input(marcaCtrl, 'Marca'),
                  _input(stockCtrl, 'Stock', tipo: TextInputType.number),
                  _input(precioCtrl, 'Precio', tipo: TextInputType.number),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.white.withOpacity(0.6)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFa855f7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                String? imagenUrl = producto?.imagenUrl;
                final id =
                    producto?.id ??
                    FirebaseFirestore.instance.collection('products').doc().id;

                if (imagenSeleccionada != null) {
                  imagenUrl = await _service.subirImagen(
                    imagenSeleccionada!,
                    id,
                  );
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

                if (context.mounted) {
                  Navigator.pop(context);
                  if (p.stock < 3) {
                    _mostrarAlertaStockBajo(context, p.nombre, p.stock);
                  }
                }
              },
              child: Text(esEdicion ? 'Guardar' : 'Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController controller,
    String label, {
    TextInputType tipo = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: tipo,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.07),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFa855f7)),
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
        content: const Text('¿Seguro que quieres eliminar este producto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _service.eliminarProducto(id);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                // Opcional: mostrar error si falla
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al eliminar: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
