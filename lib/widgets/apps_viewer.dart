
import 'dart:convert';
import 'dart:io';

import 'package:flauncher/database.dart';
import 'package:flauncher/models/config_model.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/widgets/adds/adds_v1.dart';
import 'package:flauncher/widgets/adds/adds_v2.dart';
import 'package:flauncher/widgets/grids/apps_grid.dart';
import 'package:flauncher/widgets/category_row.dart';
import 'package:flauncher/widgets/grids/apps_home_grid.dart';
import 'package:flauncher/widgets/grids/apps_home_grid_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:crypto/crypto.dart';

enum ViewerStates {
  Home1, Home2, AllApps
}

class AppsViewer extends StatefulWidget {
  final App appMenu;
  AppsViewer(this.appMenu);

  @override
  State<AppsViewer> createState() => AppsViewerState(appMenu);
}

class AppsViewerState extends State<AppsViewer> {
  final App appMenu;
  ConfigsModel config = ConfigsModel(launcher: "0");
  ViewerStates selectedHome = ViewerStates.AllApps;
  ViewerStates state = ViewerStates.AllApps;
  bool fetch = true;
  List<Widget> _images = List.empty();
  bool starting = false;

  AppsViewerState(this.appMenu);

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
              mainAxisSize: MainAxisSize.max,
              children: state == ViewerStates.Home1
                ? Home1Widgets(homeCategory, homeApps, _images)
                : Home2Widgets(homeCategory, homeApps, config.images)
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
            padding: EdgeInsets.symmetric(vertical: 8),
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
        .sublist(0, homeApps.length > 8 ? 8 : homeApps.length);

    return
      [
        AddsV1Widget(_images),
        //Home Apps
        Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: AppsHomeGrid(
            itemsPerRow: 4,
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

  List<Widget> Home2Widgets(homeCategory, homeApps, images) {
    var appsList = homeApps
        .sublist(0, homeApps.length > 7 ? 7 : homeApps.length);

    return
      [
        AdsV2Widget(),
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
    fetchConfig().then((configResponse) {
      if(configResponse != null) {
        if(configResponse.launcher == "1") {
          selectedHome = ViewerStates.Home1;
          getApplicationDocumentsDirectory().then((dir) {
            setState(() {
              config = configResponse;
              selectedHome = selectedHome;
              state = (this.config.launcher != "1")
                  ? selectedHome : state;
              fetch = false;
              _images = convertConfigImagesToWidgets(context, configResponse.images, dir.path);
            });
          });
        }
        else {
          selectedHome = ViewerStates.Home2;
          setState(() {
            config = configResponse;
            selectedHome = selectedHome;
            state = (this.config.launcher != "2")
                ? selectedHome : state;
            fetch = false;
          });
        }
      }
    });
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