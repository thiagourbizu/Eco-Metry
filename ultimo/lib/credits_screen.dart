import 'package:flutter/material.dart';

class CreditsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Créditos',
          style: TextStyle(color: Colors.white), // Título en blanco
        ),
        backgroundColor: const Color.fromARGB(255, 78, 161, 202),
        iconTheme: IconThemeData(color: Colors.white), // Flecha de retroceso en blanco
      ),
      body: Container(
        color: Colors.blueGrey[900], // Fondo del cuerpo igual que el de la aplicación
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espacio entre los elementos
          children: [
            Expanded(
              child: Center( // Centro los créditos en la pantalla
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Créditos de Eco-Metry',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Texto en blanco
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Desarrolladores\n'
                        'Thiago Urbizu, Matias Galliano, Ignacio Makara\n'
                        'Contacto\n'
                        'thiago.urbizu@gmail.com\n',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white), // Texto en blanco
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0), // Espacio inferior
              child: Text(
                'Versión 1.0.0',
                style: TextStyle(
                  color: Colors.white, // Texto en blanco
                  fontSize: 16, // Tamaño de fuente para la versión
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
