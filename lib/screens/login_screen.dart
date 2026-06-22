import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _loading = false;

  void handleLogin() async {
    setState(() => _loading = true);
    var res = await ApiService.login(_userController.text, _passController.text);
    setState(() => _loading = false);

    if (res != null) {
      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => DashboardScreen(role: res["role"]))
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Authentication Failed: Access Denied"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("AOI GATEWAY LOG", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.cyan)),
            const SizedBox(height: 20),
            TextField(controller: _userController, decoration: const InputDecoration(labelText: "Operator ID / Username")),
            TextField(controller: _passController, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
            const SizedBox(height: 30),
            _loading ? const Center(child: CircularProgressIndicator()) : ElevatedButton(
              onPressed: handleLogin,
              child: const Text("INITIALIZE SESSION"),
            )
          ],
        ),
      ),
    );
  }
}
