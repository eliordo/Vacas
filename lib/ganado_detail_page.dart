import 'dart:io'; // Import for File
import 'package:flutter/material.dart';
import 'editar_animal_page.dart'; // Importa la página de edición
import 'db_helper.dart'; // Importa DBHelper para recargar los datos

class GanadoDetailPage extends StatefulWidget {
  final Map<String, dynamic> animal;

  const GanadoDetailPage({super.key, required this.animal});

  @override
  State<GanadoDetailPage> createState() => _GanadoDetailPageState();
}

class _GanadoDetailPageState extends State<GanadoDetailPage> {
  late Map<String, dynamic> _animal;

  @override
  void initState() {
    super.initState();
    _animal = widget.animal; // Inicializa los datos del animal
  }

  Future<void> _reloadAnimalData() async {
    try {
      final dbAnimal = await DBHelper.getGanado(); // Obtén todos los animales
      final updatedAnimal = dbAnimal.firstWhere(
        (animal) => animal['id'] == _animal['id'],
        orElse: () => _animal,
      );
      setState(() {
        _animal = updatedAnimal; // Actualiza los datos del animal
      });
    } catch (e) {
      print('Error al recargar los datos del animal: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Animal'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (_animal['foto'] != null && _animal['foto'].isNotEmpty)
              Image.file(
                File(_animal['foto']),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Text('Error al cargar la imagen');
                },
              ),
            const SizedBox(height: 16),
            Text('Arete ID: ${_animal['arete_id']}', style: _detailTextStyle()),
            Text('Arete Siniga: ${_animal['arete_siniga']}',
                style: _detailTextStyle()),
            Text('Padre: ${_animal['padre'] ?? "No especificado"}',
                style: _detailTextStyle()),
            Text('Madre: ${_animal['madre'] ?? "No especificado"}',
                style: _detailTextStyle()),
            Text('Fecha de Nacimiento: ${_animal['fecha_nacimiento']}',
                style: _detailTextStyle()),
            Text('Descripción: ${_animal['descripcion'] ?? "No especificado"}',
                style: _detailTextStyle()),
            Text('Sexo: ${_animal['sexo']}', style: _detailTextStyle()),
            Text('Estado: ${_animal['estado']}', style: _detailTextStyle()),
            if (_animal['fecha_ultima_vacunacion'] != null)
              Text('Última Vacunación: ${_animal['fecha_ultima_vacunacion']}',
                  style: _detailTextStyle()),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Editar Animal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditarAnimalPage(animal: _animal),
                  ),
                );
                if (result == true) {
                  await _reloadAnimalData(); // Recarga los datos si se realizaron cambios
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Datos actualizados correctamente'),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _detailTextStyle() {
    return const TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
  }
}
