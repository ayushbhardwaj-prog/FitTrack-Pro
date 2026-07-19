import 'package:flutter/material.dart';

class ProgressDashboard extends StatelessWidget {
  final double volume;
  final int sets;
  final int exercises;
  final int workouts;

  const ProgressDashboard({
    super.key,
    required this.volume,
    required this.sets,
    required this.exercises,
    required this.workouts,
  });

  Widget buildRow(
    IconData icon,
    Color color,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [

          CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(.15),
            child: Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            buildRow(
              Icons.local_fire_department,
              Colors.orange,
              "Total Volume",
              "${volume.toInt()} kg",
            ),

            const Divider(),

            buildRow(
              Icons.layers,
              Colors.blue,
              "Sets",
              sets.toString(),
            ),

            const Divider(),

            buildRow(
              Icons.accessibility_new,
              Colors.green,
              "Exercises",
              exercises.toString(),
            ),

            const Divider(),

            buildRow(
              Icons.fitness_center,
              Colors.deepPurple,
              "Workouts",
              workouts.toString(),
            ),
          ],
        ),
      ),
    );
  }
}