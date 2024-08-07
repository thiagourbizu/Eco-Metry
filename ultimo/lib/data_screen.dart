import 'package:flutter/material.dart';

class DataScreen extends StatelessWidget {
  final List<String> receivedLines;

  DataScreen({required this.receivedLines});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Datos Recibidos'),
        backgroundColor: const Color.fromARGB(255, 78, 161, 202),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
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
        ),
      ),
    );
  }
}
