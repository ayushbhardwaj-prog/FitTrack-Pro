import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/exercise_set.dart';
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

  //--------------------------------------------------
  // Selected Exercise
  //--------------------------------------------------

  String? selectedExercise;

  //--------------------------------------------------
  // Dynamic Sets
  //--------------------------------------------------

  final List<TextEditingController> weightControllers = [];
  final List<TextEditingController> repsControllers = [];

  //--------------------------------------------------
  // Init
  //--------------------------------------------------

  @override
  void initState() {
    super.initState();
    addSet();
  }

  //--------------------------------------------------
  // Add New Set
  //--------------------------------------------------

  void addSet() {

  final weight = TextEditingController();
  final reps = TextEditingController();

  weight.addListener(() {
    setState(() {});
  });

  reps.addListener(() {
    setState(() {});
  });

  setState(() {

    weightControllers.add(weight);

    repsControllers.add(reps);

  });

}

  //--------------------------------------------------
  // Remove Set
  //--------------------------------------------------

  void removeSet(int index) {

    setState(() {

      weightControllers[index].dispose();
      repsControllers[index].dispose();

      weightControllers.removeAt(index);
      repsControllers.removeAt(index);

    });

  }

  //--------------------------------------------------
  // Dispose
  //--------------------------------------------------

  @override
  void dispose() {

    for (final controller in weightControllers) {
      controller.dispose();
    }

    for (final controller in repsControllers) {
      controller.dispose();
    }

    super.dispose();

  }

  //--------------------------------------------------
  // Save Exercise
  //--------------------------------------------------

  void saveExercise() {

    if (selectedExercise == null) return;

    final exerciseSets = <ExerciseSet>[];

    for (int i = 0; i < weightControllers.length; i++) {

      exerciseSets.add(

        ExerciseSet(

          weight: double.tryParse(
                  weightControllers[i].text) ??
              0,

          reps: int.tryParse(
                  repsControllers[i].text) ??
              0,

        ),

      );

    }

    final exercise = Exercise(

      workoutDay: widget.workoutDay,

      name: selectedExercise!,

      sets: exerciseSets,

    );

    widget.onSave(exercise);

    Navigator.pop(context);

  }

@override
Widget buildSetCard(int index) {
  return Card(
    margin: const EdgeInsets.only(bottom: 18),
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              Text(
                "Set ${index + 1}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              if (weightControllers.length > 1)

                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    removeSet(index);
                  },
                ),

            ],
          ),

          const SizedBox(height: 15),

          TextField(
            controller: weightControllers[index],
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Weight (kg)",
              prefixIcon: const Icon(Icons.fitness_center),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: repsControllers[index],
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Reps",
              prefixIcon: const Icon(Icons.repeat),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
  double getTotalVolume() {

  double volume = 0;

  for (int i = 0; i < weightControllers.length; i++) {

    final weight =
        double.tryParse(weightControllers[i].text) ?? 0;

    final reps =
        int.tryParse(repsControllers[i].text) ?? 0;

    volume += weight * reps;
  }

  return volume;
}
  double getEstimatedCalories() {

  return getTotalVolume() / 75;

}
@override
Widget build(BuildContext context) {
  return SafeArea(
    child: Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              //--------------------------------------------------
              // Drag Handle
              //--------------------------------------------------

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

              //--------------------------------------------------
              // Title
              //--------------------------------------------------

              Text(
                "Add Exercise",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                widget.workoutDay,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 25),

              //--------------------------------------------------
              // Exercise Picker
              //--------------------------------------------------

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: Text(
                    selectedExercise ?? "Choose Exercise",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(55),
                  ),
                  onPressed: () {

                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,

                      builder: (_) => ExercisePicker(
                        workoutDay: widget.workoutDay,
                        onSelected: (exercise) {

                          setState(() {

                            selectedExercise =
                                exercise.name;

                          });

                        },
                      ),

                    );

                  },
                ),
              ),

              const SizedBox(height: 25),

              //--------------------------------------------------
              // Sets
              //--------------------------------------------------

              ...List.generate(
                weightControllers.length,
                (index) => buildSetCard(index),
              ),

              //--------------------------------------------------
              // Add Set Button
              //--------------------------------------------------

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(

                  onPressed: addSet,

                  icon: const Icon(Icons.add),

                  label: const Text(
                    "Add Set",
                  ),

                ),
              ),

              const SizedBox(height: 25),

              //--------------------------------------------------
              // Live Statistics
              //--------------------------------------------------

              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [

                      Row(
                        children: [

                          const Icon(
                            Icons.bar_chart,
                            color: Colors.blue,
                          ),

                          const SizedBox(width: 10),

                          const Text(
                            "Workout Statistics",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [

                          const Text("Total Sets"),

                          Text(
                            "${weightControllers.length}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [

                          const Text("Volume"),

                          Text(
                            "${getTotalVolume().toStringAsFixed(0)} kg",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [

                          const Text("Calories"),

                          Text(
                            "${getEstimatedCalories().toStringAsFixed(0)} kcal",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
                            //--------------------------------------------------
              // Buttons
              //--------------------------------------------------

              Row(
                children: [

                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: ElevatedButton.icon(

                      onPressed: selectedExercise == null
                          ? null
                          : saveExercise,

                      icon: const Icon(Icons.save),

                      label: const Text(
                        "Save",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                ],
              ),

              const SizedBox(height: 20),

            ],
          ),
        ),
      ),
    ),
  );
}
}
