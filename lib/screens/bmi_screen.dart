import 'package:flutter/material.dart';

class BMIScreen extends StatefulWidget {
  const BMIScreen({super.key});

  @override
  State<BMIScreen> createState() => _BMIScreenState();
}

class _BMIScreenState extends State<BMIScreen> {
  final TextEditingController heightController =
      TextEditingController();

  final TextEditingController weightController =
      TextEditingController();

  double bmi = 0;
  String result = "";

  Color getBMIColor() {
    switch (result) {
      case "Underweight":
        return Colors.blue;

      case "Normal":
        return Colors.green;

      case "Overweight":
        return Colors.orange;

      case "Obese":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  void calculateBMI() {
    final double height =
        double.tryParse(heightController.text) ?? 0;

    final double weight =
        double.tryParse(weightController.text) ?? 0;

    if (height <= 0 || weight <= 0) return;

    final double heightMeters = height / 100;

    bmi = weight / (heightMeters * heightMeters);

    if (bmi < 18.5) {
      result = "Underweight";
    } else if (bmi < 25) {
      result = "Normal";
    } else if (bmi < 30) {
      result = "Overweight";
    } else {
      result = "Obese";
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BMI Calculator"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "BMI Calculator",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "Calculate your Body Mass Index",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 30),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: heightController,
                  keyboardType:
                      TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    prefixIcon:
                        Icon(Icons.height),
                    labelText: "Height (cm)",
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: weightController,
                  keyboardType:
                      TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.monitor_weight,
                    ),
                    labelText: "Weight (kg)",
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.calculate),
                label: const Text(
                  "Calculate BMI",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.blue,
                  foregroundColor:
                      Colors.white,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                            16),
                  ),
                ),
                onPressed: calculateBMI,
              ),
            ),

            const SizedBox(height: 30),
                        Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 20,
                ),
                child: Column(
                  children: [

                    const Text(
                      "Your BMI",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 20),

                    CircleAvatar(
                      radius: 55,
                      backgroundColor:
                          getBMIColor().withOpacity(.15),
                      child: Text(
                        bmi == 0
                            ? "--"
                            : bmi.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: getBMIColor(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      bmi == 0
                          ? "Enter your height and weight"
                          : result,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: getBMIColor(),
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Divider(),

                    const SizedBox(height: 15),

                    const Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [

                        Icon(
                          Icons.favorite,
                          color: Colors.blue,
                        ),

                        SizedBox(width: 8),

                        Text(
                          "Healthy BMI Range",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "18.5 - 24.9",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (bmi != 0)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: getBMIColor().withOpacity(.12),
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                        child: Text(
                          _getHealthMessage(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: getBMIColor(),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getHealthMessage() {
    switch (result) {
      case "Underweight":
        return "You are below the healthy BMI range.";

      case "Normal":
        return "Excellent! Your BMI is in the healthy range.";

      case "Overweight":
        return "You're above the healthy range. Regular exercise and a balanced diet can help.";

      case "Obese":
        return "Your BMI is significantly above the healthy range. Consider consulting a healthcare professional for personalized advice.";

      default:
        return "Enter your height and weight to calculate your BMI.";
    }
  }

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }
}