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

import 'package:flauncher/apps_service.dart';
import 'package:flauncher/database.dart';
import 'package:flauncher/widgets/move_to_category_dialog.dart';
import 'package:flauncher/widgets/right_panel_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ApplicationInfoPanel extends StatelessWidget {
  final Category category;
  final App application;

  ApplicationInfoPanel({
    required this.category,
    required this.application,
  });

  @override
  Widget build(BuildContext context) => RightPanelDialog(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Image.memory(application.icon!, width: 50),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    application.name,
                    style: Theme.of(context).textTheme.headline6,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              application.packageName,
              style: Theme.of(context).textTheme.caption,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              "v${application.version}",
              style: Theme.of(context).textTheme.caption,
              overflow: TextOverflow.ellipsis,
            ),
            Divider(),
            TextButton(
              child: Row(
                children: [
                  Icon(Icons.category),
                  Container(width: 8),
                  Text(
                    "Move to...",
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ],
              ),
              onPressed: () async {
                final newCategory = await showDialog<Category>(
                  context: context,
                  builder: (_) => MoveToCategoryDialog(excludedCategory: category),
                );
                if (newCategory != null) {
                  await context.read<AppsService>().moveToCategory(application, category, newCategory);
                  Navigator.of(context).pop(ApplicationInfoPanelResult.none);
                }
              },
            ),
            TextButton(
              child: Row(
                children: [
                  Icon(Icons.open_with),
                  Container(width: 8),
                  Text(
                    "Move",
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ],
              ),
              onPressed: () => Navigator.of(context).pop(ApplicationInfoPanelResult.moveApp),
            ),
            Divider(),
            TextButton(
              child: Row(
                children: [
                  Icon(Icons.info_outlined),
                  Container(width: 8),
                  Text(
                    "App info",
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ],
              ),
              onPressed: () => context.read<AppsService>().openAppInfo(application),
            ),
            TextButton(
              child: Row(
                children: [
                  Icon(Icons.delete_outlined),
                  Container(width: 8),
                  Text(
                    "Uninstall",
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ],
              ),
              onPressed: () async {
                await context.read<AppsService>().uninstallApp(application);
                Navigator.of(context).pop(ApplicationInfoPanelResult.none);
              },
            ),
          ],
        ),
      );
}

enum ApplicationInfoPanelResult { none, moveApp }