import 'package:flutter/material.dart';
import '../db_helper.dart';
import '../widgets/animal_list.dart';

class GanadoPage extends StatelessWidget {
  const GanadoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ganado'),
        backgroundColor: Colors.green.shade700,
      ),
      body: AnimalList(ganadoFuture: DBHelper.getGanado()),
    );
  }
}
