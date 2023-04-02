import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:getwidget/components/carousel/gf_carousel.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
import 'package:milton_relay/shared/models/post_model.dart';
import 'package:milton_relay/shared/models/roles.dart';
import 'package:milton_relay/shared/services/auth_service.dart';
import 'package:milton_relay/shared/services/post_service.dart';
import 'package:milton_relay/shared/services/user_service.dart';
import 'package:milton_relay/shared/utils/text_util.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:readmore/readmore.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:http/http.dart' as http;
import 'package:social_share/social_share.dart';
import 'package:uuid/uuid.dart';

import '../models/collections.dart';
import '../models/load_model.dart';
import '../models/user_model.dart';
import '../routing/routes.dart';
import '../utils/color_util.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({Key? key}) : super(key: key);

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> with LoadModel {
  @override
  void initState() {
    super.initState();
    // Load 3 posts.
    fetchData(3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarWidget(
            title: 'Community Posts',
            // Only show a create post button if the user is not an admin.
            icons: AuthService().isAdmin()
                ? []
                : [
                    IconButton(
                      tooltip: 'Create Post',
                      icon: const Icon(Icons.add_photo_alternate),
                      onPressed: () {
                        context.push(Routes.createPost.toPath);
                        GoRouter.of(context).addListener(_refreshPostsOnPop);
                      },
                    )
                  ]),
        // Gets the display from load model.
        // Loads 3 posts everytime the user scrolls to the bottom.
        body: getDisplay(3));
  }

  /// Listener to check for the create post screen being exited.
  ///
  /// Once exited, the current data is cleared, the [fetchData] function is called, and the listener is removed.
  void _refreshPostsOnPop() {
    if (!mounted) return;
    if (GoRouter.of(context).location.contains('/posts')) {
      setState(() {
        data.clear();
        lastDocument = null;
        isAllFetched = false;
      });
      fetchData(3);
      GoRouter.of(context).removeListener(_refreshPostsOnPop);
    }
  }

  /// Gets [loadSize] amount of posts and adds it to [data].
  ///
  /// Queries the Database for posts and then converts them to [PostWidget]s.
  @override
  Future<void> fetchData(int loadSize) async {
    if (isLoading || isAllFetched) return;
    setState(() => isLoading = true);

    Query query = FirebaseFirestore.instance
        .collection(Collections.posts.toPath)
        .orderBy('date', descending: true);
    query = lastDocument == null
        ? query.limit(loadSize)
        : query.startAfterDocument(lastDocument!).limit(loadSize);

    List<Widget> postCards = [];
    await query.get().then((value) {
      value.docs.isNotEmpty
          ? lastDocument = value.docs.last
          : lastDocument = null;
      for (var e in value.docs) {
        postCards.add(PostWidget(
            post: PostService()
                .getPostFromJson(e.id, e.data() as Map<String, dynamic>)));
      }
    });

    if (!mounted) return;
    setState(() {
      data.addAll(postCards);
      // All is fetched if length of query is less than the load size.
      isAllFetched = postCards.length < loadSize;
      isLoading = false;
    });
  }
}

/// Displays information about a post.
class PostWidget extends StatefulWidget {
  final PostModel post;

