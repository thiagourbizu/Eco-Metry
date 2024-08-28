import 'package:flutter/material.dart';

class DataScreen extends StatelessWidget {
  final Stream<List<String>> stream;

  DataScreen({required this.stream});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Datos Recibidos',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 78, 161, 202),
        iconTheme: const IconThemeData(
          color:
              Colors.white, // Cambia el color aquí para la flecha hacia atrás
        ),
      ),
      body: Container(
        color: Colors.blueGrey[900], // Fondo total gris oscuro
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<List<String>>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white)));
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No hay datos disponibles.'));
            }

            List<String> receivedLines = snapshot.data!;

            return ListView.builder(
              itemCount: receivedLines.length,
              itemBuilder: (context, index) {
                return Align(
                  // Alinear a la izquierda
                  alignment: Alignment.centerLeft,
                  child: Card(
                    color: Colors.white, // Fondo blanco para los cuadros
                    margin: EdgeInsets.symmetric(
                        vertical: 4.0), // Margen entre cuadros
                    child: Padding(
                      padding:
                          const EdgeInsets.all(8.0), // Padding dentro del Card
                      child: Text(
                        receivedLines[index],
                        style: TextStyle(
                          color:
                              Colors.black, // Texto negro para mayor contraste
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
