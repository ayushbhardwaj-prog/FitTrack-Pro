import 'package:flutter/material.dart';

class WorkoutCard extends StatelessWidget {
  final String exercise;
  final String weight;
  final String sets;
  final String reps;
  final VoidCallback onDelete;

  const WorkoutCard({
    super.key,
    required this.exercise,
    required this.weight,
    required this.sets,
    required this.reps,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: ListTile(
        leading: const Icon(
          Icons.fitness_center,
          color: Colors.blueGrey,
        ),
        title: Text(
          exercise,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "$weight kg • $sets Sets • $reps Reps",
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
          onPressed: onDelete,
        ),
      ),
    );
  }
}