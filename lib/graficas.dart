import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // Para el formato de fechas
import 'my_drawer.dart'; // Asegúrate de que la ruta sea correcta

class GraficasGastosScreen extends StatefulWidget {
  @override
  _GraficasGastosScreenState createState() => _GraficasGastosScreenState();
}

class _GraficasGastosScreenState extends State<GraficasGastosScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, double> gastosPorCategoria = {};
  Map<String, double> gastosPorSubcategoria = {};
  Map<String, String> nombresCategorias = {};
  Map<String, String> nombresSubcategorias = {};
  Map<String, DateTime> fechasCategorias = {}; // Mapeo de IDs a fechas
  Map<String, DateTime> fechasSubcategorias = {}; // Mapeo de IDs a fechas

  // Fechas seleccionadas para filtrar
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarDatos(); // Cargar datos al iniciar
  }

  Future<void> _cargarDatos() async {
    await _cargarNombresCategorias();
    await _cargarNombresSubcategorias();

    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('gastos').get();

    Map<String, double> categorias = {};
    Map<String, double> subcategorias = {};
    Map<String, DateTime> fechasCat = {};
    Map<String, DateTime> fechasSubcat = {};

    for (var doc in snapshot.docs) {
      String categoriaId = doc['categoriaId'];
      String subcategoriaId = doc['subcategoriaId'];
      double monto = doc['monto'];
      DateTime fecha = (doc['fecha'] as Timestamp).toDate(); // 'fecha' es de tipo Timestamp

      // Filtrar por las fechas seleccionadas
      if (_fechaInicio != null && _fechaFin != null) {
        if (fecha.isBefore(_fechaInicio!) || fecha.isAfter(_fechaFin!)) {
          continue; // Saltar si la fecha no está en el rango
        }
      }

      categorias[categoriaId] = (categorias[categoriaId] ?? 0) + monto;
      subcategorias[subcategoriaId] = (subcategorias[subcategoriaId] ?? 0) + monto;

      fechasCat[categoriaId] = fecha;
      fechasSubcat[subcategoriaId] = fecha;
    }

    setState(() {
      gastosPorCategoria = categorias;
      gastosPorSubcategoria = subcategorias;
      fechasCategorias = fechasCat;
      fechasSubcategorias = fechasSubcat;
    });
  }

  Future<void> _cargarNombresCategorias() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('categorias').get();
    Map<String, String> nombres = {};
    for (var doc in snapshot.docs) {
      nombres[doc.id] = doc['nombre'];
    }
    setState(() {
      nombresCategorias = nombres;
    });
  }

  Future<void> _cargarNombresSubcategorias() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('subcategorias').get();
    Map<String, String> nombres = {};
    for (var doc in snapshot.docs) {
      nombres[doc.id] = doc['nombre'];
    }
    setState(() {
      nombresSubcategorias = nombres;
    });
  }

  // Método para seleccionar una fecha
  Future<void> _seleccionarFechaInicio(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaInicio ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _fechaInicio) {
      setState(() {
        _fechaInicio = picked;
      });
    }
  }

  Future<void> _seleccionarFechaFin(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaFin ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _fechaFin) {
      setState(() {
        _fechaFin = picked;
      });
    }
  }

  // Método para actualizar las gráficas cuando se presiona el botón "Enter"
  void _aplicarFechas() {
    _cargarDatos(); // Recargar los datos con las fechas seleccionadas
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gráficas de Gastos', style: TextStyle(fontSize: 22)), // Ajuste del tamaño del título
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Categorías',),
            Tab(text: 'Subcategorías'),
          ],
        ),
      ),
      drawer: MyDrawer(), // Agrega el Drawer aquí
      body: Column(
        children: [
          // Botones para seleccionar fechas
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => _seleccionarFechaInicio(context),
                  child: Text(
                    _fechaInicio == null
                        ? 'Seleccionar Fecha Inicio'
                        : DateFormat('dd/MM/yyyy').format(_fechaInicio!),
                    style: TextStyle(fontSize: 16), // Ajuste del tamaño del texto
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _seleccionarFechaFin(context),
                  child: Text(
                    _fechaFin == null
                        ? 'Seleccionar Fecha Fin'
                        : DateFormat('dd/MM/yyyy').format(_fechaFin!),
                    style: TextStyle(fontSize: 16), // Ajuste del tamaño del texto
                  ),
                ),
                // Botón "Enter" para aplicar el filtro de fechas
                ElevatedButton(
                  onPressed: _aplicarFechas,
                  child: Text('Enter', style: TextStyle(fontSize: 16)), // Ajuste del tamaño del texto
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCategoriaView(),
                _buildSubcategoriaView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriaView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20),
          Text(
            'Gráfica de Barras - Categoría',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), // Ajuste del tamaño del título
          ),
          _buildBarChart(gastosPorCategoria, nombresCategorias, fechasCategorias),
          SizedBox(height: 40),
          Text(
            'Gráfica de Pastel - Categoría',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), // Ajuste del tamaño del título
          ),
          _buildPieChart(gastosPorCategoria, nombresCategorias),
        ],
      ),
    );
  }

  Widget _buildSubcategoriaView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20),
          Text(
            'Gráfica de Barras - Subcategoría',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), // Ajuste del tamaño del título
          ),
          _buildBarChart(gastosPorSubcategoria, nombresSubcategorias, fechasSubcategorias),
          SizedBox(height: 40),
          Text(
            'Gráfica de Pastel - Subcategoría',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), // Ajuste del tamaño del título
          ),
          _buildPieChart(gastosPorSubcategoria, nombresSubcategorias),
        ],
      ),
    );
  }

  Widget _buildBarChart(Map<String, double> data, Map<String, String> nombres, Map<String, DateTime> fechas) {
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          barGroups: data.entries
              .map(
                (e) => BarChartGroupData(
              x: data.keys.toList().indexOf(e.key),
              barRods: [
                BarChartRodData(
                  toY: e.value,
                  color: Colors.blueAccent,
                ),
              ],
            ),
          ).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  String categoriaId = data.keys.elementAt(value.toInt());
                  return Text(
                    nombres[categoriaId] ?? '',
                    style: TextStyle(fontSize: 12),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(Map<String, double> data, Map<String, String> nombres) {
    return SizedBox(
      height: 300,
      child: PieChart(
        PieChartData(
          sections: data.entries
              .map(
                (e) => PieChartSectionData(
              value: e.value,
              title: nombres[e.key] ?? '',
              color: Colors.primaries[e.key.hashCode % Colors.primaries.length],
              radius: 50,
              titleStyle: TextStyle(fontSize: 14), // Ajuste del tamaño de la etiqueta
            ),
          ).toList(),
        ),
      ),
    );
  }
}
