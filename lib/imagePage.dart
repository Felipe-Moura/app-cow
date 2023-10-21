import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

String testeUri = "http://18.223.131.149/";//trocar url sempre que ligar o servidor

Future<Teste> fetchData() async {
  final response = await http.get(Uri.parse(testeUri));

  if(response.statusCode == 200){
    return Teste.fromJson(jsonDecode(response.body));
  }
  else{
    throw Exception('Failed to fetch data');
  }
}

Future<Teste2> predictImage(String image) async {
  File myImage = File(image);

  var request = http.MultipartRequest(
    'POST',
    Uri.parse("${testeUri}detect"),
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
  print("request: " + request.toString());
  var res = await request.send();
  print("this is response: " + res.toString());
  http.Response response = await http.Response.fromStream(res);

  print(response.body);

  if(response.statusCode == 200){
    return Teste2.fromJson(jsonDecode(response.body));
  }
  else{
    throw Exception('Failed to send image');
  }
}

class Teste {
  final String connection;

  Teste.fromJson(Map<String, dynamic> json)
    : connection = json['connection'];
}

class Teste2 {
  final List predict;

  Teste2.fromJson(Map<String, dynamic> json)
    : predict = json['predict'];
}

//----------------------------------------------------------------------------------------------------------

class ImagePage extends StatefulWidget {
  const ImagePage({super.key, required this.imagePath});

  final String imagePath;

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  //late Future<Teste> futureTeste;
  late Future<Teste2> futureTeste;

  @override
  void initState(){
    super.initState();
    //futureTeste = fetchData();
    futureTeste = predictImage(widget.imagePath);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Center(child: Text("Detected"))),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
                future:futureTeste,
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    print(futureTeste.toString());
                    return Image.file(File(widget.imagePath));
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
