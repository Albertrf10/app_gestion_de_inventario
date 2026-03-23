import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ZDI Zaitec - Inventario"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: "Cargar JSON",
            icon: const Icon(Icons.cloud_upload),
            onPressed: () async {
              await FirestoreService().importarDesdeJson();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("✅ Inventario sincronizado")),
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .orderBy('nombre')
            .limit(100)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(child: Text("Error de conexión"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Sin datos. Pulsa la nube."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;

              int stock = data['stock'] ?? 0;
              bool esCritico = stock <= 1;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(
                    Icons.smartphone,
                    color: Colors.blueAccent,
                    size: 30,
                  ),
                  title: Text(
                    data['nombre'] ?? 'Modelo Desconocido',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Marca: ${data['marca']}",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // AQUÍ APARECE TU NUEVA DESCRIPCIÓN CON CAPACIDAD
                      Text(
                        data['descripcion'] ?? 'Sin descripción',
                        maxLines: 1, // Una sola línea para que quede limpio
                        overflow:
                            TextOverflow.ellipsis, // Pone "..." si no cabe
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${data['precio']}€",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Stock: $stock",
                        style: TextStyle(
                          color: esCritico ? Colors.red : Colors.black54,
                          fontWeight: esCritico
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
