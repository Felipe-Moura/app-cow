import 'package:camera/camera.dart';
import 'package:cowapp/cameraPage.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final  cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: CameraPage(camera: firstCamera),
    )
  );
}
