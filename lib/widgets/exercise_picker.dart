import 'package:flutter/material.dart';
import '../data/exercise_data.dart';

class ExercisePicker extends StatefulWidget {
  final Function(ExerciseTemplate) onSelected;
  final String workoutDay;

  const ExercisePicker({
    super.key,
    required this.onSelected,
    required this.workoutDay,
  });

  @override
  State<ExercisePicker> createState() => _ExercisePickerState();
}

class _ExercisePickerState extends State<ExercisePicker> {
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final exercises = exerciseDatabase.where((exercise) {

      if (!exercise.workoutTypes.contains(widget.workoutDay)) {
        return false;
      }

      return exercise.name
          .toLowerCase()
          .contains(searchController.text.toLowerCase());

    }).toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .85,
      maxChildSize: .95,
      builder: (_, controller) {
        return Column(
          children: [
            const SizedBox(height: 10),

            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Choose Exercise",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search exercise...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),

            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: exercises.length,
                itemBuilder: (_, index) {
                  final exercise = exercises[index];

                  return ListTile(
                    leading: const Icon(Icons.fitness_center),
                    title: Text(exercise.name),
                    subtitle: Text(exercise.muscleGroup),

                    onTap: () {
                      widget.onSelected(exercise);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}