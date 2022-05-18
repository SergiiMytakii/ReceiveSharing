import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:receivesharing/constants/app_constants.dart';
import 'package:receivesharing/constants/color_constants.dart';
import 'package:receivesharing/constants/dimens_constants.dart';
import 'package:receivesharing/constants/file_constants.dart';
import 'package:receivesharing/constants/font_size_constants.dart';
import 'package:receivesharing/extension/scaffold_extension.dart';
import 'package:receivesharing/service/firebase_service.dart';

import 'package:receivesharing/widget/empty_view.dart';
import 'package:share_plus/share_plus.dart';

import '../../service/firebase_service.dart';
import '../model/media_preview_item.dart';

class SharingMediaPreviewScreen extends StatefulWidget {
  final List<File>? files;
  final String? text;
  SharingMediaPreviewScreen({this.files, this.text = ""});
  @override
  _SharingMediaPreviewScreenState createState() =>
      _SharingMediaPreviewScreenState();
}

class _SharingMediaPreviewScreenState extends State<SharingMediaPreviewScreen> {
  final PageController _pageController =
      PageController(initialPage: 0, viewportFraction: 0.95, keepPage: false);
  final List<MediaPreviewItem> _galleryItems = [];
  int _initialIndex = 0;
  var link = '';
  @override
  void initState() {
    super.initState();

    FirebaseServise.uploadFile(widget.files!.first)
        .then((value) => setState(() {
              link = value;
            }));
    SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
      setState(() {
        var i = 0;
        widget.files?.forEach((element) {
          _galleryItems.add(MediaPreviewItem(
              id: i,
              resource: element,
              controller: TextEditingController(),
              isSelected: i == 0 ? true : false));
          i++;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _galleryItems.isNotEmpty
        ? Column(
            children: [
              SizedBox(height: DimensionConstants.sizedBoxHeight5),
              _fullMediaPreview(context),
              SizedBox(height: DimensionConstants.sizedBoxHeight5),
              _fileName(context),
              SizedBox(height: DimensionConstants.sizedBoxHeight5),
              _link(context),
            ],
          ).generalScaffold(
            context: context,
            appTitle: "Send to...",
            files: widget.files,
          )
        : EmptyView(
            topLine: "No files are here..",
            bottomLine: "Select files from gallery or file manager.",
          ).generalScaffold(
            context: context,
            appTitle: "Send to...",
            files: widget.files,
          );
  }

  Widget _fullMediaPreview(BuildContext context) => Container(
      height: MediaQuery.of(context).size.height * 0.5,
      child: PageView(
        controller: _pageController,
        physics: ClampingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        onPageChanged: (value) {
          _mediaPreviewChanged(value);
        },
        children: _galleryItems
            .map((e) => AppConstants.imageExtensions
                    .contains(e.resource?.path.split('.').last.toLowerCase())
                ? Image.file(File(e.resource!.path))
                : Image.asset(
                    FileConstants.icFile,
                  ))
            .toList(),
      ));

  void _mediaPreviewChanged(int value) {
    _initialIndex = value;
    setState(() {
      var i = 0;
      _galleryItems.forEach((element) {
        if (i == value) {
          _galleryItems[i].isSelected = true;
        } else {
          _galleryItems[i].isSelected = false;
        }
        i++;
      });
    });
  }

  Widget _fileName(BuildContext context) => Padding(
        padding: const EdgeInsets.all(DimensionConstants.padding8),
        child: Text(
            "${_galleryItems[_initialIndex].resource!.path.split('/').last}"),
      );

  Widget _link(BuildContext context) => Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(children: [
        link.isNotEmpty
            ? Expanded(child: Text(link))
            : Expanded(child: Center(child: CircularProgressIndicator())),
        GestureDetector(
            onTap: _onSharingTap,
            child: Padding(
                padding: const EdgeInsets.only(
                    bottom: DimensionConstants.bottomPadding8),
                child: Image.asset(FileConstants.icSend, scale: 2.7)))
      ]));

  Widget _horizontalMediaFilesView(BuildContext context) =>
      (MediaQuery.of(context).viewInsets.bottom == 0)
          ? Container(
              height: DimensionConstants.containerHeight60,
              margin: const EdgeInsets.only(
                  left: DimensionConstants.leftPadding15,
                  bottom: DimensionConstants.bottomPadding10,
                  top: DimensionConstants.topPadding5),
              child: ListView.separated(
                  itemCount: _galleryItems.length,
                  separatorBuilder: (context, index) {
                    return SizedBox(width: DimensionConstants.sizedBoxWidth10);
                  },
                  itemBuilder: (context, index) {
                    return GestureDetector(
                        onTap: () {
                          _onTapHorizontalMedia(context, index);
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: _galleryItems[index].isSelected
                                        ? ColorConstants.greyColor
                                        : ColorConstants.whiteColor,
                                    width: 1.0)),
                            child: AppConstants.imageExtensions.contains(
                                    _galleryItems[index]
                                        .resource
                                        ?.path
                                        .split('.')
                                        .last
                                        .toLowerCase())
                                ? Image.file(
                                    File(_galleryItems[index].resource!.path))
                                : Image.asset(FileConstants.icFile)));
                  },
                  scrollDirection: Axis.horizontal))
          : SizedBox();

  void _onTapHorizontalMedia(BuildContext context, int index) {
    setState(() {
      var i = 0;
      _galleryItems.forEach((element) {
        if (i == index) {
          _galleryItems[i].isSelected = true;
        } else {
          _galleryItems[i].isSelected = false;
        }
        i++;
      });
    });
    _pageController.animateToPage(index,
        duration: Duration(milliseconds: 400), curve: Curves.easeIn);
  }

  void _onSharingTap() {
    if (link.isNotEmpty) {
      print('share $link');
      Share.share(link);
    }
  }
}
