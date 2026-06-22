import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'inspection_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatelessWidget {
  final String role;
  const DashboardScreen({Key? key, required this.role}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AOI CONSOLE - ROLE: ${role.toUpperCase()}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt, size: 32),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                child: Text("NEW OPTICAL INSPECTION", style: TextStyle(fontSize: 18)),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const InspectionScreen()));
              },
            ),
            const SizedBox(height: 20),
            if (role == 'admin' || role == 'manager')
              TextButton(onPressed: () {}, child: const Text("Configure New Golden Reference Samples"))
          ],
        ),
      ),
    );
  }
}
