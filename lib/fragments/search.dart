import 'dart:async';
import 'dart:convert';

import 'package:Anime4U/fragments/loading.dart';
import 'package:Anime4U/integration/Api.dart';
import 'package:Anime4U/resources/colors.dart';
import 'package:Anime4U/resources/images.dart';
import 'package:Anime4U/resources/size.dart';
import 'package:Anime4U/resources/strings.dart';
import 'package:Anime4U/utils/app_localizations.dart';
import 'package:Anime4U/utils/app_widgets.dart';
import 'package:Anime4U/utils/constants.dart';
import 'package:facebook_audience_network/ad/ad_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_applovin_max/banner.dart';
import 'package:flutter_applovin_max/flutter_applovin_max.dart';
import 'package:http/http.dart' as http;
// import 'package:native_admob_flutter/native_admob_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Search extends StatefulWidget{

  @override
  State<Search> createState() => SearchState();

}

class SearchState extends State<Search> {

  StreamController _streamController = StreamController.broadcast();
  TextEditingController _textcontroller = TextEditingController();
  bool bannerControllerSearch=false;

  // final bannerController = BannerAdController();

  Future fetchSearch(String data) async {
    final response = await http.get(Uri.parse(ApiUrl.Search + data));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print(response.body);
      _streamController.add(data['search']);
    } else {
      throw Exception('Failed to Search');
    }
  }

  // void loadAd() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   if (prefs.containsKey('ad_status')) {
  //     if (prefs.getInt('ad_status') != 1) {
  //       bannerController.onEvent.listen((e) {
  //         final event = e.keys.first;
  //         // final info = e.values.first;
  //         switch (event) {
  //           case BannerAdEvent.loaded:
  //             bannerControllerSearch = true;
  //             break;
  //           default:
  //             break;
  //         }
  //       });
  //       bannerController.load();
  //     }
  //   }
  // }

  @override
  void initState() {
    // TODO: implement initState
    // loadAd();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: muvi_appBackground,
      appBar: AppBar(
        title: toolBarTitle(context, keyString(context, "search")!),
        backgroundColor: muvi_appBackground,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size(double.infinity, 45),
          child: Container(
            height: 50,
            color: search_edittext_color,
            padding: EdgeInsets.only(
                left: spacing_standard_new, right: spacing_standard),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _textcontroller,
                    textInputAction: TextInputAction.search,
                    style: TextStyle(
                        fontFamily: font_regular,
                        fontSize: ts_normal,
                        color: muvi_textColorPrimary),
                    decoration: InputDecoration(
                      hintText: keyString(context, "search_caption"),
                      hintStyle: TextStyle(
                          fontFamily: font_regular,
                          color: muvi_textColorSecondary),
                      border: InputBorder.none,
                      filled: false,
                    ),
                    onChanged: (value) async {
//                      searchItems();
                      Timer(const Duration(milliseconds: 500), () {
                        fetchSearch(value);
                      });
                    },
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _textcontroller.clear();
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.cancel,
                      color: muvi_colorPrimary,
                      size: 20,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
//                  searchItems();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      ic_search,
                      color: muvi_colorAccent,
                      width: 20,
                      height: 20,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(
            top: 30,
            bottom: 10,
            left: 15,
            right: 15),
        color: muvi_appBackground,
        child: Stack(
          children: <Widget>[
            StreamBuilder(
                stream: _streamController.stream,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.data == null) {
                    return Container(
                      alignment: Alignment
                          .topCenter,
                      child: Text(
                        "Type Anime Name",
                        style: TextStyle(
                            color:
                            muvi_textColorPrimary,
                            fontSize: 20),
                      ),
                    );
                  }
                  else if (snapshot.hasData) {
                    if(_streamController.stream.length == 0){
                      return Column(
                          mainAxisAlignment: MainAxisAlignment
                              .center,
                          children: [
                            Center(
                              child: CircularProgressIndicator(),
                            ),
                            Container(
                                padding: EdgeInsets
                                    .only(
                                    top: 20),
                                child: Text(
                                    "Searching...",
                                    style: TextStyle(
                                        color: Colors
                                            .white,
                                        fontSize: 20))
                            )
                          ]);
                    }
                    return Container(
                        margin: EdgeInsets.only(
                            bottom: 80),
                        child: GridView.builder(
                            itemCount:
                            snapshot.data
                                .length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                crossAxisCount: (MediaQuery
                                    .of(
                                    context)
                                    .orientation ==
                                    Orientation
                                        .portrait)
                                    ? 2
                                    : 3),
                            itemBuilder:
                                (
                                BuildContext context,
                                int index) {
                              return new GestureDetector(
                                  onTap: () {
                                    Navigator
                                        .pop(
                                        context);
                                    Navigator
                                        .push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (
                                                context) =>
                                                Loading(
                                                    snapshot
                                                        .data[index]['title'],
                                                    snapshot
                                                        .data[index]['link'],
                                                    snapshot
                                                        .data[index]['episodes'],
                                                    snapshot
                                                        .data[index]['totalEpisodes'],
                                                    0,
                                                    context)));
                                  },
                                  child: Card(
                                      semanticContainer:
                                      true,
                                      clipBehavior: Clip
                                          .antiAliasWithSaveLayer,
                                      elevation: 10,
                                      margin:
                                      EdgeInsets
                                          .all(
                                          0),
                                      shape:
                                      RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            spacing_control),
                                      ),
                                      child: Container(
                                          decoration:
                                          BoxDecoration(
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    snapshot
                                                        .data[index]
                                                    [
                                                    'img']),
                                                fit: BoxFit
                                                    .cover),
                                          ),
                                          child: Stack(
                                            alignment: Alignment
                                                .bottomCenter,
                                            children: [
                                              Container(
                                                width: width,
                                                alignment: Alignment.bottomCenter,
                                                // color: muvi_colorAccent.withOpacity(0.8),
                                                child: Container(
                                                  width: width,
                                                  padding: EdgeInsets.only(top: 5,bottom: 5),
                                                  color: muvi_colorAccent.withOpacity(0.8),
                                                  child: Text(
                                                  snapshot.data[index]['title'],
                                                  maxLines: 2,
                                                  textAlign: TextAlign.center,
                                                  // overflow:
                                                  // TextOverflow
                                                  //     .ellipsis,
                                                  style: TextStyle(
                                                      color: muvi_textColorPrimary),
                                                )),
                                              )
                                            ],
                                          ))));
                            }));
                  }
                  return Container(
                    alignment:
                    Alignment.topCenter,
                    child: Text(
                      "Type Anime Name",
                      style: TextStyle(
                          color:
                          muvi_textColorPrimary,
                          fontSize: 20),
                    ),
                  );
                }),
            Container(
                alignment: Alignment.bottomCenter,
                child:   Container(
                  alignment: Alignment(0.5, 1),
                  child: BannerMaxView((AppLovinAdListener? event) => print(event), BannerAdSize.banner, "88cb252b6932bb57")
                ),
            ),
          ],
        ),
      ),
    );
  }

}