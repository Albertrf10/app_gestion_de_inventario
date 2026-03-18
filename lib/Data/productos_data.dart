import '../models/producto.dart';

// Lista de productos de prueba con móviles reales
// Se sustituirá por datos de Firestore cuando esté listo
final List<Producto> productosEjemplo = [
  Producto(
    id: '1',
    nombre: 'iPhone 15 Pro',
    categoria: 'Apple',
    precio: 1199.99,
    stock: 23,
  ),
  Producto(
    id: '2',
    nombre: 'iPhone 14',
    categoria: 'Apple',
    precio: 799.99,
    stock: 4,
    stockMinimo: 5,
  ),
  Producto(
    id: '3',
    nombre: 'iPhone 13 Mini',
    categoria: 'Apple',
    precio: 599.99,
    stock: 0,
  ),
  Producto(
    id: '4',
    nombre: 'Samsung Galaxy S24 Ultra',
    categoria: 'Samsung',
    precio: 1299.99,
    stock: 15,
  ),
  Producto(
    id: '5',
    nombre: 'Samsung Galaxy A54',
    categoria: 'Samsung',
    precio: 449.99,
    stock: 3,
    stockMinimo: 5,
  ),
  Producto(
    id: '6',
    nombre: 'Samsung Galaxy Z Fold 5',
    categoria: 'Samsung',
    precio: 1799.99,
    stock: 0,
  ),
  Producto(
    id: '7',
    nombre: 'Pixel 8 Pro',
    categoria: 'Google',
    precio: 1099.99,
    stock: 8,
  ),
  Producto(
    id: '8',
    nombre: 'Pixel 7a',
    categoria: 'Google',
    precio: 499.99,
    stock: 2,
    stockMinimo: 5,
  ),
  Producto(
    id: '9',
    nombre: 'Xiaomi 14 Pro',
    categoria: 'Xiaomi',
    precio: 999.99,
    stock: 11,
  ),
  Producto(
    id: '10',
    nombre: 'Xiaomi Redmi Note 13',
    categoria: 'Xiaomi',
    precio: 249.99,
    stock: 0,
  ),
  Producto(
    id: '11',
    nombre: 'OnePlus 12',
    categoria: 'OnePlus',
    precio: 899.99,
    stock: 6,
  ),
  Producto(
    id: '12',
    nombre: 'OnePlus Nord 3',
    categoria: 'OnePlus',
    precio: 399.99,
    stock: 4,
    stockMinimo: 5,
  ),
];