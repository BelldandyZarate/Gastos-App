import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'my_drawer.dart'; // Asegúrate de importar el archivo

class PresupuestosPage extends StatefulWidget {
  @override
  _PresupuestosPageState createState() => _PresupuestosPageState();
}

class _PresupuestosPageState extends State<PresupuestosPage> {
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  DateTime? _fechaInicioSeleccionada;
  DateTime? _fechaFinSeleccionada;
  String? _categoriaSeleccionada;
  Map<String, String> _categoriasMap = {}; // Mapa para almacenar categorías

  bool _mostrarFormulario = false;
  String? _presupuestoId; // Variable para almacenar el ID del presupuesto que se está editando

  @override
  void initState() {
    super.initState();
    _cargarCategorias(); // Cargar categorías al inicio
  }

  // Cargar las categorías y almacenarlas en el mapa
  void _cargarCategorias() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('categorias').get();
    for (var categoria in snapshot.docs) {
      _categoriasMap[categoria.id] = categoria['nombre'];
    }
    setState(() {}); // Actualizar el estado para reflejar el cambio
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Presupuestos'),
        actions: [
          IconButton(
            icon: Icon(_mostrarFormulario ? Icons.list : Icons.add),
            onPressed: () {
              setState(() {
                _mostrarFormulario = !_mostrarFormulario;
                _presupuestoId = null; // Reiniciar ID al mostrar la lista
                _limpiarCampos(); // Limpiar campos al mostrar la lista
              });
            },
          ),
        ],
      ),
      drawer: MyDrawer(),
      body: Column(
        children: [
          if (!_mostrarFormulario) // Mostrar la lista de presupuestos
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('presupuestos').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var presupuestos = snapshot.data!.docs;

                  if (presupuestos.isEmpty) {
                    return Center(child: Text('No hay presupuestos registrados.'));
                  }

                  return ListView.builder(
                    itemCount: presupuestos.length,
                    itemBuilder: (context, index) {
                      var presupuesto = presupuestos[index];
                      return ListTile(
                        title: Text('Nombre: ${presupuesto['nombre']}'),
                        subtitle: Text(
                          'Categoría: ${_categoriasMap[presupuesto['categoriaId']] ?? 'Categoría no encontrada'} \n'
                              'Monto: \$${presupuesto['monto']} \n'
                              'Fecha Inicial: ${DateFormat.yMd().format((presupuesto['fechaInicio'] as Timestamp).toDate())} \n'
                              'Fecha Final: ${DateFormat.yMd().format((presupuesto['fechaFin'] as Timestamp).toDate())}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _editarPresupuesto(presupuesto.id, presupuesto.data() as Map<String, dynamic>);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _eliminarPresupuesto(presupuesto.id),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

          if (_mostrarFormulario) // Mostrar el formulario para crear/editar presupuesto
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: _nombreController,
                    decoration: InputDecoration(labelText: 'Nombre del Presupuesto'),
                  ),

                  DropdownButton<String>(
                    value: _categoriaSeleccionada,
                    hint: Text('Selecciona una Categoría'),
                    items: _categoriasMap.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _categoriaSeleccionada = value;
                      });
                    },
                  ),

                  TextField(
                    controller: _montoController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Monto del Presupuesto'),
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _fechaInicioSeleccionada == null
                              ? 'Seleccione Fecha Inicial'
                              : 'Fecha Inicial: ${DateFormat.yMd().format(_fechaInicioSeleccionada!)}',
                        ),
                      ),
                      TextButton(
                        child: Text('Seleccionar Fecha Inicial'),
                        onPressed: () => _seleccionarFechaInicio(context),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _fechaFinSeleccionada == null
                              ? 'Seleccione Fecha Final'
                              : 'Fecha Final: ${DateFormat.yMd().format(_fechaFinSeleccionada!)}',
                        ),
                      ),
                      TextButton(
                        child: Text('Seleccionar Fecha Final'),
                        onPressed: () => _seleccionarFechaFin(context),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _guardarPresupuesto,
                    child: Text(_presupuestoId == null ? 'Guardar Presupuesto' : 'Actualizar Presupuesto'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Función para seleccionar la fecha de inicio
  Future<void> _seleccionarFechaInicio(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _fechaInicioSeleccionada) {
      setState(() {
        _fechaInicioSeleccionada = pickedDate;
      });
    }
  }

  // Función para seleccionar la fecha de fin
  Future<void> _seleccionarFechaFin(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _fechaFinSeleccionada) {
      setState(() {
        _fechaFinSeleccionada = pickedDate;
      });
    }
  }

  // Función para guardar o actualizar un presupuesto
  void _guardarPresupuesto() {
    if (_categoriaSeleccionada != null &&
        _montoController.text.isNotEmpty &&
        _nombreController.text.isNotEmpty &&
        _fechaInicioSeleccionada != null &&
        _fechaFinSeleccionada != null) {
      Map<String, dynamic> data = {
        'nombre': _nombreController.text,
        'categoriaId': _categoriaSeleccionada,
        'monto': double.parse(_montoController.text),
        'fechaInicio': _fechaInicioSeleccionada,
        'fechaFin': _fechaFinSeleccionada,
      };

      if (_presupuestoId == null) {
        // Crear un nuevo presupuesto
        FirebaseFirestore.instance.collection('presupuestos').add(data).then((_) {
          _limpiarCampos();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Presupuesto guardado exitosamente.')));
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar el presupuesto: $error')));
        });
      } else {
        // Actualizar el presupuesto existente
        FirebaseFirestore.instance.collection('presupuestos').doc(_presupuestoId).update(data).then((_) {
          _limpiarCampos();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Presupuesto actualizado exitosamente.')));
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al actualizar el presupuesto: $error')));
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Por favor complete todos los campos.')));
    }
  }

  // Función para editar un presupuesto
  void _editarPresupuesto(String id, Map<String, dynamic> presupuesto) {
    setState(() {
      _presupuestoId = id;
      _nombreController.text = presupuesto['nombre'];
      _categoriaSeleccionada = presupuesto['categoriaId'];
      _montoController.text = presupuesto['monto'].toString();
      _fechaInicioSeleccionada = (presupuesto['fechaInicio'] as Timestamp).toDate();
      _fechaFinSeleccionada = (presupuesto['fechaFin'] as Timestamp).toDate();
      _mostrarFormulario = true; // Mostrar el formulario al editar
    });
  }

  // Función para eliminar un presupuesto
  void _eliminarPresupuesto(String id) {
    FirebaseFirestore.instance.collection('presupuestos').doc(id).delete().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Presupuesto eliminado exitosamente.')));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar el presupuesto: $error')));
    });
  }

  // Limpiar los campos del formulario
  void _limpiarCampos() {
    _nombreController.clear();
    _montoController.clear();
    _categoriaSeleccionada = null;
    _fechaInicioSeleccionada = null;
    _fechaFinSeleccionada = null;
    _presupuestoId = null; // Reiniciar el ID
  }
}
