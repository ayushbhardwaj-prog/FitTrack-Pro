import 'package:flutter/material.dart';
import '../widgets/set_editor_dialog.dart';
import '../providers/workout_provider.dart';
import '../models/exercise.dart';
import '../models/exercise_set.dart';


class ExerciseList extends StatefulWidget {
  final WorkoutProvider provider;

  const ExerciseList({
    super.key,
    required this.provider,
  });
  @override
State<ExerciseList> createState() =>
    _ExerciseListState();
}

class _ExerciseListState
    extends State<ExerciseList> {

  final Set<int> expandedCards = {};

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
    final exercises =
    widget.provider.currentWorkout?.exercises ?? [];

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

                    InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {

                        setState(() {

                          if (expandedCards.contains(index)) {
                            expandedCards.remove(index);
                          } else {
                            expandedCards.add(index);
                          }

                        });

                      },

                      child: Row(
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

                          Icon(
                            expandedCards.contains(index)
                                ? Icons.expand_less
                                : Icons.expand_more,
                          ),

                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Column(
                  children: [
                    AnimatedCrossFade(

                      firstChild: const SizedBox(),

                      secondChild: Column(

                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          // <-- paste your Sets section here

                          // <-- Statistics Card

                          // <-- Delete Button

                        ],

                      ),

                      crossFadeState:
                          expandedCards.contains(index)
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,

                      duration:
                          const Duration(milliseconds: 300),

                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [

                          Expanded(
                            child: Text(
                              "SET",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Expanded(
                            child: Text(
                              "KG",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Expanded(
                            child: Text(
                              "REPS",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    ...exercise.sets.asMap().entries.map((entry) {

                      final setIndex = entry.key;
                      final set = entry.value;

                      return Container(

                        margin: const EdgeInsets.only(bottom: 8),

                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: Row(
                          children: [

                            Expanded(
                              child: Text(
                                "${setIndex + 1}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            Expanded(
                              child: Text(
                                set.weight.toStringAsFixed(1),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            Expanded(
                              child: Text(
                                "${set.reps}",
                                textAlign: TextAlign.center,
                              ),
                            ),

                          ],
                        ),
                      );

                    }),

                  ],
                ),
                const SizedBox(height: 16),

                Card(
                  elevation: 2,
                  color: Colors.blue.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [

                        _buildWorkoutStat(
                          Icons.layers,
                          "${exercise.totalSets}",
                          "Sets",
                        ),

                        _buildWorkoutStat(
                          Icons.repeat,
                          "${exercise.totalReps}",
                          "Reps",
                        ),

                        _buildWorkoutStat(
                          Icons.fitness_center,
                          "${exercise.totalVolume.toStringAsFixed(0)}",
                          "Volume",
                        ),

                        _buildWorkoutStat(
                          Icons.local_fire_department,
                          "${exercise.estimatedCalories.toStringAsFixed(0)}",
                          "kcal",
                        ),

                      ],
                    ),
                  ),
                ),


                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Add Set"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => SetEditorDialog(
                          onSave: (newSet) {
                            widget.provider.addSetToExercise(
                              index,
                              newSet,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          widget.provider.deleteExercise(index);
                        },
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

Widget _buildWorkoutStat(
  IconData icon,
  String value,
  String label,
) {
  return Column(
    children: [

      Icon(
        icon,
        color: Colors.blue,
        size: 22,
      ),

      const SizedBox(height: 6),

      Text(
        value,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),

      Text(
        label,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 13,
        ),
      ),

    ],
  );
}
}