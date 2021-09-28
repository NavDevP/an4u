import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Anime4U/integration/Api.dart';
// import 'package:Anime4U/screens/Update_screen.dart';
import 'package:Anime4U/screens/home_screen.dart';
// import 'package:Anime4U/screens/flix_signin.dart';
// import 'package:Anime4U/utils/flix_data_generator.dart';
import 'package:Anime4U/utils/widget_extensions.dart';
import 'package:Anime4U/resources/colors.dart';
import 'package:Anime4U/resources/images.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info/package_info.dart';

class SplashScreen extends StatefulWidget {
  static String tag = '/SplashScreen';

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin, TickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // AnimationController controller;
  // Animation heartbeatAnimation = Animation;
  double _size = 250.0;
  bool isLoading=false;
  String showText="Loading...";
//  bool _large = false;

//  startTime() async {
//    var _duration = Duration(seconds: 1);
//    return Timer(_duration, navigationPage);
//  }

  void navigationPage() async {}

  @override
  void initState() {
    super.initState();
    // getData();
    // clear();
    getSocialList();
//    checkUpdate();
//    checkLogin( );

   // controller = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
//    heartbeatAnimation =
//        Tween<double>(begin: 200.0, end: 350.0).animate(controller);
//    controller.forward().whenComplete(() {
//      controller.reverse();
//    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {
        isLoading = true;
      });
    });
    Future.delayed(const Duration(milliseconds: 3000), ()
    {
      setState(() {
        showText = "Checking For Updates...";
      });
      checkUpdate();
    });
  }

  Future<List<dynamic>> getSocialList() async {
    List<dynamic> list = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('social')) {
      list = jsonDecode(prefs.getString("social")!);
    }
    return list;
  }

  void checkDownload(int id) async{
    final response = await http.get(Uri.parse(ApiUrl.OurApi + "checkDownloadOption?id=$id"));

    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('userDownload',int.parse(response.body));
    }
  }

  Future checkUpdate() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String version = packageInfo.version;
    // prefs.clear();
    final response = await http.get(Uri.parse(ApiUrl.CheckUpdate));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['success']['status'] == 1) {
        if(data['success']['update'][0]['version'].toString().contains(version)) {
          // Navigator.of(context).pushReplacement(MaterialPageRoute(
          //     builder: (context) =>
          //         UpdateScreen(url: data['success']['update'][0]['link'],
          //             button: data['success']['update'][0]['button_text'])));
        }else{
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setInt('download',data['success']['download']);
          if(prefs.getString('_apiToken') != null) {
            // checkDownload(prefs.getInt('userId')!);
//        }
            setState(() {
              showText = "Verifying...";
            });
            checkuserData();
          }else{
            Navigator.of(context).pushReplacement(_createRoute());
            // Navigator.of(context).pushReplacement(
            //     MaterialPageRoute(builder: (context) => HomeScreen(download: 0,)));
          }
        }
      } else if (data['success']['status'] == 0) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt('download',data['success']['download']);
        if(prefs.getString('_apiToken') != null) {
          // checkDownload(prefs.getInt('userId')!);
//        }
          setState(() {
            showText = "Verifying...";
          });
          checkuserData();
        }else{
          Navigator.of(context).pushReplacement(_createRoute());
          // Navigator.of(context).pushReplacement(
          //     MaterialPageRoute(builder: (context) => HomeScreen(download: 0,)));
        }
      }
    } else {
      checkUpdate();
      throw Exception('Failed to load album');
    }
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.easeIn;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Future checkuserData() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post(Uri.parse(ApiUrl.checkUserData),
        body: {'version': version},
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ${prefs.getString('_apiToken')}'
        });

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      prefs.setInt('ad_status', data['data']['ad']);
      if (data['data']['blocked'] == 1) {
        prefs.clear();
        // Navigator.of(context).pushReplacement(
        //     MaterialPageRoute(builder: (context) => SignInScreen()));
        return true;
      }else {
        checkLogin();
      }
    } else {
      throw Exception('Failed to Login');
    }
  }

  checkLogin() async {
//    await Future.delayed(Duration(seconds: 4));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    if (prefs.getString('name') != null) {
      // finish(context);
      Navigator.of(context).pushReplacement(_createRoute());
      // launchScreen(context, HomeScreen.tag);
    } else {
      // finish(context);
      Navigator.of(context).pushReplacement(_createRoute());
      // launchScreen(context, SignInScreen.tag);
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: muvi_appBackground,
        body: Stack(
            fit: StackFit.expand,
            children:<Widget>[
              Container(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        child: Image.asset(
                            "images/muvi/images/barimage.png",
                            width: _size,
                        ),
                      ),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            isLoading ? Container(
//                width: width / 1.5,
                              margin: EdgeInsets.only(bottom: 50),
                              child: CircularProgressIndicator(backgroundColor: muvi_white,valueColor: AlwaysStoppedAnimation<Color>(muvi_colorPrimaryDark),),
                            ): Container(),
                            isLoading ?
                            Text(showText, style: TextStyle(color: muvi_textColorPrimary, fontSize: 25)):Container()
                          ]),
                    ],
                  ),
                ),
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 30),
//      height: 30,
                    child: FutureBuilder(
                        future: getSocialList(),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                    child: Container(
                                        width: double.infinity / snapshot.data.length,
                                        height: 40,
                                        child: Center(
                                            child: ListView.builder(
                                                scrollDirection: Axis.horizontal,
                                                itemCount: snapshot.data.length,
                                                shrinkWrap: true,
                                                itemBuilder: (context, index) {
                                                  String valueString = snapshot
                                                      .data[index]['color']
                                                      .split('0x')[1]
                                                      .split(')')[0]; // kind of hacky..
                                                  int value =
                                                  int.parse(valueString, radix: 16);
                                                  IconData getIconForName(
                                                      String iconName) {
                                                    switch (iconName) {
                                                      case 'facebook':
                                                        {
                                                          return FontAwesomeIcons.facebookF;
                                                        }
                                                        break;

                                                      case 'twitter':
                                                        {
                                                          return FontAwesomeIcons.twitter;
                                                        }
                                                        break;
                                                      case 'youtube':
                                                        {
                                                          return FontAwesomeIcons.youtube;
                                                        }
                                                        break;
                                                      case 'linkedin':
                                                        {
                                                          return FontAwesomeIcons
                                                              .linkedinIn;
                                                        }
                                                        break;
                                                      case 'telegram':
                                                        {
                                                          return FontAwesomeIcons
                                                              .telegram;
                                                        }
                                                        break;
                                                      case 'instagram':
                                                        {
                                                          return FontAwesomeIcons
                                                              .instagram;
                                                        }
                                                        break;
                                                      default:
                                                        {
                                                          return FontAwesomeIcons.home;
                                                        }
                                                    }
                                                  }

                                                  return GestureDetector(
                                                      onTap: () async {
                                                        var url =
                                                        snapshot.data[index]['link'];
                                                        if (await canLaunch(url))
                                                          await launch(url);
                                                        else
                                                          // can't launch url, there is some error
                                                          throw "Could not launch $url";
                                                      },
                                                      child: Center(
                                                          child: Container(
                                                            width: width / 1.5 / snapshot.data.length,
                                                            height: 40,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.all(Radius.circular(10)),
//                                                        color: Color(value),
                                                              shape: BoxShape.rectangle,
                                                            ),
                                                            child: Center(
                                                              child: Icon(
                                                                getIconForName(snapshot
                                                                    .data[index]['icon']),
                                                                color: Colors.white,
                                                                size: 20,
                                                              ),
                                                            ),
                                                          )));
                                                })))),
                              ],
                            ).paddingAll(10);
                          }
                          return Container();
                        }),
                  )),
            ]
        ));
  }
}
