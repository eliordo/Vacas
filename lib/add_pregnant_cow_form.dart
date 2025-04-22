import 'package:flutter/material.dart';
import 'db_helper.dart';

class AddPregnantCowForm extends StatefulWidget {
  const AddPregnantCowForm({super.key});

  @override
  State<AddPregnantCowForm> createState() => _AddPregnantCowFormState();
}

class _AddPregnantCowFormState extends State<AddPregnantCowForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fechaFecundacionController =
      TextEditingController();
  List<Map<String, dynamic>> _machos = [];
  List<Map<String, dynamic>> _hembras = [];
  String? _selectedMacho;
  String? _selectedHembra;

  @override
  void initState() {
    super.initState();
    _loadAnimals();
  }

  Future<void> _loadAnimals() async {
    try {
      final ganado = await DBHelper.getGanado();
      setState(() {
        _machos = ganado.where((animal) {
          final edad = _calculateAge(animal['fecha_nacimiento']);
          return animal['sexo'] == 'Macho' && edad >= 1.5; // Machos >= 1.5 años
        }).toList();
        _hembras = ganado.where((animal) {
          final edad = _calculateAge(animal['fecha_nacimiento']);
          return animal['sexo'] == 'Hembra' &&
              edad >= 1.5; // Hembras >= 1.5 años
        }).toList();
      });
    } catch (e) {
      print('Error al cargar los animales: $e');
    }
  }

  double _calculateAge(String? fechaNacimiento) {
    if (fechaNacimiento == null || fechaNacimiento.isEmpty) return 0;
    try {
      final birthDate = DateTime.parse(fechaNacimiento);
      final today = DateTime.now();
      final ageInMonths = (today.year - birthDate.year) * 12 +
          (today.month - birthDate.month) +
          (today.day >= birthDate.day ? 0 : -1);
      return ageInMonths / 12; // Convierte meses a años
    } catch (e) {
      print('Error al calcular la edad: $e');
      return 0;
    }
  }

  Future<void> _savePregnantCow() async {
    if (_formKey.currentState!.validate()) {
      try {
        final newPregnantCow = {
          'fecha_fecundacion': _fechaFecundacionController.text,
          'padre': _selectedMacho,
          'madre': _selectedHembra,
          // Otros campos necesarios
        };
        await DBHelper.insertGanado(
            newPregnantCow); // Guarda en la base de datos
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Vaca preñada registrada')),
        );
        Navigator.pop(context);
      } catch (e) {
        print('Error al guardar la vaca preñada: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error al guardar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Vaca Preñada'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _fechaFecundacionController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Fecha Aproximada de Fecundación',
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
                      _fechaFecundacionController.text =
                          '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
                    });
                  }
                },
                validator: (value) =>
                    value!.isEmpty ? 'Seleccione una fecha' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedMacho,
                decoration: const InputDecoration(
                  labelText: 'Seleccione el Macho',
                  border: OutlineInputBorder(),
                ),
                items: _machos
                    .map((macho) => DropdownMenuItem(
                          value: macho['id'].toString(),
                          child: Text(macho['identificacion'] ?? 'Sin ID'),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMacho = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Seleccione un macho' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedHembra,
                decoration: const InputDecoration(
                  labelText: 'Seleccione la Hembra',
                  border: OutlineInputBorder(),
                ),
                items: _hembras
                    .map((hembra) => DropdownMenuItem(
                          value: hembra['id'].toString(),
                          child: Text(hembra['identificacion'] ?? 'Sin ID'),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedHembra = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Seleccione una hembra' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _savePregnantCow,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
