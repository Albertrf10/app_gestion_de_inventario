import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/producto.dart';
import '../../services/pdf_service.dart';
import '../../services/firestore_service.dart';

class BusquedaScreen extends StatefulWidget {
  const BusquedaScreen({super.key});

  @override
  State<BusquedaScreen> createState() => _BusquedaScreenState();
}

class _BusquedaScreenState extends State<BusquedaScreen> {
  final _searchController = TextEditingController();
  final FirestoreService _service = FirestoreService();

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
    'Nubia':     'https://fdn2.gsmarena.com/vv/bigpic/nubia-redmagic-9-pro.jpg',
    'Blackview': 'https://fdn2.gsmarena.com/vv/bigpic/blackview-bv9900-pro.jpg',
    'Ulefone':   'https://fdn2.gsmarena.com/vv/bigpic/ulefone-armor-25t-pro.jpg',
    'Vivo':      'https://fdn2.gsmarena.com/vv/bigpic/vivo-x100-pro.jpg',
    'TCL':       'https://fdn2.gsmarena.com/vv/bigpic/tcl-50-pro.jpg',
    'ZTE':       'https://fdn2.gsmarena.com/vv/bigpic/zte-axon-50-ultra.jpg',
    'Fairphone': 'https://fdn2.gsmarena.com/vv/bigpic/fairphone-5.jpg',
  };

  String _query = '';
  String _marcaSeleccionada = 'Todas';
  double _precioMax = 2000;
  String _stockFiltro = 'Todos';
  final double _precioMaximo = 2000;

  // Guarda los productos filtrados actuales para el botón PDF
  List<Producto> _productosFiltradosActuales = [];

  // Stream que escucha en tiempo real la colección products de Firestore
  Stream<List<Producto>> get _productosStream {
    return FirebaseFirestore.instance
        .collection('products')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Producto.fromFirestore(doc)).toList());
  }

  // Aplica todos los filtros activos sobre la lista recibida
  List<Producto> _filtrar(List<Producto> productos) {
    return productos.where((p) {
      final matchQuery = _query.isEmpty ||
          p.nombre.toLowerCase().contains(_query.toLowerCase()) ||
          p.marca.toLowerCase().contains(_query.toLowerCase());

      final matchMarca =
          _marcaSeleccionada == 'Todas' || p.marca == _marcaSeleccionada;

      final matchPrecio = p.precio <= _precioMax;

      final matchStock = _stockFiltro == 'Todos' ||
          (_stockFiltro == 'Disponible' && p.stock > p.stockMinimo) ||
          (_stockFiltro == 'Stock bajo' && p.stockBajo) ||
          (_stockFiltro == 'Sin stock' && p.sinStock);

      return matchQuery && matchMarca && matchPrecio && matchStock;
    }).toList();
  }

  // Extrae las marcas únicas de la lista para los filtros
  List<String> _getMarcas(List<Producto> productos) {
    final marcas = productos.map((p) => p.marca).toSet().toList();
    marcas.sort();
    return ['Todas', ...marcas];
  }

  // Resetea todos los filtros a sus valores por defecto
  void _limpiarFiltros() {
    setState(() {
      _query = '';
      _searchController.clear();
      _marcaSeleccionada = 'Todas';
      _precioMax = _precioMaximo;
      _stockFiltro = 'Todos';
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                // Header y barra de búsqueda fuera del StreamBuilder
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildSearchBar(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                // StreamBuilder escucha Firestore en tiempo real
                Expanded(
                  child: StreamBuilder<List<Producto>>(
                    stream: _productosStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFa855f7),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error al cargar productos',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5)),
                          ),
                        );
                      }

                      final todosProductos = snapshot.data ?? [];
                      final productosFiltrados = _filtrar(todosProductos);
                      final marcas = _getMarcas(todosProductos);

                      // Guardamos para usar en el PDF
                      _productosFiltradosActuales = productosFiltrados;

                      return Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Panel filtros izquierda
                            SizedBox(
                              width: 150,
                              child: SingleChildScrollView(
                                child: _buildFiltros(marcas),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Resultados derecha
                            Expanded(
                              child: _buildResultados(productosFiltrados),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
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
            top: -80,
            right: -80,
            child: _blob(300, const Color(0xFF7c3aed), 0.5),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: _blob(200, const Color(0xFF6d28d9), 0.4),
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

  // Header con botón volver y botón exportar PDF
  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: const Icon(Icons.arrow_back,
                color: Colors.white70, size: 18),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Text('Búsqueda',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600)),
        ),
        // Botón exportar PDF
        GestureDetector(
          onTap: () async {
            if (_productosFiltradosActuales.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('No hay productos para exportar'),
                  backgroundColor: Colors.red.withValues(alpha: 0.8),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }
            await PdfService.exportarProductos(_productosFiltradosActuales);
          },
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFa855f7).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color(0xFFa855f7).withValues(alpha: 0.4)),
            ),
            child: const Icon(Icons.picture_as_pdf_outlined,
                color: Color(0xFFa855f7), size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: 'Buscar por nombre o marca...',
            hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.3), fontSize: 14),
            prefixIcon: Icon(Icons.search,
                color: Colors.white.withValues(alpha: 0.4), size: 20),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close,
                        color: Colors.white.withValues(alpha: 0.4),
                        size: 18),
                    onPressed: () => setState(() {
                      _query = '';
                      _searchController.clear();
                    }),
                  )
                : null,
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.12)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFa855f7)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFiltros(List<String> marcas) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.12)),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filtros',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 14),

              _filtroTitulo('Marca'),
              const SizedBox(height: 8),
              ...marcas.map((m) => _opcionItem(
                    m,
                    _marcaSeleccionada == m,
                    () => setState(() => _marcaSeleccionada = m),
                  )),
              const SizedBox(height: 14),

              _filtroTitulo('Precio máx.'),
              const SizedBox(height: 4),
              Text('€${_precioMax.toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFFa855f7),
                  inactiveTrackColor:
                      Colors.white.withValues(alpha: 0.15),
                  thumbColor: const Color(0xFFa855f7),
                  overlayColor:
                      const Color(0xFFa855f7).withValues(alpha: 0.2),
                  thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6),
                  trackHeight: 3,
                ),
                child: Slider(
                  value: _precioMax,
                  min: 0,
                  max: _precioMaximo,
                  onChanged: (value) =>
                      setState(() => _precioMax = value),
                ),
              ),
              const SizedBox(height: 14),

              _filtroTitulo('Stock'),
              const SizedBox(height: 8),
              ...['Todos', 'Disponible', 'Stock bajo', 'Sin stock']
                  .map((s) => _opcionItem(
                        s,
                        _stockFiltro == s,
                        () => setState(() => _stockFiltro = s),
                      )),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: _limpiarFiltros,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFa855f7).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: const Color(0xFFa855f7)
                            .withValues(alpha: 0.3)),
                  ),
                  child: const Center(
                    child: Text('Limpiar filtros',
                        style: TextStyle(
                            color: Color(0xFFa855f7),
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filtroTitulo(String titulo) {
    return Text(titulo,
        style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 11,
            fontWeight: FontWeight.w500));
  }

  // Widget reutilizable para opciones de filtro
  Widget _opcionItem(String label, bool seleccionado, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: seleccionado
                    ? const Color(0xFFa855f7)
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: seleccionado
                      ? const Color(0xFFa855f7)
                      : Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: seleccionado
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                    color: seleccionado
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultados(List<Producto> productos) {
    if (productos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off,
                color: Colors.white.withValues(alpha: 0.3), size: 48),
            const SizedBox(height: 12),
            Text('Sin resultados',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 14)),
            const SizedBox(height: 4),
            Text('Prueba con otros filtros',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.25),
                    fontSize: 12)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${productos.length} ${productos.length == 1 ? 'resultado' : 'resultados'}',
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            itemCount: productos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) =>
                _productoCard(productos[index]),
          ),
        ),
      ],
    );
  }

  Widget _productoCard(Producto producto) {
    final Color borderColor = producto.sinStock
        ? const Color(0xFFef4444).withValues(alpha: 0.4)
        : producto.stockBajo
            ? const Color(0xFFfb923c).withValues(alpha: 0.4)
            : Colors.white.withValues(alpha: 0.12);

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

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _productoImagen(producto),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(producto.nombre,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(producto.marca,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('€${producto.precio.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
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
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _mostrarFormulario(producto: producto),
                        child: Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFFa855f7).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: const Icon(Icons.edit, color: Color(0xFFa855f7), size: 13),
                        ),
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () => _confirmarEliminar(producto.id),
                        child: Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFFef4444).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: const Icon(Icons.delete, color: Color(0xFFef4444), size: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _productoImagen(Producto producto) {
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
      child: const Icon(Icons.smartphone, color: Color(0xFFa855f7), size: 20),
    );
  }

  void _mostrarFormulario({Producto? producto}) {
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
                    width: double.infinity, height: 110,
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
                                  Icon(Icons.add_photo_alternate, size: 36,
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(esEdicion ? 'Guardar' : 'Agregar',
                  style: const TextStyle(color: Colors.white)),
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

  void _confirmarEliminar(String id) {
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
        content: Text('¿Estás seguro de que quieres eliminar este producto?',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
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