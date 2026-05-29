import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'business_selection_screen.dart';
import 'engineering_selection_screen.dart';
import 'medicine_selection_screen.dart';

class FieldSelectionScreen extends StatelessWidget {
  const FieldSelectionScreen({super.key});

  Future<void> saveFieldAndGoHome(BuildContext context, String field) async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('userEmail');

    if (email != null && email.isNotEmpty) {
      await prefs.setString('selectedField_$email', field);
    }

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(selectedField: field),
      ),
    );
  }

  Widget buildFieldCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
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
        title: const Text('Choose Your Mode'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select how you want to use My Notebook',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Basic users get all notebook features. Specialized fields also get field-specific resources.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                buildFieldCard(
                  context: context,
                  title: 'Basic',
                  icon: Icons.note_alt,
                  color: Colors.blue,
                  onTap: () => saveFieldAndGoHome(context, 'Basic'),
                ),
                const SizedBox(width: 20),
                buildFieldCard(
                  context: context,
                  title: 'Business',
                  icon: Icons.business_center,
                  color: Colors.teal,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BusinessSelectionScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                buildFieldCard(
                  context: context,
                  title: 'Engineering',
                  icon: Icons.engineering,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const EngineeringSelectionScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 20),
                buildFieldCard(
                  context: context,
                  title: 'Medicine',
                  icon: Icons.local_hospital,
                  color: Colors.red,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MedicineSelectionScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}