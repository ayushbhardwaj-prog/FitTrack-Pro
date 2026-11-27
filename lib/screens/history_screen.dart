import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/workout_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Workout History"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,

        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Delete History"),
                  content: const Text(
                    "Are you sure you want to delete all workout history?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Delete"),
                    ),
                  ],
                ),
              );

              if (!context.mounted) return;
              if (confirm == true) {
                await context.read<WorkoutProvider>().clearHistory();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (provider.cloudSyncing || provider.cloudError != null)
            MaterialBanner(
              content: Text(
                provider.cloudSyncing
                    ? 'Syncing workout history…'
                    : 'Cloud sync: ${provider.cloudError}',
              ),
              actions: [
                if (!provider.cloudSyncing)
                  TextButton(
                    onPressed: provider.isLoggedIn
                        ? () =>
                              context.read<WorkoutProvider>().syncCloudHistory()
                        : null,
                    child: const Text('RETRY'),
                  ),
                if (provider.cloudSyncing) const SizedBox.shrink(),
              ],
            ),
          Expanded(
            child: provider.workoutHistory.isEmpty
                ? const Center(
                    child: Text(
                      "No workouts completed yet 💪",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: provider.workoutHistory.length,
                    itemBuilder: (context, index) {
                      final workout = provider.workoutHistory[index];

                      return Dismissible(
                        key: ValueKey(workout.date),

                        direction: DismissDirection.endToStart,

                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),

                        confirmDismiss: (_) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Delete Workout"),
                              content: const Text(
                                "Delete this workout from your history?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Delete"),
                                ),
                              ],
                            ),
                          );
                        },

                        onDismissed: (_) async {
                          await context.read<WorkoutProvider>().deleteWorkout(
                            index,
                          );
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Workout deleted")),
                          );
                        },

                        child: Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Icon(
                                Icons.fitness_center,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              workout.day,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "${workout.totalExercises} exercises\n"
                              "${workout.totalSets} sets\n"
                              "Volume: ${workout.totalVolume.toStringAsFixed(0)} kg\n"
                              "🔥 Calories: ${workout.caloriesBurned} kcal\n"
                              "⏱ Duration: ${workout.durationMinutes} min",
                            ),
                            trailing: Text(
                              "${workout.date.day}/${workout.date.month}/${workout.date.year}",
                              style: const TextStyle(fontSize: 12),
                            ),
                            isThreeLine: false,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
