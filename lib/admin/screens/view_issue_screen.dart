import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/components/carousel/gf_carousel.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:milton_relay/shared/models/issue_model.dart';
import 'package:milton_relay/shared/services/issue_service.dart';
import 'package:milton_relay/shared/services/user_service.dart';
import 'package:milton_relay/shared/utils/display_util.dart';
import 'package:milton_relay/shared/utils/text_util.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../shared/models/collections.dart';
import '../../shared/utils/color_util.dart';

class ViewIssueScreen extends StatefulWidget {
  final IssueModel issue;
  const ViewIssueScreen({required this.issue, Key? key}) : super(key: key);

  @override
  State<ViewIssueScreen> createState() => _ViewIssueScreenState();
}

class _ViewIssueScreenState extends State<ViewIssueScreen> {
  String? _name;

  @override
  void initState() {
    super.initState();
    _initName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppBar('${widget.issue.issue.toName.capitalize()} Issue'),
        body: SingleChildScrollView(
          child: Card(
              margin: EdgeInsets.all(3.w),
              color: ColorUtil.snowWhite,
              child: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                          text: TextSpan(
                        children: [
                          TextSpan(
                              text: 'Reported by: ',
                              style: TextStyle(
                                  fontSize: 5.w, color: ColorUtil.blue)),
                          WidgetSpan(
                              child: Padding(
                            padding: EdgeInsets.only(right: 1.w),
                            child: Icon(Icons.person, size: 5.w),
                          )),
                          TextSpan(
                              text: _name ?? 'Loading...',
                              style:
                                  TextStyle(fontSize: 5.w, color: Colors.black))
                        ],
                      )),
                      RichText(
                          text: TextSpan(
                        children: [
                          TextSpan(
                              text: 'Date: ',
                              style: TextStyle(
                                  fontSize: 5.w, color: ColorUtil.blue)),
                          WidgetSpan(
                              child: Padding(
                            padding: EdgeInsets.only(right: 1.w),
                            child: Icon(Icons.calendar_today, size: 5.w),
                          )),
                          TextSpan(
                              text:
                                  DateFormat.yMMMMd().format(widget.issue.date),
                              style:
                                  TextStyle(fontSize: 5.w, color: Colors.black))
                        ],
                      )),
                      RichText(
                          text: TextSpan(
                        children: [
                          TextSpan(
                              text: 'Description: ',
                              style: TextStyle(
                                  fontSize: 5.w, color: ColorUtil.blue)),
                          WidgetSpan(
                              child: Padding(
                            padding: EdgeInsets.only(right: 1.w),
                            child: Icon(Icons.description, size: 5.w),
                          )),
                          TextSpan(
                              text: widget.issue.description,
                              style:
                                  TextStyle(fontSize: 5.w, color: Colors.black))
                        ],
                      )),
                      RichText(
                          text: TextSpan(
                        children: [
                          TextSpan(
                              text: 'Resolved: ',
                              style: TextStyle(
                                  fontSize: 5.w, color: ColorUtil.blue)),
                          WidgetSpan(
                              child: Padding(
                            padding: EdgeInsets.only(right: 1.w),
                            child: Icon(
                                widget.issue.resolved
                                    ? Icons.done
                                    : Icons.not_interested,
                                size: 5.w),
                          )),
                          TextSpan(
                              text:
                                  widget.issue.resolved.toString().capitalize(),
                              style:
                                  TextStyle(fontSize: 5.w, color: Colors.black))
                        ],
                      )),
                      if (widget.issue.imageURLs.isNotEmpty)
                        GFCarousel(
                            enableInfiniteScroll: false,
                            hasPagination: widget.issue.imageURLs.length > 1,
                            height: 50.h,
                            items: widget.issue.imageURLs
                                .map((url) => Container(
                                      margin: const EdgeInsets.all(8.0),
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5.0)),
                                        child: Image.network(url,
                                            fit: BoxFit.cover),
                                      ),
                                    ))
                                .toList()),
                      SizedBox(height: 1.h),
                      Center(
                        child: GFButton(
                            onPressed: () async {
                              widget.issue.resolved = !widget.issue.resolved;
                              context.loaderOverlay.show();
                              await FirebaseFirestore.instance
                                  .collection(Collections.issues.toPath)
                                  .doc(widget.issue.id)
                                  .set(
                                      IssueService().issueToJson(widget.issue));
                              if (!mounted) return;
                              context.loaderOverlay.hide();
                              context.pop();
                              showSnackBar(context,
                                  'Marked as ${widget.issue.resolved ? 'Resolved' : 'Unresolved'}');
                            },
                            color: ColorUtil.red,
                            size: 5.h,
                            textStyle: TextStyle(fontSize: 2.h),
                            icon: widget.issue.resolved
                                ? Icon(Icons.not_interested,
                                    color: Colors.white, size: 3.h)
                                : Icon(Icons.done,
                                    color: Colors.white, size: 3.h),
                            text: widget.issue.resolved
                                ? 'Mark as Unresolved'
                                : 'Mark as Resolved'),
                      ),
                    ],
                  ))),
        ));
  }

  void _initName() async {
    String name =
        (await UserService().getUserFromID(widget.issue.reporter)).fullName;
    setState(() => _name = name);
  }
}
