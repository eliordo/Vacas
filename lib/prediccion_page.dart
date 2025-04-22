import 'package:flutter/material.dart';
import 'add_pregnant_cow_form.dart'; // Ensure this import points to the correct file

class PrediccionPage extends StatelessWidget {
  const PrediccionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Predicción de Partos y Destete'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Añadir Vaca Preñada'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade800,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
          onPressed: () {
            print('Botón presionado'); // Debugging log
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddPregnantCowForm(),
              ),
            );
          },
        ),
      ),
    );
  }
}
