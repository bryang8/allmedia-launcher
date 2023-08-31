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

  }

  Widget _emptyStateImage(BuildContext context) => Container(color: Colors.grey);
}

