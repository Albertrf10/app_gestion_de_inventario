import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/producto.dart';

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
      print("✅ Inventario subido con éxito!");
    } catch (e) {
      print("❌ Error: $e");
    }
  }
}