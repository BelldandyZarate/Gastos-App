import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CrearSubcategoria extends StatefulWidget {
  final String categoriaId;
  final String? subcategoriaId; // Para editar
  final String? nombreInicial; // Nombre actual de la subcategoría para edición

  CrearSubcategoria({required this.categoriaId, this.subcategoriaId, this.nombreInicial});

  @override
  _CrearSubcategoriaState createState() => _CrearSubcategoriaState();
}

class _CrearSubcategoriaState extends State<CrearSubcategoria> {
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
        title: Text(widget.subcategoriaId == null ? 'Crear Subcategoría' : 'Editar Subcategoría'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nombre de la Subcategoría'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (widget.subcategoriaId == null) {
                  // Crear nueva subcategoría
                  String newSubcategoriaId = FirebaseFirestore.instance
                      .collection('subcategorias')
                      .doc().id;

                  await FirebaseFirestore.instance
                      .collection('subcategorias')
                      .doc(newSubcategoriaId)
                      .set({
                    'nombre': _nombreController.text,
                    'categoriaId': widget.categoriaId,
                  });
                } else {
                  // Editar subcategoría existente
                  await FirebaseFirestore.instance
                      .collection('subcategorias')
                      .doc(widget.subcategoriaId)
                      .update({
                    'nombre': _nombreController.text,
                  });
                }
                Navigator.pop(context);
              },
              child: Text(widget.subcategoriaId == null ? 'Crear Subcategoría' : 'Actualizar Subcategoría'),
            ),
          ],
        ),
      ),
    );
  }
}
