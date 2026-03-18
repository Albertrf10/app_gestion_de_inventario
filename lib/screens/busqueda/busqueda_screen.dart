import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/producto.dart';
import '../../data/productos_data.dart';

class BusquedaScreen extends StatefulWidget {
  const BusquedaScreen({super.key});

  @override
  State<BusquedaScreen> createState() => _BusquedaScreenState();
}

class _BusquedaScreenState extends State<BusquedaScreen> {
  // Controlador para leer el texto de la barra de búsqueda
  final _searchController = TextEditingController();

  // Estado de los filtros
  String _query = '';                    // Texto de búsqueda
  String _categoriaSeleccionada = 'Todas'; // Categoría activa
  double _precioMax = 1800;              // Precio máximo del slider
  String _stockFiltro = 'Todos';         // Filtro de stock

  // Precio máximo posible (tope del slider)
  final double _precioMaximo = 1800;

  // Lista de categorías extraída de los datos
  // 'Todas' es la opción por defecto
  List<String> get _categorias {
    final cats = productosEjemplo.map((p) => p.categoria).toSet().toList();
    cats.sort();
    return ['Todas', ...cats];
  }

  // Getter que aplica todos los filtros activos sobre la lista de productos
  // Se recalcula cada vez que cambia cualquier filtro
  List<Producto> get _productosFiltrados {
    return productosEjemplo.where((p) {
      // Filtro por nombre o categoría
      final matchQuery = _query.isEmpty ||
          p.nombre.toLowerCase().contains(_query.toLowerCase()) ||
          p.categoria.toLowerCase().contains(_query.toLowerCase());

      // Filtro por categoría seleccionada
      final matchCategoria =
          _categoriaSeleccionada == 'Todas' || p.categoria == _categoriaSeleccionada;

      // Filtro por precio máximo
      final matchPrecio = p.precio <= _precioMax;

      // Filtro por estado de stock
      final matchStock = _stockFiltro == 'Todos' ||
          (_stockFiltro == 'Disponible' && p.stock > p.stockMinimo) ||
          (_stockFiltro == 'Stock bajo' && p.stockBajo) ||
          (_stockFiltro == 'Sin stock' && p.sinStock);

      // Solo muestra el producto si pasa TODOS los filtros
      return matchQuery && matchCategoria && matchPrecio && matchStock;
    }).toList();
  }

  // Resetea todos los filtros a sus valores por defecto
  void _limpiarFiltros() {
    setState(() {
      _query = '';
      _searchController.clear();
      _categoriaSeleccionada = 'Todas';
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
                // Cabecera y barra de búsqueda (fijos arriba)
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
                // Contenido scrollable (filtros + resultados)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Panel de filtros (izquierda, fijo)
                        SizedBox(
                          width: 150,
                          child: SingleChildScrollView(
                            child: _buildFiltros(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Lista de resultados (derecha, scrollable)
                        Expanded(
                          child: _buildResultados(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fondo con blobs igual que el resto de pantallas
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
            top: -80, right: -80,
            child: _blob(300, const Color(0xFF7c3aed), 0.5),
          ),
          Positioned(
            bottom: -60, left: -60,
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

  // Cabecera con botón de volver y título
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
        const Text(
          'Búsqueda',
          style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // Barra de búsqueda — llama a setState cada vez que el texto cambia
  Widget _buildSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          // onChanged se ejecuta en cada tecla pulsada
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: 'Buscar por nombre o marca...',
            hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.3), fontSize: 14),
            prefixIcon: Icon(Icons.search,
                color: Colors.white.withValues(alpha: 0.4), size: 20),
            // Botón para borrar el texto de búsqueda
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close,
                        color: Colors.white.withValues(alpha: 0.4),
                        size: 18),
                    onPressed: () =>
                        setState(() {
                          _query = '';
                          _searchController.clear();
                        }),
                  )
                : null,
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.12)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFFa855f7)),
            ),
          ),
        ),
      ),
    );
  }

  // Panel de filtros lateral
  Widget _buildFiltros() {
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

              // Filtro por categoría (marca)
              _filtroTitulo('Marca'),
              const SizedBox(height: 8),
              // Genera un botón por cada categoría disponible
              ..._categorias.map((cat) => _categoriaItem(cat)),
              const SizedBox(height: 14),

              // Filtro por precio con slider
              _filtroTitulo('Precio máx.'),
              const SizedBox(height: 4),
              Text(
                '€${_precioMax.toStringAsFixed(0)}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
              // SliderTheme para personalizar el color del slider
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
                  // Actualiza el precio máximo al mover el slider
                  onChanged: (value) =>
                      setState(() => _precioMax = value),
                ),
              ),
              const SizedBox(height: 14),

              // Filtro por estado de stock
              _filtroTitulo('Stock'),
              const SizedBox(height: 8),
              ...['Todos', 'Disponible', 'Stock bajo', 'Sin stock']
                  .map((s) => _stockItem(s)),
              const SizedBox(height: 16),

              // Botón para limpiar todos los filtros
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

  // Título de sección dentro del panel de filtros
  Widget _filtroTitulo(String titulo) {
    return Text(titulo,
        style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 11,
            fontWeight: FontWeight.w500));
  }

  // Item de categoría — se marca en púrpura si está seleccionado
  Widget _categoriaItem(String categoria) {
    final bool seleccionado = _categoriaSeleccionada == categoria;
    return GestureDetector(
      onTap: () => setState(() => _categoriaSeleccionada = categoria),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            // Checkbox visual
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
              child: Text(
                categoria,
                style: TextStyle(
                  color: seleccionado
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Item de stock — mismo estilo que categoriaItem
  Widget _stockItem(String opcion) {
    final bool seleccionado = _stockFiltro == opcion;
    return GestureDetector(
      onTap: () => setState(() => _stockFiltro = opcion),
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
              child: Text(
                opcion,
                style: TextStyle(
                  color: seleccionado
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Lista de resultados filtrados
  Widget _buildResultados() {
    final productos = _productosFiltrados;

    // Si no hay resultados muestra un mensaje
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
        // Contador de resultados
        Text(
          '${productos.length} ${productos.length == 1 ? 'resultado' : 'resultados'}',
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
        ),
        const SizedBox(height: 8),
        // ListView con los productos filtrados
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

  // Tarjeta de producto individual en los resultados
  Widget _productoCard(Producto producto) {
    // Color del borde y badge según estado del stock
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
              // Icono del producto
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFa855f7).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.smartphone,
                    color: Color(0xFFa855f7), size: 20),
              ),
              const SizedBox(width: 12),
              // Nombre y marca
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
                    Text(producto.categoria,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 11)),
                  ],
                ),
              ),
              // Precio y badge de stock
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: stockColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(stockLabel,
                        style:
                            TextStyle(color: stockColor, fontSize: 10)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
