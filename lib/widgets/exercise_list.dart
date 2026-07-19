import 'package:flutter/material.dart';

import '../models/exercise.dart';

class ExerciseList extends StatelessWidget {
  final List<Exercise> exercises;
  final Function(int) onDelete;

  const ExerciseList({
    super.key,
    required this.exercises,
    required this.onDelete,
  });

  IconData _getIcon(String day) {
    switch (day) {
      case "Chest":
        return Icons.fitness_center;
      case "Back":
        return Icons.sports_gymnastics;
      case "Legs":
        return Icons.directions_run;
      case "Shoulders":
        return Icons.accessibility_new;
      case "Arms":
        return Icons.sports_mma;
      case "Cardio":
        return Icons.favorite;
      default:
        return Icons.fitness_center;
    }
  }

  Color _getColor(String day) {
    switch (day) {
      case "Chest":
        return Colors.red;
      case "Back":
        return Colors.blue;
      case "Legs":
        return Colors.orange;
      case "Shoulders":
        return Colors.purple;
      case "Arms":
        return Colors.teal;
      case "Cardio":
        return Colors.pink;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (exercises.isEmpty) {
      return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [

            Icon(
              Icons.fitness_center,
              size: 80,
              color: Colors.grey,
            ),

            SizedBox(height: 20),

            Text(
              "No Exercises Yet",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8),

            Text(
              "Tap the + button to add your first exercise.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];

        return Card(
          elevation: 5,
          margin: const EdgeInsets.only(bottom: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Row(
                  children: [

                    CircleAvatar(
                      radius: 24,
                      backgroundColor:
                          _getColor(exercise.workoutDay),
                      child: Icon(
                        _getIcon(exercise.workoutDay),
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(width: 14),

                                        Expanded(
                      child: Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Row(
                  children: [

                    Expanded(
                      child: _buildStatChip(
                        Icons.monitor_weight,
                        "${exercise.weight.toStringAsFixed(1)} kg",
                      ),
                    ),
                      const SizedBox(width: 10),

                        Expanded(
                          child: _buildStatChip(
                            Icons.repeat,
                            "${exercise.sets} Sets",
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _buildStatChip(
                            Icons.tag,
                            "${exercise.reps} Reps",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => onDelete(index),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text("Delete Exercise"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(
                            color: Colors.red,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }

      Widget _buildStatChip(
        IconData icon,
        String value,
      ) {
        return Container(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: Colors.green,
                size: 20,
              ),
              const SizedBox(height: 6),
              Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      }
    }