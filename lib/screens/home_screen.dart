import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/workout_provider.dart';
import '../widgets/progress_dashboard.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onWorkoutPressed;

  const HomeScreen({
    super.key,
    required this.onWorkoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();

    final history = provider.workoutHistory;
    final lastWorkout = history.isNotEmpty ? history.first : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("FitTrack Pro"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Good Evening 👋",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              "Welcome back, Ayush",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Today's Progress",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            ProgressDashboard(
              volume: provider.totalVolume,
              sets: provider.totalSets,
              exercises: provider.totalExercises,
              workouts: provider.totalWorkouts,
            ),

            const SizedBox(height: 30),

            const Text(
              "Today's Activity",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [

                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(
                          Icons.fitness_center,
                          color: Colors.white,
                        ),
                      ),
                      title: const Text("Workouts Completed"),
                      subtitle: const Text("Today's sessions"),
                      trailing: Text(
                        provider.totalWorkouts.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const Divider(),

                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.orange,
                        child: Icon(
                          Icons.accessibility_new,
                          color: Colors.white,
                        ),
                      ),
                      title: const Text("Exercises Completed"),
                      subtitle: const Text("Total exercises"),
                      trailing: Text(
                        provider.totalExercises.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const Divider(),

                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        child: Icon(
                          Icons.monitor_weight,
                          color: Colors.white,
                        ),
                      ),
                      title: const Text("Total Volume"),
                      subtitle: const Text("Weight lifted"),
                      trailing: Text(
                        "${provider.totalVolume.toInt()} kg",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    if (lastWorkout != null) ...[
                      const Divider(),

                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(
                            Icons.timer,
                            color: Colors.white,
                          ),
                        ),
                        title: const Text("Workout Duration"),
                        subtitle: const Text("Latest workout"),
                        trailing: Text(
                          "${lastWorkout.durationMinutes} min",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(.10),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Row(
                        children: [

                          Icon(
                            Icons.trending_up,
                            color: Colors.green,
                          ),

                          SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              "Keep training consistently! 💪",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            Card(
  elevation: 5,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(18),
  ),
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: lastWorkout == null
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "No workouts completed yet 💪",
                style: TextStyle(fontSize: 18),
              ),
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                "Last Workout",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [

                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.green,
                    child: Icon(
                      Icons.fitness_center,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Text(
                          lastWorkout.day,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(.15),
                            borderRadius:
                                BorderRadius.circular(30),
                          ),
                          child: const Text(
                            "Latest Workout",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [

                  _buildChip(
                    Icons.sports_gymnastics,
                    "${lastWorkout.totalExercises}",
                    "Exercises",
                    Colors.green,
                  ),

                  _buildChip(
                    Icons.layers,
                    "${lastWorkout.totalSets}",
                    "Sets",
                    Colors.blue,
                  ),

                  _buildChip(
                    Icons.monitor_weight,
                    "${lastWorkout.totalVolume.toInt()} kg",
                    "Volume",
                    Colors.orange,
                  ),

                  _buildChip(
                    Icons.timer,
                    "${lastWorkout.durationMinutes} min",
                    "Duration",
                    Colors.deepPurple,
                  ),
                ],
              ),
            ],
          ),
  ),
),

const SizedBox(height: 30),

SizedBox(
  width: double.infinity,
  height: 60,
  child: ElevatedButton.icon(
    icon: Icon(
      provider.workoutStarted
          ? Icons.play_circle_fill_rounded
          : Icons.play_arrow,
    ),
    label: Text(
      provider.workoutStarted
          ? "Continue Workout"
          : "Start Workout",
      style: const TextStyle(
        fontSize: 20,
      ),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
    ),
    onPressed: onWorkoutPressed,
  ),
),
          ],
        ),
      ),
    );
  }
  Widget _buildChip(
  IconData icon,
  String value,
  String label,
  Color color,
) {
  return Container(
    width: 155,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withOpacity(.12),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        Icon(
          icon,
          color: color,
          size: 28,
        ),

        const SizedBox(height: 8),

        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}
}