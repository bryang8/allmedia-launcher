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

import 'package:flauncher/actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'database.dart';
import 'flauncher.dart';
import 'flauncher_channel.dart';

class FLauncherApp extends StatelessWidget {
  final ChangeNotifierProvider _settingsService;
  final ChangeNotifierProvider _appsService;
  final ChangeNotifierProxyProvider _wallpaperService;
  final Provider _tickerModel;

  static const MaterialColor _swatch = MaterialColor(0xFF011526, <int, Color>{
    50: Color(0xFF36A0FA),
    100: Color(0xFF067BDE),
    200: Color(0xFF045CA7),
    300: Color(0xFF033662),
    400: Color(0xFF022544),
    500: Color(0xFF011526),
    600: Color(0xFF000508),
    700: Color(0xFF000000),
    800: Color(0xFF000000),
    900: Color(0xFF000000),
  });

  FLauncherApp(
    this._settingsService,
    this._appsService,
    this._wallpaperService,
    this._tickerModel
  );

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          _settingsService,
          _appsService,
          _wallpaperService,
          _tickerModel
        ],
        child: MaterialApp(
          shortcuts: {
            ...WidgetsApp.defaultShortcuts,
            SingleActivator(LogicalKeyboardKey.select): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.gameButtonB): PrioritizedIntents(orderedIntents: [
              DismissIntent(),
              BackIntent(),
            ]),
          },
          actions: {
            ...WidgetsApp.defaultActions,
            DirectionalFocusIntent: SoundFeedbackDirectionalFocusAction(context),
          },
          title: 'FLauncher',
          theme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: _swatch,
            // ignore: deprecated_member_use
            //accentColor: _swatch[200], //showing error
            cardColor: _swatch[300],
            canvasColor: _swatch[300],
            dialogBackgroundColor: _swatch[400],
            // ignore: deprecated_member_use
            backgroundColor: _swatch[400],
            scaffoldBackgroundColor: _swatch[400],
            textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: Colors.white)),
            appBarTheme: AppBarTheme(elevation: 0, backgroundColor: Colors.transparent),
            typography: Typography.material2018(),
            inputDecorationTheme: InputDecorationTheme(
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              labelStyle: Typography.material2018().white.bodyMedium,
            ),
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: Colors.white,
              selectionColor: _swatch[200],
              selectionHandleColor: _swatch[200],
            ),
          ),
          home: Builder(
            builder: (context) => WillPopScope(
              onWillPop: () async {
                final shouldPop = await shouldPopScope(context);
                if (!shouldPop) {
                  //context.read<AppsService>().startAmbientMode();
                }
                return shouldPop;
              },
              child: Actions(
                actions: {
                  BackIntent: BackAction(context, systemNavigator: true)
                },
                child: FLauncher()
              ),
            ),
          ),
        ),
      );
}
