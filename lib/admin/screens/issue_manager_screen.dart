import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:getwidget/components/tabs/gf_segment_tabs.dart';
import 'package:getwidget/components/tabs/gf_tabbar_view.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:milton_relay/shared/models/issue_model.dart';
import 'package:milton_relay/shared/routing/routes.dart';
import 'package:milton_relay/shared/services/issue_service.dart';
import 'package:milton_relay/shared/services/user_service.dart';
import 'package:milton_relay/shared/utils/text_util.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../shared/models/collections.dart';
import '../../shared/utils/color_util.dart';

class IssueManagerScreen extends StatefulWidget {
  const IssueManagerScreen({Key? key}) : super(key: key);

  @override
  State<IssueManagerScreen> createState() => _IssueManagerScreenState();
}

class _IssueManagerScreenState extends State<IssueManagerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<_IssueViewState> _resolvedKey = GlobalKey(),
      _unresolvedKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar("Issues"),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox.square(dimension: 3.w),
            GFSegmentTabs(
              length: 2,
              unselectedLabelColor: Colors.black,
              indicatorColor: ColorUtil.red,
              border: Border.all(color: Colors.black, width: 0.1.w),
              tabs: const <Widget>[Text("Unresolved"), Text("Resolved")],
              tabController: _tabController,
            ),
            SizedBox.square(dimension: 3.w),
            Expanded(
              child: GFTabBarView(controller: _tabController, children: [
                IssueView(false, _refreshContent, key: _unresolvedKey),
                IssueView(true, _refreshContent, key: _resolvedKey)
              ]),
            )
          ],
        ),
      ),
    );
  }

  void _refreshContent() {
    _resolvedKey.currentState?.setState(() {
      _resolvedKey.currentState?._allFetched = false;
      _resolvedKey.currentState?._lastDocument = null;
      _resolvedKey.currentState?._issues.clear();
      _resolvedKey.currentState?._getIssueData();
    });
    _unresolvedKey.currentState?.setState(() {
      _unresolvedKey.currentState?._allFetched = false;
      _unresolvedKey.currentState?._lastDocument = null;
      _unresolvedKey.currentState?._issues.clear();
      _unresolvedKey.currentState?._getIssueData();
    });
  }
}

class IssueView extends StatefulWidget {
  final bool resolved;
  final Function refreshFunction;
  const IssueView(this.resolved, this.refreshFunction, {Key? key})
      : super(key: key);

  @override
  State<IssueView> createState() => _IssueViewState();
}

class _IssueViewState extends State<IssueView>
    with AutomaticKeepAliveClientMixin {
  static const int loadSize = 10;
  bool _loading = false, _allFetched = false;
  final List<Widget> _issues = [];
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();
    _getIssueData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return NotificationListener<ScrollEndNotification>(
      child: ListView.builder(
        itemBuilder: (context, index) {
          if (_issues.isEmpty && _allFetched) {
            return SizedBox(
                height: 10.w,
                child: Center(
                    child: Text('No Issues', style: TextStyle(fontSize: 5.w))));
          }
          if (index == _issues.length) {
            return SizedBox(
              width: double.infinity,
              height: 10.w,
              child: const Center(child: CircularProgressIndicator()),
            );
          }
          return _issues[index];
        },
        itemCount: _issues.length +
            ((_allFetched && _issues.isEmpty) || _loading ? 1 : 0),
      ),
      onNotification: (scrollEnd) {
        if (scrollEnd.metrics.atEdge && scrollEnd.metrics.pixels > 0) {
          _getIssueData();
        }
        return true;
      },
    );
  }

  void _getIssueData() async {
    if (_loading || _allFetched) return;
    setState(() => _loading = true);
    Query query = FirebaseFirestore.instance
        .collection(Collections.issues.toPath)
        .where('resolved', isEqualTo: widget.resolved)
        .orderBy('date');
    query = _lastDocument == null
        ? query.limit(loadSize)
        : query.startAfterDocument(_lastDocument!).limit(loadSize);
    QuerySnapshot querySnapshot = await query.get();
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      IssueModel issueModel = IssueService()
          .getIssueFromJson(doc.id, doc.data() as Map<String, dynamic>);
      if (!mounted) return;
      _issues.add(await _getIssueWidget(context, issueModel));
    }
    setState(() {
      _loading = false;
      _lastDocument = querySnapshot.docs.isNotEmpty
          ? _lastDocument = querySnapshot.docs.last
          : _lastDocument = null;
      _allFetched = querySnapshot.docs.length < loadSize;
    });
  }

  Future<Widget> _getIssueWidget(
          BuildContext context, IssueModel issue) async =>
      Container(
        margin: EdgeInsets.all(1.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(1.w)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 0.3.w,
              blurRadius: 0.3.w,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: GFListTile(
          onTap: () {
            context.push(Routes.viewIssue.toPath, extra: issue);
            GoRouter.of(context).addListener(_refreshIssuesOnPop);
          },
          color: ColorUtil.snowWhite,
          avatar: Padding(
            padding: EdgeInsets.only(right: 1.w),
            child: Icon(issue.issue.toIcon, color: ColorUtil.red, size: 7.w),
          ),
          title: Text(issue.issue.toName.capitalize(),
              style: TextStyle(fontSize: 5.w, color: ColorUtil.blue)),
          subTitle: Text(
              'Submitted by ${(await UserService().getUserFromID(issue.reporter)).fullName} on ${DateFormat.yMMMMd().format(issue.date)}',
              style: TextStyle(fontSize: 3.w)),
        ),
      );

  void _refreshIssuesOnPop() {
    if (!mounted) return;
    if (GoRouter.of(context).location == Routes.issueManager.toPath) {
      widget.refreshFunction.call();
      GoRouter.of(context).removeListener(_refreshIssuesOnPop);
    }
  }

  @override
  bool get wantKeepAlive => true;
}
