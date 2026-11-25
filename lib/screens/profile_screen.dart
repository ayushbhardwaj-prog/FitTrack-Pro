import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  //--------------------------------------------------
  // Controllers
  //--------------------------------------------------

  final TextEditingController nameController =
      TextEditingController();

  //--------------------------------------------------
  // State Variables
  //--------------------------------------------------

  String selectedGender = "Male";

  String selectedAge = "21";

  String selectedHeight = "179";

  String selectedWeight = "88";

  //--------------------------------------------------
  // Init
  //--------------------------------------------------

  @override
  void initState() {
    super.initState();
    loadData();
  }

  //--------------------------------------------------
  // Dispose
  //--------------------------------------------------

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  //--------------------------------------------------
  // Load Profile
  //--------------------------------------------------

  Future<void> loadData() async {

    final prefs =
        await SharedPreferences.getInstance();

    setState(() {

      nameController.text =
          prefs.getString("name") ?? "Ayush";

      selectedGender =
          prefs.getString("gender") ?? "Male";

      selectedAge =
          prefs.getString("age") ?? "21";

      selectedHeight =
          prefs.getString("height") ?? "179";

      selectedWeight =
          prefs.getString("weight") ?? "88";

    });

  }

  //--------------------------------------------------
  // Save Profile
  //--------------------------------------------------

  Future<void> saveData() async {

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      "name",
      nameController.text,
    );

    await prefs.setString(
      "gender",
      selectedGender,
    );

    await prefs.setString(
      "age",
      selectedAge,
    );

    await prefs.setString(
      "height",
      selectedHeight,
    );

    await prefs.setString(
      "weight",
      selectedWeight,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(

        content: Text(
          "Profile Saved Successfully! ✅",
        ),

        backgroundColor: Colors.blue,

      ),

    );

  }

Widget buildTextField(
  String title,
  TextEditingController controller,
  IconData icon,
) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: Colors.blue,
            ),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildDropdown({

  required String title,

  required String value,

  required List<String> items,

  required IconData icon,

  required String unit,

  required ValueChanged<String> onChanged,

}) {

  return Padding(

    padding: const EdgeInsets.only(bottom: 22),

    child: Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(

          title,

          style: const TextStyle(

            fontSize: 18,

            fontWeight: FontWeight.bold,

          ),

        ),

        const SizedBox(height: 8),

        DropdownButtonFormField<String>(

          value: items.contains(value)
              ? value
              : items.first,

          decoration: InputDecoration(

            prefixIcon: Icon(
              icon,
              color: Colors.blue,
            ),

            filled: true,

            border: OutlineInputBorder(

              borderRadius:
                  BorderRadius.circular(16),

            ),

          ),

          items: items.map((item) {

            return DropdownMenuItem(

              value: item,

              child: Text(

                "$item $unit",

              ),

            );

          }).toList(),

          onChanged: (newValue) {

            if (newValue != null) {

              onChanged(newValue);

            }

          },

        ),

      ],

    ),

  );

}

 Widget buildGenderChip(
  String gender,
  IconData icon,
) {
  final selected = selectedGender == gender;

  return ChoiceChip(

    avatar: Icon(
      icon,
      size: 18,
      color: selected
          ? Colors.white
          : Colors.blue,
    ),

    label: Text(gender),

    selected: selected,

    selectedColor: Colors.blue,

    labelStyle: TextStyle(
      color: selected
          ? Colors.white
          : Colors.black,
      fontWeight: FontWeight.bold,
    ),

    onSelected: (_) {

      setState(() {

        selectedGender = gender;

      });

    },

  );
}

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          //-----------------------------------
          // Profile Header
          //-----------------------------------

          Center(
            child: Column(
              children: [

                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.blue,

                  child: Text(
                    nameController.text.isEmpty
                        ? "?"
                        : nameController.text[0].toUpperCase(),

                    style: const TextStyle(
                      fontSize: 42,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  nameController.text.isEmpty
                      ? "Your Name"
                      : nameController.text,

                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Keep pushing yourself 💪",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 35),

          //-----------------------------------
          // Personal Information
          //-----------------------------------

          const Text(
            "Personal Information",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          buildTextField(
            "Name",
            nameController,
            Icons.person_outline,
          ),

          //-----------------------------------
          // Gender
          //-----------------------------------

          const Text(
            "Gender",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [

              buildGenderChip(
                "Male",
                Icons.male,
              ),

              buildGenderChip(
                "Female",
                Icons.female,
              ),

              buildGenderChip(
                "Other",
                Icons.people_outline,
              ),

            ],
          ),

          const SizedBox(height: 25),

          //-----------------------------------
          // Age
          //-----------------------------------

          buildDropdown(

            title: "Age",

            value: selectedAge,

            items: List.generate(
              83,
              (i) => "${i + 18}",
            ),

            icon: Icons.cake_outlined,

            unit: "",

            onChanged: (value) {

              setState(() {

                selectedAge = value;

              });

            },

          ),

          //-----------------------------------
          // Height
          //-----------------------------------

          buildDropdown(

            title: "Height",

            value: selectedHeight,

            items: List.generate(
              151,
              (i) => "${i + 100}",
            ),

            icon: Icons.height,

            unit: "cm",

            onChanged: (value) {

              setState(() {

                selectedHeight = value;

              });

            },

          ),

          //-----------------------------------
          // Weight
          //-----------------------------------

          buildDropdown(

            title: "Weight",

            value: selectedWeight,

            items: List.generate(
              171,
              (i) => "${i + 30}",
            ),

            icon: Icons.monitor_weight_outlined,

            unit: "kg",

            onChanged: (value) {

              setState(() {

                selectedWeight = value;

              });

            },

          ),
            //-----------------------------------
      // Settings
      //-----------------------------------

            const SizedBox(height: 10),

            const Text(
              "Settings",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SwitchListTile(
                    secondary: const Icon(
                      Icons.dark_mode,
                      color: Colors.blue,
                    ),
                    title: const Text("Dark Mode"),
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme(value);
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 35),

            //-----------------------------------
            // Save Button
            //-----------------------------------

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: saveData,
                icon: const Icon(Icons.save),
                label: const Text(
                  "Save Profile",
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

          ],
        ),
      ),
    );
  }
}

