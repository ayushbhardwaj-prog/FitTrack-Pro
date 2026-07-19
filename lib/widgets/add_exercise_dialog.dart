import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../widgets/exercise_picker.dart';

class AddExerciseDialog extends StatefulWidget {
  final String workoutDay;
  final Function(Exercise) onSave;

  const AddExerciseDialog({
    super.key,
    required this.workoutDay,
    required this.onSave,
  });

  @override
  State<AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<AddExerciseDialog> {
  String? selectedExercise;

  final weightController = TextEditingController();
  final setsController = TextEditingController();
  final repsController = TextEditingController();

  @override
  void dispose() {
    weightController.dispose();
    setsController.dispose();
    repsController.dispose();
    super.dispose();
  }

  void saveExercise() {
    if (selectedExercise == null) return;

    final exercise = Exercise(
      workoutDay: widget.workoutDay,
      name: selectedExercise!,
      weight: double.tryParse(weightController.text) ?? 0,
      sets: int.tryParse(setsController.text) ?? 0,
      reps: int.tryParse(repsController.text) ?? 0,
    );

    widget.onSave(exercise);
    Navigator.pop(context);
  }

  Widget buildField(
    String label,
    TextEditingController controller,
    TextInputType type,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        textInputAction: TextInputAction.next,
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

@override
Widget build(BuildContext context) {
  return SafeArea(
    child: Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Center(
              child: Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Add Exercise (${widget.workoutDay})",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.search),
                label: Text(
                  selectedExercise ?? "Choose Exercise",
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => ExercisePicker(
                      workoutDay: widget.workoutDay,
                      onSelected: (exercise) {
                        setState(() {
                          selectedExercise = exercise.name;
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 18),

            buildField(
              "Weight (kg)",
              weightController,
              TextInputType.number,
            ),

            buildField(
              "Sets",
              setsController,
              TextInputType.number,
            ),

            buildField(
              "Reps",
              repsController,
              TextInputType.number,
            ),

            const SizedBox(height: 10),

            Row(
              children: [

                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: saveExercise,
                    icon: const Icon(Icons.save),
                    label: const Text("Save"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}