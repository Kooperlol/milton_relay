import 'dart:io';
import 'dart:math';

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
import 'package:openai_client/openai_client.dart';
import 'package:pexels_null_safety/pexels_null_safety.dart';
import 'package:readmore/readmore.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:openai_client/src/model/openai_chat/chat_message.dart';
import 'package:openai_client/src/model/openai_chat/chat.dart';
import 'package:uuid/uuid.dart';

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

void _createPosts() async {
  const conf = OpenAIConfiguration(
      apiKey: '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');
  final client = OpenAIClient(configuration: conf, enableLogging: true);
  var pclient =
      PexelsClient('5lTuhMroFd5rLgxbJXsYVTc9IKCStqOAymX3JLjD3YnAaVr3rUXxxUtS');

  while (true) {
    Chat chat =
        await client.chat.create(model: 'gpt-3.5-turbo', messages: const [
      ChatMessage(
          role: 'user',
          content:
              "Do you know about Milton School District in Wisconsin? They are home of the Red Hawks and their rival is the Janesville Vikings. Our colors are red, white, and black. The school spirit is good and our website shows all of the classes, etc we offer. MHS was ranked as #1 in rock county. Currently, the district is trying to pass a referendum for the spring of 2023."),
      ChatMessage(
          role: 'user',
          content:
              "Currently, I'm creating a social media network for the school where students and teachers can create posts. DO NOT INCLUDE ANYTHING THAT HAS TO DO WITH THE FIRST DAY OF SCHOOL. BE UNIQUE. Teachers may use this to post events, upcoming deadlines, fieldtrips, etc. Students may post this to meet others, organize clubs, and show school spirit and excitement for upcoming events. Can you come up with a sample post from a teacher or student? The post should have a title and description. There can be up to 5 images. Describe some images to go with the post. Student posts can share experiences at the school and do not need to be overly professional. Avoid using hashtags. The school year is 2022-2023. Also indicate if a student or teacher posted it. Output with the following format by replacing the opening and closing brackets with the content and keeping the | that separates each. It is very important the format is followed; do not use any colons to specify which content is what, just replace it in the corresponding spot. The desired output format starts on the next line.\n[replace with title here with maximum length of 75 characters]|[replace with description here with a maximum of 400 characters]|[replace with a list of simple image descriptions here separated by commas; make these descriptions detailed as they are being searched on google; use the keyword of school; PHOTOS MUST BE GENERIC]|[replace with whether a student or teacher made this post]|[date of the event from 2022 to 2023 school year in format of m/d/yyyy like 1/2/2022 or 6/14/2023]")
    ]).data;

    List<String> content = chat.choices[0].message.content.split('|');
    if (content.length < 5) {
      print('Skipped one due to error!');
      continue;
    }
    String title = content[0].trim();
    String description = content[1].trim();
    List<String> images = content[2].split(',');
    String role = content[3].trim();
    List<String> dateText = content[4].trim().split('/');
    if (dateText.length != 3) {
      print('Skipped one due to error!');
      continue;
    }
    DateTime date = DateTime(
        int.parse(dateText[2]), int.parse(dateText[0]), int.parse(dateText[1]));

    List<String> imageURLS = [];
    for (String img in images) {
      try {
        var result = await pclient.searchPhotos(img);
        imageURLS.add(result!.items[0]!.sources['medium']!.link!);
      } catch (e) {
        print('Skipping image due to errors...');
        continue;
      }
    }
    if (imageURLS.isEmpty) {
      print('Image URLS empty so skipping...');
      continue;
    }

    print(
        "-----------\nTitle: $title\nDescription: $description\nImages: $images\nRole: $role\n");
    print("Image URLS: $imageURLS\n---------------");

    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection(Collections.users.toPath);
    String poster;
    if (role == "Student") {
      QuerySnapshot snapshot =
          await usersCollection.where('role', isEqualTo: "student").get();
      QueryDocumentSnapshot doc =
          snapshot.docs[Random().nextInt(snapshot.docs.length)];
      poster = doc.id;
    } else {
      QuerySnapshot snapshot =
          await usersCollection.where('role', isEqualTo: "instructor").get();
      QueryDocumentSnapshot doc =
          snapshot.docs[Random().nextInt(snapshot.docs.length)];
      poster = doc.id;
    }

    List<String> likesRaw =
        (await usersCollection.where('role', isNotEqualTo: 'parent').get())
            .docs
            .map((e) => e.id)
            .toList();
    likesRaw.shuffle();
    List<String> likes =
        likesRaw.take(Random().nextInt(likesRaw.length)).toList();

    var uuid = const Uuid();
    var id = uuid.v1();
    try {
      CollectionReference postsCollection =
          FirebaseFirestore.instance.collection(Collections.posts.toPath);
      PostModel postModel =
          PostModel(id, poster, date, imageURLS, title, description, likes);
      await postsCollection.doc(id).set(PostService().postToJson(postModel));
    } catch (error) {
      stderr.writeln(
          "An error has occurred while attempting to create a post: ${error.toString()}");
    }
  }
}
