import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ev_simulator/model/news_model.dart';
import 'package:ev_simulator/pages/details_page.dart';
import 'package:ev_simulator/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ev_simulator/model/news_model.dart' as src;

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  List<QueryDocumentSnapshot<Map<String, dynamic>>> favourites = [];
  final user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    FirebaseFirestore.instance
        .collection('Triveous')
        .doc(user.uid)
        .collection('favorites')
        .get()
        .then((value) {
      setState(() {
        favourites = value.docs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xffFEFEFE),
      body: Column(
        children: [
          const CustomAppBar2(),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Triveous')
                  .doc(user.uid)
                  .collection('favorites')
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Something went wrong'),
                  );
                }
                final List<DocumentSnapshot> documents = snapshot.data.docs;
                return ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 20),
                    children: documents
                        .map(
                          (doc) => Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.only(
                                    top: 2, bottom: 2, right: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [],
                                  border: Border.all(
                                      color: const Color(0xffF6F6F7),
                                      width: 1.5),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 110,
                                        width: 110,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: Colors.grey,
                                          image: DecorationImage(
                                              image: CachedNetworkImageProvider(
                                                  doc["urlToImage"]),
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Flexible(
                                        child: SizedBox(
                                          width: size.width - 150,
                                          height: 100,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                doc["title"],
                                                style: GoogleFonts.inter(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: true,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(doc["source"],
                                                      style: GoogleFonts
                                                          .montserrat(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color: Colors
                                                                  .black)),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  const Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: FaIcon(
                                                          FontAwesomeIcons
                                                              .certificate,
                                                          size: 10,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Icon(
                                                          Icons.verified,
                                                          size: 15,
                                                          color:
                                                              Color(0xff0B85B5),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const Spacer(),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  const FaIcon(
                                                    FontAwesomeIcons.userPen,
                                                    color: Colors.black,
                                                    size: 11,
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  SizedBox(
                                                    width: size.width * 0.3,
                                                    child: Text(
                                                      doc["author"] ??
                                                          "Unknown",
                                                      style: GoogleFonts
                                                          .montserrat(
                                                              fontSize: 13,
                                                              letterSpacing:
                                                                  0.1,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color:
                                                                  Colors.black),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  NewsDetailPage(
                                                                      news:
                                                                          NewsModel(
                                                                    publishedAt:
                                                                        DateTime.fromMicrosecondsSinceEpoch(
                                                                            doc["publishedAt"].microsecondsSinceEpoch),
                                                                    title: doc[
                                                                        "title"],
                                                                    description:
                                                                        doc["description"],
                                                                    url: doc[
                                                                        "url"],
                                                                    urlToImage:
                                                                        doc["urlToImage"],
                                                                    source: src
                                                                        .Source(
                                                                      name: doc[
                                                                          "source"],
                                                                    ),
                                                                  ))));
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xffF6F6F7),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: const Center(
                                                        child: Text(
                                                          "Read More",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                  top: -10,
                                  right: -10,
                                  child: InkWell(
                                    onTap: () {
                                      FirebaseFirestore.instance
                                          .collection('Triveous')
                                          .doc(user.uid)
                                          .collection('favorites')
                                          .doc(doc.id)
                                          .delete();
                                    },
                                    child: SizedBox(
                                        height: 38,
                                        width: 38,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(500),
                                              color: const Color(0xffF6F6F7)),
                                          child: const Center(
                                              child: FaIcon(
                                            FontAwesomeIcons.trashAlt,
                                            color: Colors.red,
                                            size: 14,
                                          )),
                                        )),
                                  )),
                            ],
                          ),
                        )
                        .toList());
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CustomAppBar2 extends StatelessWidget {
  const CustomAppBar2({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18, top: 45),
      child: Row(
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
          Text(
            "Favourites",
            style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          const Spacer(),
          const SizedBox(
            width: 12,
          ),
          InkWell(
            onTap: () {
              // logOutUser();
              FirebaseAuth.instance.signOut();
            },
            child: AppbarCircleWrapper(
                icon: const FaIcon(
              FontAwesomeIcons.powerOff,
              size: 18,
              color: Colors.black,
            )),
          ),
        ],
      ),
    );
  }
}
