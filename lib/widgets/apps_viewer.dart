
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flauncher/database.dart';
import 'package:flauncher/models/config_model.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/widgets/adds/ads_v1.dart';
import 'package:flauncher/widgets/adds/ads_v2.dart';
import 'package:flauncher/widgets/elements/video_card.dart';
import 'package:flauncher/widgets/grids/apps_grid.dart';
import 'package:flauncher/widgets/category_row.dart';
import 'package:flauncher/widgets/grids/apps_home_grid.dart';
import 'package:flauncher/widgets/grids/apps_home_grid_2.dart';
import 'package:flutter/material.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:crypto/crypto.dart';

enum ViewerStates {
  home1, home2, allApps
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
  ViewerStates selectedHome = ViewerStates.allApps;
  ViewerStates state = ViewerStates.allApps;
  List<Widget> _images = List.empty();

  AppsViewerState(this.appMenu, this.macAddress);

  @override
  void initState() {
    var initialConfig = context.read<SettingsService>().launcherConfig;
    try {
      if(initialConfig != null) {
        onConfigFetched(ConfigsModel.fromJson(jsonDecode(initialConfig)));
      }
    } catch (ex) {
      //ignored
    }

    startFetchingImages(context);

    var timer = Timer.periodic(Duration(seconds: 10), (Timer t) {
      startFetchingImages(context);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var appsService = context.read<AppsService>();
    var categoriesWithApps = appsService.categoriesWithApps;

    var homeCategory = appsService.categoriesWithApps[0];
    List<App> homeApps = homeCategory.applications.toList();

    homeApps.insert(0, appMenu);

    if(state != ViewerStates.allApps) {
      return WillPopScope (
        onWillPop: () async {
          return false;
        },
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: state == ViewerStates.home1
                ? home1Widgets(homeCategory, homeApps, _images)
                : home2Widgets(homeCategory, homeApps, _images)
          ),
        )
      );
    }
    else {
      return WillPopScope(
        onWillPop: () async {
          setState(() {
            state = selectedHome;
          });
          return false;
        },
        child: SingleChildScrollView(child: _categories(categoriesWithApps)),
      );
    }
  }

  List<Widget> home1Widgets(homeCategory, homeApps, _images) {
    var appsList = homeApps
        .sublist(0, homeApps.length > 10 ? 10 : homeApps.length);

    return
      [
        AdsV1Widget(_images),
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
                state = ViewerStates.allApps;
              });
            }),
        )
      ];
  }

  List<Widget> home2Widgets(homeCategory, homeApps, _images) {
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
                state = ViewerStates.allApps;
              });
            }),
        )
      ];
  }

  void startFetchingImages(BuildContext context) {
    fetchConfig(macAddress).then((configResponse) {
      if (configResponse != null) {
        onConfigFetched(configResponse);
      }
    });
  }

  void onConfigFetched(ConfigsModel configResponse) {
    getApplicationDocumentsDirectory().then((dir) {
      var newHome = launcherIdToHome(configResponse.launcher);

      var homeImages = convertConfigImagesToWidgets(
          context, configResponse.images, dir.path, imagesLenFromHomeType(newHome));

      if(state == selectedHome && selectedHome != newHome){
        setState(() {
          config = configResponse;
          selectedHome = newHome;
          state = newHome;
          _images = homeImages;
        });
      }
      else {
        setState(() {
          config = configResponse;
          selectedHome = newHome;
          state = state;
          _images = homeImages;
        });
      }

    });
  }

  Future<ConfigsModel?> fetchConfig(String macAddress) async {
    final uri = Uri.parse(apiDomain+'api/device/device/'+macAddress);
    print(uri.toString());
    final response = await http.get(uri);

    print(response.statusCode);
    if (response.statusCode == 200 || response.statusCode == 404) {
      var model = ConfigsModel.fromJson(jsonDecode(response.body));

      print(model.launcher);
      context.read<SettingsService>().setLauncherConfig(response.body);
      return model;
    } else {
      return null;
    }
  }
}

int imagesLenFromHomeType(ViewerStates homeId) {
  if(homeId == ViewerStates.home1) {
    return 3;
  }
  if(homeId == ViewerStates.home2) {
    return 5;
  }
  return 0;
}

launcherIdToHome(int? launcherId) {
  if(launcherId == null) {
    return ViewerStates.allApps;
  }
  else if(launcherId! == 1){
    return ViewerStates.home1;
  }
  else if(launcherId! == 2) {
    return ViewerStates.home2;
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
        print(image.id.toString() + ' : ' + image.path!);
      }
      else {
        list.add(_emptyStateImage());
        print(i.toString() + ' : ');
      }
    }
  }
  return list;
}

Widget _image(BuildContext context, url, file, int id, String link)  {
  var nImage = NetworkToFileImage(
      url: apiDomain + url,
      file: file,
      debug: true);

  return VideoCard(
      image: Image(image:nImage,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      ),
      link: link,
      id: id,
      autofocus: false,
      onMove: (p0) {

      },
      onMoveEnd: () {

      },
    key: Key("vc-" + id.toString() + generateMd5(url + link ?? '')),
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