import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'imagePage.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key, required this.camera,});

  final CameraDescription camera;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {

  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState(){
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(title: const Center(child: Text("Camera"))),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.done){
                  return CameraPreview(_controller);
                }
                else{
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final image = await _controller.takePicture();
            if(!mounted) return;
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ImagePage(imagePath: image.path)
              ),
            );
          } catch (e) {
            // ignore: avoid_print
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}