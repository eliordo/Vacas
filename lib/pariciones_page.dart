import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Importa el paquete de notificaciones
import 'package:timezone/data/latest.dart' as tz; // Import timezone package
import 'package:timezone/timezone.dart' as tz;
import 'add_pregnant_cow_form.dart';
import 'db_helper.dart';

class ParicionesPage extends StatefulWidget {
  const ParicionesPage({super.key});

  @override
  State<ParicionesPage> createState() => _ParicionesPageState();
}

class _ParicionesPageState extends State<ParicionesPage> {
  List<Map<String, dynamic>> _pregnantCows = [];
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin(); // Instancia de notificaciones

  @override
  void initState() {
    super.initState();
    _initializeNotifications(); // Inicializa las notificaciones
    _loadPregnantCows();
    _removeExpiredPregnancies(); // Llama a la función al iniciar
  }

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones(); // Initialize timezone data
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('app_icon'); // Replace with your app icon
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(); // iOS-specific settings

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings, // Include iOS settings
    );

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        print('Notification tapped: ${response.payload}');
      },
    );
  }

  Future<void> _scheduleNotification(
      int id, String title, String body, DateTime scheduledTime) async {
    try {
      final tz.TZDateTime tzScheduledTime =
          tz.TZDateTime.from(scheduledTime, tz.local); // Convert to TZDateTime
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'pariciones_channel',
            'Pariciones',
            channelDescription: 'Notificaciones para pariciones',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print('Error al programar la notificación: $e');
    }
  }

  Future<void> _scheduleNotificationsForCow(
      Map<String, dynamic> cow, int daysLeft) async {
    final today = DateTime.now();
    final notificationTimes = {
      10: today.add(Duration(days: daysLeft - 10)),
      5: today.add(Duration(days: daysLeft - 5)),
      1: today.add(Duration(days: daysLeft - 1)),
    };

    for (final entry in notificationTimes.entries) {
      if (entry.key <= daysLeft && entry.value.isAfter(today)) {
        await _scheduleNotification(
          cow['id'] * 100 + entry.key, // ID único para cada notificación
          'Vaca próxima a dar a luz',
          'La vaca ${cow['madre']} está a ${entry.key} días de dar a luz.',
          entry.value,
        );
      }
    }
  }

  Future<void> _loadPregnantCows() async {
    try {
      final ganado = await DBHelper.getGanado();
      setState(() {
        _pregnantCows = ganado.where((animal) {
          return animal['padre'] != null &&
              animal['padre'].isNotEmpty &&
              animal['madre'] != null &&
              animal['madre'].isNotEmpty &&
              animal['fecha_fecundacion'] != null &&
              animal['fecha_fecundacion'].isNotEmpty;
        }).toList();
      });

      // Programa notificaciones para cada vaca
      for (final cow in _pregnantCows) {
        final daysLeft = _calculateDaysLeft(cow['fecha_fecundacion']);
        if (daysLeft > 0) {
          await _scheduleNotificationsForCow(cow, daysLeft);
        }
      }
    } catch (e) {
      print('Error al cargar las vacas preñadas: $e');
    }
  }

  Future<void> _removeExpiredPregnancies() async {
    try {
      final today = DateTime.now();
      const maxGestationDays = 285;

      // Filtra los registros que han excedido los 285 días
      final expiredPregnancies = _pregnantCows.where((animal) {
        final fecundacionDate = DateTime.parse(animal['fecha_fecundacion']);
        final daysSinceFecundacion = today.difference(fecundacionDate).inDays;
        return daysSinceFecundacion > maxGestationDays;
      }).toList();

      // Elimina los registros de la base de datos
      for (var animal in expiredPregnancies) {
        await DBHelper.deleteAnimalById(animal['id']);
      }

      // Recarga los datos después de eliminar
      await _loadPregnantCows();
    } catch (e) {
      print('Error al eliminar los registros de embarazo vencidos: $e');
    }
  }

  Future<String> _getParentName(String parentId) async {
    try {
      final ganado = await DBHelper.getGanado();
      final parent = ganado.firstWhere(
        (animal) => animal['id'].toString() == parentId,
        orElse: () => {'identificacion': 'Desconocido'}, // Default value
      );
      return parent['identificacion'] ?? 'Desconocido';
    } catch (e) {
      print('Error al obtener el nombre del padre/madre: $e');
      return 'Desconocido';
    }
  }

  double _calculateProgress(String fechaFecundacion) {
    try {
      final fecundacionDate = DateTime.parse(fechaFecundacion);
      final today = DateTime.now();
      const gestationDays = 290; // Duración máxima de la gestación en días

      // Calcula los días transcurridos desde la fecha de fecundación
      final daysSinceFecundacion = today.difference(fecundacionDate).inDays;

      // Calcula el progreso basado en los días transcurridos
      final progress = daysSinceFecundacion / gestationDays;

      return progress.clamp(
          0.0, 1.0); // Asegura que el progreso esté entre 0 y 1
    } catch (e) {
      print('Error al calcular el progreso: $e');
      return 0.0;
    }
  }

  int _calculateDaysLeft(String fechaFecundacion) {
    try {
      final fecundacionDate = DateTime.parse(fechaFecundacion);
      final today = DateTime.now();
      const gestationDays = 290; // Duración máxima de la gestación en días

      // Calcula los días transcurridos desde la fecha de fecundación
      final daysSinceFecundacion = today.difference(fecundacionDate).inDays;

      // Calcula los días restantes
      final daysLeft = gestationDays - daysSinceFecundacion;

      return daysLeft > 0 ? daysLeft : 0; // Asegura que no sea negativo
    } catch (e) {
      print('Error al calcular los días restantes: $e');
      return 0;
    }
  }

  Color _getProgressColor(double progress) {
    return Color.lerp(Colors.yellow, Colors.green, progress)!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pariciones y Destete'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Añadir Vaca Preñada'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade800,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddPregnantCowForm(),
                  ),
                ).then((_) async {
                  await _loadPregnantCows();
                  await _removeExpiredPregnancies(); // Verifica nuevamente después de añadir
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _pregnantCows.isEmpty
                  ? const Text(
                      'No hay vacas preñadas registradas.',
                      style:
                          TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    )
                  : ListView.builder(
                      itemCount: _pregnantCows.length,
                      itemBuilder: (context, index) {
                        final cow = _pregnantCows[index];
                        final progress =
                            _calculateProgress(cow['fecha_fecundacion']);
                        final daysLeft =
                            _calculateDaysLeft(cow['fecha_fecundacion']);
                        return FutureBuilder(
                          future: Future.wait([
                            _getParentName(cow['padre']),
                            _getParentName(cow['madre']),
                          ]),
                          builder:
                              (context, AsyncSnapshot<List<String>> snapshot) {
                            if (!snapshot.hasData) {
                              return const CircularProgressIndicator();
                            }
                            final padreName = snapshot.data![0];
                            final madreName = snapshot.data![1];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title:
                                    Text('Madre: $madreName (${cow['madre']})'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Padre: $padreName (${cow['padre']})'),
                                    Text(
                                        'Fecha de Fecundación: ${cow['fecha_fecundacion']}'),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: Colors.grey.shade300,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _getProgressColor(progress),
                                      ),
                                    ),
                                    Text(
                                      'Progreso: ${(progress * 100).toStringAsFixed(1)}%',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Días restantes: $daysLeft días',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
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
