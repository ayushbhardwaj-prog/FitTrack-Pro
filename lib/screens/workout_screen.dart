import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exercise.dart';
import '../providers/workout_provider.dart';
import '../widgets/add_exercise_dialog.dart';
import '../widgets/current_workout_card.dart';
import '../widgets/exercise_list.dart';
import '../widgets/workout_day_sheet.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {

  @override
  void initState() {
    super.initState();
  }

  Future<void> startWorkout(String day) async {
  final provider = context.read<WorkoutProvider>();

  final intensity = await showDialog<String>(
    context: context,
    builder: (context) {
      return SimpleDialog(
        title: const Text("Select Workout Intensity"),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, "Light"),
            child: const ListTile(
              leading: Icon(
                Icons.circle,
                color: Color.fromARGB(255, 35, 52, 66),
              ),
              title: Text("Light"),
              subtitle: Text("≈ 4 kcal/min"),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, "Moderate"),
            child: const ListTile(
              leading: Icon(
                Icons.circle,
                color: Colors.orange,
              ),
              title: Text("Moderate"),
              subtitle: Text("≈ 6 kcal/min"),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, "Heavy"),
            child: const ListTile(
              leading: Icon(
                Icons.circle,
                color: Colors.red,
              ),
              title: Text("Heavy"),
              subtitle: Text("≈ 8 kcal/min"),
            ),
          ),
        ],
      );
    },
  );

  if (intensity == null) return;

  provider.setWorkoutIntensity(intensity);
  provider.startWorkout(day);
}
  Future<void> finishWorkout() async {
  await context.read<WorkoutProvider>().finishWorkout();

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Workout saved successfully! 💪"),
      backgroundColor: Colors.blue,
    ),
  );
}

  void addExercise() {
    final provider = context.read<WorkoutProvider>();

    if (provider.currentWorkout == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color.fromARGB(255, 43, 67, 87),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) => AddExerciseDialog(
        workoutDay: provider.currentWorkout!.day,
        onSave: (Exercise exercise) {
          provider.addExercise(exercise);
        },
      ),
    );
  }

  void deleteExercise(int index) {
    context.read<WorkoutProvider>().deleteExercise(index);
  }

  @override
Widget build(BuildContext context) {
  final provider = context.watch<WorkoutProvider>();

  return Scaffold(
    appBar: AppBar(
      title: const Text("Workout"),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),

    floatingActionButton: FloatingActionButton.extended(
      backgroundColor: Colors.blue,
      icon: Icon(
        provider.workoutStarted
            ? Icons.add
            : Icons.play_arrow,
      ),
      label: Text(
        provider.workoutStarted
            ? "Add Exercise"
            : "Start Workout",
      ),
      onPressed: () {
        if (!provider.workoutStarted) {
          showModalBottomSheet(
            context: context,
            builder: (_) => WorkoutDaySheet(
              onSelected: startWorkout,
            ),
          );
        } else {
          addExercise();
        }
      },
    ),

    body: Column(
      children: [

        if (provider.currentWorkout != null)
          CurrentWorkoutCard(
            workout: provider.currentWorkout!,
            onFinish: finishWorkout,
          ),

        Expanded(
          child: ExerciseList(
            provider: provider,
          ),
        ),
      ],
    ),
  );
}
}