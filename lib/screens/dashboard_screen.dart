import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../models/product.dart';
import 'busqueda/busqueda_screen.dart';
import 'package:flutter/foundation.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Stream que escucha en tiempo real la colección 'products' de Firestore
  // Devuelve una lista de objetos Producto cada vez que hay un cambio
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
            // StreamBuilder escucha el stream y reconstruye la UI
            // automáticamente cada vez que Firestore cambia
            child: StreamBuilder<List<Producto>>(
              stream: _productosStream,
              builder: (context, snapshot) {
                // Mientras carga muestra spinner
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFa855f7),
                    ),
                  );
                }

                // Si hay error muestra mensaje
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error al cargar datos',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5)),
                    ),
                  );
                }

                final productos = snapshot.data ?? [];

                // Calculamos los KPIs a partir de los datos reales
                final totalProductos = productos.length;
                final valorTotal = productos.fold<double>(
                    0, (sum, p) => sum + (p.precio * p.stock));
                final stockBajo =
                    productos.where((p) => p.stockBajo).length;
                final sinStock =
                    productos.where((p) => p.sinStock).length;

                // Últimos 3 productos ordenados por fecha de creación
                final ultimosTres = productos.take(3).toList();

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
                    ],
                  ),
                );
              },
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

  Widget _buildHeader(
      BuildContext context, AuthService auth, String nombre) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bienvenido de nuevo',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 13)),
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
            // Botón búsqueda
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const BusquedaScreen()),
              ),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: const Icon(Icons.search,
                    color: Colors.white70, size: 20),
              ),
            ),
            const SizedBox(width: 8),
            // Botón logout
            GestureDetector(
              onTap: () async => await auth.logout(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: const Icon(Icons.logout,
                    color: Colors.white70, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Recibe los valores calculados desde el StreamBuilder
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
    // En web 4 columnas, en móvil 2
    crossAxisCount: kIsWeb ? 4 : 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
    // En web las tarjetas más pequeñas, en móvil más cuadradas
    childAspectRatio: kIsWeb ? 1.8 : 1.3,
    children: [
      _kpiCard(
        label: 'Total productos',
        value: '$totalProductos',
        icon: Icons.smartphone,
        iconColor: const Color(0xFFa855f7),
        iconBg: const Color(0xFFa855f7),
      ),
      _kpiCard(
        label: 'Valor total',
        value: valorFormateado,
        icon: Icons.euro_outlined,
        iconColor: const Color(0xFF22c55e),
        iconBg: const Color(0xFF22c55e),
      ),
      _kpiCard(
        label: 'Stock bajo',
        value: '$stockBajo',
        icon: Icons.warning_amber_outlined,
        iconColor: const Color(0xFFfb923c),
        iconBg: const Color(0xFFfb923c),
        valueColor: const Color(0xFFfb923c),
        borderColor: const Color(0xFFfb923c),
      ),
      _kpiCard(
        label: 'Sin stock',
        value: '$sinStock',
        icon: Icons.remove_circle_outline,
        iconColor: const Color(0xFFef4444),
        iconBg: const Color(0xFFef4444),
        valueColor: const Color(0xFFef4444),
        borderColor: const Color(0xFFef4444),
      ),
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
            border:
                Border.all(color: borderColor.withValues(alpha: 0.2)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconBg.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const Spacer(),
              Text(label,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11)),
              const SizedBox(height: 4),
              Text(value,
                  style: TextStyle(
                      color: valueColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w700)),
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
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Productos recientes',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                // Ver todos navega a BusquedaScreen
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const BusquedaScreen()),
                  ),
                  child: const Text('Ver todos',
                      style: TextStyle(
                          color: Color(0xFFa855f7), fontSize: 12)),
                ),
              ],
            ),
              const SizedBox(height: 12),
              // Si no hay productos muestra mensaje
              if (productos.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No hay productos todavía',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 13),
                  ),
                )
              else
                ...productos.map((p) => _productRow(p)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _productRow(Producto producto) {
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
          bottom:
              BorderSide(color: Colors.white.withValues(alpha: 0.07)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFa855f7).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.smartphone,
                color: Color(0xFFa855f7), size: 18),
          ),
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
    );
  }
}
