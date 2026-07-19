class ExerciseTemplate {
  final String name;
  final String muscleGroup;
  final List<String> workoutTypes;

  const ExerciseTemplate({
    required this.name,
    required this.muscleGroup,
    required this.workoutTypes,
  });
}
const List<ExerciseTemplate> exerciseDatabase = [

  // =========================
  // CHEST
  // =========================

  ExerciseTemplate(
    name: "Bench Press",
    muscleGroup: "Chest",
    workoutTypes: ["Chest", "Push"],
  ),
  ExerciseTemplate(
    name: "Incline Bench Press",
    muscleGroup: "Chest",
    workoutTypes: ["Chest", "Push"],
  ),
  ExerciseTemplate(
    name: "Decline Bench Press",
    muscleGroup: "Chest",
    workoutTypes: ["Chest", "Push"],
  ),
  ExerciseTemplate(
    name: "Flat Dumbbell Press",
    muscleGroup: "Chest",
    workoutTypes: ["Chest", "Push"],
  ),
  ExerciseTemplate(
    name: "Incline Dumbbell Press",
    muscleGroup: "Chest",
    workoutTypes: ["Chest", "Push"],
  ),
  ExerciseTemplate(
    name: "Chest Press Machine",
    muscleGroup: "Chest",
    workoutTypes: ["Chest", "Push"],
  ),
  ExerciseTemplate(
    name: "Cable Fly",
    muscleGroup: "Chest",
    workoutTypes: ["Chest", "Push"],
  ),
  ExerciseTemplate(
    name: "Pec Deck",
    muscleGroup: "Chest",
    workoutTypes: ["Chest", "Push"],
  ),
  ExerciseTemplate(
    name: "Dips",
    muscleGroup: "Chest",
    workoutTypes: ["Chest", "Push"],
  ),

  // =========================
  // BACK
  // =========================

  ExerciseTemplate(
    name: "Wide Grip Lat Pulldown",
    muscleGroup: "Back",
    workoutTypes: ["Back", "Pull"],
  ),
  ExerciseTemplate(
    name: "Close Grip Lat Pulldown",
    muscleGroup: "Back",
    workoutTypes: ["Back", "Pull"],
  ),
  ExerciseTemplate(
    name: "Seated Cable Row",
    muscleGroup: "Back",
    workoutTypes: ["Back", "Pull"],
  ),
  ExerciseTemplate(
    name: "Chest Supported Row",
    muscleGroup: "Back",
    workoutTypes: ["Back", "Pull"],
  ),
  ExerciseTemplate(
    name: "T-Bar Row",
    muscleGroup: "Back",
    workoutTypes: ["Back", "Pull"],
  ),
  ExerciseTemplate(
    name: "Barbell Row",
    muscleGroup: "Back",
    workoutTypes: ["Back", "Pull"],
  ),
  ExerciseTemplate(
    name: "One Arm Dumbbell Row",
    muscleGroup: "Back",
    workoutTypes: ["Back", "Pull"],
  ),
  ExerciseTemplate(
    name: "Deadlift",
    muscleGroup: "Back",
    workoutTypes: ["Back", "Pull"],
  ),
  ExerciseTemplate(
    name: "Pull-ups",
    muscleGroup: "Back",
    workoutTypes: ["Back", "Pull"],
  ),

  // =========================
  // SHOULDERS
  // =========================

  ExerciseTemplate(
    name: "Shoulder Press",
    muscleGroup: "Shoulders",
    workoutTypes: ["Shoulders", "Push"],
  ),
  ExerciseTemplate(
    name: "Machine Shoulder Press",
    muscleGroup: "Shoulders",
    workoutTypes: ["Shoulders", "Push"],
  ),
  ExerciseTemplate(
    name: "Arnold Press",
    muscleGroup: "Shoulders",
    workoutTypes: ["Shoulders", "Push"],
  ),
  ExerciseTemplate(
    name: "Lateral Raise",
    muscleGroup: "Shoulders",
    workoutTypes: ["Shoulders", "Push"],
  ),
  ExerciseTemplate(
    name: "Cable Lateral Raise",
    muscleGroup: "Shoulders",
    workoutTypes: ["Shoulders", "Push"],
  ),
  ExerciseTemplate(
    name: "Rear Delt Fly",
    muscleGroup: "Shoulders",
    workoutTypes: ["Shoulders", "Push"],
  ),
  ExerciseTemplate(
    name: "Face Pull",
    muscleGroup: "Shoulders",
    workoutTypes: ["Shoulders", "Pull"],
  ),

  // =========================
  // BICEPS
  // =========================

  ExerciseTemplate(
    name: "Barbell Curl",
    muscleGroup: "Biceps",
    workoutTypes: ["Arms", "Pull"],
  ),
  ExerciseTemplate(
    name: "EZ Bar Curl",
    muscleGroup: "Biceps",
    workoutTypes: ["Arms", "Pull"],
  ),
  ExerciseTemplate(
    name: "Hammer Curl",
    muscleGroup: "Biceps",
    workoutTypes: ["Arms", "Pull"],
  ),
  ExerciseTemplate(
    name: "Preacher Curl",
    muscleGroup: "Biceps",
    workoutTypes: ["Arms", "Pull"],
  ),
  ExerciseTemplate(
    name: "Cable Curl",
    muscleGroup: "Biceps",
    workoutTypes: ["Arms", "Pull"],
  ),

  // =========================
  // TRICEPS
  // =========================

  ExerciseTemplate(
    name: "Rope Pushdown",
    muscleGroup: "Triceps",
    workoutTypes: ["Arms", "Push"],
  ),
  ExerciseTemplate(
    name: "Straight Bar Pushdown",
    muscleGroup: "Triceps",
    workoutTypes: ["Arms", "Push"],
  ),
  ExerciseTemplate(
    name: "Overhead Rope Extension",
    muscleGroup: "Triceps",
    workoutTypes: ["Arms", "Push"],
  ),
  ExerciseTemplate(
    name: "Skull Crushers",
    muscleGroup: "Triceps",
    workoutTypes: ["Arms", "Push"],
  ),
  ExerciseTemplate(
    name: "Close Grip Bench Press",
    muscleGroup: "Triceps",
    workoutTypes: ["Arms", "Push"],
  ),

  // =========================
  // LEGS
  // =========================

  ExerciseTemplate(
    name: "Squat",
    muscleGroup: "Legs",
    workoutTypes: ["Legs"],
  ),
  ExerciseTemplate(
    name: "Hack Squat",
    muscleGroup: "Legs",
    workoutTypes: ["Legs"],
  ),
  ExerciseTemplate(
    name: "Leg Press",
    muscleGroup: "Legs",
    workoutTypes: ["Legs"],
  ),
  ExerciseTemplate(
    name: "Romanian Deadlift",
    muscleGroup: "Legs",
    workoutTypes: ["Legs"],
  ),
  ExerciseTemplate(
    name: "Leg Extension",
    muscleGroup: "Legs",
    workoutTypes: ["Legs"],
  ),
  ExerciseTemplate(
    name: "Seated Leg Curl",
    muscleGroup: "Legs",
    workoutTypes: ["Legs"],
  ),
  ExerciseTemplate(
    name: "Standing Calf Raise",
    muscleGroup: "Legs",
    workoutTypes: ["Legs"],
  ),

  // =========================
  // CORE
  // =========================

  ExerciseTemplate(
    name: "Crunch",
    muscleGroup: "Core",
    workoutTypes: ["Core"],
  ),
  ExerciseTemplate(
    name: "Cable Crunch",
    muscleGroup: "Core",
    workoutTypes: ["Core"],
  ),
  ExerciseTemplate(
    name: "Plank",
    muscleGroup: "Core",
    workoutTypes: ["Core"],
  ),
];