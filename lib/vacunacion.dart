import 'package:flutter/material.dart';
import 'db_helper.dart'; // Importa DBHelper para acceder a la base de datos

class VacunacionPage extends StatefulWidget {
  const VacunacionPage({super.key});

  @override
  State<VacunacionPage> createState() => _VacunacionPageState();
}

class _VacunacionPageState extends State<VacunacionPage> {
  final TextEditingController _fechaVacunacionController =
      TextEditingController();
  final TextEditingController _medicamentosController =
      TextEditingController(); // Controlador para la descripción de medicamentos
  final List<Map<String, dynamic>> _registeredDates =
      []; // Lista para almacenar las fechas y medicamentos

  @override
  void initState() {
    super.initState();
    _loadRegisteredDates(); // Carga las fechas al iniciar la página
  }

  @override
  void dispose() {
    _fechaVacunacionController.dispose();
    _medicamentosController.dispose();
    super.dispose();
  }

  Future<void> _loadRegisteredDates() async {
    try {
      final ganado =
          await DBHelper.getGanado(); // Obtén los datos de la base de datos
      setState(() {
        _registeredDates.clear();
        for (var animal in ganado) {
          if (animal['fecha_ultima_vacunacion'] != null &&
              animal['fecha_ultima_vacunacion'].toString().isNotEmpty) {
            _registeredDates.add({
              'fecha': animal['fecha_ultima_vacunacion'],
              'medicamentos': animal['medicamentos'] ?? '',
            });
          }
        }
      });
    } catch (e) {
      print('Error al cargar las fechas: $e');
    }
  }

  Future<void> _deleteDate(String date) async {
    try {
      // Elimina la fecha de la base de datos
      await DBHelper.deleteGanadoByDate(date);
      _loadRegisteredDates(); // Recarga las fechas registradas
    } catch (e) {
      print('Error al eliminar la fecha: $e');
    }
  }

  String _formatDate(DateTime date) {
    // Formatea la fecha manualmente en formato yyyy-MM-dd
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vacunación'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Registrar última fecha de vacunación:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _fechaVacunacionController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Fecha de Vacunación',
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    _fechaVacunacionController.text = _formatDate(pickedDate);
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _medicamentosController,
              decoration: const InputDecoration(
                labelText: 'Descripción de Medicamentos',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (_fechaVacunacionController.text.isNotEmpty &&
                      _medicamentosController.text.isNotEmpty) {
                    try {
                      // Guarda la fecha y los medicamentos en la base de datos
                      await DBHelper.insertGanado({
                        'fecha_ultima_vacunacion':
                            _fechaVacunacionController.text,
                        'medicamentos': _medicamentosController.text,
                        // Rellena los campos restantes con valores predeterminados
                        'identificacion': '',
                        'arete_id': '',
                        'arete_siniga': '',
                        'padre': '',
                        'madre': '',
                        'fecha_nacimiento': '',
                        'descripcion': '',
                        'sexo': '',
                        'estado': '',
                        'foto': '',
                      });
                      _fechaVacunacionController.clear();
                      _medicamentosController.clear();
                      _loadRegisteredDates(); // Recarga las fechas registradas
                    } catch (e) {
                      print('Error al guardar la fecha: $e');
                    }
                  } else {
                    print(
                        'Debe ingresar una fecha y una descripción de medicamentos');
                  }
                },
                child: const Text('Guardar'),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _registeredDates.isEmpty
                  ? const Text(
                      'No hay fechas registradas.',
                      style:
                          TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    )
                  : ListView.builder(
                      itemCount: _registeredDates.length,
                      itemBuilder: (context, index) {
                        final date = _registeredDates[index]['fecha'];
                        final medicamentos =
                            _registeredDates[index]['medicamentos'];
                        return ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: Text(
                            'Fecha: $date',
                            style: const TextStyle(fontSize: 16),
                          ),
                          subtitle: medicamentos.isNotEmpty
                              ? Text('Medicamentos: $medicamentos')
                              : null,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteDate(
                                  date); // Llama al método para eliminar la fecha
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
