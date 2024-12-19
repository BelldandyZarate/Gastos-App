import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // Para formatear fechas
import 'firebase_services.dart';

class GastosPorCategoriaScreen extends StatefulWidget {
  @override
  _GastosPorCategoriaScreenState createState() => _GastosPorCategoriaScreenState();
}

class _GastosPorCategoriaScreenState extends State<GastosPorCategoriaScreen> {
  DateTime? fechaInicio;
  DateTime? fechaFin;
  Map<String, double>? gastosPorCategoria;

  Future<void> _seleccionarFecha(BuildContext context, bool esFechaInicio) async {
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: esFechaInicio ? (fechaInicio ?? DateTime.now()) : (fechaFin ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (fechaSeleccionada != null) {
      setState(() {
        if (esFechaInicio) {
          fechaInicio = fechaSeleccionada;
        } else {
          fechaFin = fechaSeleccionada;
        }
      });
    }
  }

  Future<void> _obtenerDatos() async {
    if (fechaInicio != null && fechaFin != null) {
      // Asegúrate de que las fechas sean válidas
      if (fechaInicio!.isBefore(fechaFin!)) {
        gastosPorCategoria = await getExpensesByCategoryInDateRange(fechaInicio!, fechaFin!);
        setState(() {});
      } else {
        // Mensaje de error si el rango de fechas no es válido
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('La fecha de inicio debe ser anterior a la fecha de fin.'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Distribución de Gastos por Categoría'), // Título de la página
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Permitir desplazamiento si es necesario
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _seleccionarFecha(context, true),
                      child: Text(fechaInicio == null ? 'Seleccionar Fecha de Inicio' : 'Inicio: ${DateFormat('dd/MM/yyyy').format(fechaInicio!)}'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _seleccionarFecha(context, false),
                      child: Text(fechaFin == null ? 'Seleccionar Fecha de Fin' : 'Fin: ${DateFormat('dd/MM/yyyy').format(fechaFin!)}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _obtenerDatos,
                child: const Text('Generar gráficas'),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  // Título descriptivo
                  const Text(
                    'Distribución de Gastos por Categoría (Gráfico de Pastel)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20), // Espacio entre el título y la gráfica
                  // Gráfica de pastel con tamaño ajustado
                  SizedBox(
                    height: 250, // Ajustar la altura según sea necesario
                    child: gastosPorCategoria == null
                        ? const Center(child: Text('Seleccione un rango de fechas y obtenga los datos'))
                        : PieChart(
                      PieChartData(
                        sections: gastosPorCategoria!.entries.map((entry) {
                          return PieChartSectionData(
                            value: entry.value,
                            title: '${entry.key}\n${entry.value.toStringAsFixed(2)}', // Mostrar nombre de la categoría y valor
                            titleStyle: const TextStyle(
                              fontSize: 14, // Tamaño de fuente del título
                              fontWeight: FontWeight.bold,
                              color: Colors.black45, // Color del texto
                            ),
                            color: Colors.primaries[gastosPorCategoria!.keys.toList().indexOf(entry.key) % Colors.primaries.length],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Espacio entre las gráficas
                  const Text(
                    'Distribución de Gastos por Categoría (Gráfico de Barras)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10), // Espacio entre el título y la gráfica
                  SizedBox(
                    height: 250, // Ajustar la altura según sea necesario
                    child: gastosPorCategoria == null
                        ? const Center(child: Text('Seleccione un rango de fechas y obtenga los datos'))
                        : BarChart(
                      BarChartData(
                        barGroups: gastosPorCategoria!.entries.map((entry) {
                          return BarChartGroupData(
                            x: gastosPorCategoria!.keys.toList().indexOf(entry.key),
                            barRods: [
                              BarChartRodData(
                                toY: entry.value,
                                color: Colors.primaries[gastosPorCategoria!.keys.toList().indexOf(entry.key) % Colors.primaries.length],
                                width: 30,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 38,
                              getTitlesWidget: (value, meta) {
                                return Text(gastosPorCategoria!.keys.toList()[value.toInt()]);
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        gridData: FlGridData(show: true),
                        alignment: BarChartAlignment.spaceAround,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
