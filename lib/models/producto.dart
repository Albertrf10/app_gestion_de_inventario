import 'package:cloud_firestore/cloud_firestore.dart';

class Producto {
  final String id;
  final String nombre;
  final String descripcion;
  final String marca;
  final double precio;
  final int stock;
  final int stockMinimo;

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.marca,
    required this.precio,
    required this.stock,
    this.stockMinimo = 5,
  });

  bool get stockBajo => stock > 0 && stock <= stockMinimo;
  bool get sinStock => stock == 0;

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

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'marca': marca,
      'precio': precio,
      'stock': stock,
      'stockMinimo': stockMinimo,
    };
  }
}