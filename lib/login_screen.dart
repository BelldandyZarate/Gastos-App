import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Función para mostrar mensajes en pantalla
  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Función para validar el login
  Future<void> loginWithFirebase() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMessage('Por favor, complete todos los campos.');
      return;
    }

    try {
      // Autenticación con Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Si el inicio de sesión es exitoso, redirigir a HomeScreen
      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Mostrar errores de autenticación
      if (e.code == 'user-not-found') {
        showMessage('No se encontró un usuario con ese correo.');
      } else if (e.code == 'wrong-password') {
        showMessage('Contraseña incorrecta.');
      } else {
        showMessage('Error: ${e.message}');
      }
    } catch (e) {
      showMessage('Ocurrió un error. Intente nuevamente.');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ingrese login'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(30),
              child: Center(
                child: Container(
                  width: 100,
                  height: 100,
                  child: Image.asset('Image/img.png'),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: 'Correo',
                  hintText: 'Escriba su correo',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: 'Contraseña',
                  hintText: 'Escriba su contraseña',
                ),
                obscureText: true,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, top: 150, right: 10),
              child: Center(
                child: ElevatedButton(
                  onPressed: loginWithFirebase,
                  child: Text('Ingresar'),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                child: Text('Registrarse'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
