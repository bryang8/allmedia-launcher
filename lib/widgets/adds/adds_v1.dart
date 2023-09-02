import 'package:flutter/material.dart';

class AddsV1Widget extends StatefulWidget  {
  final List<Widget> _images;
  const AddsV1Widget(this._images, {Key? key}) : super(key: key);

  @override
  State<AddsV1Widget> createState() {
    return AddsState(_images);
  }
}

class AddsState extends State<AddsV1Widget> {
  final List<Widget> _images;

  AddsState(this._images);

  @override
  Widget build(BuildContext context) {
    double containerHeight = (MediaQuery.of(context).size.height * 0.6) - 16;
    return Container(
      height: containerHeight,
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
                    child: _images[0],
                    height: containerHeight / 2,
                  ),
                  Container(
                    child: _images[2],
                    padding: EdgeInsets.only(top: 4),
                    height: containerHeight / 2,
                  )
                ] ,
              ),
            ),
            Container(
              width: (MediaQuery.of(context).size.width * 0.7) - 32,
              padding: EdgeInsets.fromLTRB(4,0,0,0),
              child:_images[1],
            )

          ]
      ),
    );
  }

  @override
  initState() {

  }
}

