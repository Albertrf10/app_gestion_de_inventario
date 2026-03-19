class Product {
  String id;
  String nombre;
  String descripcion;
  String marca;
  int stock;
  double precio;

  Product({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.marca,
    required this.stock,
    required this.precio,
  });

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      marca: data['marca'] ?? '',
      stock: data['stock'] ?? 0,
      precio: (data['precio'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'marca': marca,
      'stock': stock,
      'precio': precio,
    };
  }
}