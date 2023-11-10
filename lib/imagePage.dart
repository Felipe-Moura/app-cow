import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

String serverUri = "http://url/"; //change url here

class ApiData {
  final List predict;

  ApiData.fromJson(Map<String, dynamic> json)
    : predict = json['predict'];
}

Future<ApiData> predictImage(String image) async {
  File myImage = File(image);

  var request = http.MultipartRequest(
    'POST',
    Uri.parse("${serverUri}detect"),
  );

  Map<String, String> headers = {"Content-type": "multipart/form-data"};

  request.files.add(
    http.MultipartFile(
      'file',
      myImage.readAsBytes().asStream(),
      myImage.lengthSync(),
      filename: "cow",
      contentType: MediaType('image', 'jpeg')
    ),
  );

  request.headers.addAll(headers);
  var res = await request.send();
  http.Response response = await http.Response.fromStream(res);

  if(response.statusCode == 200){
    return ApiData.fromJson(jsonDecode(response.body));
  }
  else{
    throw Exception('Failed to send image');
  }
}

class MyPainter extends CustomPainter{

  MyPainter({
    required this.img,
    required this.points,
  });

  final ui.Image img;
  final List points;

  @override
  void paint(Canvas canvas, Size size){
    canvas.drawImage(img, Offset.zero, Paint());

    canvas.drawRect(
      Rect.fromPoints(
        Offset(points[0], points[1]),
        Offset(points[2], points[3]),
      ),
      Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = Colors.green,
    );
  }

  @override
  bool shouldRepaint(MyPainter oldDelegate) => false;
}

//----------------------------------------------------------------------------------------------------------

class ImagePage extends StatefulWidget {
  const ImagePage({super.key, required this.imagePath});

  final String imagePath;

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  late Future<ApiData> _futureRequest;
  late ui.Image _myImage;

  Future<ui.Image> convertImage() async {
    var image = File(widget.imagePath);
    final Uint8List bytes = await image.readAsBytes();
    ui.Codec codec = await ui.instantiateImageCodec(bytes);
    ui.FrameInfo frame = await codec.getNextFrame();

    return frame.image;
  }

  @override
  void initState(){
    super.initState();
    _futureRequest = predictImage(widget.imagePath);
    convertImage().then((value) {
      _myImage = value;
    });
  }

  Widget markDetected(ApiData? values) {
    return FittedBox(
      child: Column(
        children: [
          Text(
          values?.predict[0][0],
          style: const TextStyle(
            color: Colors.green,
            fontSize: 15.0,
          ),
        ),
          SizedBox(
            width: 720,
            height: 1280,
            child: CustomPaint(
              painter: MyPainter(img: _myImage ,points: values?.predict[0][1]),
              size: const Size.square(720),
            ),
          ),
        ],
      ),
    );
  }

  Widget noDetection(){
    return Column(
      children: [
        const Text(
          "Nothing found",
          style: TextStyle(
            color: Colors.red,
            fontSize: 15.0,
          ),
        ),
        Image.file(File(widget.imagePath)),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Center(child: Text("Detected"))),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
                future:_futureRequest,
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    return snapshot.data!.predict.isEmpty
                      ? noDetection()
                      : markDetected(snapshot.data);
                  }
                  if(snapshot.hasError){
                    return Text('${snapshot.error}');
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              )
            ),
        ],
      ),
    );
  }
}
