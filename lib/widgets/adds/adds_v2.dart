import 'dart:convert';

import 'package:flauncher/models/config_model.dart';
import 'package:flauncher/widgets/elements/video_card.dart';
import 'package:flutter/material.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:crypto/crypto.dart';

final exampleImagePath = 'https://cdnb.artstation.com/p/assets/images/images/043/787/189/large/ravi-sanker-coke-land.jpg';
final exampleImageFile = '/data/user/0/me.efesser.flauncher/app_flutter/108b09a40529f888b357777aa364f8a3.jpg';

class AdsV2Widget extends StatefulWidget  {
  final List<Widget> _images;
  final List<String> _links;

  const AdsV2Widget(this._images, this._links, {Key? key}) : super(key: key);

  @override
  State<AdsV2Widget> createState() {
    return AddsState(_images,_links);
  }
}

class AddsState extends State<AdsV2Widget> {
  final List<Widget> _images;
  final List<String> _links;

  AddsState(this._images, this._links);

  Timer? timer;

  @override
  Widget build(BuildContext context) {
    bool showImages = _images.isNotEmpty;
    double containerHeight = MediaQuery.of(context).size.height * 0.72;

    return
      Container(
      height: containerHeight,
      child: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.25,
                padding: EdgeInsets.fromLTRB(0, 0, 4, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      child: showImages ? _image(_images[0],_links[0],0)
                : _emptyStateImage(context),
                      height: containerHeight / 2,
                    ),
                    Container(
                      child: showImages ? _image(_images[3],_links[3],3) : _emptyStateImage(context),
                      padding: EdgeInsets.only(top: 4),
                      height: containerHeight /2,
                    )
                  ] ,
                ),
              ),
              Container(
                width: (MediaQuery.of(context).size.width * 0.5) - 32,
                padding: EdgeInsets.fromLTRB(4,0,4,0),
                child: showImages ? _image(_images[1],_links[1],1) : _emptyStateImage(context),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.25,
                padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      child: showImages ? _image(_images[2],_links[2],2) : _emptyStateImage(context),
                      height: containerHeight / 2,
                    ),
                    Container(
                      child: showImages ? _image(_images[4],_links[4],4) : _emptyStateImage(context),
                      padding: EdgeInsets.only(top: 4),
                      height: containerHeight / 2,
                    )
                  ] ,
                ),
              )
            ]
        ),
      ),
    );
  }

  @override
  initState() {

  }

  Widget _emptyStateImage(BuildContext context) => Container(color: Colors.grey);
}

Widget _image(Widget image, String url, int id)  {
  return VideoCard(
      image: image,
      link: url,
      id: id,
      autofocus: false,
      onMove: (p0) {

      },
      onMoveEnd: () {

      }
  );
}
