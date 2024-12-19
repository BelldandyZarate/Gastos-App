import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'my_drawer.dart';

class GastosPage extends StatefulWidget {
  @override
  _GastosPageState createState() => _GastosPageState();
}

class _GastosPageState extends State<GastosPage> {
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();
  String? _categoriaSeleccionada;
  String? _subcategoriaSeleccionada;
  double? _presupuestoRestante;
  double _presupuestoTotal = 0.0;
  bool _mostrarFormulario = false;
  String? _gastoId;
  DateTime? _fechaGasto;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gastos'),
        actions: [
          IconButton(
            icon: Icon(_mostrarFormulario ? Icons.list : Icons.add),
            onPressed: () {
              setState(() {
                _mostrarFormulario = !_mostrarFormulario;
                if (_mostrarFormulario) {
                  _limpiarCampos();
                }
              });
            },
          ),
        ],
      ),
      drawer: MyDrawer(),
      body: Column(
        children: [
          if (!_mostrarFormulario)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('gastos').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  var gastos = snapshot.data!.docs;

                  if (gastos.isEmpty) {
                    return Center(child: Text('No hay gastos registrados.'));
                  }

                  return ListView.builder(
                    itemCount: gastos.length,
                    itemBuilder: (context, index) {
                      var gasto = gastos[index];
                      Map<String, dynamic>? data = gasto.data() as Map<String, dynamic>?;
                      String descripcion = data?['descripcion'] ?? 'Descripción no disponible';
                      double monto = data?['monto'] ?? 0.0;
                      String categoriaId = data?['categoriaId'] ?? 'Categoría no disponible';
                      Timestamp? fechaTimestamp = data?['fecha'];
                      String fecha = fechaTimestamp != null ? fechaTimestamp.toDate().toString().split(' ')[0] : 'Fecha no disponible';

                      return ListTile(
                        title: Text(descripcion),
                        subtitle: Text(
                          'Monto: \$${monto.toStringAsFixed(2)} \nCategoría: $categoriaId \nFecha: $fecha',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _editarGasto(gasto),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _eliminarGasto(gasto.id),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          if (_mostrarFormulario)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _buildCategoriaDropdown(),
                  if (_categoriaSeleccionada != null) _buildSubcategoriaDropdown(),
                  _buildTextField('Descripción del Gasto', _descripcionController),
                  _buildTextField('Monto del Gasto', _montoController, keyboardType: TextInputType.number),
                  _buildFechaField(),
                  _buildTextField('Observaciones', _observacionesController),
                  if (_presupuestoRestante != null) _buildPresupuestoRestante(),
                  ElevatedButton(
                    onPressed: _guardarGasto,
                    child: Text(_gastoId == null ? 'Guardar Gasto' : 'Actualizar Gasto'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoriaDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('categorias').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        var categorias = snapshot.data!.docs;
        return DropdownButton<String>(
          value: _categoriaSeleccionada,
          hint: Text('Selecciona una Categoría'),
          items: categorias.map((categoria) {
            return DropdownMenuItem<String>(
              value: categoria.id,
              child: Text(categoria['nombre'] ?? 'Nombre no disponible'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _categoriaSeleccionada = value;
              _subcategoriaSeleccionada = null;
              _obtenerPresupuestoRestante(value!);
            });
          },
        );
      },
    );
  }

  Widget _buildSubcategoriaDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('subcategorias')
          .where('categoriaId', isEqualTo: _categoriaSeleccionada)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        var subcategorias = snapshot.data!.docs;
        return DropdownButton<String>(
          value: _subcategoriaSeleccionada,
          hint: Text('Selecciona una Subcategoría'),
          items: subcategorias.map((subcategoria) {
            return DropdownMenuItem<String>(
              value: subcategoria.id,
              child: Text(subcategoria['nombre'] ?? 'Nombre no disponible'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _subcategoriaSeleccionada = value;
            });
          },
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _buildFechaField() {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Fecha del Gasto',
        hintText: _fechaGasto != null ? _fechaGasto!.toLocal().toString().split(' ')[0] : 'Selecciona una fecha',
      ),
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        DateTime? fechaSeleccionada = await showDatePicker(
          context: context,
          initialDate: _fechaGasto ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (fechaSeleccionada != null) {
          setState(() {
            _fechaGasto = fechaSeleccionada;
          });
        }
      },
    );
  }

  Widget _buildPresupuestoRestante() {
    return Text(
      'Presupuesto restante: \$${_presupuestoRestante!.toStringAsFixed(2)}',
      style: TextStyle(
        color: _presupuestoRestante! < 0 ? Colors.red : Colors.green,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void _limpiarCampos() {
    _categoriaSeleccionada = null;
    _subcategoriaSeleccionada = null;
    _descripcionController.clear();
    _montoController.clear();
    _observacionesController.clear();
    _gastoId = null;
    _fechaGasto = null;
    _presupuestoRestante = null;
  }

  Future<void> _obtenerPresupuestoRestante(String categoriaId) async {
    var presupuestosSnapshot = await FirebaseFirestore.instance
        .collection('presupuestos')
        .where('categoriaId', isEqualTo: categoriaId)
        .get();
    if (presupuestosSnapshot.docs.isNotEmpty) {
      var presupuesto = presupuestosSnapshot.docs.first.data();
      _presupuestoTotal = presupuesto['monto'];
      var gastosSnapshot = await FirebaseFirestore.instance
          .collection('gastos')
          .where('categoriaId', isEqualTo: categoriaId)
          .get();
      double gastosTotales = 0.0;
      for (var gasto in gastosSnapshot.docs) {
        gastosTotales += gasto['monto'];
      }
      setState(() {
        _presupuestoRestante = _presupuestoTotal - gastosTotales;
      });
    } else {
      setState(() {
        _presupuestoRestante = null;
      });
    }
  }

  void _guardarGasto() {
    if (_categoriaSeleccionada != null &&
        _subcategoriaSeleccionada != null &&
        _montoController.text.isNotEmpty &&
        _fechaGasto != null) {
      double montoGasto = double.parse(_montoController.text);
      if (_gastoId == null) {
        FirebaseFirestore.instance.collection('gastos').add({
          'descripcion': _descripcionController.text,
          'monto': montoGasto,
          'categoriaId': _categoriaSeleccionada,
          'subcategoriaId': _subcategoriaSeleccionada,
          'fecha': _fechaGasto,
          'observaciones': _observacionesController.text,
        });
      } else {
        FirebaseFirestore.instance.collection('gastos').doc(_gastoId).update({
          'descripcion': _descripcionController.text,
          'monto': montoGasto,
          'categoriaId': _categoriaSeleccionada,
          'subcategoriaId': _subcategoriaSeleccionada,
          'fecha': _fechaGasto,
          'observaciones': _observacionesController.text,
        });
      }
      setState(() {
        _mostrarFormulario = false;
      });
    }
  }

  void _editarGasto(QueryDocumentSnapshot gasto) {
    setState(() {
      _categoriaSeleccionada = gasto['categoriaId'];
      _subcategoriaSeleccionada = gasto['subcategoriaId'];
      _descripcionController.text = gasto['descripcion'];
      _montoController.text = gasto['monto'].toString();
      _observacionesController.text = gasto['observaciones'];
      _fechaGasto = (gasto['fecha'] as Timestamp).toDate();
      _gastoId = gasto.id;
      _mostrarFormulario = true;
    });
  }

  void _eliminarGasto(String id) {
    FirebaseFirestore.instance.collection('gastos').doc(id).delete();
  }
}
