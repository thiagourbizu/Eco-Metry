import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
        iconTheme:
            IconThemeData(color: Colors.white), // Flecha de retroceso en blanco
      ),
      body: Container(
        color: Colors
            .blueGrey[900], // Fondo del cuerpo igual que el de la aplicación
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Espacio entre los elementos
          children: [
            Expanded(
              child: Center(
                // Centro los créditos en la pantalla
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
                        'Thiago Urbizu, Matias Galliano, Ignacio Makara\n',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                        // Texto en blanco
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showContactDialog(context);
                        },
                        child: Text('Contacto'),
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
void showContactDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.black, // Color de fondo negro
        title: Text(
          'Contáctanos',
          style: TextStyle(color: Colors.white), // Texto del título en blanco
        ),
        content: Text(
          '¿Quieres enviarnos un correo?',
          style: TextStyle(color: Colors.white), // Texto del contenido en blanco
        ),
        actions: [
          TextButton(
            onPressed: () {
              _sendEmail();
              Navigator.of(context).pop(); // Cerrar el diálogo
            },
            child: Text(
              'Enviar',
              style: TextStyle(color: Colors.white), // Texto en blanco
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar el diálogo
            },
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.white), // Texto en blanco
            ),
          ),
        ],
      );
    },
  );
}


void _sendEmail() async {
  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: 'thiago.urbizu@gmail.com', // Cambia esto por tu dirección de correo
    query: 'subject=Consulta de Eco-Metry&body=Hola, tengo una consulta sobre Eco-Metry.', // Mensaje predefinido
  );

  await launch(emailLaunchUri.toString());
}