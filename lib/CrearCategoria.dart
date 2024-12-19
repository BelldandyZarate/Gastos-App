import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CrearCategoria extends StatefulWidget {
  final String? categoriaId; // Para editar la categoría
  final String? nombreInicial; // Para mostrar el nombre actual al editar

  CrearCategoria({this.categoriaId, this.nombreInicial});

  @override
  _CrearCategoriaState createState() => _CrearCategoriaState();
}

class _CrearCategoriaState extends State<CrearCategoria> {
  final TextEditingController _nombreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.nombreInicial != null) {
      _nombreController.text = widget.nombreInicial!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoriaId == null ? 'Crear Categoría' : 'Editar Categoría'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nombre de la Categoría'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (widget.categoriaId == null) {
                  // Crear nueva categoría
                  String newId = FirebaseFirestore.instance.collection('categorias').doc().id;
                  await FirebaseFirestore.instance.collection('categorias').doc(newId).set({
                    'nombre': _nombreController.text,
                  });
                } else {
                  // Editar categoría existente
                  await FirebaseFirestore.instance.collection('categorias').doc(widget.categoriaId).update({
                    'nombre': _nombreController.text,
                  });
                }
                Navigator.pop(context);
              },
              child: Text(widget.categoriaId == null ? 'Crear Categoría' : 'Actualizar Categoría'),
            ),
          ],
        ),
      ),
    );
  }
}
