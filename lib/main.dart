import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vacas/ver_ganado_page.dart';
import 'db_helper.dart';
import '/registro.dart';
import '/vacunacion.dart';
import 'package:vacas/pariciones_page.dart'; // Importa la página de vacunación
import 'calendario.dart'; // Import CalendarioPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized
  if (!kIsWeb) {
    // Initialize FFI for non-web platforms
    sqfliteFfiInit();
    // Set the database factory
    databaseFactory = databaseFactoryFfi;
  }

  await DBHelper.initDB(); // Initialize the database
  await DBHelper
      .verifyDatabaseSchema(); // Verifica el esquema de la base de datos

  runApp(const VacasApp());
}

class VacasApp extends StatelessWidget {
  const VacasApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('Building VacasApp');
    return MaterialApp(
      title: 'Administración de Ganado - Vacas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade700),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _deleteDatabase(BuildContext context) async {
    try {
      await DBHelper
          .deleteDatabaseFile(); // Llama al método para borrar la base de datos
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('✅ Base de datos eliminada correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al eliminar la base de datos: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building HomePage');
    return Scaffold(
      appBar: AppBar(
        title: const Text('🐄 Administración de Ganado'),
        backgroundColor: Colors.green.shade700,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          MenuButton(
            icon: Icons.list_alt,
            title: 'Mi Ganado',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VerGanadoPage()),
              );
            },
          ),
          MenuButton(
            icon: Icons.assignment,
            title: 'Registro y Clasificación',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegistroPage()),
              );
            },
          ),
          MenuButton(
            icon: Icons.pregnant_woman,
            title: 'Pariciones',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ParicionesPage()),
              );
            },
          ),
          MenuButton(
            icon: Icons.vaccines,
            title: 'Vacunación y Salud',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VacunacionPage()),
              );
            },
          ),
          MenuButton(
            icon: Icons.health_and_safety,
            title: 'Complicaciones y Enfermedades',
            onTap: () {
              // TODO: Navegar a Salud
            },
          ),
          MenuButton(
            icon: Icons.calendar_today,
            title: 'Calendario',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalendarioPage()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _deleteDatabase(context),
            backgroundColor: Colors.red,
            child: const Icon(Icons.delete),
            tooltip: 'Eliminar Base de Datos',
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () async {
              await DBHelper.deleteDatabaseFile();
              print('Database deleted. Restart the app to recreate it.');
            },
            backgroundColor: Colors.orange,
            child: const Icon(Icons.restart_alt),
            tooltip: 'Eliminar y Reiniciar Base de Datos',
          ),
        ],
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const MenuButton({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, size: 32, color: Colors.green.shade800),
        title: Text(title, style: const TextStyle(fontSize: 18)),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
