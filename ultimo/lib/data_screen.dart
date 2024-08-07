import 'package:flutter/material.dart';

class DataScreen extends StatelessWidget {
  final Stream<List<String>> stream;

  DataScreen({required this.stream});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Datos Recibidos'),
        backgroundColor: const Color.fromARGB(255, 78, 161, 202),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<List<String>>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No hay datos disponibles.'));
            }

            List<String> receivedLines = snapshot.data!;

            return ListView.builder(
              itemCount: receivedLines.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.blueGrey[700],
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      receivedLines[index],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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
