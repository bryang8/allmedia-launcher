import 'dart:convert';

import 'package:flauncher/models/config_model.dart';
import 'package:flutter/material.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

final exampleImagePath = 'https://cdnb.artstation.com/p/assets/images/images/043/787/189/large/ravi-sanker-coke-land.jpg';
final exampleImageFile = '/data/user/0/me.efesser.flauncher/app_flutter/108b09a40529f888b357777aa364f8a3.jpg';

class AddsV1Widget extends StatefulWidget  {
  const AddsV1Widget({Key? key}) : super(key: key);

  @override
  State<AddsV1Widget> createState() {
    return AddsState();
  }
}

class AddsState extends State<AddsV1Widget> {
  List<Widget> _images = List.empty(growable: true);
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    bool showImages = _images.isNotEmpty;

    return Container(
      height: MediaQuery.of(context).size.height * 0.50,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.30,
              padding: EdgeInsets.fromLTRB(0, 0, 4, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    child: showImages ? _images[0] : _emptyStateImage(context),
                    height: MediaQuery.of(context).size.height * 0.25,
                  ),
                  Container(
                    child: showImages ? _images[1] : _emptyStateImage(context),
                    padding: EdgeInsets.only(top: 4),
                    height: MediaQuery.of(context).size.height * 0.25,
                  )
                ] ,
              ),
            ),
            Container(
              width: (MediaQuery.of(context).size.width * 0.7) - 32,
              padding: EdgeInsets.fromLTRB(4,0,0,0),
              child: showImages ? _images[2] : _emptyStateImage(context),
            )

          ]
      ),
    );
  }

  @override
  initState() {
    getApplicationDocumentsDirectory().then((dir) {
      startFetchingImages(context, dir.path);
    });
  }

  Widget _emptyStateImage(BuildContext context) => Container(color: Colors.grey);

  void startFetchingImages(BuildContext context, String dir) {
    //timer = Timer.periodic(Duration(seconds: 60), (Timer t) {
      fetchConfig().then((config) {
        if(config != null) {
          setState(() {
            _images = convertConfigImagesToWidgets(context, config.images, dir);
          });
        }
      });
    //});
  }
}

Future<ConfigsModel?> fetchConfig() async {
  final response = await http
      .get(Uri.parse('https://api.mockfly.dev/mocks/fa7c156d-0223-4daf-ae7a-3feb306a3460/v1/config'));

  if (response.statusCode == 200) {
    return ConfigsModel.fromJson(jsonDecode(response.body));
  } else {
    return null;
  }
}

List<Widget> convertConfigImagesToWidgets(context, List<ConfigsImage>? images, dir) {
  var list = List<Widget>.empty(growable: true);

  if(images != null) {
    for (var image in images) {
      var imagePath = image.path;
      var filename = generateMd5(image.path!);
      var imageSrc = fileFromPath(dir, filename, image.ext!);

      list.add(_image(context, imagePath, imageSrc));
    }
  }

  return list;
}

Widget _image(BuildContext context, url, file)  {
  return Image(image:NetworkToFileImage(
      url: url,
      file: file,
      debug: true),
    fit: BoxFit.fill,
    filterQuality: FilterQuality.high,
  );
}

File fileFromPath(String dir, String filename, String ext) {
  String pathName = p.join(dir, (filename + '.' + ext));
  return File(pathName);
}

String generateMd5(String input) {
  return md5.convert(utf8.encode(input)).toString();
}