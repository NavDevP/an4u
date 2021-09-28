import 'dart:convert';

import 'package:Anime4U/integration/Api.dart';
import 'package:Anime4U/models/response.dart';
import 'package:Anime4U/resources/colors.dart';
import 'package:Anime4U/resources/size.dart';
import 'package:Anime4U/resources/strings.dart';
import 'package:Anime4U/utils/app_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:Anime4U/utils/widget_extensions.dart';
import 'package:loadmore/loadmore.dart';
import 'package:http/http.dart' as http;

import 'loading.dart';

class SeeMore extends StatefulWidget {
  SeeMore({required this.title, required this.index});

  final String title;
  final int index;

  @override
  State<SeeMore> createState() => SeeMoreState();
}

class SeeMoreState extends State<SeeMore> {
  ScrollController _scrollConroller =
      ScrollController(initialScrollOffset: 0.0);

  List<CurrPopular> currPop = [];

  bool isLoadingScrollData = false;
  int currIndex = 1;
  Future<List<CurrPopular>> _futurePopular = Future.value(<CurrPopular>[]);

  Future<List<CurrPopular>> getPopular(
      int index, int page, String genre) async {
    // print("Genre: $genre");
    var url;
    if (index == 1) {
      url = ApiUrl.Popular + page.toString();
    } else if (index == 2) {
      url = ApiUrl.Recent + page.toString();
    } else if (index == 3) {
      url = ApiUrl.Genre + genre + "/" + page.toString();
    } else if (index == 4) {
      url = ApiUrl.Movies + page.toString();
    }
    print(url);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var popular;
      if (index == 1) {
        popular = data['popular'];
      } else if (index == 3) {
        popular = data['anime'];
      } else if (index == 4) {
        popular = data['movies'];
      }
      for (var i = 0; i < popular.length; i++) {
        CurrPopular categroies = CurrPopular(
          popular[i]['title'],
          popular[i]['link'],
          popular[i]['img'],
          popular[i]['synopsis'],
          popular[i]['genres'],
          popular[i]['category'],
          popular[i]['episode'],
          popular[i]['totalEpisodes'],
          popular[i]['released'],
          popular[i]['status'],
          popular[i]['otherName'],
          popular[i]['servers'],
          popular[i]['episodes'],
        );
        // _loadMoreStream.add(currPop);
        setState(() {
          currPop.add(categroies);
        });
      }
      setState(() {
        isLoadingScrollData = false;
      });
      return currPop;
    } else {
      setState(() {
        isLoadingScrollData = false;
      });
      throw Exception('Failed to load Recent Release');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    isLoadingScrollData = true;
    getPopular(widget.index, 1, widget.title.toString().toLowerCase());
    super.initState();
    _scrollConroller..addListener(_scrollListener);
  }

