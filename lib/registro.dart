import 'package:flutter/material.dart';
import 'dart:io'; // Import for File
import 'package:image_picker/image_picker.dart'; // Import image_picker
import '../db_helper.dart';
import 'ver_ganado_page.dart'; // Import the new page

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _identificacionController =
      TextEditingController();
  final TextEditingController _areteIdController = TextEditingController();
  final TextEditingController _areteSinigaController = TextEditingController();
  final TextEditingController _padreController = TextEditingController();
  final TextEditingController _madreController = TextEditingController();
  final TextEditingController _fechaNacimientoController =
      TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  DateTime? _selectedDate;

  File? _selectedImage; // To store the selected image
  final ImagePicker _picker = ImagePicker(); // ImagePicker instance

  String _sexo = 'Macho';
  String _estado = 'Propiedad';
  String? _selectedUltimaVacunacionDate; // Fecha seleccionada de vacunación
  List<String> _fechasVacunacion =
      []; // Lista de fechas registradas en vacunación

  @override
  void initState() {
    super.initState();
    _loadFechasVacunacion(); // Carga las fechas registradas en vacunación
  }

  Future<void> _loadFechasVacunacion() async {
    try {
      final ganado =
          await DBHelper.getGanado(); // Obtén los datos de la base de datos
      setState(() {
        _fechasVacunacion = ganado
            .where((animal) => animal['fecha_ultima_vacunacion'] != null)
            .map<String>(
                (animal) => animal['fecha_ultima_vacunacion'] as String)
            .toList();
      });
    } catch (e) {
      print('Error al cargar las fechas de vacunación: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se seleccionó ninguna imagen.')),
        );
      }
    } catch (e) {
      print('Error al seleccionar la imagen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al abrir la cámara o galería: $e')),
      );
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Imagen'),
        content: const Text('Elige una opción para cargar la imagen.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera); // Abre la cámara
            },
            child: const Text('Cámara'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery); // Abre la galería
            },
            child: const Text('Galería'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Building RegistroPage');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Cabeza de Ganado'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 16),
              TextFormField(
                controller: _identificacionController,
                decoration: const InputDecoration(
                  labelText: 'Identificación',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Ingrese la Identificación' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _areteIdController,
                decoration: const InputDecoration(
                  labelText: 'Arete ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Ingrese el Arete ID' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _areteSinigaController,
                decoration: const InputDecoration(
                  labelText: 'Arete Siniga',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Ingrese el Arete Siniga' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _padreController,
                decoration: const InputDecoration(
                  labelText: 'Padre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _madreController,
                decoration: const InputDecoration(
                  labelText: 'Madre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fechaNacimientoController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Fecha de Nacimiento',
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                      _fechaNacimientoController.text =
                          '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
                    });
                  }
                },
                validator: (value) =>
                    value!.isEmpty ? 'Seleccione la fecha de nacimiento' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _selectedImage != null
                      ? Image.file(
                          _selectedImage!,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        )
                      : const Text('No se ha seleccionado una imagen'),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _showImageSourceDialog,
                    child: const Text('Seleccionar Foto'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedUltimaVacunacionDate,
                decoration: const InputDecoration(
                  labelText: 'Fecha de Última Vacunación',
                  border: OutlineInputBorder(),
                ),
                items: _fechasVacunacion
                    .map((fecha) => DropdownMenuItem(
                          value: fecha,
                          child: Text(fecha),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedUltimaVacunacionDate = value;
                  });
                },
                validator: (value) {
                  if (_fechasVacunacion.isEmpty) {
                    return 'No hay fechas disponibles';
                  }
                  if (value == null) {
                    return 'Seleccione una fecha de última vacunación';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _sexo,
                decoration: const InputDecoration(
                  labelText: 'Sexo',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Macho', child: Text('Macho')),
                  DropdownMenuItem(value: 'Hembra', child: Text('Hembra')),
                ],
                onChanged: (value) {
                  setState(() {
                    _sexo = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _estado,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'Propiedad', child: Text('Propiedad')),
                  DropdownMenuItem(value: 'Vendido', child: Text('Vendido')),
                ],
                onChanged: (value) {
                  setState(() {
                    _estado = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _guardarAnimal();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _guardarAnimal() async {
    String id = _identificacionController.text.trim();
    String areteId = _areteIdController.text.trim();
    String areteSiniga = _areteSinigaController.text.trim();
    String padre = _padreController.text.trim();
    String madre = _madreController.text.trim();
    String fechaNacimiento = _fechaNacimientoController.text.trim();
    String descripcion = _descripcionController.text.trim();

    // Debug statements to verify values
    print('Identificación: $id');
    print('Arete ID: $areteId');
    print('Arete Siniga: $areteSiniga');
    print('Padre: $padre');
    print('Madre: $madre');
    print('Fecha de Nacimiento: $fechaNacimiento');
    print('Descripción: $descripcion');
    print('Sexo: $_sexo');
    print('Estado: $_estado');

    // Construye el mapa de datos para insertar
    Map<String, dynamic> animal = {
      'identificacion': id,
      'arete_id': areteId,
      'arete_siniga': areteSiniga,
      'padre': padre,
      'madre': madre,
      'fecha_nacimiento': fechaNacimiento,
      'descripcion': descripcion,
      'sexo': _sexo,
      'estado': _estado,
      'foto': _selectedImage != null ? _selectedImage!.path : '',
      'medicamentos': '', // Valor predeterminado para medicamentos
    };

    print('Datos a insertar: $animal'); // Debug statement to log the data

    try {
      await DBHelper.insertGanado(animal);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Animal registrado en la base de datos'),
        ),
      );

      // Limpia los campos del formulario después de guardar
      _formKey.currentState!.reset();
      _identificacionController.clear();
      _areteIdController.clear();
      _areteSinigaController.clear();
      _padreController.clear();
      _madreController.clear();
      _fechaNacimientoController.clear();
      _descripcionController.clear();
      setState(() {
        _sexo = 'Macho';
        _estado = 'Propiedad';
        _selectedImage = null;
        _selectedUltimaVacunacionDate = null;
      });
    } catch (e) {
      print('Error al guardar el animal: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al guardar el animal: $e')),
      );
    }
  }
}
