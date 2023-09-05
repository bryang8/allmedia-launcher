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

import 'dart:convert';
import 'dart:typed_data';

import 'package:flauncher/models/config_model.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class LauncherLogoWidget extends StatefulWidget {
  final Uint8List _theBoxIcon;
  final Uint8List _youBoxIcon;

  LauncherLogoWidget(this._theBoxIcon, this._youBoxIcon);

  @override
  State<StatefulWidget> createState() => _LauncherLogoWidgetState(_theBoxIcon, _youBoxIcon);
}

class _LauncherLogoWidgetState extends State<LauncherLogoWidget> {
  final Uint8List _theBoxIcon;
  final Uint8List _youBoxIcon;
  int state = 0;

  _LauncherLogoWidgetState(this._theBoxIcon, this._youBoxIcon);

  @override
  void initState() {
    var settingsService = context.read<SettingsService>();
    var config = settingsService.launcherConfig;

    settingsService.addListener(() {
      config = settingsService.launcherConfig;
      setConfig(config);
    });

    setConfig(config);
  }

  void setConfig(config) {
    try {
      if(config != null) {
        var configModel = ConfigsModel.fromJson(jsonDecode(config));
        setState(() {
          state = configModel.launcher ?? 0;
        });
      }
    } catch (ex) {
      //ignored
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    key: Key("llogo-" + state.toString()),
    height: 32,
    width: 32,
    decoration: state == 0
        ? BoxDecoration(color: Colors.transparent)
        : BoxDecoration( image: DecorationImage(
        fit: BoxFit.cover, image: MemoryImage( state == 1
        ? _theBoxIcon : _youBoxIcon, scale: 0.5))
    ),
  );
}