  Future<bool> _loadMore() async {
    // print("onLoadMore");
    setState(() {
      isLoadingScrollData = true;
    });
    await Future.delayed(Duration(seconds: 0, milliseconds: 100));
    currIndex = currIndex + 1;
    getPopular(currIndex, widget.index, widget.title.toString().toLowerCase());
    return true;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    // TODO: implement build
    return Scaffold(
      backgroundColor: muvi_appBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: muvi_appBackground,
        centerTitle: false,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: flixTitle(context),
        actions: [
          Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(right: 10),
              child: Text(
                widget.title.toUpperCase(),
                style: TextStyle(fontSize: 17),
              )),
        ],
      ),
      body: Container(
        child: Stack(children: [
          currPop.length > 0
              ? LoadMore(
                  isFinish: currPop.length >= 120,
                  onLoadMore: _loadMore,
                  whenEmptyLoad: false,
                  textBuilder: DefaultLoadMoreTextBuilder.english,
                  child: GridView.builder(
                    controller: _scrollConroller,
                    itemCount: currPop.length,
                    padding: EdgeInsets.only(
                        left: 11, right: 21, top: spacing_standard_new),
                    physics: const AlwaysScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, childAspectRatio: 9 / 15),
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Loading(
                                      currPop[index].title,
                                      currPop[index].link,
                                      currPop[index].episodes,
                                      currPop[index].totalEpisodes,
                                      0,
                                      context)));
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Card(
                                semanticContainer: true,
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                elevation: spacing_control_half,
                                margin: EdgeInsets.all(0),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(spacing_control),
                                ),
                                child: CachedNetworkImage(
                                    placeholder: (context, url) => Image.asset(
                                        "images/muvi/images/alogo.png",
                                        fit: BoxFit.cover),
                                    imageUrl: currPop[index].img,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover),
                              ),
                            ),
                            Text(
                              currPop[index].title,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Monsterrat',
                                  fontSize: 15),
                              maxLines: 2,
                            )
                          ],
                        ),
                      ).paddingOnly(
                          left: 5, right: 5, bottom: spacing_standard_new);
                    },
                  ))
              : Container(child:Center(child:CircularProgressIndicator())),
          isLoadingScrollData
              ? Container(
                  alignment: Alignment.bottomCenter,
                  child:LinearProgressIndicator(minHeight: 6,color: muvi_colorPrimary,backgroundColor: muvi_appBackgroundLight,),
              )
              : Container(),
        ]),
      ),
      // Container(
      //     child: Column(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: <Widget>[
      //           Container(
      //               color: muvi_appBackground,
      //               padding: EdgeInsets.only(top: 10, bottom: 10),
      //               width: width,
      //               child: Center(
      //                   child: Text(
      //                     widget.title,
      //                     style: TextStyle(
      //                         fontSize: 20,
      //                         color: muvi_textColorPrimary,
      //                         fontWeight: FontWeight.bold),
      //                   ))),
      //           // Container(
      //           //   child: BannerAd(controller: bannerController,loading: Container(),unitId: adId1,),
      //           // ),
      //           FutureBuilder(
      //             future: _futurePopular,
      //             builder: (BuildContext context, AsyncSnapshot snapshot) {
      //               if (snapshot.hasData) {
      //                 return GridView.builder(
      //                   controller: _scrollConroller,
      //                   itemCount: snapshot.data.length,
      //                   shrinkWrap: true,
      //                   padding: EdgeInsets.only(
      //                       left: 11, right: 21, top: spacing_standard_new),
      //                   physics: BouncingScrollPhysics(),
      //                   gridDelegate:
      //                   SliverGridDelegateWithFixedCrossAxisCount(
      //                       crossAxisCount: 3, childAspectRatio: 9 / 15),
      //                   scrollDirection: Axis.vertical,
      //                   itemBuilder: (context, index) {
      //                     return InkWell(
      //                       onTap: () {
      //                         Navigator.push(
      //                             context,
      //                             MaterialPageRoute(
      //                                 builder: (context) => Loading(snapshot.data[index].title,snapshot.data[index].episodes,snapshot.data[index].totalEpisodes,context)));
      //                       },
      //                       child: Column(
      //                         crossAxisAlignment: CrossAxisAlignment.center,
      //                         children: <Widget>[
      //                           Expanded(
      //                             child: Card(
      //                               semanticContainer: true,
      //                               clipBehavior: Clip.antiAliasWithSaveLayer,
      //                               elevation: spacing_control_half,
      //                               margin: EdgeInsets.all(0),
      //                               shape: RoundedRectangleBorder(
      //                                 borderRadius: BorderRadius.circular(
      //                                     spacing_control),
      //                               ),
      //                               child: CachedNetworkImage(
      //                                   placeholder: (context, url) =>
      //                                       Image.asset(
      //                                           "images/muvi/images/alogo.png",
      //                                           fit: BoxFit.cover),
      //                                   imageUrl: snapshot.data[index].img,
      //                                   width: double.infinity,
      //                                   height: double.infinity,
      //                                   fit: BoxFit.cover),
      //                             ),
      //                           ),
      //                           Text(snapshot.data[index].title,style: TextStyle(color: Colors.white,fontFamily: 'Monsterrat',fontSize: 15),maxLines: 2,)
      //                         ],
      //                       ),
      //                     ).paddingOnly(
      //                         left: 5,
      //                         right: 5,
      //                         bottom: spacing_standard_new);
      //                   },
      //                 );
      //               }
      //               return Center(
      //                 child: CircularProgressIndicator(),
      //               );
      //             },
      //           ),
      //           isLoadingScrollData
      //               ? CircularProgressIndicator()
      //               : Container(),
      //         ]))));
    );
  }

  _scrollListener() {
    if (_scrollConroller.offset >= _scrollConroller.position.maxScrollExtent &&
        !_scrollConroller.position.outOfRange) {
      setState(() {
        print("comes to bottom $isLoadingScrollData");
        isLoadingScrollData = true;

        if (isLoadingScrollData) {
          print("RUNNING LOAD MORE");

          currIndex = currIndex + 1;

          getPopular(
              widget.index, currIndex, widget.title.toString().toLowerCase());
        }
      });
    }
  }
}
