import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:receivesharing/constants/app_constants.dart';
import 'package:receivesharing/constants/color_constants.dart';
import 'package:receivesharing/constants/dimens_constants.dart';
import 'package:receivesharing/constants/font_size_constants.dart';
import 'package:receivesharing/extension/scaffold_extension.dart';

import 'package:receivesharing/ui/sharing/sharing_media_preview_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
      listenShareMediaFiles(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: DimensionConstants.horizontalPadding10),
        child: Text("Receive Sharing Files And Send To Firebase",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: FontSizeWeightConstants.fontSize20,
                color: ColorConstants.greyColor)),
      ),
    ).generalScaffold(
      context: context,
      appTitle: "Screenie",
      isBack: false,
      files: [],
    );
  }

  //All listeners to listen Sharing media files & text
  void listenShareMediaFiles(BuildContext context) {
    void navigateToShareMedia(
        BuildContext context, List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        var newFiles = <File>[];
        value.forEach((element) {
          newFiles.add(File(
            Platform.isIOS
                ? element.type == SharedMediaType.FILE
                    ? element.path
                        .toString()
                        .replaceAll(AppConstants.replaceableText, "")
                    : element.path
                : element.path,
          ));
        });
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SharingMediaPreviewScreen(
                  files: newFiles,
                  text: "",
                )));
      }
    }

    // For sharing images coming from outside the app
    // while the app is in the memory
    ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> value) {
      navigateToShareMedia(context, value);
    }, onError: (err) {
      debugPrint("$err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      navigateToShareMedia(context, value);
    });
  }
}
