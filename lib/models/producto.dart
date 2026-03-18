// Clase que representa un producto (móvil) en la app
// Cada instancia es un móvil con sus propiedades
class Producto {
  final String id;
  final String nombre;      // Ej: iPhone 15 Pro
  final String categoria;   // Ej: Apple, Samsung...
  final double precio;
  final int stock;
  final int stockMinimo;    // Umbral para considerar stock bajo

  Producto({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.precio,
    required this.stock,
    this.stockMinimo = 5,
  });

  // Devuelve true si el stock está por debajo del mínimo
  bool get stockBajo => stock > 0 && stock <= stockMinimo;

  // Devuelve true si no hay stock
  bool get sinStock => stock == 0;
}