import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DBHelper {
  static Database? _database;

  // Inicializar la base de datos
  static Future<void> initDB() async {
    if (_database != null)
      return; // Asegúrate de inicializar la base de datos solo una vez
    if (kIsWeb) {
      // En la web no se puede usar sqflite
      return;
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'ganado.db');

    _database = await openDatabase(
      path,
      version: 4, // Incrementa la versión de la base de datos
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ganado (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            identificacion TEXT,
            arete_id TEXT,
            arete_siniga TEXT,
            padre TEXT,
            madre TEXT,
            fecha_nacimiento TEXT,
            descripcion TEXT,
            sexo TEXT,
            estado TEXT,
            foto TEXT,
            fecha_ultima_vacunacion TEXT,
            medicamentos TEXT,
            fecha_fecundacion TEXT,
            nombre TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE ganado ADD COLUMN medicamentos TEXT');
        }
        if (oldVersion < 3) {
          await db
              .execute('ALTER TABLE ganado ADD COLUMN fecha_fecundacion TEXT');
        }
        if (oldVersion < 4) {
          print('Upgrading database to version 4: Adding "nombre" column.');
          await db.execute('ALTER TABLE ganado ADD COLUMN nombre TEXT');
        }
      },
    );
  }

  // Verifica que la base de datos esté inicializada
  static Future<Database> _getDatabase() async {
    if (_database == null) {
      await initDB();
    }
    if (_database == null) {
      throw Exception('La base de datos no se pudo inicializar.');
    }
    return _database!;
  }

  // Eliminar la base de datos
  static Future<void> deleteDatabaseFile() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'ganado.db');
    try {
      await deleteDatabase(path);
      _database =
          null; // Asegúrate de reiniciar la referencia a la base de datos
      print('Base de datos eliminada: $path');
    } catch (e) {
      print('Error al eliminar la base de datos: $e');
    }
  }

  // Insertar un animal en la base de datos
  static Future<void> insertGanado(Map<String, dynamic> animal) async {
    final db =
        await _getDatabase(); // Asegúrate de que la base de datos esté inicializada
    try {
      // Debug statement to log the data being inserted
      print('Insertando en la base de datos: $animal');
      await db.insert(
        'ganado',
        {
          'identificacion': animal['identificacion'] ?? '',
          'arete_id': animal['arete_id'] ?? '', // Ensure arete_id is inserted
          'arete_siniga':
              animal['arete_siniga'] ?? '', // Ensure arete_siniga is inserted
          'padre': animal['padre'] ?? '',
          'madre': animal['madre'] ?? '',
          'fecha_nacimiento': animal['fecha_nacimiento'] ?? '',
          'descripcion': animal['descripcion'] ?? '',
          'sexo': animal['sexo'] ?? '',
          'estado': animal['estado'] ?? '',
          'foto': animal['foto'] ?? '',
          'fecha_ultima_vacunacion': animal['fecha_ultima_vacunacion'] ?? '',
          'medicamentos': animal['medicamentos'] ?? '',
          'fecha_fecundacion': animal['fecha_fecundacion'] ?? '',
          'nombre': animal['nombre'] ?? '',
        },
        conflictAlgorithm:
            ConflictAlgorithm.ignore, // Evita sobrescribir registros existentes
      );
    } catch (e) {
      print('Error inserting animal: $e');
      throw Exception('Error inserting animal');
    }
  }

  // Obtener la lista de ganado registrado
  static Future<List<Map<String, dynamic>>> getGanado() async {
    final db = await _getDatabase();
    try {
      // Ensure all relevant fields are retrieved, including 'nombre'
      final result = await db.query(
        'ganado',
        columns: [
          'id',
          'identificacion',
          'nombre', // Include the 'nombre' field
          'fecha_nacimiento',
          'fecha_ultima_vacunacion',
          'fecha_fecundacion',
          'sexo',
          'estado',
          'foto',
        ],
      );
      print('Datos obtenidos de la base de datos: $result'); // Debug statement
      return result;
    } catch (e) {
      print('Error al obtener los datos: $e');
      throw Exception('Error al obtener los datos');
    }
  }

  // Eliminar un registro por fecha
  static Future<void> deleteGanadoByDate(String date) async {
    final db =
        await _getDatabase(); // Asegúrate de que la base de datos esté inicializada
    try {
      await db.delete(
        'ganado',
        where: 'fecha_ultima_vacunacion = ?',
        whereArgs: [date],
      );
    } catch (e) {
      print('Error al eliminar el registro: $e');
      throw Exception('Error al eliminar el registro');
    }
  }

  // Eliminar un registro por ID
  static Future<void> deleteAnimalById(int id) async {
    final db = await _getDatabase();
    try {
      await db.delete(
        'ganado',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error al eliminar el registro por ID: $e');
      throw Exception('Error al eliminar el registro por ID');
    }
  }

  // Actualizar medicamentos por fecha
  static Future<void> updateMedicamentosByDate(
      String date, String medicamentos) async {
    final db =
        await _getDatabase(); // Asegúrate de que la base de datos esté inicializada
    try {
      final int count = await db.update(
        'ganado',
        {'medicamentos': medicamentos},
        where: 'fecha_ultima_vacunacion = ?',
        whereArgs: [date],
      );
      if (count == 0) {
        throw Exception(
            'No se encontró un registro con la fecha especificada.');
      }
    } catch (e) {
      print('Error al actualizar los medicamentos: $e');
      throw Exception('Error al actualizar los medicamentos: $e');
    }
  }

  // Actualizar los datos de un animal
  static Future<void> updateAnimal(Map<String, dynamic> animal) async {
    final db = await _getDatabase();
    try {
      await db.update(
        'ganado',
        animal,
        where: 'id = ?',
        whereArgs: [animal['id']],
      );
    } catch (e) {
      print('Error al actualizar el animal: $e');
      throw Exception('Error al actualizar el animal');
    }
  }

  // Verificar el esquema de la base de datos
  static Future<void> verifyDatabaseSchema() async {
    final db = await _getDatabase();
    try {
      final result = await db.rawQuery('PRAGMA table_info(ganado)');
      print('Esquema de la tabla ganado: $result');
    } catch (e) {
      print('Error al verificar el esquema de la base de datos: $e');
    }
  }
}
