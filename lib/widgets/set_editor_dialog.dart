import 'package:flutter/material.dart';

import '../models/exercise_set.dart';

class SetEditorDialog extends StatefulWidget {
  final ExerciseSet? initialSet;

  final Function(ExerciseSet) onSave;

  final VoidCallback? onDelete;

  const SetEditorDialog({
    super.key,
    this.initialSet,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<SetEditorDialog> createState() =>
      _SetEditorDialogState();
}

class _SetEditorDialogState
    extends State<SetEditorDialog> {

  late TextEditingController weightController;
  late TextEditingController repsController;

  @override
  void initState() {
    super.initState();

    weightController = TextEditingController(
      text: widget.initialSet == null
          ? ""
          : widget.initialSet!.weight.toString(),
    );

    repsController = TextEditingController(
      text: widget.initialSet == null
          ? ""
          : widget.initialSet!.reps.toString(),
    );
  }

  @override
  void dispose() {
    weightController.dispose();
    repsController.dispose();
    super.dispose();
  }

  void save() {

    final weight =
        double.tryParse(weightController.text);

    final reps =
        int.tryParse(repsController.text);

    if (weight == null || reps == null) {
      return;
    }

    widget.onSave(

      ExerciseSet(

        weight: weight,

        reps: reps,

      ),

    );

    Navigator.pop(context);

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
              widget.initialSet == null
                  ? "Add Set"
                  : "Edit Set",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            //--------------------------------------------------
            // Weight
            //--------------------------------------------------

            TextField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: "Weight (kg)",
                prefixIcon: const Icon(
                  Icons.fitness_center,
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            //--------------------------------------------------
            // Reps
            //--------------------------------------------------

            TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Repetitions",
                prefixIcon: const Icon(
                  Icons.repeat,
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 30),
                        //--------------------------------------------------
            // Delete Button (Only when editing)
            //--------------------------------------------------

            if (widget.initialSet != null &&
                widget.onDelete != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onDelete!();
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text("Delete Set"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(
                      color: Colors.red,
                    ),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

            if (widget.initialSet != null)
              const SizedBox(height: 15),

            //--------------------------------------------------
            // Bottom Buttons
            //--------------------------------------------------

            Row(
              children: [

                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize:
                          const Size.fromHeight(55),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: save,
                    icon: const Icon(Icons.check),
                    label: Text(
                      widget.initialSet == null
                          ? "Add"
                          : "Save",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.blue,
                      foregroundColor:
                          Colors.white,
                      minimumSize:
                          const Size.fromHeight(55),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

              ],
            ),

            const SizedBox(height: 10),

          ],
        ),
      ),
    ),
  );
}
}