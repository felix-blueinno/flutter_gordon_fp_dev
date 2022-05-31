// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:developer';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_gordon_dev/classifier_float.dart';
import 'package:image/image.dart' as imageLib;

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  runApp(CameraApp());
}

class CameraApp extends StatefulWidget {
  const CameraApp({Key? key}) : super(key: key);

  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;

  // Create an instance of classifier to load model and labels
  ClassifierFloat classifier = ClassifierFloat(numThreads: 4);

  bool predicting = false;
  var result = '';
  int cameraIndex = 0;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  void initCamera() {
    controller = CameraController(cameras[cameraIndex], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) return;

      controller.startImageStream((image) => processCameraImage(image));
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !controller.value.isInitialized
        ? Container() // camera not yet ready
        : MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              appBar: AppBar(
                title: Text("Gordon's mask detector"),
                actions: [
                  IconButton(
                      onPressed: () {
                        cameraIndex < cameras.length - 1
                            ? cameraIndex++
                            : cameraIndex = 0;
                        initCamera();
                      },
                      icon: Icon(Icons.cameraswitch)),
                ],
              ),
              body: Stack(
                children: [
                  Center(child: CameraPreview(controller)),
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(child: Text(result.toString())),
                  ),
                ],
              ),
            ),
          );
  }

  void processCameraImage(CameraImage cameraImage) async {
    if (predicting) return;
    predicting = true;

    final ReceivePort receivePort = ReceivePort();

    if (cameraImage.format.group == ImageFormatGroup.yuv420) {
      final isolate = await Isolate.spawn(
          convertYUV420ToImage, [receivePort.sendPort, cameraImage]);

      receivePort.listen((image) {
        result = classifier.predict(image).toString();
        isolate.kill();
        setState(() => predicting = false);
      });
    } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
      final isolate = await Isolate.spawn(
          convertBGRA8888ToImage, [receivePort.sendPort, cameraImage]);

      receivePort.listen((image) {
        result = classifier.predict(image).toString();
        isolate.kill();
        setState(() => predicting = false);
      });
    }
  }
}

/// Utitlity functions below:

/// Converts a [CameraImage] in YUV420 format to [imageLib.Image] in RGB format
void convertYUV420ToImage(List<Object> args) {
  SendPort sendPort = args[0] as SendPort;
  CameraImage cameraImage = args[1] as CameraImage;

  final int width = cameraImage.width;
  final int height = cameraImage.height;

  final int uvRowStride = cameraImage.planes[1].bytesPerRow;
  final int? uvPixelStride = cameraImage.planes[1].bytesPerPixel;

  final image = imageLib.Image(width, height);

  for (int w = 0; w < width; w++) {
    for (int h = 0; h < height; h++) {
      final int uvIndex =
          uvPixelStride! * (w / 2).floor() + uvRowStride * (h / 2).floor();
      final int index = h * width + w;

      final y = cameraImage.planes[0].bytes[index];
      final u = cameraImage.planes[1].bytes[uvIndex];
      final v = cameraImage.planes[2].bytes[uvIndex];

      image.data[index] = yuv2rgb(y, u, v);
    }
  }
  sendPort.send(image);
}

/// Converts a [CameraImage] in BGRA888 format to [imageLib.Image] in RGB format
void convertBGRA8888ToImage(List<Object> args) {
  SendPort sendPort = args[0] as SendPort;
  CameraImage cameraImage = args[1] as CameraImage;

  imageLib.Image img = imageLib.Image.fromBytes(cameraImage.planes[0].width!,
      cameraImage.planes[0].height!, cameraImage.planes[0].bytes,
      format: imageLib.Format.bgra);

  sendPort.send(img);
}

/// Convert a single YUV pixel to RGB
int yuv2rgb(int y, int u, int v) {
  // Convert yuv pixel to rgb
  int r = (y + v * 1436 / 1024 - 179).round();
  int g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
  int b = (y + u * 1814 / 1024 - 227).round();

  // Clipping RGB values to be inside boundaries [ 0 , 255 ]
  r = r.clamp(0, 255);
  g = g.clamp(0, 255);
  b = b.clamp(0, 255);

  return 0xff000000 | ((b << 16) & 0xff0000) | ((g << 8) & 0xff00) | (r & 0xff);
}
