import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'db_helper.dart';

class CalendarioPage extends StatefulWidget {
  const CalendarioPage({Key? key}) : super(key: key);

  @override
  _CalendarioPageState createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  late Map<DateTime, List<String>> _events;
  late List<String> _selectedEvents;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _events = {};
    _selectedEvents = [];
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final ganado = await DBHelper.getGanado();
    final Map<DateTime, List<String>> events = {};

    for (var animal in ganado) {
      // Parse and add fecha_nacimiento
      if (animal['fecha_nacimiento'] != null &&
          animal['fecha_nacimiento'].isNotEmpty) {
        final date = DateTime.tryParse(animal['fecha_nacimiento']);
        if (date != null) {
          final normalizedDate = DateTime(date.year, date.month, date.day);
          events[normalizedDate] = (events[normalizedDate] ?? [])
            ..add('Nacimiento: ${animal['identificacion']}');
        } else {
          print(
              'Invalid fecha_nacimiento format: ${animal['fecha_nacimiento']}');
        }
      }

      // Parse and add fecha_fecundacion
      if (animal['fecha_fecundacion'] != null &&
          animal['fecha_fecundacion'].isNotEmpty) {
        final date = DateTime.tryParse(animal['fecha_fecundacion']);
        if (date != null) {
          final normalizedDate = DateTime(date.year, date.month, date.day);
          final nombre = animal['nombre'] ?? 'Sin Nombre'; // Fallback value
          events[normalizedDate] = (events[normalizedDate] ?? [])
            ..add('Fecundación: ${animal['identificacion']} ($nombre)');
          final partoDate = normalizedDate
              .add(const Duration(days: 283)); // Approx. 283 days for delivery
          events[partoDate] = (events[partoDate] ?? [])
            ..add('Posible Parto: ${animal['identificacion']} ($nombre)');
        } else {
          print(
              'Invalid fecha_fecundacion format: ${animal['fecha_fecundacion']}');
        }
      }

      // Parse and add fecha_ultima_vacunacion
      if (animal['fecha_ultima_vacunacion'] != null &&
          animal['fecha_ultima_vacunacion'].isNotEmpty) {
        final date = DateTime.tryParse(animal['fecha_ultima_vacunacion']);
        if (date != null) {
          final normalizedDate = DateTime(date.year, date.month, date.day);
          events[normalizedDate] = (events[normalizedDate] ?? [])
            ..add('Vacunación: ${animal['identificacion']}');
        } else {
          print(
              'Invalid fecha_ultima_vacunacion format: ${animal['fecha_ultima_vacunacion']}');
        }
      }
    }

    print('Loaded events: $events'); // Debug statement to check loaded events

    setState(() {
      _events = events;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Eventos'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: (day) {
              final normalizedDay = DateTime(day.year, day.month, day.day);
              final events = _events[normalizedDay] ?? [];
              print(
                  'Events for $normalizedDay: $events'); // Debug statement to check events for a day
              return events;
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _selectedEvents = _events[DateTime(selectedDay.year,
                        selectedDay.month, selectedDay.day)] ??
                    [];
              });
            },
            calendarStyle: CalendarStyle(
              markerDecoration: const BoxDecoration(
                color: Colors.green, // Green marker for all events
                shape: BoxShape.circle,
              ),
              markersMaxCount: 1, // Show only one marker per day
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false, // Disable the FormatButton
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedEvents.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_selectedEvents[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
