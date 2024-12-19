import 'package:cloud_firestore/cloud_firestore.dart';

final db = FirebaseFirestore.instance;

/// Verificar si hay superposición de presupuestos para una categoría en un rango de fechas
Future<bool> checkOverlappingBudgets(String categoryId, DateTime startDate, DateTime endDate) async {
  final querySnapshot = await db.collection('presupuestos')
      .where('id_categoria', isEqualTo: categoryId) // Cambiado 'categoryId' por 'id_categoria'
      .get();

  for (var doc in querySnapshot.docs) {
    final data = doc.data();
    DateTime existingStartDate = DateTime.parse(data['fecha_inicio']); // Cambiado 'startDate' por 'fecha_inicio'
    DateTime existingEndDate = DateTime.parse(data['fecha_fin']); // Cambiado 'endDate' por 'fecha_fin'

    // Verifica si hay superposición de fechas
    if ((startDate.isBefore(existingEndDate) && endDate.isAfter(existingStartDate))) {
      return true; // Hay superposición
    }
  }
  return false; // No hay superposición
}

/// Obtener gastos distribuidos por categoría en un rango de fechas
Future<Map<String, double>> getExpensesByCategoryInDateRange(DateTime startDate, DateTime endDate) async {
  // Consulta los gastos dentro del rango de fechas
  final expensesQuery = await db.collection('gastos')
      .where("fecha_solicitud", isGreaterThanOrEqualTo: startDate.toIso8601String()) // Cambiado 'date' por 'fecha_solicitud'
      .where("fecha_solicitud", isLessThanOrEqualTo: endDate.toIso8601String()) // Cambiado 'date' por 'fecha_solicitud'
      .get();

  Map<String, double> categoryExpenses = {};

  for (var doc in expensesQuery.docs) {
    final expenseData = doc.data();
    String categoryName = expenseData["tema_solicitud"]; // Cambiado 'categoryName' por 'tema_solicitud'
    double amount = expenseData["monto"]; // Cambiado 'amount' por 'monto'

    // Acumula los gastos por categoría
    // Asegúrate de inicializar el monto si ya existe
    if (categoryExpenses.containsKey(categoryName)) {
      categoryExpenses[categoryName] = (categoryExpenses[categoryName] ?? 0) + amount;
    } else {
      categoryExpenses[categoryName] = amount;
    }
  }

  return categoryExpenses; // Retorna un mapa con los gastos por categoría
}
