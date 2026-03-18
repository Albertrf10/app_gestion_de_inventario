import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'busqueda/busqueda_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    // Extraemos el nombre del email (parte antes del @)
    final email = auth.currentUser?.email ?? '';
    final nombre = email.contains('@') ? email.split('@')[0] : 'Usuario';

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, auth, nombre),
                  const SizedBox(height: 24),
                  _buildKPIs(),
                  const SizedBox(height: 24),
                  _buildRecentProducts(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fondo con blobs igual que login/registro
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

  // Cabecera con saludo y botón logout
Widget _buildHeader(BuildContext context, AuthService auth, String nombre) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // Saludo izquierda
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
      // Botones derecha
      Row(
        children: [
          // Botón búsqueda
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BusquedaScreen()),
            ),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: const Icon(Icons.search, color: Colors.white70, size: 20),
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

  // Grid de 4 tarjetas KPI
  Widget _buildKPIs() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      // shrinkWrap + NeverScrollableScrollPhysics permiten meter
      // el GridView dentro de un SingleChildScrollView
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _kpiCard(
          label: 'Total productos',
          value: '248',
          icon: Icons.inventory_2_outlined,
          iconColor: const Color(0xFFa855f7),
          iconBg: const Color(0xFFa855f7),
        ),
        _kpiCard(
          label: 'Valor total',
          value: '€14.2k',
          icon: Icons.euro_outlined,
          iconColor: const Color(0xFF22c55e),
          iconBg: const Color(0xFF22c55e),
        ),
        _kpiCard(
          label: 'Stock bajo',
          value: '12',
          icon: Icons.warning_amber_outlined,
          iconColor: const Color(0xFFfb923c),
          iconBg: const Color(0xFFfb923c),
          valueColor: const Color(0xFFfb923c),
          borderColor: const Color(0xFFfb923c),
        ),
        _kpiCard(
          label: 'Sin stock',
          value: '3',
          icon: Icons.remove_circle_outline,
          iconColor: const Color(0xFFef4444),
          iconBg: const Color(0xFFef4444),
          valueColor: const Color(0xFFef4444),
          borderColor: const Color(0xFFef4444),
        ),
      ],
    );
  }

  // Tarjeta KPI individual con efecto glass
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

  // Sección de productos recientes
  Widget _buildRecentProducts() {
    // Lista de datos de ejemplo — se sustituirá por datos de Firestore
    final productos = [
      {
        'nombre': 'Monitor 27" 4K',
        'categoria': 'Electrónica',
        'precio': '€349',
        'stock': '0',
        'estado': 'sin_stock'
      },
      {
        'nombre': 'Camiseta básica M',
        'categoria': 'Ropa',
        'precio': '€12.50',
        'stock': '134',
        'estado': 'ok'
      },
      {
        'nombre': 'Auriculares BT Pro',
        'categoria': 'Electrónica',
        'precio': '€59.99',
        'stock': '5',
        'estado': 'bajo'
      },
    ];

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
              // Cabecera de la sección
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Productos recientes',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                  Text('Ver todos',
                      style: TextStyle(
                          color: const Color(0xFFa855f7), fontSize: 12)),
                ],
              ),
              const SizedBox(height: 12),
              // Lista de productos
              ...productos.map((p) => _productRow(p)),
            ],
          ),
        ),
      ),
    );
  }

  // Fila de producto individual
  Widget _productRow(Map<String, String> p) {
    // Colores según el estado del stock
    final Color stockColor = p['estado'] == 'sin_stock'
        ? const Color(0xFFef4444)
        : p['estado'] == 'bajo'
            ? const Color(0xFFfb923c)
            : const Color(0xFF22c55e);

    final String stockLabel = p['estado'] == 'sin_stock'
        ? 'Sin stock'
        : p['estado'] == 'bajo'
            ? '${p['stock']} uds ⚠'
            : '${p['stock']} uds';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
        ),
      ),
      child: Row(
        children: [
          // Icono categoría
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFa855f7).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.inventory_2_outlined,
                color: Color(0xFFa855f7), size: 18),
          ),
          const SizedBox(width: 12),
          // Nombre y categoría
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p['nombre']!,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(p['categoria']!,
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
              Text(p['precio']!,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: stockColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(stockLabel,
                    style: TextStyle(color: stockColor, fontSize: 10)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
