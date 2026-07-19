class WorkoutDay {
  final String name;

  const WorkoutDay(this.name);

  static const List<WorkoutDay> all = [
    WorkoutDay("Chest"),
    WorkoutDay("Back"),
    WorkoutDay("Legs"),
    WorkoutDay("Shoulders"),
    WorkoutDay("Arms"),
    WorkoutDay("Cardio"),
  ];
}