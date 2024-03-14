import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ev_simulator/components/my_buttom.dart';
import 'package:ev_simulator/controllers/dropdown_controller.dart';
import 'package:ev_simulator/model/news_model.dart';
import 'package:ev_simulator/pages/details_page.dart';
import 'package:ev_simulator/pages/favourite_page.dart';
import 'package:ev_simulator/services/api_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: const Color(0xffFEFEFE),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomAppBar(),
            const SizedBox(
              height: 20,
            ),
            const BreakingNewsText(),
            const SizedBox(
              height: 15,
            ),
            FutureBuilder<List<NewsModel>>(
              future: ApiServices().getNews(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<NewsModel>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 200,
                        ),
                        Text(
                          "An error occured ${snapshot.error}",
                          style: GoogleFonts.poppins(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 3),
                        viewportFraction: 0.9,
                        enlargeCenterPage: true,
                        enlargeStrategy: CenterPageEnlargeStrategy.height,
                        pauseAutoPlayOnTouch: true,
                        height: 200,
                        autoPlayAnimationDuration:
                            const Duration(milliseconds: 800),
                        pauseAutoPlayInFiniteScroll: true,
                      ),
                      items: snapshot.data!
                          .where((element) =>
                              element.urlToImage != null &&
                              element.title != null &&
                              element.source != null)
                          .toList()
                          .sublist(0, 5)
                          .map(
                        (i) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          NewsDetailPage(news: i)));
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                decoration: BoxDecoration(
                                    color: Colors.grey,
                                    image: DecorationImage(
                                        image: CachedNetworkImageProvider(
                                          i.urlToImage!,
                                        ),
                                        colorFilter: ColorFilter.mode(
                                            Colors.black.withOpacity(0.5),
                                            BlendMode.darken),
                                        fit: BoxFit.cover),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(24))),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 18, left: 18, right: 8, bottom: 18),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Chip(
                                          backgroundColor:
                                              const Color(0xff0B85B5),
                                          labelPadding: EdgeInsets.zero,
                                          elevation: 0,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                          side: BorderSide.none,
                                          visualDensity: VisualDensity.compact,
                                          label: Text(
                                              timeago.format(i.publishedAt!),
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.white))),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          Text(
                                              i.source!.name!
                                                          .toString()
                                                          .split(" ")
                                                          .length >
                                                      2
                                                  ? "${i.source!.name!.toString().split(" ")[0]} ${i.source!.name!.toString().split(" ")[1]}"
                                                  : i.source!.name!.toString(),
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.white)),
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
                                                  size: 10,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  Icons.verified,
                                                  size: 15,
                                                  color: Color(0xff0B85B5),
                                                ),
                                              )
                                            ],
                                          ),
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
                                          SizedBox(
                                            width: size.width * 0.3,
                                            child: Text(
                                              i.author == null
                                                  ? "Unknown"
                                                  : i.author!
                                                      .toString()
                                                      .split(",")[0],
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.white),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        i.title!.toString().split("-")[0],
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                )),
                          );
                        },
                      ).toList(),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const RecommendedText(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: SizedBox(
                          height: size.height - 412,
                          child:
                              context.watch<DropdownProvider>().dropdownvalue ==
                                      "Grid"
                                  ? GridView.count(
                                      padding: EdgeInsets.zero,
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      crossAxisCount: 2,
                                      children: snapshot.data!
                                          .where((element) =>
                                              element.urlToImage != null &&
                                              element.title != null &&
                                              element.source != null)
                                          .toList()
                                          .sublist(
                                              5,
                                              snapshot.data!
                                                      .where((element) =>
                                                          element.urlToImage !=
                                                              null &&
                                                          element.title !=
                                                              null &&
                                                          element.source !=
                                                              null)
                                                      .toList()
                                                      .length -
                                                  1)
                                          .map((e) => InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              NewsDetailPage(
                                                                  news: e)));
                                                },
                                                child: Container(
                                                  margin:
                                                      const EdgeInsets.all(5),
                                                  height: 100,
                                                  width: 100,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    color: Colors.grey,
                                                    image: DecorationImage(
                                                        image:
                                                            CachedNetworkImageProvider(
                                                          e.urlToImage!,
                                                        ),
                                                        colorFilter:
                                                            ColorFilter.mode(
                                                                Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.5),
                                                                BlendMode
                                                                    .darken),
                                                        fit: BoxFit.cover),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(
                                                      children: [
                                                        const Spacer(),
                                                        SizedBox(
                                                          child: Text(
                                                            e.title!
                                                                .toString()
                                                                .split("-")[0],
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontSize: 14,
                                                              letterSpacing:
                                                                  0.7,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            maxLines: 3,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ))
                                          .toList(),
                                    )
                                  : SingleChildScrollView(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 18),
                                        child: Column(
                                          children: snapshot.data!
                                              .where((element) =>
                                                  element.urlToImage != null &&
                                                  element.title != null &&
                                                  element.source != null)
                                              .toList()
                                              .sublist(
                                                  5,
                                                  snapshot.data!
                                                          .where((element) =>
                                                              element.urlToImage !=
                                                                  null &&
                                                              element.title !=
                                                                  null &&
                                                              element.source !=
                                                                  null)
                                                          .toList()
                                                          .length -
                                                      1)
                                              .map(
                                                (e) => Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 0),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            height: 110,
                                                            width: 110,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              color:
                                                                  Colors.grey,
                                                              image:
                                                                  DecorationImage(
                                                                      image:
                                                                          CachedNetworkImageProvider(
                                                                        e.urlToImage!,
                                                                      ),
                                                                      fit: BoxFit
                                                                          .cover),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 12,
                                                          ),
                                                          Flexible(
                                                            child: SizedBox(
                                                              width:
                                                                  size.width -
                                                                      150,
                                                              height: 100,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    e.title!
                                                                        .toString()
                                                                        .split(
                                                                            "-")[0],
                                                                    style: GoogleFonts.inter(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        color: Colors
                                                                            .black),
                                                                    maxLines: 2,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    softWrap:
                                                                        true,
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Text(e.source!.name!.toString().split(" ").length >= 2 ? e.source!.name!.toString().split(" ")[0] + e.source!.name!.toString().split(" ")[1] : e.source!.name!.toString().split(" ")[0],
                                                                          style: GoogleFonts.montserrat(
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.normal,
                                                                              color: Colors.black)),
                                                                      const SizedBox(
                                                                        width:
                                                                            5,
                                                                      ),
                                                                      const Stack(
                                                                        alignment:
                                                                            Alignment.center,
                                                                        children: [
                                                                          Align(
                                                                            alignment:
                                                                                Alignment.center,
                                                                            child:
                                                                                FaIcon(
                                                                              FontAwesomeIcons.certificate,
                                                                              size: 10,
                                                                              color: Colors.white,
                                                                            ),
                                                                          ),
                                                                          Align(
                                                                            alignment:
                                                                                Alignment.center,
                                                                            child:
                                                                                Icon(
                                                                              Icons.verified,
                                                                              size: 15,
                                                                              color: Color(0xff0B85B5),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const Spacer(),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      const FaIcon(
                                                                        FontAwesomeIcons
                                                                            .userPen,
                                                                        color: Colors
                                                                            .black,
                                                                        size:
                                                                            11,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            5,
                                                                      ),
                                                                      SizedBox(
                                                                        width: size.width *
                                                                            0.3,
                                                                        child:
                                                                            Text(
                                                                          e.author == null
                                                                              ? "Unknown"
                                                                              : e.author!.toString().split(",")[0],
                                                                          style: GoogleFonts.montserrat(
                                                                              fontSize: 13,
                                                                              letterSpacing: 0.1,
                                                                              fontWeight: FontWeight.normal,
                                                                              color: Colors.black),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                      const Spacer(),
                                                                      GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(builder: (context) => NewsDetailPage(news: e)));
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              horizontal: 10,
                                                                              vertical: 4),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                const Color(0xffF6F6F7),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8),
                                                                          ),
                                                                          child:
                                                                              const Center(
                                                                            child:
                                                                                Text(
                                                                              "Read More",
                                                                              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w700, fontSize: 12),
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
                                                    const Divider(),
                                                  ],
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    )),
                    ),
                  ],
                );
              },
            ),
          ],
        ));
  }
}

