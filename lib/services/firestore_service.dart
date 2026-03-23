import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> importarDesdeJson() async {
    try {
      // 1. Cargar el archivo con el nombre exacto que le diste
      final String respuesta = await rootBundle.loadString(
        'assets/data/products.json',
      );

      // 2. Convertir el texto JSON en una lista de Dart
      final List<dynamic> datos = json.decode(respuesta);

      WriteBatch batch = _db.batch();

      for (var item in datos) {
        // Validación básica: Solo subir si tiene nombre y precio
        if (item['nombre'] != null && item['precio'] != null) {
          DocumentReference ref = _db.collection('products').doc();

          batch.set(ref, {
            "nombre": item['nombre'],
            "marca": item['marca'] ?? "Genérica",
            "precio": item['precio'],
            "stock": item['stock'] ?? 0,
            "descripcion": item['descripcion'] ?? "Sin descripción",
            "fecha_creacion": FieldValue.serverTimestamp(),
          });
        }
      }

      // 3. Enviar todo a Firebase
      await batch.commit();
      print("🚀 ¡Inventario subido con éxito desde products.json!");
    } catch (e) {
      print(
        "❌ Error: Asegúrate de que assets/data/products.json existe y está en el pubspec.yaml. Error: $e",
      );
    }
  }
}
