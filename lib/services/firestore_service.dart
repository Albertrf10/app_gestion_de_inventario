import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Stream<List<Producto>> getProductos() {
    return _db.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Producto.fromFirestore(doc)).toList();
    });
  }

  Future<void> agregarProducto(Producto producto) async {
    await _db.collection('products').add(producto.toMap());
  }

  Future<void> editarProducto(Producto producto) async {
    await _db.collection('products').doc(producto.id).update(producto.toMap());
  }

  Future<void> eliminarProducto(String id) async {
    await _db.collection('products').doc(id).delete();
  }

  Future<String?> subirImagen(File imagen, String productoId) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('productos/$productoId.jpg');
      await ref.putFile(imagen);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('❌ Error subiendo imagen: $e');
      return null;
    }
  }

  Future<void> asignarImagenes() async {
    const Map<String, String> imagenes = {
      // Apple
      'iPhone 17': 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-16-pro.jpg',
      'iPhone 17 Air': 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-16-pro.jpg',
      'iPhone 17 Pro': 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-16-pro.jpg',
      'iPhone 17 Pro Max': 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-16-pro-max.jpg',
      'iPhone 17e': 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-16e.jpg',
      'iPhone 16 Pro': 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-16-pro.jpg',
      'iPhone 16 Pro Max': 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-16-pro-max.jpg',
      'iPhone 16 Plus': 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-16-plus.jpg',
      'iPhone 15': 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-15.jpg',
      'iPhone 15 Plus': 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-15-plus.jpg',
      'iPhone 15 Pro Max': 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-15-pro-max.jpg',
      'iPhone 14': 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-14.jpg',
      'iPhone 14 Pro': 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-14-pro.jpg',
      'iPhone 14 Plus': 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-14-plus.jpg',
      'iPhone 13 Mini': 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-13-mini.jpg',
      'iPhone 12': 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-12.jpg',
      'iPhone 11': 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-11.jpg',
      'iPhone SE 4': 'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-16e.jpg',
      // Samsung
      'Samsung Galaxy S26 Ultra': 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-s25-ultra.jpg',
      'Samsung Galaxy S26': 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-s25.jpg',
      'Samsung Galaxy S25 FE': 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-s25.jpg',
      'Samsung Galaxy S24 FE': 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-s24-fe.jpg',
      'Samsung Galaxy S23 Ultra': 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-s23-ultra.jpg',
      'Samsung Galaxy S22': 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-s22.jpg',
      'Samsung Galaxy A56': 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-a56.jpg',
      'Samsung Galaxy A35': 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-a35.jpg',
      'Samsung Galaxy A16': 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-a16.jpg',
      'Samsung Galaxy A75': 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-a55.jpg',
      'Samsung Galaxy A05': 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-a05.jpg',
      'Samsung Galaxy M36': 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-m35.jpg',
      'Samsung Galaxy Z Fold 7': 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-z-fold6.jpg',
      'Samsung Galaxy Z Flip 7': 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-z-flip6.jpg',
      'Samsung Tab S10 Cell': 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-tab-s10.jpg',
      'Samsung Galaxy XCover 7': 'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-xcover7.jpg',
      // Xiaomi
      'Xiaomi 15 Pro': 'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-15-pro.jpg',
      'Xiaomi 14 Ultra': 'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-14-ultra.jpg',
      'Xiaomi 14T Pro': 'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-14t-pro.jpg',
      'Xiaomi Mi 11i': 'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-mi-11i-5g.jpg',
      'Xiaomi Mi 11 Ultra': 'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-mi-11-ultra.jpg',
      'Xiaomi Mi 15 Ultra': 'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-15-ultra.jpg',
      'Xiaomi Poco F7': 'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-poco-f6-pro.jpg',
      'Poco X7 Pro': 'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-poco-x7-pro.jpg',
      'Xiaomi Redmi Note 14': 'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-redmi-note-14.jpg',
      'Xiaomi Redmi Note 14 Pro+': 'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-redmi-note-14-pro-plus.jpg',
      'Xiaomi Redmi Note 13 Pro': 'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-redmi-note-13-pro.jpg',
      'Xiaomi Redmi Note 13 Pro+': 'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-redmi-note-13-pro-plus.jpg',
      'Xiaomi Redmi 13C': 'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-redmi-13c.jpg',
      'Xiaomi Mix Fold 4': 'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-mix-fold-4.jpg',
      'Xiaomi Black Shark 6': 'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-black-shark-5-pro.jpg',
      // Google
      'Google Pixel 10': 'https://fdn2.gsmarena.com/vv/bigpic/google-pixel-9.jpg',
      'Google Pixel 10 Pro': 'https://fdn2.gsmarena.com/vv/bigpic/google-pixel-9-pro.jpg',
      'Google Pixel 9a': 'https://fdn2.gsmarena.com/vv/bigpic/google-pixel-8a.jpg',
      'Google Pixel 8 Pro': 'https://fdn2.gsmarena.com/vv/bigpic/google-pixel-8-pro.jpg',
      'Google Pixel 7a': 'https://fdn2.gsmarena.com/vv/bigpic/google-pixel-7a.jpg',
      'Google Pixel 6a': 'https://fdn2.gsmarena.com/vv/bigpic/google-pixel-6a.jpg',
      'Google Pixel Fold 2': 'https://fdn2.gsmarena.com/vv/bigpic/google-pixel-fold.jpg',
      // Motorola
      'Motorola Edge 60': 'https://fdn2.gsmarena.com/vv/bigpic/motorola-edge-60.jpg',
      'Motorola Edge 50 Neo': 'https://fdn2.gsmarena.com/vv/bigpic/motorola-edge-50-neo.jpg',
      'Motorola Edge 40 Pro': 'https://fdn2.gsmarena.com/vv/bigpic/motorola-edge-40-pro.jpg',
      'Motorola Razr 60': 'https://fdn2.gsmarena.com/vv/bigpic/motorola-razr-50-ultra.jpg',
      'Motorola Razr 50 Ultra': 'https://fdn2.gsmarena.com/vv/bigpic/motorola-razr-50-ultra.jpg',
      'Motorola Moto G86': 'https://fdn2.gsmarena.com/vv/bigpic/motorola-moto-g85.jpg',
      'Motorola Moto G35': 'https://fdn2.gsmarena.com/vv/bigpic/motorola-moto-g35.jpg',
      // Realme
      'Realme 13 Pro+': 'https://fdn2.gsmarena.com/vv/bigpic/realme-13-pro-plus.jpg',
      'Realme GT 6': 'https://fdn2.gsmarena.com/vv/bigpic/realme-gt-6.jpg',
      'Realme GT 5 Pro': 'https://fdn2.gsmarena.com/vv/bigpic/realme-gt-5-pro.jpg',
      'Realme GT Neo 6': 'https://fdn2.gsmarena.com/vv/bigpic/realme-gt-neo-6.jpg',
      'Realme 12': 'https://fdn2.gsmarena.com/vv/bigpic/realme-12.jpg',
      'Realme 12x 5G': 'https://fdn2.gsmarena.com/vv/bigpic/realme-12x.jpg',
      'Realme C65': 'https://fdn2.gsmarena.com/vv/bigpic/realme-c65.jpg',
      // OnePlus
      'OnePlus 13': 'https://fdn2.gsmarena.com/vv/bigpic/oneplus-13.jpg',
      'OnePlus Open': 'https://fdn2.gsmarena.com/vv/bigpic/oneplus-open.jpg',
      'OnePlus Nord 4': 'https://fdn2.gsmarena.com/vv/bigpic/oneplus-nord-4.jpg',
      'OnePlus Nord CE 4': 'https://fdn2.gsmarena.com/vv/bigpic/oneplus-nord-ce4.jpg',
      // Sony
      'Sony Xperia 1 VI': 'https://fdn2.gsmarena.com/vv/bigpic/sony-xperia-1-vi.jpg',
      'Sony Xperia 5 VI': 'https://fdn2.gsmarena.com/vv/bigpic/sony-xperia-5-vi.jpg',
      'Sony Xperia 10 VI': 'https://fdn2.gsmarena.com/vv/bigpic/sony-xperia-10-vi.jpg',
      // Oppo
      'Oppo Find X8': 'https://fdn2.gsmarena.com/vv/bigpic/oppo-find-x8.jpg',
      'Oppo Find N3 Flip': 'https://fdn2.gsmarena.com/vv/bigpic/oppo-find-n3-flip.jpg',
      'Oppo Reno 12': 'https://fdn2.gsmarena.com/vv/bigpic/oppo-reno12.jpg',
      'Oppo A98': 'https://fdn2.gsmarena.com/vv/bigpic/oppo-a98.jpg',
      // Nothing
      'Nothing Phone (3)': 'https://fdn2.gsmarena.com/vv/bigpic/nothing-phone-2.jpg',
      'Nothing Phone (2a)': 'https://fdn2.gsmarena.com/vv/bigpic/nothing-phone-2a.jpg',
      // Huawei / Honor
      'Huawei P70': 'https://fdn2.gsmarena.com/vv/bigpic/huawei-p60-pro.jpg',
      'Huawei Mate 60 Pro': 'https://fdn2.gsmarena.com/vv/bigpic/huawei-mate-60-pro.jpg',
      'Honor Magic 7 Pro': 'https://fdn2.gsmarena.com/vv/bigpic/honor-magic7-pro.jpg',
      'Honor 200 Pro': 'https://fdn2.gsmarena.com/vv/bigpic/honor-200-pro.jpg',
      'Honor X9b': 'https://fdn2.gsmarena.com/vv/bigpic/honor-x9b.jpg',
      // Asus
      'Asus Zenfone 12': 'https://fdn2.gsmarena.com/vv/bigpic/asus-zenfone-11-ultra.jpg',
      'Asus Zenfone 11 Ultra': 'https://fdn2.gsmarena.com/vv/bigpic/asus-zenfone-11-ultra.jpg',
      'Asus ROG Phone 9': 'https://fdn2.gsmarena.com/vv/bigpic/asus-rog-phone-8-pro.jpg',
      // Otros
      'Nokia G500': 'https://fdn2.gsmarena.com/vv/bigpic/nokia-g42.jpg',
      'Nokia XR30': 'https://fdn2.gsmarena.com/vv/bigpic/nokia-xr21.jpg',
      'ZTE Axon 60': 'https://fdn2.gsmarena.com/vv/bigpic/zte-axon-50-ultra.jpg',
      'Vivo X100 Pro': 'https://fdn2.gsmarena.com/vv/bigpic/vivo-x100-pro.jpg',
      'Vivo V40 Pro': 'https://fdn2.gsmarena.com/vv/bigpic/vivo-v40-pro.jpg',
      'TCL 50 Pro': 'https://fdn2.gsmarena.com/vv/bigpic/tcl-50-pro.jpg',
      'TCL 40 SE': 'https://fdn2.gsmarena.com/vv/bigpic/tcl-40-se.jpg',
      'Nubia RedMagic 10': 'https://fdn2.gsmarena.com/vv/bigpic/nubia-redmagic-9-pro.jpg',
      'Fairphone 6': 'https://fdn2.gsmarena.com/vv/bigpic/fairphone-5.jpg',
      'Blackview BV9900': 'https://fdn2.gsmarena.com/vv/bigpic/blackview-bv9900-pro.jpg',
      'Ulefone Armor 25': 'https://fdn2.gsmarena.com/vv/bigpic/ulefone-armor-25t-pro.jpg',
    };

    try {
      final snapshot = await _db.collection('products').get();
      final batch = _db.batch();
      int actualizados = 0;

      const Map<String, String> marcaFallback = {
        'Apple':    'https://fdn2.gsmarena.com/vv/bigpic/apple-iphone-15.jpg',
        'Samsung':  'https://fdn2.gsmarena.com/vv/bigpic/samsung-galaxy-s24.jpg',
        'Xiaomi':   'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-14.jpg',
        'Google':   'https://fdn2.gsmarena.com/vv/bigpic/google-pixel-8.jpg',
        'Motorola': 'https://fdn2.gsmarena.com/vv/bigpic/motorola-edge-50-fusion.jpg',
        'Realme':   'https://fdn2.gsmarena.com/vv/bigpic/realme-12-pro-plus.jpg',
        'OnePlus':  'https://fdn2.gsmarena.com/vv/bigpic/oneplus-12.jpg',
        'Sony':     'https://fdn2.gsmarena.com/vv/bigpic/sony-xperia-1-vi.jpg',
        'Oppo':     'https://fdn2.gsmarena.com/vv/bigpic/oppo-reno12-pro.jpg',
        'Nothing':  'https://fdn2.gsmarena.com/vv/bigpic/nothing-phone-2.jpg',
        'Huawei':   'https://fdn2.gsmarena.com/vv/bigpic/huawei-mate-60-pro.jpg',
        'Honor':    'https://fdn2.gsmarena.com/vv/bigpic/honor-magic6-pro.jpg',
        'Asus':     'https://fdn2.gsmarena.com/vv/bigpic/asus-zenfone-11-ultra.jpg',
        'Nokia':    'https://fdn2.gsmarena.com/vv/bigpic/nokia-g42.jpg',
        'ZTE':      'https://fdn2.gsmarena.com/vv/bigpic/zte-axon-50-ultra.jpg',
        'Vivo':     'https://fdn2.gsmarena.com/vv/bigpic/vivo-x100-pro.jpg',
        'TCL':      'https://fdn2.gsmarena.com/vv/bigpic/tcl-50-pro.jpg',
        'Nubia':    'https://fdn2.gsmarena.com/vv/bigpic/nubia-redmagic-9-pro.jpg',
        'Fairphone':'https://fdn2.gsmarena.com/vv/bigpic/fairphone-5.jpg',
        'Blackview':'https://fdn2.gsmarena.com/vv/bigpic/blackview-bv9900-pro.jpg',
        'Ulefone':  'https://fdn2.gsmarena.com/vv/bigpic/ulefone-armor-25t-pro.jpg',
        'Poco':     'https://fdn2.gsmarena.com/vv/bigpic/xiaomi-poco-x7-pro.jpg',
      };

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final nombre = data['nombre'] as String? ?? '';
        final marca  = data['marca']  as String? ?? '';
        final yaTimeneImagen = data['imagenUrl'] != null && (data['imagenUrl'] as String).isNotEmpty;

        if (!yaTimeneImagen) {
          final url = imagenes[nombre] ?? marcaFallback[marca];
          if (url != null) {
            batch.update(doc.reference, {'imagenUrl': url});
            actualizados++;
          }
        }
      }

      await batch.commit();
      debugPrint('✅ Imágenes asignadas a $actualizados productos');
    } catch (e) {
      debugPrint('❌ Error asignando imágenes: $e');
    }
  }

  Future<void> importarDesdeJson() async {
    try {
      final List<Map<String, dynamic>> datos = [
        {"nombre": "iPhone 17", "marca": "Apple", "precio": 999.0, "stock": 15, "descripcion": "128GB, pantalla OLED y chip A19"},
        {"nombre": "iPhone 17 Air", "marca": "Apple", "precio": 1099.0, "stock": 10, "descripcion": "256GB, diseño ultrafino y chip A19"},
        {"nombre": "iPhone 17 Pro", "marca": "Apple", "precio": 1299.0, "stock": 8, "descripcion": "256GB, cámara pro y chip A19 Pro"},
        {"nombre": "iPhone 17 Pro Max", "marca": "Apple", "precio": 1499.0, "stock": 1, "descripcion": "512GB, batería XL y gama premium"},
        {"nombre": "iPhone 17e", "marca": "Apple", "precio": 699.0, "stock": 20, "descripcion": "256GB, edición especial con chip A19"},
        {"nombre": "Samsung Galaxy S26 Ultra", "marca": "Samsung", "precio": 1449.0, "stock": 5, "descripcion": "1TB, cámara de 200MP y S-Pen"},
        {"nombre": "Samsung Galaxy S26", "marca": "Samsung", "precio": 999.0, "stock": 0, "descripcion": "256GB, pantalla AMOLED de 120Hz"},
        {"nombre": "Xiaomi 15 Pro", "marca": "Xiaomi", "precio": 899.0, "stock": 12, "descripcion": "512GB, carga ultrarrápida 120W"},
        {"nombre": "Google Pixel 10", "marca": "Google", "precio": 799.0, "stock": 1, "descripcion": "128GB, IA avanzada y cámara pura"},
        {"nombre": "Motorola Edge 60", "marca": "Motorola", "precio": 599.0, "stock": 25, "descripcion": "256GB, pantalla curva sin bordes"},
        {"nombre": "iPhone 16 Pro", "marca": "Apple", "precio": 1120.0, "stock": 7, "descripcion": "128GB, titanio y botón de cámara"},
        {"nombre": "Samsung Galaxy A56", "marca": "Samsung", "precio": 450.0, "stock": 40, "descripcion": "128GB, el rey de la gama media"},
        {"nombre": "Xiaomi Poco F7", "marca": "Xiaomi", "precio": 399.0, "stock": 18, "descripcion": "256GB, potencia gaming extrema"},
        {"nombre": "Google Pixel 10 Pro", "marca": "Google", "precio": 1050.0, "stock": 4, "descripcion": "256GB, teleobjetivo y Magic Eraser"},
        {"nombre": "iPhone 15", "marca": "Apple", "precio": 780.0, "stock": 30, "descripcion": "128GB, Dynamic Island y USB-C"},
        {"nombre": "Samsung Galaxy Z Fold 7", "marca": "Samsung", "precio": 1850.0, "stock": 3, "descripcion": "512GB, plegable de gran formato"},
        {"nombre": "Samsung Galaxy Z Flip 7", "marca": "Samsung", "precio": 1100.0, "stock": 9, "descripcion": "256GB, plegable compacto y chic"},
        {"nombre": "Xiaomi Redmi Note 14", "marca": "Xiaomi", "precio": 249.0, "stock": 50, "descripcion": "128GB, batería de larga duración"},
        {"nombre": "Motorola Razr 60", "marca": "Motorola", "precio": 899.0, "stock": 6, "descripcion": "256GB, estilo icónico plegable"},
        {"nombre": "Sony Xperia 1 VI", "marca": "Sony", "precio": 1200.0, "stock": 2, "descripcion": "256GB, formato 21:9 para cine"},
        {"nombre": "Asus Zenfone 12", "marca": "Asus", "precio": 750.0, "stock": 11, "descripcion": "128GB, potente y muy compacto"},
        {"nombre": "Realme GT 6", "marca": "Realme", "precio": 649.0, "stock": 14, "descripcion": "512GB, carga en 15 minutos"},
        {"nombre": "Oppo Find X8", "marca": "Oppo", "precio": 999.0, "stock": 8, "descripcion": "256GB, fotografía Hasselblad"},
        {"nombre": "Nothing Phone (3)", "marca": "Nothing", "precio": 699.0, "stock": 22, "descripcion": "256GB, luces Glyph y diseño transparente"},
        {"nombre": "iPhone 14", "marca": "Apple", "precio": 650.0, "stock": 1, "descripcion": "128GB, fiable y con gran soporte"},
        {"nombre": "Samsung Galaxy M36", "marca": "Samsung", "precio": 320.0, "stock": 35, "descripcion": "128GB, enorme batería 6000mAh"},
        {"nombre": "Xiaomi 14 Ultra", "marca": "Xiaomi", "precio": 1350.0, "stock": 5, "descripcion": "512GB, lente Leica de 1 pulgada"},
        {"nombre": "Google Pixel 9a", "marca": "Google", "precio": 499.0, "stock": 19, "descripcion": "128GB, la mejor cámara barata"},
        {"nombre": "Huawei P70", "marca": "Huawei", "precio": 880.0, "stock": 12, "descripcion": "256GB, tecnología de cámara XMAGE"},
        {"nombre": "Motorola Moto G86", "marca": "Motorola", "precio": 299.0, "stock": 45, "descripcion": "128GB, Android puro y fluido"},
        {"nombre": "Honor Magic 7 Pro", "marca": "Honor", "precio": 1050.0, "stock": 7, "descripcion": "512GB, reconocimiento facial 3D"},
        {"nombre": "Samsung S24 FE", "marca": "Samsung", "precio": 680.0, "stock": 16, "descripcion": "128GB, funciones premium a buen precio"},
        {"nombre": "iPhone SE 4", "marca": "Apple", "precio": 520.0, "stock": 0, "descripcion": "64GB, chip potente en cuerpo clásico"},
        {"nombre": "Xiaomi Black Shark 6", "marca": "Xiaomi", "precio": 740.0, "stock": 4, "descripcion": "256GB, gatillos físicos para juegos"},
        {"nombre": "OnePlus 13", "marca": "OnePlus", "precio": 890.0, "stock": 13, "descripcion": "256GB, fluidez OxygenOS y carga rápida"},
        {"nombre": "Nokia G500", "marca": "Nokia", "precio": 230.0, "stock": 27, "descripcion": "128GB, durabilidad y 3 años de updates"},
        {"nombre": "ZTE Axon 60", "marca": "ZTE", "precio": 550.0, "stock": 9, "descripcion": "256GB, cámara bajo la pantalla"},
        {"nombre": "Vivo X100 Pro", "marca": "Vivo", "precio": 1100.0, "stock": 6, "descripcion": "512GB, óptica Zeiss avanzada"},
        {"nombre": "Realme 13 Pro+", "marca": "Realme", "precio": 480.0, "stock": 21, "descripcion": "256GB, diseño premium y zoom 50x"},
        {"nombre": "Poco X7 Pro", "marca": "Xiaomi", "precio": 360.0, "stock": 1, "descripcion": "256GB, pantalla 144Hz para gamers"},
        {"nombre": "iPhone 13 Mini", "marca": "Apple", "precio": 599.0, "stock": 5, "descripcion": "128GB, el último gran móvil pequeño"},
        {"nombre": "Samsung Tab S10 Cell", "marca": "Samsung", "precio": 950.0, "stock": 8, "descripcion": "256GB, tablet con funciones de móvil"},
        {"nombre": "Xiaomi Mix Fold 4", "marca": "Xiaomi", "precio": 1600.0, "stock": 2, "descripcion": "512GB, el plegable más fino del mundo"},
        {"nombre": "Google Pixel Fold 2", "marca": "Google", "precio": 1750.0, "stock": 4, "descripcion": "256GB, experiencia Android plegable"},
        {"nombre": "Motorola Edge 50 Neo", "marca": "Motorola", "precio": 420.0, "stock": 15, "descripcion": "128GB, colores Pantone y diseño ligero"},
        {"nombre": "TCL 50 Pro", "marca": "TCL", "precio": 299.0, "stock": 33, "descripcion": "256GB, pantalla tipo papel NXTPAPER"},
        {"nombre": "Nubia RedMagic 10", "marca": "Nubia", "precio": 850.0, "stock": 10, "descripcion": "512GB, ventilador interno activo"},
        {"nombre": "iPhone 15 Plus", "marca": "Apple", "precio": 980.0, "stock": 1, "descripcion": "256GB, la mejor batería de Apple"},
        {"nombre": "Samsung Galaxy A16", "marca": "Samsung", "precio": 190.0, "stock": 60, "descripcion": "64GB, básico, fiable y barato"},
        {"nombre": "Xiaomi 14T Pro", "marca": "Xiaomi", "precio": 650.0, "stock": 12, "descripcion": "256GB, rendimiento flagship a menor coste"},
        {"nombre": "Oppo Reno 12", "marca": "Oppo", "precio": 530.0, "stock": 24, "descripcion": "256GB, IA para retratos perfecta"},
        {"nombre": "Realme C65", "marca": "Realme", "precio": 170.0, "stock": 41, "descripcion": "128GB, diseño brillante y económico"},
        {"nombre": "Fairphone 6", "marca": "Fairphone", "precio": 699.0, "stock": 7, "descripcion": "128GB, modular y fácil de reparar"},
        {"nombre": "Nothing Phone (2a)", "marca": "Nothing", "precio": 349.0, "stock": 18, "descripcion": "128GB, esencia Nothing a precio medio"},
        {"nombre": "iPhone 12", "marca": "Apple", "precio": 450.0, "stock": 0, "descripcion": "64GB, entrada al ecosistema Apple"},
        {"nombre": "Samsung Galaxy S23 Ultra", "marca": "Samsung", "precio": 920.0, "stock": 9, "descripcion": "256GB, gran cámara y rendimiento sólido"},
        {"nombre": "Sony Xperia 10 VI", "marca": "Sony", "precio": 450.0, "stock": 14, "descripcion": "128GB, ligero, estrecho y resistente"},
        {"nombre": "Ulefone Armor 25", "marca": "Ulefone", "precio": 380.0, "stock": 20, "descripcion": "256GB, rugerizado e indestructible"},
        {"nombre": "Asus ROG Phone 9", "marca": "Asus", "precio": 1150.0, "stock": 3, "descripcion": "512GB, el rey absoluto del gaming"},
        {"nombre": "OnePlus Nord 4", "marca": "OnePlus", "precio": 499.0, "stock": 28, "descripcion": "256GB, equilibrio perfecto en gama media"},
        {"nombre": "Xiaomi Redmi 13C", "marca": "Xiaomi", "precio": 120.0, "stock": 100, "descripcion": "128GB, funcional por muy poco dinero"},
        {"nombre": "Samsung Galaxy A35", "marca": "Samsung", "precio": 330.0, "stock": 45, "descripcion": "128GB, equilibrio con pantalla SuperAMOLED"},
        {"nombre": "Google Pixel 8 Pro", "marca": "Google", "precio": 750.0, "stock": 1, "descripcion": "128GB, fotografía computacional top"},
        {"nombre": "iPhone 16 Plus", "marca": "Apple", "precio": 1050.0, "stock": 12, "descripcion": "128GB, pantalla grande y colores vivos"},
        {"nombre": "Motorola Moto G35", "marca": "Motorola", "precio": 160.0, "stock": 55, "descripcion": "64GB, básico para redes y llamadas"},
        {"nombre": "Xiaomi Mi 11 Ultra", "marca": "Xiaomi", "precio": 550.0, "stock": 2, "descripcion": "256GB, pantalla trasera secundaria"},
        {"nombre": "Realme GT Neo 6", "marca": "Realme", "precio": 450.0, "stock": 15, "descripcion": "256GB, carga ultra rápida y buen diseño"},
        {"nombre": "Honor 200 Pro", "marca": "Honor", "precio": 799.0, "stock": 11, "descripcion": "512GB, experto en fotografía de retrato"},
        {"nombre": "Samsung Galaxy S25 FE", "marca": "Samsung", "precio": 650.0, "stock": 20, "descripcion": "128GB, potencia de gama alta"},
        {"nombre": "iPhone 14 Pro", "marca": "Apple", "precio": 899.0, "stock": 1, "descripcion": "256GB, primera Dynamic Island"},
        {"nombre": "Nokia XR30", "marca": "Nokia", "precio": 499.0, "stock": 8, "descripcion": "128GB, resistente a caídas y agua"},
        {"nombre": "TCL 40 SE", "marca": "TCL", "precio": 150.0, "stock": 30, "descripcion": "128GB, pantalla grande y altavoces duales"},
        {"nombre": "Vivo V40 Pro", "marca": "Vivo", "precio": 599.0, "stock": 10, "descripcion": "256GB, diseño ultra delgado"},
        {"nombre": "Xiaomi Redmi Note 13 Pro", "marca": "Xiaomi", "precio": 340.0, "stock": 0, "descripcion": "256GB, cámara de 200MP"},
        {"nombre": "Samsung Galaxy A75", "marca": "Samsung", "precio": 520.0, "stock": 15, "descripcion": "256GB, pantalla fluida y buena cámara"},
        {"nombre": "Google Pixel 7a", "marca": "Google", "precio": 380.0, "stock": 6, "descripcion": "128GB, compactura y gran cámara Google"},
        {"nombre": "Motorola Edge 40 Pro", "marca": "Motorola", "precio": 799.0, "stock": 4, "descripcion": "256GB, carga rápida de 125W"},
        {"nombre": "Realme 12", "marca": "Realme", "precio": 299.0, "stock": 25, "descripcion": "128GB, estilo de lujo a precio bajo"},
        {"nombre": "iPhone 11", "marca": "Apple", "precio": 350.0, "stock": 2, "descripcion": "64GB, un clásico que aún rinde"},
        {"nombre": "OnePlus Open", "marca": "OnePlus", "precio": 1599.0, "stock": 1, "descripcion": "512GB, el plegable con mejor software"},
        {"nombre": "Oppo A98", "marca": "Oppo", "precio": 320.0, "stock": 18, "descripcion": "256GB, carga rápida y pantalla 120Hz"},
        {"nombre": "Xiaomi Mi 15 Ultra", "marca": "Xiaomi", "precio": 1499.0, "stock": 3, "descripcion": "1TB, sensor de cámara gigantesco"},
        {"nombre": "Samsung Galaxy XCover 7", "marca": "Samsung", "precio": 420.0, "stock": 12, "descripcion": "128GB, para trabajo duro en exteriores"},
        {"nombre": "Huawei Mate 60 Pro", "marca": "Huawei", "precio": 1100.0, "stock": 5, "descripcion": "512GB, conectividad satelital avanzada"},
        {"nombre": "Realme GT 5 Pro", "marca": "Realme", "precio": 650.0, "stock": 8, "descripcion": "256GB, potencia bruta Snapdragon"},
        {"nombre": "Asus Zenfone 11 Ultra", "marca": "Asus", "precio": 899.0, "stock": 6, "descripcion": "256GB, pantalla grande y jack de audio"},
        {"nombre": "Motorola Razr 50 Ultra", "marca": "Motorola", "precio": 1050.0, "stock": 3, "descripcion": "512GB, pantalla externa funcional"},
        {"nombre": "iPhone 15 Pro Max", "marca": "Apple", "precio": 1150.0, "stock": 1, "descripcion": "256GB, zoom 5x y botón acción"},
        {"nombre": "Samsung Galaxy A05", "marca": "Samsung", "precio": 110.0, "stock": 80, "descripcion": "64GB, el smartphone más barato"},
        {"nombre": "Xiaomi Redmi Note 14 Pro+", "marca": "Xiaomi", "precio": 499.0, "stock": 14, "descripcion": "512GB, carga rápida y gran sensor"},
        {"nombre": "OnePlus Nord CE 4", "marca": "OnePlus", "precio": 299.0, "stock": 20, "descripcion": "128GB, fluidez OnePlus barata"},
        {"nombre": "Honor X9b", "marca": "Honor", "precio": 350.0, "stock": 15, "descripcion": "256GB, pantalla ultra resistente"},
        {"nombre": "Google Pixel 6a", "marca": "Google", "precio": 290.0, "stock": 0, "descripcion": "128GB, compacto e ideal para regalar"},
        {"nombre": "Sony Xperia 5 VI", "marca": "Sony", "precio": 899.0, "stock": 5, "descripcion": "128GB, potencia compacta profesional"},
        {"nombre": "Blackview BV9900", "marca": "Blackview", "precio": 450.0, "stock": 7, "descripcion": "256GB, rugerizado con cámara térmica"},
        {"nombre": "Oppo Find N3 Flip", "marca": "Oppo", "precio": 999.0, "stock": 4, "descripcion": "256GB, el plegable con mejor cámara"},
        {"nombre": "Realme 12x 5G", "marca": "Realme", "precio": 199.0, "stock": 22, "descripcion": "128GB, 5G para todo el mundo"},
        {"nombre": "iPhone 14 Plus", "marca": "Apple", "precio": 799.0, "stock": 1, "descripcion": "128GB, gran pantalla, buen precio"},
        {"nombre": "Samsung Galaxy S22", "marca": "Samsung", "precio": 480.0, "stock": 10, "descripcion": "128GB, sigue siendo un gran gama alta"},
        {"nombre": "Xiaomi Mi 11i", "marca": "Xiaomi", "precio": 320.0, "stock": 8, "descripcion": "128GB, gran rendimiento pantalla plana"},
      ];

      WriteBatch batch = _db.batch();
      for (var item in datos) {
        if (item['nombre'] != null && item['precio'] != null) {
          DocumentReference ref = _db.collection('products').doc();
          batch.set(ref, {
            "nombre": item['nombre'],
            "marca": item['marca'] ?? "General",
            "precio": item['precio'],
            "stock": item['stock'] ?? 0,
            "descripcion": item['descripcion'] ?? "",
            "fecha_creacion": FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();
      debugPrint("✅ Inventario subido con éxito!");
    } catch (e) {
      debugPrint("❌ Error: $e");
    }
  }
}