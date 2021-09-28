import 'dart:convert';
import 'dart:io';

import 'package:Anime4U/integration/Api.dart';
import 'package:Anime4U/resources/colors.dart';
import 'package:Anime4U/resources/size.dart';
import 'package:Anime4U/screens/flix_signin.dart';
import 'package:Anime4U/screens/flix_signup.dart';
import 'package:Anime4U/screens/scrap_video_screen.dart';
import 'package:Anime4U/utils/app_widgets.dart';
import 'package:Anime4U/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:Anime4U/utils/widget_extensions.dart';

import '../loading.dart';

class Profile extends StatefulWidget {
  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  final double circleRadius = 100.0;
  final double circleBorderWidth = 8.0;
  Future? _futureFav, _futureWatch;
  String NAME = "";
  var netImage = null;
  bool networkimage = false;

  bool isUserLoggedIn = false;

  Future _refreshUserData() async {
    setState(() {
      _getProfile();
      _futureFav = getFavourite();
      _futureWatch = getWatchHistory();
      getWatch();
    });
  }

  void getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    if (prefs.containsKey('name')) {
      // print("NETIMAGE: ${prefs.getString('userImage')}");
      setState(() {
        NAME = prefs.getString('name')!;
        // EMAIL = prefs.getString('email')!;
        // netImage = prefs.getString('userImage')!;
        networkimage = true;
        // _getFav.addAll(jsonDecode(prefs.getString('userFav')!)['anime']['nodes']);
        // userStats.addAll(jsonDecode(prefs.getString("userStat")!));
      });
    }
  }

  Future getFavourite() async {
    var DataMain = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http
        .post(Uri.parse(ApiUrl.OurApi + "get_favHistory"), headers: {
      HttpHeaders.authorizationHeader: 'Bearer ${prefs.getString('_apiToken')}'
    });

    if (response.statusCode == 200) {
      var Data = [];
      var map = json.decode(response.body);
      for (var i = 0; i < map.length; i++) {
        Data.add({
          'anime_name': map[i]['anime_name'],
          'anime_image': map[i]['anime_image'],
          'anime_link': map[i]['anime_link'],
        });
      }
      return Data;
    }
  }

  Future _getProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('profileImage')) {
      Directory directory;
      directory = (await getExternalStorageDirectory())!;
      String path =
          directory.path + "/profile/${prefs.getString('profileImage')}";
      // print(path);
      setState(() {
        netImage = path;
      });
    }
  }

  Future getWatchHistory() async {
    var DataMain = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http
        .post(Uri.parse(ApiUrl.OurApi + "get_watchHistory"), headers: {
      HttpHeaders.authorizationHeader: 'Bearer ${prefs.getString('_apiToken')}'
    });

    if (response.statusCode == 200) {
      var Data = [];
      var map = json.decode(response.body);
      for (var i = 0; i < map.length; i++) {
        Data.add({
          'anime_name': map[i]['anime_name'],
          'anime_image': map[i]['anime_image'],
          'anime_episode': map[i]['anime_episode'],
          'anime_link': map[i]['anime_link'],
        });
      }
      return Data;
    }
  }

  Future userLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    if (prefs.getString('_apiToken') != null) {
      setState(() {
        isUserLoggedIn = true;
      });
    } else {
      setState(() {
        isUserLoggedIn = false;
      });
    }
  }

  Future getWatch() async {
    var DataMain = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http
        .post(Uri.parse(ApiUrl.OurApi + "get_userData"), headers: {
      HttpHeaders.authorizationHeader: 'Bearer ${prefs.getString('_apiToken')}'
    });

    if (response.statusCode == 200) {
      var map = json.decode(response.body);
      DataMain.add({'watch': map['watchCount'], 'favourite': map['favCount']});
      return DataMain;
    }
  }

  @override
  void initState() {
    getUser();
    _getProfile();
    userLogin();
    _futureFav = getFavourite();
    _futureWatch = getWatchHistory();
    getWatch();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    final Size cardSize = Size(width, width * (13 / 13.5));
    // TODO: implement build
    return Scaffold(
        backgroundColor: muvi_appBackground,
        body: Scaffold(
          backgroundColor: muvi_appBackground,
          body: isUserLoggedIn
              ? RefreshIndicator(
                  onRefresh: _refreshUserData,
                  child: Stack(children: <Widget>[
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Stack(
                            children: [
                              Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.only(top: 1, bottom: 15),
                                  decoration: BoxDecoration(
                                      // borderRadius: BorderRadius.circular(7),
                                      ),
//                                        image: DecorationImage(image: AssetImage("assets/images/original.gif",),fit: BoxFit.fill)),
                                  child: ShaderMask(
                                      shaderCallback: (rect) {
                                        return LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: <Color>[
                                            muvi_appBackground,
                                            muvi_appBackground.withOpacity(0.8),
                                            Colors.transparent,
                                            Colors.transparent,
                                          ],
                                        ).createShader(Rect.fromLTRB(0, 0,
                                            rect.width, rect.height * 0.75));
                                      },
                                      blendMode: BlendMode.dstOut,
                                      child: Stack(
                                        children: [
                                          Container(
                                              height: height,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: AssetImage(
                                                        "images/muvi/images/profileback.jpg"),
                                                    fit: BoxFit.cover),
                                              ),
                                              child: Container()),
                                          Container(
                                              height: height,
                                              decoration: BoxDecoration(
                                                gradient: new LinearGradient(
                                                    colors: [
                                                      muvi_colorPrimary
                                                          .withOpacity(0.3),
                                                      muvi_colorPrimaryDark
                                                          .withOpacity(0.2),
                                                    ],
                                                    begin:
                                                        const FractionalOffset(
                                                            0.0, 0.0),
                                                    end: const FractionalOffset(
                                                        1.0, 0.0),
                                                    stops: [0.0, 1.0],
                                                    tileMode: TileMode.decal),
                                              ))
                                        ],
                                      ))),
                              Container(
                                  width: width,
                                  margin: EdgeInsets.only(top: height / 5.5),
                                  child: Stack(
                                    alignment: Alignment.topCenter,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: circleRadius / 2.0),
                                        child: Container(
                                          width: width / 1.05,
                                          child: Column(children: [
                                            Container(
                                                margin:
                                                    EdgeInsets.only(top: 60),
                                                child: Center(
                                                    child: Text(
                                                  NAME.toUpperCase(),
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ))),
                                            FutureBuilder(
                                                future: getWatch(),
                                                builder: (BuildContext context,
                                                    AsyncSnapshot snapshot) {
                                                  if (snapshot.hasData) {
                                                    return Container(
                                                        margin: EdgeInsets.only(
                                                            top: height /
                                                                width *
                                                                15,
                                                            left: width / 5.5,
                                                            right: width / 5.5),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Column(children: [
                                                              Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          bottom:
                                                                              10),
                                                                  child: Text(
                                                                    "Watching",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            20,
                                                                        color: Colors
                                                                            .white),
                                                                  )),
                                                              Text(
                                                                  snapshot
                                                                      .data[0][
                                                                          'watch']
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      color: Colors
                                                                          .white)),
                                                            ]),
                                                            Column(children: [
                                                              Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          bottom:
                                                                              10),
                                                                  child: Text(
                                                                    "Favourites",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            20,
                                                                        color: Colors
                                                                            .white),
                                                                  )),
                                                              Text(
                                                                  snapshot
                                                                      .data[0][
                                                                          'favourite']
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      color: Colors
                                                                          .white)),
                                                            ]),
                                                          ],
                                                        ));
                                                  }
                                                  return Container(
                                                      margin: EdgeInsets.only(
                                                          top: height /
                                                              width *
                                                              15,
                                                          left: width / 5.5,
                                                          right: width / 5.5),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Column(children: [
                                                            Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        bottom:
                                                                            10),
                                                                child: Text(
                                                                  "Watching",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          20,
                                                                      color: Colors
                                                                          .white),
                                                                )),
                                                            Text("0",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    color: Colors
                                                                        .white)),
                                                          ]),
                                                          Column(children: [
                                                            Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        bottom:
                                                                            10),
                                                                child: Text(
                                                                  "Favourites",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          20,
                                                                      color: Colors
                                                                          .white),
                                                                )),
                                                            Text("0",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    color: Colors
                                                                        .white)),
                                                          ]),
                                                        ],
                                                      ));
                                                }),
                                          ]),
                                          color: Colors.black87,
                                          height: 200.0,
                                        ),
                                      ),
                                      GestureDetector(
                                          onTap: () async {
                                            SharedPreferences pref =
                                                await SharedPreferences
                                                    .getInstance();
                                            var profileImageFile =
                                                await ImagePicker
                                                    .platform
                                                    .pickImage(
                                                        source: ImageSource
                                                            .gallery);
                                            var file =
                                                File(profileImageFile!.path);
                                            Directory directory;
                                            directory =
                                                (await getExternalStorageDirectory())!;
                                            var path = Directory(
                                                directory.path + "/profile");
                                            if (!await path.exists()) {
                                              await path.create(
                                                  recursive: true);
                                            }
                                            DateTime now = new DateTime.now();
                                            var newFileName =
                                                "Profile-${now.second}.png";
                                            File newFile = await file.copy(
                                                directory.path +
                                                    "/profile/${newFileName}");
                                            pref.setString(
                                                'profileImage', newFileName);
                                            _getProfile();
                                          },
                                          child: Container(
                                            width: circleRadius,
                                            height: circleRadius,
                                            decoration: ShapeDecoration(
                                                shape: CircleBorder(),
                                                image:  netImage != null
                                                    ? DecorationImage(
                                                  fit: BoxFit.cover,
                                                    image: FileImage(
                                                        File(netImage))):
                                                DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: AssetImage("")),
                                                color: muvi_appBackgroundLight),
                                            child: Stack(children: [
                                              Container(
                                                alignment:
                                                    Alignment.bottomRight,
                                                color: Colors.transparent,
                                                padding: EdgeInsets.all(3),
                                                child: Icon(Icons.image,
                                                    color: Colors.white70),
                                              ),
                                              netImage == null
                                                  ? Container(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        "SELECT \n IMAGE",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ))
                                                  : Container(),
                                            ]),
                                          )),
                                    ],
                                  )),
                              Container(
                                  margin: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height /
                                          2),
                                  child: SingleChildScrollView(
                                      child: Stack(children: [
                                    Column(
                                      children: [
                                        FutureBuilder(
                                            future: _futureFav,
                                            builder: (BuildContext context,
                                                AsyncSnapshot snapshot) {
                                              switch (
                                                  snapshot.connectionState) {
                                                case ConnectionState.waiting:
                                                  return Container(
                                                    margin: EdgeInsets.only(
                                                        left: 30,
                                                        bottom: 20,
                                                        right: 30),
                                                    child:
                                                        LinearProgressIndicator(
                                                      valueColor:
                                                          new AlwaysStoppedAnimation<
                                                                  Color>(
                                                              muvi_colorPrimaryDark),
                                                      backgroundColor:
                                                          muvi_appBackground,
                                                    ),
                                                  );
                                                case ConnectionState.none:
                                                  return Container();
                                                default:
                                                  if (snapshot.hasData) {
                                                    return Column(children: [
                                                      Row(
                                                        children: <Widget>[
                                                          Expanded(
                                                              child: Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                Container(
                                                                  width: 20,
                                                                  height: 5,
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          top:
                                                                              7),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                          color:
                                                                              muvi_colorPrimary),
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                  "Favourites",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          22,
                                                                      fontFamily:
                                                                          font_bold,
                                                                      color: Colors
                                                                          .white),
                                                                )
                                                              ])),
                                                          // InkWell(onTap: (){}, child: itemSubTitle(context, keyString(context, "view_more"), fontsize: ts_medium, fontFamily: font_medium, colorThird: true).paddingAll(spacing_control_half))
                                                        ],
                                                      ).paddingAll(
                                                          spacing_standard_new),
                                                      Container(
                                                        height: (width * 0.38) *
                                                            8.8 /
                                                            6,
                                                        child: ListView.builder(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            itemCount: snapshot
                                                                .data.length,
                                                            // shrinkWrap: true,
                                                            physics:
                                                                ScrollPhysics(),
                                                            padding: EdgeInsets.only(
                                                                left:
                                                                    spacing_standard,
                                                                right:
                                                                    spacing_standard_new),
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              spacing_standard),
                                                                  width: width *
                                                                      0.28,
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: <
                                                                        Widget>[
                                                                      InkWell(
                                                                        child:
                                                                            AspectRatio(
                                                                          aspectRatio:
                                                                              6 / 8.8,
                                                                          child:
                                                                              Card(
                                                                            color:
                                                                                Colors.transparent,
                                                                            semanticContainer:
                                                                                true,
                                                                            clipBehavior:
                                                                                Clip.antiAliasWithSaveLayer,
                                                                            elevation:
                                                                                30,
                                                                            margin:
                                                                                EdgeInsets.all(0),
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(15),
                                                                            ),
                                                                            child:
                                                                                Stack(
                                                                              alignment: Alignment.bottomLeft,
                                                                              children: <Widget>[
                                                                                Card(
                                                                                  color: Colors.transparent,
                                                                                  semanticContainer: true,
                                                                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                                                                  elevation: 50,
                                                                                  margin: EdgeInsets.all(0),
                                                                                  shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(spacing_control),
                                                                                  ),
                                                                                  child: Image.network(
                                                                                    snapshot.data[index]['anime_image'],
                                                                                    height: double.infinity,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        onTap:
                                                                            () {
                                                                          Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(builder: (context) => Loading(snapshot.data[index]['anime_name'], snapshot.data[index]['anime_link'], null, null, 1, context)));
                                                                        },
                                                                        radius:
                                                                            spacing_control,
                                                                      ),
                                                                      Flexible(
                                                                        child:
                                                                            new Text(
                                                                          snapshot.data[index]
                                                                              [
                                                                              'anime_name'],
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontFamily: 'Monsterrat'),
                                                                          maxLines:
                                                                              2,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ));
                                                            }),
                                                      ),
                                                    ]);
                                                  }
                                                  return Container();
                                              }
                                            }),
                                        FutureBuilder(
                                            future: _futureWatch,
                                            builder: (BuildContext context,
                                                AsyncSnapshot snapshot) {
                                              switch (
                                                  snapshot.connectionState) {
                                                case ConnectionState.waiting:
                                                  return Container(
                                                    margin: EdgeInsets.only(
                                                        left: 30, right: 30),
                                                    child:
                                                        LinearProgressIndicator(
                                                      valueColor:
                                                          new AlwaysStoppedAnimation<
                                                                  Color>(
                                                              muvi_colorPrimaryDark),
                                                      backgroundColor:
                                                          muvi_appBackground,
                                                    ),
                                                  );
                                                case ConnectionState.none:
                                                  return Container();
                                                default:
                                                  if (snapshot.hasData) {
                                                    return Column(children: [
                                                      Row(
                                                        children: <Widget>[
                                                          Expanded(
                                                              child: Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                Container(
                                                                  width: 20,
                                                                  height: 5,
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          top:
                                                                              7),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                          color:
                                                                              muvi_colorPrimary),
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                  "Watch History",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          22,
                                                                      fontFamily:
                                                                          font_bold,
                                                                      color: Colors
                                                                          .white),
                                                                )
                                                              ])),
                                                          // InkWell(onTap: (){}, child: itemSubTitle(context, keyString(context, "view_more"), fontsize: ts_medium, fontFamily: font_medium, colorThird: true).paddingAll(spacing_control_half))
                                                        ],
                                                      ).paddingAll(
                                                          spacing_standard_new),
                                                      Container(
                                                        height: (width * 0.38) *
                                                            8.8 /
                                                            6,
                                                        child: ListView.builder(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            itemCount: snapshot
                                                                .data.length,
                                                            // shrinkWrap: true,
                                                            physics:
                                                                ScrollPhysics(),
                                                            padding: EdgeInsets.only(
                                                                left:
                                                                    spacing_standard,
                                                                right:
                                                                    spacing_standard_new),
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              spacing_standard),
                                                                  width: width *
                                                                      0.28,
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: <
                                                                        Widget>[
                                                                      InkWell(
                                                                        child: AspectRatio(
                                                                            aspectRatio: 6 / 8.8,
                                                                            child: Stack(
                                                                              children: [
                                                                                Card(
                                                                                  color: Colors.transparent,
                                                                                  semanticContainer: true,
                                                                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                                                                  elevation: 30,
                                                                                  margin: EdgeInsets.all(0),
                                                                                  shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(15),
                                                                                  ),
                                                                                  child: Stack(
                                                                                    alignment: Alignment.bottomLeft,
                                                                                    children: <Widget>[
                                                                                      Card(
                                                                                        color: Colors.transparent,
                                                                                        semanticContainer: true,
                                                                                        clipBehavior: Clip.antiAliasWithSaveLayer,
                                                                                        elevation: 50,
                                                                                        margin: EdgeInsets.all(0),
                                                                                        shape: RoundedRectangleBorder(
                                                                                          borderRadius: BorderRadius.circular(spacing_control),
                                                                                        ),
                                                                                        child: Image.network(
                                                                                          snapshot.data[index]['anime_image'],
                                                                                          height: double.infinity,
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                Container(
                                                                                  decoration: BoxDecoration(color: muvi_colorPrimary, shape: BoxShape.rectangle, borderRadius: BorderRadius.all(Radius.circular(spacing_control_half))),
                                                                                  padding: EdgeInsets.only(top: 0, bottom: 0, left: spacing_control, right: spacing_control),
                                                                                  child: text(context, "Ep: " + snapshot.data[index]['anime_episode'].toString(), textColor: Colors.white, fontSize: ts_medium, fontFamily: font_bold),
                                                                                ).paddingRight(spacing_standard).visible(true).paddingAll(spacing_standard),
                                                                              ],
                                                                            )),
                                                                        onTap:
                                                                            () {
                                                                          Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(builder: (context) => ScrapVideo(snapshot.data[index]['anime_name'], snapshot.data[index]['anime_link'], snapshot.data[index]['anime_episode'].toString(), snapshot.data[index]['anime_image'], 0, 0, [])));
                                                                        },
                                                                        radius:
                                                                            spacing_control,
                                                                      ),
                                                                      Flexible(
                                                                        child:
                                                                            new Text(
                                                                          snapshot.data[index]
                                                                              [
                                                                              'anime_name'],
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontFamily: 'Monsterrat'),
                                                                          maxLines:
                                                                              2,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ));
                                                            }),
                                                      )
                                                    ]);
                                                  }
                                                  return Container();
                                              }
                                            }),
                                      ],
                                    ),
                                  ]))),
                              Container(
                                  margin: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height /
                                          15),
                                  child: Center(
                                      child: Column(
                                    children: [
                                      Text(
                                        "Swipe Down to Refresh",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'MonsterratBold'),
                                      ),
                                      Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.white,
                                      )
                                    ],
                                  )))
                            ],
                          ),
                        ],
                      ),
                    )
                  ]))
              : Stack(children: <Widget>[
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Stack(
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.height / 1.06,
                                padding: EdgeInsets.only(top: 1),
                                decoration: BoxDecoration(
                                    // borderRadius: BorderRadius.circular(7),
                                    ),
                                child: Stack(
                                  children: [
                                    Container(
                                      alignment: Alignment.topLeft,
                                      child: Image.asset(
                                          'images/muvi/images/topabstract.png'),
                                    ),
                                    Container(
                                      alignment: Alignment.bottomRight,
                                      child: Image.asset(
                                          'images/muvi/images/bottomabstract.png'),
                                    ),
                                    Container(
                                        margin: EdgeInsets.only(
                                            top: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                3.6,
                                            left: 20),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Text(
                                          "Join a Community \nof Weebs",
                                          style: TextStyle(
                                              fontSize: 27,
                                              letterSpacing: 4,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontFamily: 'MonsterratBold'),
                                        )),
                                    Container(
                                        margin: EdgeInsets.only(
                                            top: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                2.5,
                                            left: 20),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Text(
                                          "A Simple and fun way to watch your Favourite Anime free and in Quality.\nLogin to Enjoy more Benefits",
                                          style: TextStyle(
                                              fontSize: 16,
                                              letterSpacing: 2,
                                              color: Colors.white70,
                                              fontFamily: 'Monsterrat'),
                                        )),
                                    Container(
                                        margin: EdgeInsets.only(
                                            top: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                1.69),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Column(
                                          children: [
                                            Material(
                                                //Wrap with Material
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0)),
                                                elevation: 18.0,
                                                color: Colors.transparent,
                                                clipBehavior: Clip.antiAlias,
                                                // Add This
                                                child: MaterialButton(
                                                  height: 50.0,
                                                  minWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          1.2,
                                                  color: Colors.grey
                                                      .withOpacity(0.7),
                                                  textColor: Colors.white,
                                                  child: new Text(
                                                    "Sign In",
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Monsterrat',
                                                        fontSize: 18),
                                                  ),
                                                  onPressed: () => {
                                                    Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                SignInScreen()))
                                                  },
                                                  splashColor: Colors.redAccent,
                                                )),
                                            SizedBox(
                                              height: 15,
                                            ),
                                            Material(
                                                //Wrap with Material
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0)),
                                                elevation: 18.0,
                                                clipBehavior: Clip.antiAlias,
                                                // Add This
                                                child: MaterialButton(
                                                  height: 50.0,
                                                  minWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          1.2,
                                                  color: muvi_colorPrimaryDark,
                                                  textColor: Colors.white,
                                                  child: new Text(
                                                    "Sign Up",
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Monsterrat',
                                                        fontSize: 18),
                                                  ),
                                                  onPressed: () => {
                                                    Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                SignUpScreen()))
                                                  },
                                                  splashColor: Colors.redAccent,
                                                )),
                                          ],
                                        ))
                                  ],
                                ))
                          ],
                        ),
                      ],
                    ),
                  )
                ]),
        ));
  }
}
