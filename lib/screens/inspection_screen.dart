import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';

class InspectionScreen extends StatefulWidget {
  const InspectionScreen({Key? key}) : super(key: key);
  @override
  State<InspectionScreen> createState() => _InspectionScreenState();
}

class _InspectionScreenState extends State<InspectionScreen> {
  File? _image;
  final _jobIdController = TextEditingController(text: "JOB_PCB_REV1");
  bool _processing = false;
  Map<String, dynamic>? _report;

  Future<void> _captureImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 100);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _report = null;
      });
    }
  }

  void _runAOI() async {
    if (_image == null) return;
    setState(() => _processing = true);
    var result = await ApiService.uploadAndInspect(_jobIdController.text, _image!);
    setState(() {
      _report = result;
      _processing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Optical Acquisition")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: _jobIdController, decoration: const InputDecoration(labelText: "Active Production Job ID")),
            const SizedBox(height: 15),
            ElevatedButton(onPressed: _captureImage, child: const Text("Trigger Handheld Capture")),
            const SizedBox(height: 15),
            if (_image != null) Image.file(_image!, height: 250, fit: BoxFit.contain),
            const SizedBox(height: 15),
            if (_image != null && !_processing) ElevatedButton(onPressed: _runAOI, style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text("PROCESS AI INSPECTION")),
            if (_processing) const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator())),
            if (_report != null) ...[
              const Divider(color: Colors.cyan),
              Text("VERDICT: ${_report!['status']}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _report!['status'] == 'PASS' ? Colors.green : Colors.red)),
              const SizedBox(height: 10),
              if (_report!['anomalies'] != null)
                ...(_report!['anomalies'] as List).map((anomaly) => ListTile(
                  leading: const Icon(Icons.error, color: Colors.orange),
                  title: Text("Ref: ${anomaly['designator']} | ${anomaly['type']}"),
                  subtitle: Text(anomaly['details'] ?? ""),
                ))
            ]
          ],
        ),
      ),
    );
  }
}
