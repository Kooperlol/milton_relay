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
import '../../shared/models/load_model.dart';
import '../../shared/utils/color_util.dart';

class IssueManagerScreen extends StatefulWidget {
  const IssueManagerScreen({Key? key}) : super(key: key);

  @override
  State<IssueManagerScreen> createState() => _IssueManagerScreenState();
}

class _IssueManagerScreenState extends State<IssueManagerScreen>
    with SingleTickerProviderStateMixin {
  // Tab controller for switching between resolved and unresolved.
  late TabController _tabController;
  // Stores the state of widgets so they can be refreshed.
  final GlobalKey<_IssueViewState> _resolvedKey = GlobalKey(),
      _unresolvedKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Initializes the tab controller with vsync.
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
      appBar: const AppBarWidget(title: "Issues"),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox.square(dimension: 3.w),
            // Tabs to switch between the unresolved and resolved screen.
            GFSegmentTabs(
              length: 2,
              unselectedLabelColor: Colors.black,
              indicatorColor: ColorUtil.red,
              border: Border.all(color: Colors.black, width: 0.1.w),
              tabs: const <Widget>[Text("Unresolved"), Text("Resolved")],
              tabController: _tabController,
            ),
            SizedBox.square(dimension: 3.w),
            // Shows the resolved or unresolved screen depending on the tab selected.
            // Passes the [_refreshContent] function to be used from the key.
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

  /// Refreshes the issues by clearing the data and resetting the current index. Then, fetches 10 issues.
  void _refreshContent() {
    _resolvedKey.currentState?.setState(() {
      _resolvedKey.currentState?.isAllFetched = false;
      _resolvedKey.currentState?.lastDocument = null;
      _resolvedKey.currentState?.data.clear();
      _resolvedKey.currentState?.fetchData(10);
    });
    _unresolvedKey.currentState?.setState(() {
      _unresolvedKey.currentState?.isAllFetched = false;
      _unresolvedKey.currentState?.lastDocument = null;
      _unresolvedKey.currentState?.data.clear();
      _unresolvedKey.currentState?.fetchData(10);
    });
  }
}

/// Shows either all resolved issues or unresolved issues depending on [resolved].
class IssueView extends StatefulWidget {
  final bool resolved;
  final Function refreshFunction;
  const IssueView(this.resolved, this.refreshFunction, {Key? key})
      : super(key: key);

  @override
  State<IssueView> createState() => _IssueViewState();
}

class _IssueViewState extends State<IssueView>
    with AutomaticKeepAliveClientMixin, LoadModel {
  @override
  void initState() {
    super.initState();
    // Load 10 issues.
    fetchData(10);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Loads data if the bottom is reached. Otherwise, it displays the issue at that index that is within [data].
    return NotificationListener<ScrollEndNotification>(
      child: ListView.builder(
        itemBuilder: (context, index) {
          if (data.isEmpty && isAllFetched) {
            return SizedBox(
                height: 10.w,
                child: Center(
                    child: Text('No Issues', style: TextStyle(fontSize: 5.w))));
          }
          if (index == data.length) {
            return loading;
          }
          return data[index];
        },
        itemCount:
            data.length + ((isAllFetched && data.isEmpty) || isLoading ? 1 : 0),
      ),
      onNotification: (scrollEnd) {
        if (scrollEnd.metrics.atEdge && scrollEnd.metrics.pixels > 0) {
          fetchData(10);
        }
        return true;
      },
    );
  }

  /// Returns a widget which displays information about [issue]
  ///
  /// On tap, the view issue screen will be opened to see more information and manage it.
  /// Once the view issue screen is popped, the content will be refreshed using [_refreshIssuesOnPop].
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

  /// Listener to check for the view issue screen being exited.
  ///
  /// Once exited, the [refreshFunction] is called and the listener is removed.
  void _refreshIssuesOnPop() {
    if (!mounted) return;
    if (GoRouter.of(context).location == Routes.issueManager.toPath) {
      widget.refreshFunction.call();
      GoRouter.of(context).removeListener(_refreshIssuesOnPop);
    }
  }

  /// Saves the state of the screen so the data isn't always being refreshed.
  @override
  bool get wantKeepAlive => true;

  /// Gets [loadSize] amount of resolved or unresolved issues depending on [widget.resolved].
  ///
  /// Queries the Database for issues that match and then adds them to [data] after calling the [_getIssueWidget] function.
  @override
  Future<void> fetchData(int loadSize) async {
    if (isLoading || isAllFetched) return;
    setState(() => isLoading = true);
    Query query = FirebaseFirestore.instance
        .collection(Collections.issues.toPath)
        .where('resolved', isEqualTo: widget.resolved)
        .orderBy('date', descending: true);
    query = lastDocument == null
        ? query.limit(loadSize)
        : query.startAfterDocument(lastDocument!).limit(loadSize);
    QuerySnapshot querySnapshot = await query.get();
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      IssueModel issueModel = IssueService()
          .getIssueFromJson(doc.id, doc.data() as Map<String, dynamic>);
      if (!mounted) return;
      data.add(await _getIssueWidget(context, issueModel));
    }
    setState(() {
      if (!mounted) return;
      isLoading = false;
      lastDocument = querySnapshot.docs.isNotEmpty
          ? lastDocument = querySnapshot.docs.last
          : lastDocument = null;
      isAllFetched = querySnapshot.docs.length < loadSize;
    });
  }
}
