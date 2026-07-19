import 'package:flutter/material.dart';

class WorkoutDaySheet extends StatelessWidget {
  final Function(String) onSelected;

  const WorkoutDaySheet({
    super.key,
    required this.onSelected,
  });

  Widget tile(
    BuildContext context,
    String day,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color,
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
      title: Text(
        day,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.pop(context);
        onSelected(day);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [

          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                "Choose Workout",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          tile(
            context,
            "Chest",
            Icons.fitness_center,
            Colors.red,
          ),

          tile(
            context,
            "Back",
            Icons.sports_gymnastics,
            Colors.blue,
          ),

          tile(
            context,
            "Legs",
            Icons.directions_run,
            Colors.orange,
          ),

          tile(
            context,
            "Shoulders",
            Icons.accessibility_new,
            Colors.purple,
          ),

          tile(
            context,
            "Arms",
            Icons.fitness_center,
            Colors.teal,
          ),

          tile(
            context,
            "Cardio",
            Icons.favorite,
            Colors.pink,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}