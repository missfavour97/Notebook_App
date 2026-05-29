import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class MedicineSelectionScreen extends StatelessWidget {
  const MedicineSelectionScreen({super.key});

  Future<void> selectMedicine(
      BuildContext context,
      String specialization,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('userEmail');

    if (email != null && email.isNotEmpty) {
      await prefs.setString('selectedField_$email', specialization);
    }

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(selectedField: specialization),
      ),
    );
  }

  Widget buildMedicineCard(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      ) {
    return Expanded(
      child: InkWell(
        onTap: () => selectMedicine(context, title),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.35)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 52, color: color),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Medical Type'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select your medical specialization',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Choose the medical area you want to use in My Notebook.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                buildMedicineCard(
                  context,
                  'Medicine',
                  Icons.local_hospital,
                  Colors.red,
                ),
                const SizedBox(width: 20),
                buildMedicineCard(
                  context,
                  'Pharmacy',
                  Icons.medication,
                  Colors.deepOrange,
                ),
                const SizedBox(width: 20),
                buildMedicineCard(
                  context,
                  'Nursing',
                  Icons.health_and_safety,
                  Colors.pink,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}