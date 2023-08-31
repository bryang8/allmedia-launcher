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

import 'dart:io';

import 'package:flauncher/models/config_model.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/ticker_model.dart';
import 'package:flauncher/widgets/color_helpers.dart';
import 'package:flauncher/widgets/focus_keyboard_listener.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

const _validationKeys = [LogicalKeyboardKey.select, LogicalKeyboardKey.enter, LogicalKeyboardKey.gameButtonA];

class VideoCard extends StatefulWidget {
  final ConfigsImage image;
  final String url;
  final File file;
  final bool autofocus;
  final void Function(AxisDirection) onMove;
  final VoidCallback onMoveEnd;

  VideoCard({
    Key? key,
    required this.image,
    required this.url,
    required this.file,
    required this.autofocus,
    required this.onMove,
    required this.onMoveEnd,
  }) : super(key: key);

  @override
  _VideoCard createState() {
    return _VideoCard(image, url, file);
  }
}

class _VideoCard extends State<VideoCard> with SingleTickerProviderStateMixin {
  final ConfigsImage image;
  final String url;
  final File file;

  _VideoCard(this.image, this.url, this.file);

  bool _moving = false;
  MemoryImage? _imageProvider;
  late final AnimationController _animation = AnimationController(
    vsync: Provider.of<TickerModel>(context, listen: false).tickerProvider ?? this,
    duration: Duration(
      milliseconds: 800,
    ),
  );
  Color _lastBorderColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _animation.addStatusListener((animationStatus) {
      switch (animationStatus) {
        case AnimationStatus.completed:
          _animation.reverse();
          break;
        case AnimationStatus.dismissed:
          _animation.forward();
          break;
        case AnimationStatus.forward:
        case AnimationStatus.reverse:
        // nothing to do
          break;
      }
    });
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  ImageProvider _cachedMemoryImage(Uint8List bytes) {
    if (!listEquals(bytes, _imageProvider?.bytes)) {
      _imageProvider = MemoryImage(bytes);
    }
    return _imageProvider!;
  }

  @override
  Widget build(BuildContext context) => FocusKeyboardListener(
    onPressed: (key) => _onPressed(context, key),
    builder: (context) => FocusTraversalOrder(
      order: NumericFocusOrder(image.id!.toDouble()),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transformAlignment: Alignment.center,
        transform: _scaleTransform(context),
        child: Material(
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          elevation: Focus.of(context).hasFocus ? 16 : 0,
          shadowColor: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              InkWell(
                autofocus: widget.autofocus,
                focusColor: Colors.transparent,
                onTap: () => _onPressed(context, null),
                child: Image(
                  image:NetworkToFileImage(
                      url: url,
                      file: file,
                      debug: true
                  ),
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high,
                ),
              ),
              IgnorePointer(
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  opacity: Focus.of(context).hasFocus ? 0 : 0.10,
                  child: Container(color: Colors.black),
                ),
              ),
              Selector<SettingsService, bool>(
                selector: (_, settingsService) => settingsService.appHighlightAnimationEnabled,
                builder: (context, appHighlightAnimationEnabled, __) {
                  if (appHighlightAnimationEnabled) {
                    _animation.forward();
                    return AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) => IgnorePointer(
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            border: Focus.of(context).hasFocus
                                ? Border.all(
                                color: _lastBorderColor =
                                    computeBorderColor(_animation.value, _lastBorderColor),
                                width: 3)
                                : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    );
                  }
                  _animation.stop();
                  return SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Matrix4 _scaleTransform(BuildContext context) {
    final scale = _moving
        ? 1.0
        : Focus.of(context).hasFocus
        ? 1.0
        : 1.0;
    return Matrix4.diagonal3Values(scale, scale, 1.0);
  }

  KeyEventResult _onPressed(BuildContext context, LogicalKeyboardKey? key) {
    if (_validationKeys.contains(key)) {
      var uri =  Uri.parse(image.link!);
      _launchUrl(uri);

      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Future<void> _launchUrl(uri) async {
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

}