  const PostWidget({Key? key, required this.post}) : super(key: key);

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  // Posts collection in the database.
  final CollectionReference _postsCollection =
      FirebaseFirestore.instance.collection(Collections.posts.toPath);
  // User Model of poster.
  UserModel? _poster;
  // Index of image in carousal.
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Gets poster from the post details.
    _initUser();
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
                // Poster's Avatar.
                CircleAvatar(
                  radius: 5.w,
                  backgroundColor: ColorUtil.red,
                  backgroundImage:
                      _poster != null ? _poster!.avatar.image : null,
                ),
                SizedBox(width: 2.w),
                // Name and role of the poster.
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _poster != null
                        ? Text(_poster!.fullName, style: nameStyle)
                        : Text('Loading...', style: nameStyle),
                    _poster != null
                        ? Text(_poster!.role.toName.capitalize(),
                            style: roleStyle)
                        : Text('Loading...', style: roleStyle)
                  ],
                ),
                const Expanded(child: SizedBox.square()),
                // If the viewer is an Admin, create an icon to delete the post.
                if (AuthService().isAdmin())
                  IconButton(
                      onPressed: () async {
                        Reference storageRef = FirebaseStorage.instance
                            .ref()
                            .child('posts/${widget.post.id}');
                        await storageRef.delete();
                        await FirebaseFirestore.instance
                            .collection(Collections.posts.toPath)
                            .doc(widget.post.id)
                            .delete();
                      },
                      iconSize: 5.w,
                      icon: const Icon(Icons.delete))
              ]),
              SizedBox(height: 1.w),
              // Displays the images in a carousel.
              // Uses [_index] for the current image view.
              GFCarousel(
                  viewportFraction: 1.0,
                  enableInfiniteScroll: false,
                  hasPagination: false,
                  onPageChanged: (i) => setState(() => _index = i),
                  height: 50.h,
                  items: widget.post.images
                      .map((url) => Image.network(url, fit: BoxFit.fill))
                      .toList()),
              Stack(
                alignment: Alignment.center,
                children: [
                  // Displays a like button which updates the post data on toggle.
                  Row(
                    children: [
                      LikeButton(
                          size: 5.w,
                          likeCount: widget.post.likes.length,
                          onTap: (e) async {
                            e
                                ? widget.post.likes.remove(_poster!.id)
                                : widget.post.likes.add(_poster!.id);
                            _postsCollection
                                .doc(widget.post.id)
                                .update(<String, List<String>>{
                              'likes': widget.post.likes
                            });
                            return !e;
                          },
                          isLiked: _poster == null
                              ? false
                              : widget.post.likes.contains(_poster!.id)),
                      SizedBox(width: 1.w),
                      // Creates a button to share the currently viewed image to Instagram.
                      SizedBox(
                        width: 10.w,
                        height: 10.w,
                        child: IconButton(
                            onPressed: () async =>
                                await SocialShare.shareInstagramStory(
                                    imagePath: await _saveImageData(
                                        widget.post.images[_index]),
                                    appId: '1891518221201628'),
                            color: ColorUtil.red,
                            icon: SvgPicture.asset(
                              'assets/instagram-icon.svg',
                              colorFilter: ColorFilter.mode(
                                  ColorUtil.red, BlendMode.srcIn),
                            )),
                      ),
                      const Expanded(child: SizedBox.square()),
                      // Shows the date that the post was uploaded.
                      Text(DateFormat.yMMMMd().format(widget.post.date),
                          style: TextStyle(
                              color: ColorUtil.darkGray, fontSize: 2.5.w))
                    ],
                  ),
                  // Shows a dot indicator for the carousel only if there is more than one image.
                  widget.post.images.length > 1
                      ? Center(
                          child: DotsIndicator(
                              dotsCount: widget.post.images.length,
                              position: _index.toDouble(),
                              decorator: DotsDecorator(
                                  color: ColorUtil.darkGray,
                                  activeColor: ColorUtil.red,
                                  size: Size(1.5.w, 1.5.w),
                                  activeSize: Size(1.5.w, 1.5.w))),
                        )
                      : Container(),
                ],
              ),
              // Title of post.
              Text(widget.post.title,
                  style:
                      TextStyle(fontSize: 2.5.w, fontWeight: FontWeight.w600)),
              // Description of post with a read more button after two lines.
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

  /// Sets [_poster] to the User Model of the poster.
  ///
  /// Fetches the users collection for the ID using [UserService].
  Future<void> _initUser() async {
    UserModel userModel = await UserService().getUserFromID(widget.post.poster);
    if (!mounted) return;
    setState(() => _poster = userModel);
  }

  /// Saves a web image temporarily in cache and returns the file path.
  ///
  /// Used to share the image to social media sites like Instagram.
  Future<String> _saveImageData(String url) async {
    // Get image data from the URL.
    var response = await http.get(Uri.parse(url));
    // Get the temporary storage directory.
    Directory? documentDirectory = await getTemporaryDirectory();
    // Create a file with the directory and a unique ID for the name.
    File file = File(path.join(documentDirectory.path, const Uuid().v1()));
    // Write the data from the [response] to the file.
    file.writeAsBytes(response.bodyBytes);
    // Returns the file path.
    return file.path;
  }
}
