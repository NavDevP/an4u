import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:Anime4U/fragments/main/genre.dart';
import 'package:Anime4U/fragments/main/home.dart';
import 'package:Anime4U/fragments/main/profile.dart';
import 'package:Anime4U/fragments/search.dart';
import 'package:Anime4U/fragments/see_more.dart';
import 'package:Anime4U/integration/Api.dart';
import 'package:Anime4U/screens/settings_screen.dart';
import 'package:animations/animations.dart';
import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:facebook_audience_network/ad/ad_banner.dart';
import 'package:flutter/material.dart';
import 'package:Anime4U/resources/colors.dart';
import 'package:Anime4U/resources/size.dart';
import 'package:Anime4U/resources/strings.dart';
import 'package:flutter_applovin_max/banner.dart';
// import 'package:flutter_applovin_max/banner.dart';
import 'package:flutter_applovin_max/flutter_applovin_max.dart';
// import 'package:native_admob_flutter/native_admob_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  static String tag = '/HomeScreen';

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, TickerProviderStateMixin {
  var _selectedIndex = 0;
  bool isSeeMore = false, dailyData = false;
  bool isNetworkAvailable = true,banneradLoaded=false;
  final PageStorageBucket bucket = PageStorageBucket();

  // final bannerController = BannerAdController();
  ReceivePort _port = ReceivePort();
  int downloaded = 0;
  bool updateDownloaded=false;

  Future<void> checkNetwork() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
//        const oneSec = const Duration(seconds:1);
//        new Timer.periodic(oneSec, (Timer t) => checkNetwork());
        setState(() {
          isNetworkAvailable = true;
        });
      }
    } on SocketException catch (_) {
      const oneSec = const Duration(seconds: 1);
      new Timer.periodic(oneSec, (Timer t) => checkNetwork());
      setState(() {
        isNetworkAvailable = false;
      });
    }
  }

  // void loadAd() async{
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   if(prefs.containsKey('ad_status')){
  //     if(prefs.getInt('ad_status') != 1) {
  //       bannerController.onEvent.listen((e) {
  //         final event = e.keys.first;
  //         // final info = e.values.first;
  //         switch (event) {
  //           case BannerAdEvent.loaded:
  //             setState(() => banneradLoaded = true);
  //             break;
  //           default:
  //             break;
  //         }
  //       });
  //       bannerController.load();
  //     }
  //   }
  // }

  Future getSocial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.get(Uri.parse(ApiUrl.SocialUpdate));
    List<Social> socialList = [];
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (prefs.containsKey('social')) {
        if (data['update'] == "1") {
          for (var i in data['success']) {
            socialList.add(Social(
                name: i['name'],
                link: i['link'],
                icon: i['icon'],
                color: i['color']));
          }
          final String encodedData = Social.encode(socialList);
          prefs.setString('social', encodedData);
        } else if (data['delete'] == "1") {
          if (prefs.containsKey('social')) {
            prefs.remove('social');
            for (var i in data['success']) {
              socialList.add(Social(
                  name: i['name'],
                  link: i['link'],
                  icon: i['icon'],
                  color: i['color']));
            }
            final String encodedData = Social.encode(socialList);
            prefs.setString('social', encodedData);
          }
        }
      } else {
        for (var i in data['success']) {
          socialList.add(Social(
              name: i['name'],
              link: i['link'],
              icon: i['icon'],
              color: i['color']));
        }
        final String encodedData = Social.encode(socialList);
        prefs.setString('social', encodedData);
      }
    }
  }

  void listener(AppLovinAdListener event) {
    print(event);
    if (event == AppLovinAdListener.onUserRewarded) {
      print('👍get reward');
    }
  }

  @override
  void initState() {
    checkNetwork();
    getSocial();
    // loadAd();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      HomeFragment(),
      GenreFragment(),
      Profile(),
      SettingScreen()
    ];
    // TODO: implement build
    return WillPopScope(
        onWillPop: () async {
          if (_selectedIndex == 0) {
            showDialog(
              context: context,
              builder: (context) => new AlertDialog(
                backgroundColor: muvi_appBackground,
                title: new Text(
                  'Are you sure?',
                  style: TextStyle(color: Colors.white),
                ),
                content: new Text(
                  'Do you want to exit Anime4U?',
                  style: TextStyle(color: Colors.white),
                ),
                actions: <Widget>[
                  new FlatButton(
                    textColor: Colors.deepOrange,
                    onPressed: () => Navigator.of(context).pop(false),
                    child: new Text('No'),
                  ),
                  new FlatButton(
                    textColor: Colors.deepOrange,
                    onPressed: () => exit(0),
                    child: new Text('Yes'),
                  ),
                ],
              ),
            );
          }
          else if (_selectedIndex == 1) {
            setState(() {
              _selectedIndex = 0;
            });
          }
          else if (_selectedIndex == 2) {
            setState(() {
              _selectedIndex = 0;
            });
          }
          return false;
        },
        child: Scaffold(
            body: Stack(children: <Widget>[
          isNetworkAvailable
              ? Scaffold(
                  backgroundColor: muvi_appBackground,
                  body: PageStorage(
                    child: pages[_selectedIndex],
                    bucket: bucket,
                  ),
                  floatingActionButton: _selectedIndex != 0 &&
                          _selectedIndex != 1
                      ? Container()
                      : OpenContainer(
                          closedBuilder: (_, openContainer) {
                            return FloatingActionButton(
                              elevation: 0.0,
                              onPressed: openContainer,
                              backgroundColor: muvi_colorAccent,
                              child: Icon(Icons.search, color: Colors.white),
                            );
                          },
                          openColor: muvi_colorAccent,
                          closedElevation: 5.0,
                          closedShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100)),
                          closedColor: muvi_colorAccent,
                          openBuilder: (_, closeContainer) {
                            return WillPopScope(
                                onWillPop: () async {
                                  // setState(() {
                                  //   _textcontroller.clear();
                                  // });
                                  return true;
                                },
                                child: Search());
                          }),
                  bottomNavigationBar: Container(
                    decoration: BoxDecoration(
                      color: muvi_appBackground,
                      // boxShadow: [
                      //   BoxShadow(
                      //       color: Colors.grey.withOpacity(0.5),
                      //       offset: Offset.fromDirection(3, 1),
                      //       spreadRadius: 7,
                      //       blurRadius: 10)
                      // ]
                    ),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        alignment: Alignment(0.5, 1),
                        child:  BannerMaxView((AppLovinAdListener? event) => print(event), BannerAdSize.banner, "daaf4fddc7d17c43")
                      ),
                      CustomNavigationBar(
                        borderRadius: Radius.elliptical(0, 10),
                        iconSize: 25.0,
                        opacity: 0.5,
                        blurEffect: true,
                        scaleCurve: Curves.easeIn,
                        selectedColor: muvi_colorPrimary,
                        strokeColor: Colors.black.withOpacity(0.6),
                        unSelectedColor: Colors.white,
                        backgroundColor: Colors.black,
                        items: [
                          CustomNavigationBarItem(
                            icon: Icon(Icons.home),
                          ),
                          CustomNavigationBarItem(
                            icon: Icon(Icons.list),
                          ),
                          CustomNavigationBarItem(
                            icon: Icon(Icons.account_circle),
                          ),
                          CustomNavigationBarItem(
                            icon: Icon(Icons.settings),
                          ),
                        ],
                        currentIndex: _selectedIndex,
                        onTap: (int index) => {
                          setState(() => _selectedIndex = index),
                        },
                        // type: BottomNavigationBarType.fixed,
                      ),
                    ]),
                  ),
                )
              : Scaffold(
                  backgroundColor: muvi_appBackground,
                  body: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.srgbToLinearGamma(),
                          image:
                              AssetImage("images/muvi/images/nonotifback.jfif"),
                        ),
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "images/muvi/images/nointernet.png",
                            width: MediaQuery.of(context).size.width / 1.5,
                          ),
                          Text(
                            "No Network",
                            style: TextStyle(color: Colors.white, fontSize: 35),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            "Please check your Internet Connection",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ],
                      ))),
                ),
        ])));
  }
}
