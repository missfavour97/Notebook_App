import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class EngineeringSelectionScreen extends StatelessWidget {
  const EngineeringSelectionScreen({super.key});

  Future<void> selectEngineering(
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

  Widget buildEngineeringCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () => selectEngineering(context, title),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.35)),
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
        title: const Text('Choose Engineering Type'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select your engineering specialization',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Choose the engineering area you want to use in My Notebook.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                buildEngineeringCard(
                  context,
                  'Computer Engineering',
                  Icons.memory,
                  Colors.indigo,
                ),
                const SizedBox(width: 20),
                buildEngineeringCard(
                  context,
                  'Mechanical Engineering',
                  Icons.precision_manufacturing,
                  Colors.orange,
                ),
                const SizedBox(width: 20),
                buildEngineeringCard(
                  context,
                  'Electrical Engineering',
                  Icons.electrical_services,
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
