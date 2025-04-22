import 'package:flutter/material.dart';
import '../db_helper.dart';
import '../widgets/animal_list.dart';

class VerGanadoPage extends StatelessWidget {
  final Function(Map<String, dynamic>)? onCowSelected; // Callback for selection

  const VerGanadoPage({super.key, this.onCowSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ganado Registrado'),
        backgroundColor: Colors.green.shade700,
      ),
      body: AnimalList(
        ganadoFuture: DBHelper.getGanado(),
        onCowSelected: onCowSelected, // Pass the callback to AnimalList
      ),
    );
  }
}

class AnimalDetailsPage extends StatelessWidget {
  final Map<String, dynamic> animal;

  const AnimalDetailsPage({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(animal['name']),
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text('Editar Animal'),
            trailing: const Icon(Icons.edit, color: Colors.blue),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditarAnimalPage(animal: animal),
                ),
              );
              if (result == true) {
                _loadGanado(); // Recarga los datos si se realizaron cambios
              }
            },
          ),
        ],
      ),
    );
  }

  void _loadGanado() {
    // Implementación de la recarga de datos
  }
}

class EditarAnimalPage extends StatelessWidget {
  final Map<String, dynamic> animal;

  const EditarAnimalPage({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Animal'),
      ),
      body: Center(
        child: Text('Formulario de edición para ${animal['name']}'),
      ),
    );
  }
}
