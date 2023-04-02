import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

/// Used to request content from a database gradually and storing widgets to display in [data].
mixin LoadModel {
  // Booleans to keep track of whether all content is fetched and if the content is currently loading.
  bool isLoading = false, isAllFetched = false;
  // Document snapshot that stores the last document fetched.
  DocumentSnapshot? lastDocument;
  // Stores the current data of widgets to display.
  final List<Widget> data = [];

  /// Fetches [loadSize] amount of data.
  Future<void> fetchData(int loadSize);

  /// Gets the loading display.
  SizedBox get loading => SizedBox(
      width: double.infinity,
      height: 10.w,
      child: const Center(child: CircularProgressIndicator()));

  /// Listview to display [data].
  ///
  /// Displays [loading] if [isLoading] is true.
  /// Does nothing if [isAllFetched] is true.
  /// Calls [fetchData] if all data is loaded and the user is scrolling.
  Widget getDisplay(int loadSize) =>
      NotificationListener<ScrollEndNotification>(
        child: ListView.builder(
            itemBuilder: (context, index) {
              if (index == data.length || (isLoading && data.isEmpty)) {
                return loading;
              }
              return data[index];
            },
            itemCount: data.isEmpty
                ? 1
                : isAllFetched
                    ? data.length
                    : data.length + 1),
        onNotification: (scrollEnd) {
          if (scrollEnd.metrics.atEdge && scrollEnd.metrics.pixels > 0) {
            fetchData(loadSize);
          }
          return true;
        },
      );
}
