import 'package:flutter/material.dart';
import '../db_helper.dart';
import '../ganado_detail_page.dart';

class AnimalList extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> ganadoFuture;
  final Function(Map<String, dynamic>)? onCowSelected; // Callback for selection

  const AnimalList({super.key, required this.ganadoFuture, this.onCowSelected});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ganadoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay ganado registrado'));
        } else {
          final ganado = snapshot.data!;
          return ListView.builder(
            itemCount: ganado.length,
            itemBuilder: (context, index) {
              final animal = ganado[index];
              return ListTile(
                leading: _buildAnimalIcon(animal),
                title: Text(
                  'ID: ${animal['arete_id']} - Sexo: ${animal['sexo']}',
                ),
                subtitle: Text('Estado: ${animal['estado']}'),
                onTap: () {
                  if (onCowSelected != null) {
                    onCowSelected!(animal); // Trigger the callback
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GanadoDetailPage(animal: animal),
                      ),
                    );
                  }
                },
              );
            },
          );
        }
      },
    );
  }

  Widget _buildAnimalIcon(Map<String, dynamic> animal) {
    if (animal['sexo'] == 'Hembra') {
      return const Icon(Icons.female, color: Colors.pink, size: 40);
    } else if (animal['sexo'] == 'Macho') {
      return const Icon(Icons.male, color: Colors.blue, size: 40);
    }
    return const Icon(Icons.help_outline, size: 40);
  }
}
