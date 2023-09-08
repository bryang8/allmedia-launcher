
import 'package:flutter/material.dart';

class AdsV2Widget extends StatelessWidget  {

  final List<Widget> _images;

  const AdsV2Widget(this._images, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                        child: _images[0],
                        height: containerHeight / 2,
                      ),
                      Container(
                        child: _images[3],
                        padding: EdgeInsets.only(top: 4),
                        height: containerHeight /2,
                      )
                    ] ,
                  ),
                ),
                Container(
                  width: (MediaQuery.of(context).size.width * 0.5) - 32,
                  padding: EdgeInsets.fromLTRB(4,0,4,0),
                  child: _images[1],
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.25,
                  padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        child: _images[2],
                        height: containerHeight / 2,
                      ),
                      Container(
                        child: _images[4],
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
}