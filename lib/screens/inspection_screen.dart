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
  File? _imageFile;
  final _jobIdController = TextEditingController(text: "JOB_PCB_REV1");
  bool _isLoading = false;
  
  String _verdict = "";
  Map<String, dynamic> _failedBoxes = {};

  // Reference constraints of your system's Golden Frame standard template width/height
  // Used to scale coordinates seamlessly across various smartphone screens
  final double referenceCanvasWidth = 1000.0;
  final double referenceCanvasHeight = 1000.0;

  Future<void> _captureOpticalSample() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 95);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _verdict = "";
        _failedBoxes = {};
      });
    }
  }

  void _runCloudInspection() async {
    if (_imageFile == null) return;
    setState(() { _isLoading = true; _verdict = ""; });

    try {
      var jsonResponse = await ApiService.uploadAndInspect(_jobIdController.text, _imageFile!);
      setState(() {
        _verdict = jsonResponse["status"] ?? "ERROR";
        _failedBoxes = jsonResponse["failed_box_mappings"] ?? {};
      });
    } catch(e) {
      setState(() { _verdict = "SYSTEM SERVER COMMUNICATION TIMEOUT"; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Optics Inspection Engine")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(controller: _jobIdController, decoration: const InputDecoration(labelText: "Active Factory Work Order Job ID")),
              const SizedBox(height: 12),
              ElevatedButton.icon(onPressed: _captureOpticalSample, icon: const Icon(Icons.camera_alt), label: const Text("CAPTURE HANDHELD IMAGE")),
              const SizedBox(height: 15),
              
              if (_imageFile != null)
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Compute how much the image scales down to fit the current phone screen
                    double displayWidth = constraints.maxWidth;
                    double scaleFactor = displayWidth / referenceCanvasWidth;
                    double displayHeight = referenceCanvasHeight * scaleFactor;

                    return Stack(
                      children: [
                        // Base Handheld Image Display
                        Image.file(_imageFile!, width: displayWidth, height: displayHeight, fit: BoxFit.fill),
                        
                        // Dynamic Red Highlight Boxes drawn directly over the image components
                        ..._failedBoxes.entries.map((entry) {
                          List<dynamic> coords = entry.value;
                          double x = coords[0].toDouble() * scaleFactor;
                          double y = coords[1].toDouble() * scaleFactor;
                          double w = coords[2].toDouble() * scaleFactor;
                          double h = coords[3].toDouble() * scaleFactor;

                          return Positioned(
                            left: x,
                            top: y,
                            width: w,
                            height: h,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red, width: 3.0),
                                color: Colors.red.withOpacity(0.22),
                              ),
                              child: const Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: EdgeInsets.all(2.0),
                                  child: Icon(Icons.warning, color: Colors.red, size: 14),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  }
                ),

              const SizedBox(height: 15),
              if (_imageFile != null && !_isLoading)
                ElevatedButton(onPressed: _runCloudInspection, style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan, minimumSize: const Size.fromHeight(48)), child: const Text("RUN LIVE AUDIT EVALUATION", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
              if (_isLoading) const CircularProgressIndicator(),
              if (_verdict.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text("INSPECTION VERDICT: $_verdict", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _verdict == "PASS" ? Colors.green : Colors.red)),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
