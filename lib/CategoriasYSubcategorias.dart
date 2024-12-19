import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'CrearCategoria.dart';
import 'CrearSubcategoria.dart';
import 'my_drawer.dart'; // Importa tu widget MyDrawer

class CategoriasYSubcategorias extends StatefulWidget {
  @override
  _CategoriasYSubcategoriasState createState() => _CategoriasYSubcategoriasState();
}

class _CategoriasYSubcategoriasState extends State<CategoriasYSubcategorias> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categorías y Subcategorías'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CrearCategoria()),
              );
            },
          ),
        ],
      ),
      drawer: MyDrawer(), // Agrega MyDrawer al Scaffold
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('categorias').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final categorias = snapshot.data!.docs;

          return ListView.builder(
            itemCount: categorias.length,
            itemBuilder: (context, index) {
              var categoria = categorias[index];
              return ExpansionTile(
                title: Text(categoria['nombre']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CrearCategoria(
                              categoriaId: categoria.id,
                              nombreInicial: categoria['nombre'],
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        // Eliminar categoría
                        await FirebaseFirestore.instance
                            .collection('categorias')
                            .doc(categoria.id)
                            .delete();
                        // También debes eliminar sus subcategorías asociadas
                        await _eliminarSubcategorias(categoria.id);
                      },
                    ),
                  ],
                ),
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('subcategorias')
                        .where('categoriaId', isEqualTo: categoria.id)
                        .snapshots(),
                    builder: (context, subSnapshot) {
                      if (!subSnapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final subcategorias = subSnapshot.data!.docs;

                      return Column(
                        children: [
                          for (var subcategoria in subcategorias)
                            ListTile(
                              title: Text(subcategoria['nombre']),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CrearSubcategoria(
                                            categoriaId: categoria.id,
                                            subcategoriaId: subcategoria.id,
                                            nombreInicial: subcategoria['nombre'],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection('subcategorias')
                                          .doc(subcategoria.id)
                                          .delete();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ListTile(
                            leading: Icon(Icons.add),
                            title: Text('Agregar Subcategoría'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CrearSubcategoria(categoriaId: categoria.id),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _eliminarSubcategorias(String categoriaId) async {
    final subcategoriasSnapshot = await FirebaseFirestore.instance
        .collection('subcategorias')
        .where('categoriaId', isEqualTo: categoriaId)
        .get();

    for (var doc in subcategoriasSnapshot.docs) {
      await FirebaseFirestore.instance.collection('subcategorias').doc(doc.id).delete();
    }
  }
}
