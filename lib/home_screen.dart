import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Asegúrate de importar FirebaseAuth
import 'my_drawer.dart'; // Asegúrate de que esta ruta sea correcta
import 'login_screen.dart'; // Asegúrate de que esta ruta sea correcta

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pantalla Principal'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              try {
                // Cerrar sesión usando Firebase
                await FirebaseAuth.instance.signOut();

                // Redirigir al LoginScreen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              } catch (e) {
                // Manejar errores aquí, si es necesario
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al cerrar sesión: $e')),
                );
              }
            },
          ),
        ],
      ),
      drawer: MyDrawer(), // Agregado el MyDrawer aquí
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenido a la pantalla principal!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Aquí puedes añadir funcionalidades adicionales
                // como navegar a otras pantallas o realizar acciones
              },
              child: Text('Explorar'),
            ),
          ],
        ),
      ),
    );
  }
}
