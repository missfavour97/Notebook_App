import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class BusinessSelectionScreen extends StatelessWidget {
  const BusinessSelectionScreen({super.key});

  Future<void> selectBusiness(
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

  Widget buildBusinessCard(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      ) {
    return Expanded(
      child: InkWell(
        onTap: () => selectBusiness(context, title),
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
        title: const Text('Choose Business Type'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select your business specialization',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Choose the business area you want to use in My Notebook.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                buildBusinessCard(
                  context,
                  'Accounting',
                  Icons.calculate,
                  Colors.teal,
                ),
                const SizedBox(width: 20),
                buildBusinessCard(
                  context,
                  'Finance',
                  Icons.attach_money,
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                buildBusinessCard(
                  context,
                  'Marketing',
                  Icons.campaign,
                  Colors.purple,
                ),
                const SizedBox(width: 20),
                buildBusinessCard(
                  context,
                  'Management',
                  Icons.groups,
                  Colors.indigo,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}