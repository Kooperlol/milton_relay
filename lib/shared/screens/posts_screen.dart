import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/carousel/gf_carousel.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
import 'package:milton_relay/shared/models/post_model.dart';
import 'package:milton_relay/shared/models/roles.dart';
import 'package:milton_relay/shared/services/post_service.dart';
import 'package:milton_relay/shared/services/user_service.dart';
import 'package:milton_relay/shared/utils/text_util.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:readmore/readmore.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../models/collections.dart';
import '../models/user_model.dart';
import '../routing/routes.dart';
import '../services/auth_service.dart';
import '../utils/color_util.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({Key? key}) : super(key: key);

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  static const int loadSize = 8;
  final List<Widget> _posts = [];
  bool _isLoading = false, _allFetched = false;
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();
    _getPostData();
    //_createPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppBar('Community Posts', icons: [
          IconButton(
            tooltip: 'Create Post',
            icon: const Icon(Icons.add_photo_alternate),
            onPressed: () {
              context.push(Routes.createPost.toPath);
              GoRouter.of(context).addListener(_refreshPostsOnPop);
            },
          )
        ]),
        body: NotificationListener<ScrollEndNotification>(
          child: ListView.builder(
              itemBuilder: (context, index) {
                if (index == _posts.length) {
                  return SizedBox(
                    width: double.infinity,
                    height: 10.w,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
                return _posts[index];
              },
              itemCount: _posts.length + (_allFetched ? 0 : 1)),
          onNotification: (scrollEnd) {
            if (scrollEnd.metrics.atEdge && scrollEnd.metrics.pixels > 0) {
              _getPostData();
            }
            return true;
          },
        ));
  }

  Future<void> _getPostData() async {
    if (_isLoading || _allFetched) return;
    setState(() => _isLoading = true);

    Query query = FirebaseFirestore.instance
        .collection(Collections.posts.toPath)
        .orderBy('date', descending: true);
    query = _lastDocument == null
        ? query.limit(loadSize)
        : query.startAfterDocument(_lastDocument!).limit(loadSize);

    List<Widget> postCards = [];
    await query.get().then((value) {
      value.docs.isNotEmpty
          ? _lastDocument = value.docs.last
          : _lastDocument = null;
      for (var e in value.docs) {
        postCards.add(PostWidget(
            post: PostService()
                .getPostFromJson(e.id, e.data() as Map<String, dynamic>)));
      }
    });

    if (!mounted) return;
    setState(() {
      _posts.addAll(postCards);
      _allFetched = postCards.length < loadSize;
      _isLoading = false;
    });
  }

  void _refreshPostsOnPop() {
    if (!mounted) return;
    if (GoRouter.of(context).location.contains('/posts')) {
      setState(() {
        _posts.clear();
        _lastDocument = null;
        _allFetched = false;
      });
      _getPostData();
      GoRouter.of(context).removeListener(_refreshPostsOnPop);
    }
  }
}

class PostWidget extends StatefulWidget {
  final PostModel post;

  const PostWidget({Key? key, required this.post}) : super(key: key);

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  final CollectionReference postsCollection =
      FirebaseFirestore.instance.collection(Collections.posts.toPath);
  UserModel? poster;
  int index = 0;

  @override
  void initState() {
    super.initState();
    initUser();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle nameStyle = TextStyle(fontSize: 3.w, color: Colors.black),
        roleStyle = TextStyle(fontSize: 2.w, color: ColorUtil.blue);
    return Card(
        color: ColorUtil.snowWhite,
        shadowColor: Colors.black,
        elevation: 2,
        margin: EdgeInsets.all(1.w),
        child: Padding(
          padding: EdgeInsets.all(1.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                CircleAvatar(
                  radius: 5.w,
                  backgroundColor: ColorUtil.red,
                  backgroundImage: poster != null ? poster!.avatar.image : null,
                ),
                SizedBox(width: 2.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    poster != null
                        ? Text(poster!.fullName, style: nameStyle)
                        : Text('Loading...', style: nameStyle),
                    poster != null
                        ? Text(poster!.role.toName.capitalize(),
                            style: roleStyle)
                        : Text('Loading...', style: roleStyle)
                  ],
                ),
                const Expanded(child: SizedBox.square()),
                if (AuthService().isAdmin())
                  IconButton(
                      onPressed: () => print('yest'),
                      iconSize: 4.w,
                      icon: const Icon(Icons.more_horiz_outlined))
              ]),
              SizedBox(height: 1.w),
              GFCarousel(
                  viewportFraction: 1.0,
                  enableInfiniteScroll: false,
                  hasPagination: false,
                  onPageChanged: (i) => setState(() => index = i),
                  height: 50.h,
                  items: widget.post.images
                      .map((url) => Image.network(url, fit: BoxFit.fill))
                      .toList()),
              SizedBox(height: 1.w),
              Row(
                children: [
                  LikeButton(
                      mainAxisAlignment: MainAxisAlignment.start,
                      size: 5.w,
                      likeCount: widget.post.likes.length,
                      onTap: (e) async {
                        e
                            ? widget.post.likes.remove(poster!.id)
                            : widget.post.likes.add(poster!.id);
                        postsCollection.doc(widget.post.id).update(
                            <String, List<String>>{'likes': widget.post.likes});
                        return !e;
                      },
                      isLiked: poster == null
                          ? false
                          : widget.post.likes.contains(poster!.id)),
                  const Expanded(child: SizedBox.square()),
                  widget.post.images.length > 1
                      ? DotsIndicator(
                          dotsCount: widget.post.images.length,
                          position: index.toDouble(),
                          decorator: DotsDecorator(
                              color: ColorUtil.darkGray,
                              activeColor: ColorUtil.red,
                              size: Size(1.5.w, 1.5.w),
                              activeSize: Size(1.5.w, 1.5.w)))
                      : Container(),
                  const Expanded(child: SizedBox.square()),
                  Text(DateFormat.yMMMMd().format(widget.post.date),
                      style:
                          TextStyle(color: ColorUtil.darkGray, fontSize: 2.w))
                ],
              ),
              SizedBox(height: 1.w),
              Text(widget.post.title,
                  style:
                      TextStyle(fontSize: 2.5.w, fontWeight: FontWeight.w600)),
              ReadMoreText(
                widget.post.description,
                style: TextStyle(fontSize: 2.w),
                trimLines: 2,
                trimMode: TrimMode.Line,
                trimCollapsedText: ' more',
                trimExpandedText: ' hide',
              )
            ],
          ),
        ));
  }

  Future<void> initUser() async {
    UserModel userModel = await UserService().getUserFromID(widget.post.poster);
    if (!mounted) return;
    setState(() => poster = userModel);
  }
}
