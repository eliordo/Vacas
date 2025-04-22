import 'dart:io'; // Import for File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'db_helper.dart';

class EditarAnimalPage extends StatefulWidget {
  final Map<String, dynamic> animal; // Datos del animal a editar

  const EditarAnimalPage({super.key, required this.animal});

  @override
  State<EditarAnimalPage> createState() => _EditarAnimalPageState();
}

class _EditarAnimalPageState extends State<EditarAnimalPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _identificacionController;
  late TextEditingController _areteIdController;
  late TextEditingController _areteSinigaController;
  late TextEditingController _padreController;
  late TextEditingController _madreController;
  late TextEditingController _fechaNacimientoController;
  late TextEditingController _descripcionController;
  String _sexo = 'Macho';
  String _estado = 'Propiedad';
  File? _selectedImage; // Nueva imagen seleccionada
  final ImagePicker _picker = ImagePicker(); // Instancia de ImagePicker

  @override
  void initState() {
    super.initState();
    // Inicializa los controladores con los datos del animal
    _identificacionController =
        TextEditingController(text: widget.animal['identificacion']);
    _areteIdController = TextEditingController(text: widget.animal['arete_id']);
    _areteSinigaController =
        TextEditingController(text: widget.animal['arete_siniga']);
    _padreController = TextEditingController(text: widget.animal['padre']);
    _madreController = TextEditingController(text: widget.animal['madre']);
    _fechaNacimientoController =
        TextEditingController(text: widget.animal['fecha_nacimiento']);
    _descripcionController =
        TextEditingController(text: widget.animal['descripcion']);
    _sexo = widget.animal['sexo'] ?? 'Macho';
    _estado = widget.animal['estado'] ?? 'Propiedad';
    if (widget.animal['foto'] != null && widget.animal['foto'].isNotEmpty) {
      _selectedImage = File(widget.animal['foto']);
    }
  }

  @override
  void dispose() {
    _identificacionController.dispose();
    _areteIdController.dispose();
    _areteSinigaController.dispose();
    _padreController.dispose();
    _madreController.dispose();
    _fechaNacimientoController.dispose();
    _descripcionController.dispose();
    super.dispose();
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

  Future<void> _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      // Si se selecciona una nueva imagen, reemplaza la anterior
      String? nuevaRutaImagen =
          _selectedImage != null ? _selectedImage!.path : widget.animal['foto'];

      Map<String, dynamic> updatedAnimal = {
        'id': widget.animal['id'], // Asegúrate de incluir el ID del animal
        'identificacion': _identificacionController.text.trim(),
        'arete_id': _areteIdController.text.trim(),
        'arete_siniga': _areteSinigaController.text.trim(),
        'padre': _padreController.text.trim(),
        'madre': _madreController.text.trim(),
        'fecha_nacimiento': _fechaNacimientoController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'sexo': _sexo,
        'estado': _estado,
        'foto': nuevaRutaImagen, // Actualiza la ruta de la imagen
      };

      try {
        await DBHelper.updateAnimal(updatedAnimal); // Actualiza los datos
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Datos actualizados correctamente')),
        );
        Navigator.pop(context, true); // Regresa a la página anterior
      } catch (e) {
        print('Error al actualizar el animal: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error al actualizar el animal: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Animal'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_selectedImage != null)
                Image.file(
                  _selectedImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              else if (widget.animal['foto'] != null &&
                  widget.animal['foto'].isNotEmpty)
                Image.file(
                  File(widget.animal['foto']),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              else
                const Text('No se ha seleccionado una imagen'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _showImageSourceDialog,
                child: const Text('Seleccionar Nueva Imagen'),
              ),
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
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _areteSinigaController,
                decoration: const InputDecoration(
                  labelText: 'Arete Siniga',
                  border: OutlineInputBorder(),
                ),
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
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _fechaNacimientoController.text =
                          '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
                    });
                  }
                },
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
                label: const Text('Guardar Cambios'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _guardarCambios,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
