
import 'package:flauncher/actions.dart';
import 'package:flauncher/database.dart';
import 'package:flauncher/widgets/adds/adds_v1.dart';
import 'package:flauncher/widgets/adds/adds_v2.dart';
import 'package:flauncher/widgets/grids/apps_grid.dart';
import 'package:flauncher/widgets/category_row.dart';
import 'package:flauncher/widgets/grids/apps_home_grid.dart';
import 'package:flauncher/widgets/grids/apps_home_grid_2.dart';
import 'package:flutter/cupertino.dart';

enum ViewerStates {
  Home1, Home2, AllApps, None
}

class AppsViewer extends StatefulWidget {
  final List<CategoryWithApps> categoriesWithApps;
  final CategoryWithApps homeCategory;
  final List<App> homeApps;

  AppsViewer(
    this.categoriesWithApps,
    this.homeCategory,
    this.homeApps,
  );

  @override
  State<AppsViewer> createState() => AppsViewerState(
      categoriesWithApps,
      homeCategory,
      homeApps
  );

}

class AppsViewerState extends State<AppsViewer> {
  ViewerStates state = ViewerStates.Home2;
  ViewerStates prevState = ViewerStates.Home2;
  List<CategoryWithApps> categoriesWithApps;
  CategoryWithApps homeCategory;
  List<App> homeApps;

  AppsViewerState(this.categoriesWithApps, this.homeCategory, this.homeApps);

  @override
  Widget build(BuildContext context) {
    if(state != ViewerStates.AllApps && state != ViewerStates.None) {
      return WillPopScope (
        onWillPop: () async {
          return false;
        },
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: state == ViewerStates.Home1
                ? Home1Widgets() : Home2Widgets()
          ),
        )
      );
    }
    else {
      return WillPopScope(
        onWillPop: () async {
          setState(() {
            state = prevState;
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

  List<Widget> Home1Widgets() {
    var appsList = homeApps
        .sublist(0, homeApps.length > 8 ? 8 : homeApps.length);

    return
      [
        AddsV1Widget(),
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
                prevState = state;
                state = ViewerStates.AllApps;
              });
            }),
        )
      ];
  }

  List<Widget> Home2Widgets() {
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
                prevState = state;
                state = ViewerStates.AllApps;
              });
            }),
        )
      ];
  }
}