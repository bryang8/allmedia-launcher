/*
 * FLauncher
 * Copyright (C) 2021  Étienne Fesser
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:typed_data';
import 'dart:ui';

import 'package:flauncher/custom_traversal_policy.dart';
import 'package:flauncher/database.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flauncher/widgets/apps_home_grid.dart';
import 'package:flauncher/widgets/settings/settings_panel.dart';
import 'package:flauncher/widgets/time_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  final Uint8List _allAppsBanner;
  final Function _openAllApps;

  Home(this._allAppsBanner, this._openAllApps);

  @override
  Widget build(BuildContext context) => FocusTraversalGroup(
        policy: RowByRowTraversalPolicy(),
        child: Stack(
          children: [
            Consumer<WallpaperService>(
              builder: (_, wallpaper, __) => _wallpaper(context, wallpaper.wallpaperBytes, wallpaper.gradient.gradient),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: _appBar(context),
              body: Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Consumer<AppsService>(
                  builder: (context, appsService, _) {
                    if(!appsService.initialized) {
                      return _emptyState(context);
                    }

                    var appMenu = App(
                        packageName: "menu",
                        name: "All Apps",
                        version: "0",
                        hidden: false,
                        sideloaded: false,
                        banner: _allAppsBanner
                    );

                    var homeCategory = appsService.categoriesWithApps[0];
                    List<App> homeAppsList = homeCategory.applications.toList();

                    homeAppsList.insert(0, appMenu);

                    return _home(context, homeCategory, homeAppsList);
                  }
                ),
              ),
            ),
          ],
        ),
      );

  AppBar _appBar(BuildContext context) => AppBar(
    toolbarHeight: 46,
    actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 2.0,
              top: 10.0,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2, tileMode: TileMode.decal),
                child: Icon(Icons.settings_outlined, color: Colors.black54),
              ),
            ),
            IconButton(
              padding: EdgeInsets.all(2),
              constraints: BoxConstraints(),
              splashRadius: 20,
              icon: Icon(Icons.settings_outlined),
              onPressed: () => showDialog(context: context, builder: (_) => SettingsPanel()),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: 16, right: 32),
          child: Align(
            alignment: Alignment.center,
            child: TimeWidget(),
          ),
        ),
      ],
    );

  Widget _wallpaper(BuildContext context, Uint8List? wallpaperImage, Gradient gradient) => wallpaperImage != null
      ? Image.memory(
          wallpaperImage,
          key: Key("background"),
          fit: BoxFit.cover,
          height: window.physicalSize.height,
          width: window.physicalSize.width,
        )
      : Container(key: Key("background"), decoration: BoxDecoration(gradient: gradient));

  Widget _emptyState(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Loading...", style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      );

  Widget _home(BuildContext context, CategoryWithApps homeCategory, List<App> homeApps) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children:
      [
        Container(
          height: MediaQuery.of(context).size.height * 0.50,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.30,
                  padding: EdgeInsets.fromLTRB(0, 0, 4, 0),
                  child: Column(
                    children: [
                      Container(
                        child: Container(
                          color: Colors.grey,
                        ),
                        padding: EdgeInsets.only(bottom: 4),
                        height: MediaQuery.of(context).size.height * 0.25,
                      ),
                      Container(
                        child: Container(
                          color: Colors.grey,
                        ),
                        padding: EdgeInsets.only(top: 4),
                        height: MediaQuery.of(context).size.height * 0.25,
                      )
                    ] ,
                  ),
                ),
                Container(
                  width: (MediaQuery.of(context).size.width * 0.7) - 32,
                  padding: EdgeInsets.fromLTRB(4,0,0,0),
                  child: Container(
                    color: Colors.grey,
                  ),
                )
              ]
          ),
        ),
        //Home Apps
        Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: AppsHomeGrid(
            key: Key(homeCategory.category.id.toString()),
            category: homeCategory.category,
            applications: homeApps,
            openAllApps: _openAllApps),
        )
      ]
    ),
  );
}