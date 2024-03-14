import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ev_simulator/components/my_buttom.dart';
import 'package:ev_simulator/model/news_model.dart';
import 'package:ev_simulator/pages/article_page.dart';
import 'package:ev_simulator/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

class NewsDetailPage extends StatefulWidget {
  final NewsModel news;
  NewsDetailPage({super.key, required this.news});

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  final channelName = {
    "nbc":
        "https://yt3.googleusercontent.com/Iyl3USdPKmYU1klQW1El44iCAsRZtfHobgBkIhdwm8sjgZXIfsVttGob8_cTXhU1rSWIMUEDaw=s900-c-k-c0x00ffffff-no-rj",
    "cnn":
        "https://play-lh.googleusercontent.com/375NW5yL8owK_hW9igW9sh-YJbda9ZcygpDXuVvK_R7l-yJp-fuhb4qvUw_FE4XW4ms"
  };

  final user = FirebaseAuth.instance.currentUser!;
  bool isFav = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    checkUserConnection();

    FirebaseFirestore.instance
        .collection('Triveous')
        .doc(user.uid)
        .collection("favorites")
        .where("title", isEqualTo: widget.news.title)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        setState(() {
          isFav = true;
        });
      } else {
        setState(() {
          isFav = false;
        });
      }
    });
  }

  Future<void> addToFav(NewsModel news, context) async {
    FirebaseFirestore.instance
        .collection('Triveous')
        .doc(user.uid)
        .collection("favorites")
        .add({
      "title": news.title,
      "description": news.description,
      "url": news.url,
      "urlToImage": news.urlToImage,
      "publishedAt": news.publishedAt,
      "author": news.author,
      "source": news.source!.name,
    }).then((value) {
      setState(() {
        isFav = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Added to favorites"),
      ));
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: $e"),
      ));
    });
  }

  bool ActiveConnection = false;
  String T = "";
  Future checkUserConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          ActiveConnection = true;
          T = "Turn off the data and repress again";
        });
      }
    } on SocketException catch (_) {
      setState(() {
        ActiveConnection = false;
        T = "Turn On the data and repress again";
      });
    }
  }

  DateTime loginClickTime =
      DateTime.now().subtract(const Duration(seconds: 10));

  bool isRedundentClick(DateTime currentTime) {
    if (loginClickTime == null) {
      loginClickTime = currentTime;
      print("first click");
      return false;
    }
    print('diff is ${currentTime.difference(loginClickTime).inSeconds}');
    if (currentTime.difference(loginClickTime).inSeconds < 10) {
      // set this difference time in seconds
      return true;
    }

    loginClickTime = currentTime;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    List images = channelName.keys
        .where((e) =>
            widget.news.source!.name.toString().toLowerCase().contains(e))
        .toList();

    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: size.height * 0.55,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: CachedNetworkImageProvider(
                        widget.news.urlToImage!,
                      ),
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.5), BlendMode.darken),
                      fit: BoxFit.cover)),
              child: Padding(
                padding: const EdgeInsets.only(left: 18, right: 18, top: 45),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: AppbarCircleWrapper(
                                icon: const FaIcon(
                              FontAwesomeIcons.xmark,
                              size: 18,
                              color: Colors.black,
                            )),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () async {
                              if (isRedundentClick(DateTime.now())) {
                                return;
                              }
                              if (ActiveConnection == false) {
                                AlertDialog alert = AlertDialog(
                                  title: const Text("No Internet Connection"),
                                  content: Text(T),
                                  actions: [
                                    TextButton(
                                      child: const Text("OK"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return alert;
                                  },
                                );
                                return;
                              }
                              FirebaseFirestore.instance
                                  .collection('Triveous')
                                  .doc(user.uid)
                                  .collection("favorites")
                                  .where("title", isEqualTo: widget.news.title)
                                  .get()
                                  .then((value) {
                                if (value.docs.isNotEmpty || isFav == true) {
                                  //dialog
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                            title:
                                                const Text("Remove from fav?"),
                                            content: const Text(
                                                "Are you sure you want to remove this article from favorites?"),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text("Cancel")),
                                              TextButton(
                                                  onPressed: () {
                                                    FirebaseFirestore.instance
                                                        .collection('Triveous')
                                                        .doc(user.uid)
                                                        .collection("favorites")
                                                        .where("title",
                                                            isEqualTo: widget
                                                                .news.title)
                                                        .get()
                                                        .then((value) {
                                                      value.docs.first.reference
                                                          .delete()
                                                          .then((value) {
                                                        setState(() {
                                                          isFav = false;
                                                        });
                                                        Navigator.pop(context);
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                const SnackBar(
                                                          content: Text(
                                                              "Removed from favorites"),
                                                        ));
                                                      });
                                                    });
                                                  },
                                                  child: const Text("Remove"))
                                            ],
                                          ));
                                } else {
                                  addToFav(widget.news, context);
                                }
                              });
                            },
                            child: AppbarCircleWrapper(
                                icon: FaIcon(
                              isFav
                                  ? FontAwesomeIcons.solidBookmark
                                  : FontAwesomeIcons.bookmark,
                              size: 18,
                              color: isFav ? Colors.red : Colors.black,
                            )),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        widget.news.title!.toString().split("-")[0],
                        style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Text("Trending",
                              style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white)),
                          const SizedBox(
                            width: 8,
                          ),
                          const FaIcon(
                            FontAwesomeIcons.solidCircle,
                            size: 4,
                            color: Colors.white,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                              widget.news.publishedAt.runtimeType == Timestamp
                                  ? ''
                                  : timeago.format(widget.news.publishedAt!),
                              style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white)),
                        ],
                      ),
                      const SizedBox(
                        height: 65,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            child: Expanded(
              child: DraggableScrollableSheet(
                  snap: true,
                  initialChildSize: 0.5,
                  minChildSize: 0.5,
                  maxChildSize: 0.7,
                  builder: (context, scrollController) => Container(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20))),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundImage: CachedNetworkImageProvider(
                                      images.isNotEmpty
                                          ? channelName[images[0]].toString()
                                          : "https://static.vidgyor.com/live/cnn_news18.png"),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(widget.news.source!.name!,
                                    style: GoogleFonts.montserrat(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black)),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: FaIcon(
                                        FontAwesomeIcons.certificate,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.verified,
                                        size: 22,
                                        color: Color(0xff0B85B5),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),

                            // description
                            Text(widget.news.description.toString()),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ArtilcePage(
                                            url: widget.news.url.toString())));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(22),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Visit Full Article",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ))),
            ),
          )
        ],
      ),
    );
  }
}
