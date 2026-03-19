// Clase que representa un producto (móvil) en la app
// Cada instancia es un móvil con sus propiedades
import 'package:cloud_firestore/cloud_firestore.dart';

class Producto {
  final String id;
  final String nombre;      // Ej: iPhone 15 Pro
  final String descripcion; 
  final String marca; // Ej: Apple, Samsung...
  final double precio;
  final int stock;
  final int stockMinimo;    // Umbral para considerar stock bajo

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.marca,
    required this.precio,
    required this.stock,
    this.stockMinimo = 5,
  });

  // Devuelve true si el stock está por debajo del mínimo
  bool get stockBajo => stock > 0 && stock <= stockMinimo;

  // Devuelve true si no hay stock
  bool get sinStock => stock == 0;

// Crea una instancia de Producto a partir de un documento de Firestore
// Esto facilita la conversión de datos al obtenerlos de la base de datos

  factory Producto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Producto(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      marca: data['marca'] ?? '',
      precio: (data['precio'] ?? 0).toDouble(),
      stock: (data['stock'] ?? 0).toInt(),
      stockMinimo: (data['stockMinimo'] ?? 5).toInt(),
    );
  }
}