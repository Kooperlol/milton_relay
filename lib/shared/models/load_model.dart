import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

mixin LoadModel {
  bool isLoading = false, isAllFetched = false;
  DocumentSnapshot? lastDocument;
  final List<Widget> data = [];

  Future<void> fetchData(int loadSize);

  SizedBox get loading => SizedBox(
      width: double.infinity,
      height: 10.w,
      child: const Center(child: CircularProgressIndicator()));

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
