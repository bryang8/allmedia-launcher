
import 'dart:convert';
import 'dart:io';

import 'package:flauncher/database.dart';
import 'package:flauncher/models/config_model.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/widgets/adds/adds_v1.dart';
import 'package:flauncher/widgets/adds/adds_v2.dart';
import 'package:flauncher/widgets/elements/video_card.dart';
import 'package:flauncher/widgets/grids/apps_grid.dart';
import 'package:flauncher/widgets/category_row.dart';
import 'package:flauncher/widgets/grids/apps_home_grid.dart';
import 'package:flauncher/widgets/grids/apps_home_grid_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:crypto/crypto.dart';

enum ViewerStates {
  Home1, Home2, AllApps
}

final apiDomain = "http://backend.am4.tv/";

class AppsViewer extends StatefulWidget {
  final App appMenu;
  final String macAddress;

  AppsViewer(this.appMenu, this.macAddress);

  @override
  State<AppsViewer> createState() => AppsViewerState(appMenu, macAddress);
}

class AppsViewerState extends State<AppsViewer> {
  final App appMenu;
  final String macAddress;

  ConfigsModel config = ConfigsModel(launcher: 0);
  ViewerStates selectedHome = ViewerStates.AllApps;
  ViewerStates state = ViewerStates.AllApps;
  bool fetch = true;
  List<Widget> _images = List.empty();
  List<String> _links = List.empty();

  bool starting = false;

  AppsViewerState(this.appMenu, this.macAddress);

  @override
  Widget build(BuildContext context) {
    if(fetch) startFetchingImages(context);

    var appsService = context.read<AppsService>();
    var categoriesWithApps = appsService.categoriesWithApps;

    var homeCategory = appsService.categoriesWithApps[0];
    List<App> homeApps = homeCategory.applications.toList();

    homeApps.insert(0, appMenu);

    if(state != ViewerStates.AllApps) {
      return WillPopScope (
        onWillPop: () async {
          return false;
        },
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: state == ViewerStates.Home1
                ? Home1Widgets(homeCategory, homeApps, _images)
                : Home2Widgets(homeCategory, homeApps, _images)
          ),
        )
      );
    }
    else {
      return WillPopScope(
        onWillPop: () async {
          setState(() {
            state = selectedHome;
            fetch = false;
          });
          return false;
        },
        child: SingleChildScrollView(child: _categories(categoriesWithApps)),
      );
    }
  }

  Widget _categories(List<CategoryWithApps> categoriesWithApps) => Column(
    children: categoriesWithApps.map((categoryWithApps) {
      switch (categoryWithApps.category.type) {
        case CategoryType.row:
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: CategoryRow(
                key: Key(categoryWithApps.category.id.toString()),
                category: categoryWithApps.category,
                applications: categoryWithApps.applications),
          );
        case CategoryType.grid:
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 0),
            child: AppsGrid(
                key: Key(categoryWithApps.category.id.toString()),
                category: categoryWithApps.category,
                applications: categoryWithApps.applications),
          );
      }
    }).toList(),
  );

  List<Widget> Home1Widgets(homeCategory, homeApps, _images) {
    var appsList = homeApps
        .sublist(0, homeApps.length > 10 ? 10 : homeApps.length);

    return
      [
        AddsV1Widget(_images),
        //Home Apps
        Container(
          padding: EdgeInsets.only(top: 16),
          child: AppsHomeGrid(
            itemsPerRow: 5,
            key: Key(homeCategory.category.id.toString()),
            category: homeCategory.category,
            applications: appsList,
            openAllApps: () {
              setState(() {
                state = ViewerStates.AllApps;
                fetch = true;
              });
            }),
        )
      ];
  }

  List<Widget> Home2Widgets(homeCategory, homeApps, _images) {
    var appsList = homeApps
        .sublist(0, homeApps.length > 7 ? 7 : homeApps.length);

    return
      [
        AdsV2Widget(_images),
        //Home Apps
        Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: AppsHomeGrid2(
            itemsPerRow: 7,
            key: Key(homeCategory.category.id.toString()),
            category: homeCategory.category,
            applications: appsList,
            openAllApps: () {
              setState(() {
                state = ViewerStates.AllApps;
                fetch = true;
              });
            }),
        )
      ];
  }

  void startFetchingImages(BuildContext context) {
    //timer = Timer.periodic(Duration(seconds: 60), (Timer t) {
    fetchConfig(macAddress).then((configResponse) {
      if (configResponse != null) {
        getApplicationDocumentsDirectory().then((dir) {
          if (configResponse.launcher == 1) {
            selectedHome = ViewerStates.Home1;
            setState(() {
              config = configResponse;
              selectedHome = selectedHome;
              state = (this.config.launcher != 1)
                  ? selectedHome : state;
              fetch = false;
              _images = convertConfigImagesToWidgets(
                  context, configResponse.images, dir.path, 3);
            });
          }
          else {
            selectedHome = ViewerStates.Home2;
            setState(() {
              config = configResponse;
              selectedHome = selectedHome;
              state = (this.config.launcher != 2) ? selectedHome : state;
              fetch = false;
              _images = convertConfigImagesToWidgets(
                  context, configResponse.images, dir.path, 5);
              _links = configResponse.images!.map((i) => i.link!).toList();
            });
          }
        });
      }
    });
    //});
  }

  Future<ConfigsModel?> fetchConfig(String macAddress) async {
    final uri = Uri.parse(apiDomain+'api/device/device/'+macAddress);
    final response = await http.get(uri);

    print(response.statusCode);
    if (response.statusCode == 200) {
      var model = ConfigsModel.fromJson(jsonDecode(response.body));

      print(model.launcher);
      model.images?.forEach((list) {
        print(list.id.toString() + ' : ' + list.path!);
      });

      return model;
    } else {
      return null;
    }
  }
}

List<Widget> convertConfigImagesToWidgets(context, List<ConfigsImage>? images, dir, int minLen) {
  var list = List<Widget>.empty(growable: true);

  for(int i = 0; i < minLen; i ++) {
    if(images == null) {
      list.add(_emptyStateImage());
    }
    else {
      var image = images?.where((element) => element.id == i).firstOrNull;
      if(image != null){
        var imagePath = image.path;
        var filename = generateMd5(image.path!);
        var imageSrc = fileFromPath(dir, filename, image.ext!);

        list.add(_image(context, imagePath, imageSrc, image.id!, image.link!));
      }
      else {
        list.add(_emptyStateImage());
      }
    }
  }

  return list;
}

Widget _image(BuildContext context, url, file, int id, String link)  {
  return VideoCard(
      image: Image(image:NetworkToFileImage(
          url: apiDomain + url,
          file: file,
          debug: true),
        fit: BoxFit.fill,
        filterQuality: FilterQuality.high,
      ),
      link: link,
      id: id,
      autofocus: false,
      onMove: (p0) {

      },
      onMoveEnd: () {

      }
  );
}

File fileFromPath(String dir, String filename, String ext) {
  String pathName = p.join(dir, (filename + '.' + ext));
  return File(pathName);
}

String generateMd5(String input) {
  return md5.convert(utf8.encode(input)).toString();
}

Widget _emptyStateImage() => Container(color: Colors.grey);