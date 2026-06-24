import 'package:flutter/material.dart';

class PatientBookingScreen extends StatelessWidget {
  const PatientBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agendar Consulta")),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Dr. João - Online"),
            subtitle: const Text("Terça-feira 14:00 - 15:00"),
            trailing: ElevatedButton(
              onPressed: () {
                // lógica para criar appointment
              },
              child: const Text("Agendar"),
            ),
          ),
        ],
      ),
    );
  }
}
