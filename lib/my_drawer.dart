import 'package:flutter/material.dart';
import 'home_screen.dart'; // Ajusta la ruta si es necesario
import 'CategoriasYSubcategorias.dart'; // Ajusta la ruta si es necesario
import 'login_screen.dart'; // Asegúrate de que esta ruta sea correcta
import 'gastos_page.dart'; // Ajusta la ruta si es necesario
import 'presupuestos_page.dart'; // Asegúrate de ajustar la ruta correctamente
import 'graficas.dart'; // Asegúrate de que la ruta sea correcta

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.red,
            ),
            child: Text(
              'Menú',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home), // Icono para Home
            title: Text('Inicio'), // Cambiado a "Inicio"
            onTap: () {
              Navigator.pop(context); // Cierra el Drawer
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text('Lista Categorías'),
            onTap: () {
              Navigator.pop(context); // Cierra el Drawer
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CategoriasYSubcategorias()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.list_alt), // Icono para gastos
            title: Text('Lista Gastos'),
            onTap: () {
              Navigator.pop(context); // Cierra el Drawer
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => GastosPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.show_chart), // Icono para gráficas
            title: Text('Gráficas'),
            onTap: () {
              Navigator.pop(context); // Cierra el Drawer
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => GraficasGastosScreen()), // Sustituye con tus datos reales
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.money), // Icono para presupuesto
            title: Text('Presupuestos'),
            onTap: () {
              Navigator.pop(context); // Cierra el Drawer
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PresupuestosPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout), // Icono para Cerrar sesión
            title: Text('Cerrar sesión'),
            onTap: () {
              // Aquí puedes agregar la lógica para cerrar sesión
              // Por ejemplo, usando FirebaseAuth.instance.signOut()

              // Luego redirigir al LoginScreen
              Navigator.pop(context); // Cierra el Drawer
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
