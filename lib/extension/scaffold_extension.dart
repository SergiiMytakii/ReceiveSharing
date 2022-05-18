import 'dart:io';

import 'package:flutter/material.dart';
import 'package:receivesharing/constants/color_constants.dart';
import 'package:receivesharing/constants/dimens_constants.dart';
import 'package:receivesharing/constants/file_constants.dart';
import 'package:receivesharing/constants/font_size_constants.dart';

import 'package:receivesharing/ui/sharing/sharing_media_preview_screen.dart';

extension ScaffoldExtension on Widget {
  //General Scaffold For All Screens
  Scaffold generalScaffold(
      {BuildContext? context,
      String? appTitle,
      bool isBack = true,
      bool isShowFab = false,
      List<File>? files,
      String? sharedText}) {
    return Scaffold(
        appBar: _generalAppBar(context, appTitle, isBack),
        body: SafeArea(
          child: this,
        ),
        floatingActionButton:
            isShowFab ? _fabButton(context, files) : SizedBox());
  }

  AppBar _generalAppBar(BuildContext? context, String? appTitle, bool isBack) =>
      AppBar(
          brightness: Brightness.dark,
          elevation: 4,
          title: Text(appTitle!,
              style: TextStyle(
                  color: ColorConstants.whiteColor,
                  fontSize: FontSizeWeightConstants.fontSize24,
                  fontWeight: FontSizeWeightConstants.fontWeightBold)),
          leading: (isBack)
              ? IconButton(
                  icon: Image.asset(FileConstants.icBack, scale: 3.0),
                  onPressed: () {
                    Navigator.of(context!).pop();
                  },
                )
              : SizedBox(),
          centerTitle: true);

  Widget _fabButton(
    BuildContext? context,
    List<File>? files,
  ) =>
      Padding(
        padding:
            const EdgeInsets.only(bottom: DimensionConstants.bottomPadding8),
        child: FloatingActionButton(
            backgroundColor: ColorConstants.primaryColor,
            onPressed: () {
              Navigator.of(context!).push(MaterialPageRoute(
                  builder: (context) => SharingMediaPreviewScreen(
                        files: files,
                      )));
            },
            child: Image.asset(
              FileConstants.icShareMedia,
              height: DimensionConstants.imageHeight30,
              width: DimensionConstants.imageWidth30,
              color: ColorConstants.whiteColor,
            )),
      );
}
