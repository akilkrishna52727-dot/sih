import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class DiseaseCameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const DiseaseCameraScreen({super.key, required this.cameras});

  @override
  State<DiseaseCameraScreen> createState() => _DiseaseCameraScreenState();
}

class _DiseaseCameraScreenState extends State<DiseaseCameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    if (widget.cameras.isNotEmpty) {
      _controller =
          CameraController(widget.cameras.first, ResolutionPreset.medium);
      _initializeControllerFuture = _controller!.initialize();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pro Camera')),
      body: _controller == null
          ? const Center(child: Text('No camera found'))
          : FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller!);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_controller == null) return;
          try {
            await _initializeControllerFuture;
            final file = await _controller!.takePicture();
            if (!mounted) return;
            Navigator.pop(context, File(file.path));
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error taking picture: $e')));
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
