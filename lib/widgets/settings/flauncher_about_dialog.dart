import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/services.dart';

class FLauncherAboutDialog extends StatelessWidget {
  final PackageInfo packageInfo;

  FLauncherAboutDialog({
    Key? key,
    required this.packageInfo,
  }) : super(key: key);

  Future<String> getAndroidId() async {
    const platform = MethodChannel('com.allmedia.launcher/androidid');
    try {
      final androidId = await platform.invokeMethod<String>('getAndroidId');
      if (androidId == null || androidId.isEmpty) return "";

      final formattedAndroidId = androidId.replaceAllMapped(
          RegExp(r'.{4}'),
              (match) => '${match.group(0)}:'
      );

      return formattedAndroidId.endsWith(':') ? formattedAndroidId.substring(0, formattedAndroidId.length - 1) : formattedAndroidId;
    } on PlatformException catch (e) {
      print("Failed to get Android ID: '${e.message}'.");
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium!;
    final underlined = textStyle.copyWith(decoration: TextDecoration.underline);

    return Dialog(
      child: Container(
        padding: EdgeInsets.all(20),
        child: FutureBuilder<String>(
          future: getAndroidId(),
          builder: (context, snapshot) {
            String macAddress = snapshot.data ?? 'Loading...';
            if (snapshot.hasError) {
              macAddress = 'Error: ${snapshot.error}';
            }

            return RichText(
              text: TextSpan(
                style: textStyle,
                children: [
                  TextSpan(text: "ID: "),
                  TextSpan(text: macAddress, style: underlined),
                  TextSpan(text: "."),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