class BreakingNewsText extends StatelessWidget {
  const BreakingNewsText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18),
      child: Row(
        children: [
          Text(
            "Breaking News",
            style:
                GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class RecommendedText extends StatelessWidget {
  const RecommendedText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18),
      child: Row(
        children: [
          Text(
            "Recommended",
            style:
                GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          SizedBox(
            width: 55,
            child: DropdownButton(
              isExpanded: true,
              elevation: 1,
              underline: Container(),
              value: Provider.of<DropdownProvider>(context).dropdownvalue,
              icon: context.watch<DropdownProvider>().dropdownvalue == "Grid"
                  ? const Icon(
                      Icons.grid_view_outlined,
                      color: Color(0xff0B85B5),
                      size: 20,
                    )
                  : const Icon(
                      Icons.list,
                      color: Color(0xff0B85B5),
                      size: 20,
                    ),
              items:
                  context.watch<DropdownProvider>().items.map((String items) {
                return DropdownMenuItem(
                  value: items,
                  child: Text(
                    items,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0B85B5),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                context.read<DropdownProvider>().setSelectedValue(newValue!);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18, top: 45),
      child: Row(
        children: [
          const Spacer(),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FavouritesPage()));
            },
            child: AppbarCircleWrapper(
                icon: const FaIcon(
              FontAwesomeIcons.solidBookmark,
              size: 16,
              color: Colors.black,
            )),
          ),
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

class AppbarCircleWrapper extends StatelessWidget {
  AppbarCircleWrapper({super.key, required this.icon});
  FaIcon icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      width: 38,
      child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(500),
            color: const Color(0xffF6F6F7),
          ),
          child: Center(child: icon)),
    );
  }
}
