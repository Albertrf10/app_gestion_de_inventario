import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/producto.dart';
import 'busqueda/busqueda_screen.dart';
import 'package:flutter/foundation.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _service = FirestoreService();

  static const Map<String, String> _marcaFallback = {
    'Apple':     'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-15.jpg',
    'Samsung':   'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-s24.jpg',
    'Xiaomi':    'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-14.jpg',
    'Google':    'https://fdn2.gsmarena.com/vv/bigpic/google-pixel-8.jpg',
    'Motorola':  'https://fdn2.gsmarena.com/vv/bigpic/motorola-edge-50-fusion.jpg',
    'OnePlus':   'https://fdn2.gsmarena.com/vv/bigpic/oneplus-12.jpg',
    'Sony':      'https://fdn2.gsmarena.com/vv/bigpic/sony-xperia-1-vi.jpg',
    'Oppo':      'https://fdn2.gsmarena.com/vv/bigpic/oppo-reno12-pro.jpg',
    'Huawei':    'https://fdn2.gsmarena.com/vv/bigpic/huawei-mate-60-pro.jpg',
    'Nothing':   'https://fdn2.gsmarena.com/vv/bigpic/nothing-phone-2.jpg',
    'Asus':      'https://fdn2.gsmarena.com/vv/bigpic/asus-zenfone-11-ultra.jpg',
    'Nokia':     'https://fdn2.gsmarena.com/vv/bigpic/nokia-g42.jpg',
  };

  Stream<List<Producto>> get _productosStream {
    return FirebaseFirestore.instance
        .collection('products')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Producto.fromFirestore(doc)).toList());
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
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    ),
                  );
                }

                final productos = snapshot.data ?? [];

                final totalProductos = productos.length;
                final valorTotal = productos.fold<double>(
                    0, (sum, p) => sum + (p.precio * p.stock));
                final stockBajo = productos.where((p) => p.stockBajo).length;
                final sinStock = productos.where((p) => p.sinStock).length;

                final ultimosTres = productos.take(3).toList();

                // Alerta de stock bajo al cargar
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  for (final p in productos) {
                    if (p.stockBajo && !p.sinStock) {
                      _mostrarAlertaStockBajo(context, p.nombre, p.stock);
                      break; // Muestra solo la primera para no saturar
                    }
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
            top: -100, right: -100,
            child: _blob(350, const Color(0xFF7c3aed), 0.5),
          ),
          Positioned(
            bottom: -80, left: -60,
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
          colors: [color.withValues(alpha: opacity), Colors.transparent],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthService auth, String nombre) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bienvenido de nuevo',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4), fontSize: 13)),
            const SizedBox(height: 2),
            Text('$nombre 👋',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BusquedaScreen()),
              ),
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: const Icon(Icons.search, color: Colors.white70, size: 20),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () async => await auth.logout(),
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: const Icon(Icons.logout, color: Colors.white70, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }

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
        _kpiCard(label: 'Total productos', value: '$totalProductos',
            icon: Icons.smartphone, iconColor: const Color(0xFFa855f7), iconBg: const Color(0xFFa855f7)),
        _kpiCard(label: 'Valor total', value: valorFormateado,
            icon: Icons.euro_outlined, iconColor: const Color(0xFF22c55e), iconBg: const Color(0xFF22c55e)),
        _kpiCard(label: 'Stock bajo', value: '$stockBajo',
            icon: Icons.warning_amber_outlined, iconColor: const Color(0xFFfb923c), iconBg: const Color(0xFFfb923c),
            valueColor: const Color(0xFFfb923c), borderColor: const Color(0xFFfb923c)),
        _kpiCard(label: 'Sin stock', value: '$sinStock',
            icon: Icons.remove_circle_outline, iconColor: const Color(0xFFef4444), iconBg: const Color(0xFFef4444),
            valueColor: const Color(0xFFef4444), borderColor: const Color(0xFFef4444)),
      ],
    );
  }

  Widget _kpiCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    Color valueColor = Colors.white,
    Color borderColor = Colors.white,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor.withValues(alpha: 0.2)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: iconBg.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const Spacer(),
              Text(label,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
              const SizedBox(height: 4),
              Text(value,
                  style: TextStyle(
                      color: valueColor, fontSize: 22, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentProducts(List<Producto> productos, BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Productos recientes',
                      style: TextStyle(
                          color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BusquedaScreen()),
                    ),
                    child: const Text('Ver todos',
                        style: TextStyle(color: Color(0xFFa855f7), fontSize: 12)),
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
                        color: Colors.white.withValues(alpha: 0.4), fontSize: 13),
                  ),
                )
              else
                ...productos.map((p) => _productRow(p, context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _productImage(Producto producto) {
    if (producto.imagenUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          producto.imagenUrl!,
          width: 40, height: 40, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            final fallback = _marcaFallback[producto.marca];
            if (fallback != null) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(fallback,
                    width: 40, height: 40, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _iconPlaceholder()),
              );
            }
            return _iconPlaceholder();
          },
        ),
      );
    }
    final fallback = _marcaFallback[producto.marca];
    if (fallback != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(fallback,
            width: 40, height: 40, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _iconPlaceholder()),
      );
    }
    return _iconPlaceholder();
  }

  Widget _iconPlaceholder() {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFa855f7).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.smartphone, color: Color(0xFFa855f7), size: 18),
    );
  }

  Widget _productRow(Producto producto, BuildContext context) {
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
        ),
      ),
      child: Row(
        children: [
          _productImage(producto),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(producto.nombre,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(producto.marca,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('€${producto.precio.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: stockColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(stockLabel,
                    style: TextStyle(color: stockColor, fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              GestureDetector(
                onTap: () => _mostrarFormulario(context, producto: producto),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFa855f7).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit, color: Color(0xFFa855f7), size: 15),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _confirmarEliminar(context, producto.id),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFef4444).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete, color: Color(0xFFef4444), size: 15),
                ),
              ),
            ],
          ),
        ],
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
          backgroundColor: const Color(0xFF1a0a2e),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
          ),
          title: Text(
            esEdicion ? 'Editar Producto' : 'Agregar Producto',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Selector de imagen
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(
                        source: ImageSource.gallery, imageQuality: 75);
                    if (picked != null) {
                      setStateDialog(() => imagenSeleccionada = File(picked.path));
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: imagenSeleccionada != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(imagenSeleccionada!, fit: BoxFit.cover),
                          )
                        : producto?.imagenUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(producto!.imagenUrl!, fit: BoxFit.cover),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate,
                                      size: 36,
                                      color: Colors.white.withValues(alpha: 0.3)),
                                  const SizedBox(height: 6),
                                  Text('Añadir imagen',
                                      style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.4),
                                          fontSize: 13)),
                                ],
                              ),
                  ),
                ),
                const SizedBox(height: 10),
                _inputField(nombreCtrl, 'Nombre'),
                const SizedBox(height: 8),
                _inputField(descCtrl, 'Descripción'),
                const SizedBox(height: 8),
                _inputField(marcaCtrl, 'Marca'),
                const SizedBox(height: 8),
                _inputField(stockCtrl, 'Stock', isNumber: true),
                const SizedBox(height: 8),
                _inputField(precioCtrl, 'Precio (€)', isNumber: true),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFa855f7),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final db = FirebaseFirestore.instance;
                final id = producto?.id ?? db.collection('products').doc().id;

                String? imagenUrl = producto?.imagenUrl;
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
                esEdicion
                    ? await _service.editarProducto(p)
                    : await _service.agregarProducto(p);
                if (context.mounted) {
                  Navigator.pop(context);
                  if (p.stock < 4) {
                    _mostrarAlertaStockBajo(context, p.nombre, p.stock);
                  }
                }
              },
              child: Text(
                esEdicion ? 'Guardar' : 'Agregar',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController ctrl, String label,
      {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFa855f7)),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1a0a2e),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        title: const Text('Eliminar Producto',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        content: Text(
          '¿Estás seguro de que quieres eliminar este producto?',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFef4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
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
