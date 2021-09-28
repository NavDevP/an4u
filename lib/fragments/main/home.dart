import 'dart:convert';
import 'dart:io';

import 'package:Anime4U/fragments/see_more.dart';
import 'package:Anime4U/integration/Api.dart';
import 'package:Anime4U/models/response.dart';
import 'package:Anime4U/resources/colors.dart';
import 'package:Anime4U/resources/size.dart';
import 'package:Anime4U/resources/strings.dart';
import 'package:Anime4U/screens/scrap_video_screen.dart';
import 'package:Anime4U/utils/app_localizations.dart';
import 'package:Anime4U/utils/app_widgets.dart';
import 'package:Anime4U/utils/date_generator.dart';
import 'package:Anime4U/utils/widgets/anime_list.dart';
import 'package:Anime4U/utils/widgets/slider_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:Anime4U/utils/widget_extensions.dart';
// import 'package:native_admob_flutter/native_admob_flutter.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_applovin_max/flutter_applovin_max.dart';
import 'package:flutter_applovin_max/banner.dart';


import '../loading.dart';

class HomeFragment extends StatefulWidget{

  @override
  State<HomeFragment> createState() => HomeFragmentState();
}

class HomeFragmentState extends State<HomeFragment>{

  bool isAnnouncement = false,dailyData = false;
  var announcementImage,announcementLink;

  Future<List<Popular>> _futureWeekly = Future.value(<Popular>[]);
  Future<List<Anime>> _futureRecent = Future.value(<Anime>[]);
  Future<List<Movies>> _futureMovies =  Future.value(<Movies>[]);
  Future<List<Horizontal>> _fetchVertical = Future.value(<Horizontal>[]);
  Future _futureDaily = Future.value([]);

  // final bannerController2 = BannerAdController();
  // final bannerController3 = BannerAdController();

  bool isUserLoggedIn = false,disableAdforUser = true;

  void announcement() async{
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    final response = await http.get(Uri.parse(ApiUrl.Announcement + "?ver=$version"));
    if (response.statusCode == 200) {
      if(response.body != "0") {
        var data = jsonDecode(response.body);
        setState(() {
          announcementImage = data[0]['image'];
          announcementLink = data[0]['url'];
          isAnnouncement = true;
        });
      }
    }
  }

  Future cachePopular() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    if(pref.containsKey('popularCache')){
      var data = [];
      data.addAll(jsonDecode(pref.getString('popularCache')!));
      return data;
    }
  }
  Future cacheVertical() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    if(pref.containsKey('popularCache')){
      var data = [];
      data.addAll(jsonDecode(pref.getString('sliderCache')!));
      return data;
    }
  }

  Future userLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    if (prefs.getString('_apiToken') != null) {
      setState(() {
        isUserLoggedIn = true;
      });
    }else {
      setState(() {
        isUserLoggedIn = false;
      });
    }
  }

  Future cacheRecent() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    if(pref.containsKey('popularCache')){
      var data = [];
      data.addAll(jsonDecode(pref.getString('recentCache')!));
      return data;
    }
  }
  Future cacheMovies() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    if(pref.containsKey('popularCache')){
      var data = [];
      data.addAll(jsonDecode(pref.getString('moviesCache')!));
      return data;
    }
  }

  Future<List<Popular>> fetchWeekly() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final response = await http.get(Uri.parse(ApiUrl.Popular + "1"));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var popular = data['popular'];
      List<Popular> Data = [];
      pref.setString('popularCache', jsonEncode(popular));
      for (var i = 0; i < popular.length; i++) {
        Popular categroies = Popular(
            popular[i]['title'],
            popular[i]['img'],
            popular[i]['link'],
            popular[i]['synopsis'],
            popular[i]['category'],
            popular[i]['episode'],
            popular[i]['totalEpisodes'],
            popular[i]['released'],
            popular[i]['status'],
            popular[i]['otherName'],
            popular[i]['episodes'],
            popular[i]['genres']);
        Data.add(categroies);
      }
      return Data;
    } else {
      throw Exception('Failed to load album');
    }
  }

  Future<List<Movies>> fetchMovies() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final response = await http.get(Uri.parse(ApiUrl.Movies + "1"));
    List<Movies> Data = [];
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      // print(data);
      var popular = data['movies'];
      pref.setString('moviesCache', jsonEncode(popular));
      for (var i = 0; i < popular.length; i++) {
        Movies mov = Movies(
            popular[i]['title'],
            popular[i]['link'],
            popular[i]['img'],
            popular[i]['synopsis'],
            popular[i]['genres'],
            popular[i]['released'],
            popular[i]['status'],
            popular[i]['otherName'],
            popular[i]['totalEpisodes'],
            popular[i]['episodes']);
        Data.add(mov);
      }
      return Data;
    } else {
      throw Exception('Failed to load album');
    }
  }
  Future<List<Horizontal>> fetchVertical() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final response = await http.get(Uri.parse(ApiUrl.RecentEpisode + "1"));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
//      var list = List<HomeSlider>();
      List<Horizontal> verticalD = [];
      var popular = data['anime'];
      pref.setString("sliderCache", jsonEncode(popular));
      for (var i = 0; i < popular.length; i++) {
        Horizontal recent = Horizontal(
            popular[i]['title'],
            popular[i]['img'],
            popular[i]['link'],
            popular[i]['synopsis'],
            popular[i]['category'],
            popular[i]['episode'],
            popular[i]['totalEpisodes'],
            popular[i]['released'],
            popular[i]['status'],
            popular[i]['genres'],
            popular[i]['otherName'],
            popular[i]['servers']);
        verticalD.add(recent);
      }
      return verticalD;
    } else {
      setState(() {
        _fetchVertical = fetchVertical();
      });
      throw Exception('Failed to load album');
    }
  }
  Future fetchDaily() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final response = await http.post(Uri.parse(ApiUrl.Daily),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ${pref.getString('_apiToken')}'
        });

    if (response.statusCode == 200) {
      if(response.body != 0) {
        var data = jsonDecode(response.body);
        var main = [];
//      var list = List<HomeSlider>();
//       for (var i = 0; i < data.length; i++) {
//         Horizontal recent = Horizontal(
//             data[i]['title'],
//             data[i]['img'],
//             data[i]['synopsis'],
//             data[i]['category'],
//             data[i]['episode'],
//             data[i]['totalEpisodes'],
//             data[i]['released'],
//             data[i]['status'],
//             data[i]['genres'],
//             data[i]['otherName'],
//             data[i]['servers']);
//         verticalD.add(recent);
//       }
        main.addAll(data);
        setState(() {
          dailyData = true;
        });
        return main;
      }
    }else{
      throw Exception('Failed to load Daily');
    }
  }

  Future<List<Anime>> getRecent() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final response = await http.get(Uri.parse(ApiUrl.Recent));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List<Anime> listRecent = [];
//      print("ListSG: ${data['anime']}");
      pref.setString('recentCache', jsonEncode(data['anime']));
      for (var i = 0; i < data['anime'].length; i++) {
        Anime recent = Anime(
            data['anime'][i]['title'],
            data['anime'][i]['link'],
            data['anime'][i]['img'],
            data['anime'][i]['synopsis'],
            data['anime'][i]['category'],
            data['anime'][i]['episode'],
            data['anime'][i]['totalEpisodes'],
            data['anime'][i]['released'],
            data['anime'][i]['status'],
            data['anime'][i]['otherName'],
            data['anime'][i]['episodes'],
            data['anime'][i]['genres']);
        listRecent.add(recent);
      }
      // print("ListSGL: $listRecent");
      return listRecent;
    } else {
      setState(() {
        _futureRecent = getRecent();
      });
      throw Exception('Failed to load Recent Release');
    }
  }

  // void loadAd() async{
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   if(prefs.containsKey('ad_status')){
  //     if(prefs.getInt('ad_status') != 1) {
  //       bannerController2.onEvent.listen((e) {
  //         final event = e.keys.first;
  //         // final info = e.values.first;
  //         switch (event) {
  //           case BannerAdEvent.loaded:
  //             // setState(() => banneradLoaded2 = true);
  //             // setState(() => _bannerAdHeight = (info as int)?.toDouble());
  //             break;
  //           default:
  //             break;
  //         }
  //       });
  //       bannerController2.load();
  //       bannerController3.onEvent.listen((e) {
  //         final event = e.keys.first;
  //         // final info = e.values.first;
  //         switch (event) {
  //           case BannerAdEvent.loaded:
  //             // setState(() => banneradLoaded3 = true);
  //             // setState(() => _bannerAdHeight = (info as int)?.toDouble());
  //             break;
  //           default:
  //             break;
  //         }
  //       });
  //       bannerController3.load();
  //     }
  //   } else{
  //     bannerController2.onEvent.listen((e) {
  //       final event = e.keys.first;
  //       // final info = e.values.first;
  //       switch (event) {
  //         case BannerAdEvent.loaded:
  //         // setState(() => _bannerAdHeight = (info as int)?.toDouble());
  //           break;
  //         default:
  //           break;
  //       }
  //     });
  //     bannerController2.load();
  //     bannerController3.onEvent.listen((e) {
  //       final event = e.keys.first;
  //       // final info = e.values.first;
  //       switch (event) {
  //         case BannerAdEvent.loaded:
  //         // setState(() => _bannerAdHeight = (info as int)?.toDouble());
  //           break;
  //         default:
  //           break;
  //       }
  //     });
  //     bannerController3.load();
  //   }
  // }

  @override
  void initState() {
    FlutterApplovinMax.initRewardAd('YOUR_AD_UNIT_ID');
    FlutterApplovinMax.initInterstitialAd('YOUR_AD_UNIT_ID');
    userLogin();
    _futureDaily = fetchDaily();
    _fetchVertical = fetchVertical();
    _futureMovies = fetchMovies();
    _futureWeekly = fetchWeekly();
    _futureRecent = getRecent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    final Size cardSize = Size(width, width * (13 / 13.5));
    var idx = 1;
    var list = <VerticalSlide>[];
    // TODO: implement build
    return Scaffold(
        backgroundColor: muvi_appBackground,
        body: Scaffold(
            backgroundColor: muvi_appBackground,
            body: Stack(children: <Widget>[
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(top: 30),
                        padding: EdgeInsets.only(top: 1, bottom: 15),
                        decoration: BoxDecoration(
                          // borderRadius: BorderRadius.circular(7),
                        ),
//                                        image: DecorationImage(image: AssetImage("assets/images/original.gif",),fit: BoxFit.fill)),
                        child: FutureBuilder(
                            future: _fetchVertical,
                            builder: (BuildContext context,
                                AsyncSnapshot snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return FutureBuilder(
                                      future: cacheVertical(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot snapshot) {
                                        if(snapshot.hasData){
                                          for (int i = 0; i <= snapshot.data.length - 1; i++) {
                                            var URL;
                                            var type;
                                            list.add(VerticalSlide(
                                              slideImage:
                                              snapshot.data[i]['img'],
                                              title: snapshot.data[i]['title'],
                                              isHD: true,
                                              episode: snapshot.data[i]['totalEpisodes'],
                                              episodeNo: snapshot.data[i]['episode'],
                                              link: snapshot.data[i]['link'],
                                              desc: snapshot.data[i]['synopsis'],
                                              genres: snapshot.data[i]['genres'],
                                              server: URL,
                                              type: type,
//                                      id: snapshot.data[i].id
                                            ));
                                            idx++;
                                          }
                                          return SliderWidget(
                                            viewportFraction: 0.65,
                                            height: cardSize.height,
                                            enlargeCenterPage: true,
                                            autoPlay: true,
                                            autoPlayInterval: Duration(seconds: 4),
                                            scrollDirection: Axis.horizontal,
                                            items: list.map((slider) {
                                              return Builder(
                                                builder: (BuildContext context) {
                                                  return GestureDetector(
                                                      onTap: (){
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => ScrapVideo(slider.title!,slider.link, slider.episodeNo.toString(),slider.slideImage!,0,slider.episode!,slider.genres)));
                                                      },
                                                      child: Container(
                                                        width: cardSize.width,
                                                        padding: EdgeInsets.only(top: 10),
                                                        margin: EdgeInsets.symmetric(horizontal: spacing_control),
                                                        child: Card(
                                                          semanticContainer: true,
                                                          clipBehavior: Clip.antiAliasWithSaveLayer,
                                                          elevation: 10,
                                                          margin: EdgeInsets.all(0),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(spacing_control),
                                                          ),
                                                          child: Stack(
                                                            alignment: Alignment.bottomLeft,
                                                            children: <Widget>[
                                                              Image.network(slider.slideImage ?? '',
                                                                  width: double.infinity,
                                                                  height: double.infinity,
                                                                  fit: BoxFit.fill),
                                                              Container(
                                                                  alignment: Alignment.topRight,
                                                                  child: Container(
                                                                      padding: EdgeInsets.all(10),
                                                                      decoration: BoxDecoration(
                                                                          color: muvi_colorPrimaryDark
                                                                      ),
                                                                      child: Text("Episode: ${slider.episodeNo.toString()}",style: TextStyle(color: Colors.white,fontFamily: 'MonsterratBold'),)
                                                                  )),
                                                              Container(
                                                                  width: MediaQuery.of(context).size.width,
                                                                  alignment: Alignment.bottomCenter,
                                                                  child: Container(
                                                                      width: MediaQuery.of(context).size.width,
                                                                      padding: EdgeInsets.all(10),
                                                                      decoration: BoxDecoration(
                                                                          color: muvi_colorPrimaryDark
                                                                      ),
                                                                      child: Text(slider.title.toString(),style: TextStyle(color: Colors.white,fontFamily: 'MonsterratBold'),
                                                                          maxLines: 1,textAlign: TextAlign.center)
                                                                  ))
                                                            ],
                                                          ),
                                                        ).paddingBottom(spacing_control),
                                                      )
                                                  );
                                                },
                                              );
                                            }).toList(),
                                          );
                                        }else{
                                          return Container();
                                        }
                                      });
                                default:
                                  if (snapshot.hasData) {
                                    for (int i = 0; i <= snapshot.data.length - 1; i++) {
                                      var URL;
                                      var type;
                                      list.add(VerticalSlide(
                                        slideImage:
                                        snapshot.data[i].img,
                                        title: snapshot.data[i].title,
                                        isHD: true,
                                        episode: snapshot.data[i].totalEpisodes,
                                        episodeNo: snapshot.data[i].episode,
                                        link: snapshot.data[i].link,
                                        desc: snapshot.data[i].synopsis,
                                        genres: snapshot.data[i].genres,
                                        server: URL,
                                        type: type,
//                                      id: snapshot.data[i].id
                                      ));
                                      idx++;
                                    }
                                    return SliderWidget(
                                      viewportFraction: 0.65,
                                      height: cardSize.height,
                                      enlargeCenterPage: true,
                                      autoPlay: true,
                                      autoPlayInterval: Duration(seconds: 4),
                                      scrollDirection: Axis.horizontal,
                                      items: list.map((slider) {
                                        return Builder(
                                          builder: (BuildContext context) {
                                            return GestureDetector(
                                                onTap: (){
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => ScrapVideo(slider.title!,slider.link, slider.episodeNo.toString(),slider.slideImage!,0,slider.episode!,slider.genres)));
                                                },
                                                child: Container(
                                                  width: cardSize.width,
                                                  padding: EdgeInsets.only(top: 10),
                                                  margin: EdgeInsets.symmetric(horizontal: spacing_control),
                                                  child: Card(
                                                    semanticContainer: true,
                                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                                    elevation: 10,
                                                    margin: EdgeInsets.all(0),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(spacing_control),
                                                    ),
                                                    child: Stack(
                                                      // alignment: Alignment.bottomLeft,
                                                      children: <Widget>[
                                                        Image.network(slider.slideImage ?? '',
                                                            width: double.infinity,
                                                            height: double.infinity,
                                                            fit: BoxFit.fill),
                                                        Container(
                                                            alignment: Alignment.topRight,
                                                            child: Container(
                                                                padding: EdgeInsets.all(10),
                                                                decoration: BoxDecoration(
                                                                    color: muvi_colorPrimaryDark
                                                                ),
                                                                child: Text("Episode: ${slider.episodeNo.toString()}",style: TextStyle(color: Colors.white,fontFamily: 'MonsterratBold'),)
                                                            )),
                                                        Container(
                                                            width: MediaQuery.of(context).size.width,
                                                            alignment: Alignment.bottomCenter,
                                                            child: Container(
                                                                width: MediaQuery.of(context).size.width,
                                                                padding: EdgeInsets.all(10),
                                                                decoration: BoxDecoration(
                                                                    color: muvi_colorPrimaryDark
                                                                ),
                                                                child: Text(slider.title.toString(),style: TextStyle(color: Colors.white,fontFamily: 'MonsterratBold'),
                                                                    maxLines: 1,textAlign: TextAlign.center)
                                                            ))
                                                      ],
                                                    ),
                                                  ).paddingBottom(spacing_control),
                                                )
                                            );
                                          },
                                        );
                                      }).toList(),
                                    );
                                  }
                                  return Container();
                              }
                              // );
                            })),
                    Container(
                        child: Column(
                            children: [
                              isAnnouncement ? GestureDetector(
                                  onTap: () async{
                                    if(announcementLink != null || announcementLink != ""){
                                      // if (await canLaunch(announcementLink))
                                        await launch(announcementLink);
                                      // else
                                      //   can't launch url, there is some error
                                        // throw "Could not launch $announcementLink";
                                    }
                                  },
                                  child: Container(
                                      margin: EdgeInsets.all(20),
                                      child: CachedNetworkImage(
                                        imageUrl: announcementImage,
                                        fit: BoxFit.cover,)
                                  )):Container(),
                              Container(
                                alignment: Alignment(0.5, 1),
                                child: BannerMaxView((AppLovinAdListener? event) => print(event), BannerAdSize.banner, "e6464e3d7a9b3da3"),
                              ),
                              headingWidViewAll(context, keyString(context, "weekly_top"),
                                      () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => SeeMore(title: "Popular",index: 1)
                                            ));
                                    // setState(() {
                                    //   _futurePopular = getPopular(1, 1, "popular");
                                    // });
                                  }, true).paddingAll(spacing_standard_new),
                              Container(
                                height: (width * 0.38) * 8.8 / 6,
                                child: FutureBuilder(
                                    future: _futureWeekly,
                                    builder: (BuildContext context,
                                        AsyncSnapshot snapshot) {
                                      switch (snapshot.connectionState) {
                                        case ConnectionState.waiting:
                                          return FutureBuilder(
                                              future: cachePopular(),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot snapshot) {
                                                if(snapshot.hasData) {
                                                  return ListView.builder(
                                                      scrollDirection: Axis
                                                          .horizontal,
                                                      itemCount: snapshot.data
                                                          .length,
                                                      shrinkWrap: true,
                                                      padding: EdgeInsets.only(
                                                          left: spacing_standard,
                                                          right: spacing_standard_new),
                                                      itemBuilder: (context,
                                                          index) {
                                                        return AnimeList(snapshot.data[index]['img'], snapshot.data[index]['title'], snapshot.data[index]['link'], snapshot.data[index]['episodes'], snapshot.data[index]['totalEpisodes']);
                                                      });
                                                }else{
                                                  return Container(child:Center(child:CircularProgressIndicator()));
                                                }
                                              });
                                        default:
                                          if (snapshot.hasData) {
                                            return ListView.builder(
                                                scrollDirection: Axis.horizontal,
                                                itemCount: snapshot.data.length,
                                                shrinkWrap: true,
                                                padding: EdgeInsets.only(
                                                    left: spacing_standard,
                                                    right: spacing_standard_new),
                                                itemBuilder: (context, index) {
                                                  return AnimeList(snapshot.data[index].img, snapshot.data[index].title, snapshot.data[index].link, snapshot.data[index].episodes, snapshot.data[index].totalEpisodes);
                                                });
                                          } else {
                                            return Container(
                                                child: Center(child: CircularProgressIndicator())
                                            );
                                          }
                                      }
                                    }),
                              ),
                              headingWidViewAll(context, keyString(context, "anime_movies"),
                                      () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => SeeMore(title: "Movies",index: 4)
                                            ));
                                  }, true)
                                  .paddingAll(spacing_standard_new),
                              Container(
                                height: (width * 0.38) * 8.8 / 6,
                                child: FutureBuilder(
                                    future: _futureMovies,
                                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                                      switch (snapshot.connectionState) {
                                        case ConnectionState.waiting:
                                          return FutureBuilder(
                                              future: cacheMovies(),
                                              builder: (BuildContext context, AsyncSnapshot snapshot) {
                                                if(snapshot.hasData) {
                                                  return ListView.builder(
                                                      scrollDirection: Axis.horizontal,
                                                      itemCount: snapshot.data.length,
                                                      shrinkWrap: true,
                                                      padding: EdgeInsets.only(
                                                          left: spacing_standard,
                                                          right: spacing_standard_new),
                                                      itemBuilder: (context, index) {
                                                        return AnimeList(snapshot.data[index]['img'], snapshot.data[index]['title'],snapshot.data[index]['link'] , snapshot.data[index]['episodes'], snapshot.data[index]['totalEpisodes']);
                                                      });
                                                }else{
                                                  return Container(
                                                      child: Center(child: CircularProgressIndicator())
                                                  );
                                                }
                                              });
                                        default:
                                          if (snapshot.hasData) {
                                            return ListView.builder(
                                                scrollDirection: Axis.horizontal,
                                                itemCount: snapshot.data.length,
                                                shrinkWrap: true,
                                                padding: EdgeInsets.only(
                                                    left: spacing_standard,
                                                    right: spacing_standard_new),
                                                itemBuilder: (context, index) {
                                                  return AnimeList(snapshot.data[index].img, snapshot.data[index].title,snapshot.data[index].link, snapshot.data[index].episodes, snapshot.data[index].totalEpisodes);
                                                });
                                          } else {
                                            return Container(
                                                child: Center(child: CircularProgressIndicator())
                                            );
                                          }}
                                    }),
                              ),
                              Container(
                                alignment: Alignment(0.5, 1),
                                child: BannerMaxView((AppLovinAdListener? event) => print(event), BannerAdSize.banner, "ad27565e097e31e6"),
                              ),
                              isUserLoggedIn && dailyData ?
                              SingleChildScrollView(
                                child: Container(
                                  height: (width * 0.68) * 8.8 / 7,
                                  margin:
                                  EdgeInsets.only(left: 16, right: 16, bottom: 16),
                                  child: IntrinsicHeight(
                                    child: Card(
                                      semanticContainer: true,
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: <Widget>[
                                          Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      image: AssetImage(
                                                          "images/muvi/images/dailyback.gif"),
                                                      fit: BoxFit.cover),
                                                  color: muvi_appBackground,
                                                  gradient: LinearGradient(
                                                      begin: Alignment.bottomCenter,
                                                      end: Alignment.topCenter,
                                                      colors: [
                                                        muvi_appBackground,
                                                        muvi_appBackground,
                                                        muvi_appBackground
                                                      ]
                                                  ),
                                                ),
//                                        image: DecorationImage(image: AssetImage("assets/images/original.gif",),fit: BoxFit.fill)),
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 16.0),
                                                  child: Stack(children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                            begin: Alignment.bottomCenter,
                                                            end: Alignment.topCenter,
                                                            colors: [
                                                              Colors.black87,
                                                              Colors.black87,
                                                              Colors.transparent,
                                                              Colors.transparent,
                                                              Colors.transparent
                                                            ]
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      alignment: Alignment.bottomCenter,
                                                      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 9),
                                                      height: (width * 0.38) * 8.8 / 7,
                                                      child: FutureBuilder(
                                                          future: _futureDaily,
                                                          builder: (BuildContext context,
                                                              AsyncSnapshot snapshot) {
                                                            if (snapshot.hasData) {
                                                              return ListView.builder(
                                                                  scrollDirection:
                                                                  Axis.horizontal,
                                                                  itemCount: 3,
                                                                  shrinkWrap: true,
                                                                  padding: EdgeInsets.only(
                                                                      left: spacing_standard,
                                                                      right:
                                                                      spacing_standard_new),
                                                                  itemBuilder:
                                                                      (context, index) {
                                                                    return Container(
                                                                        margin: EdgeInsets.only(
                                                                            left:
                                                                            spacing_standard),
                                                                        width: width * 0.25,
                                                                        child: Column(
                                                                          children: <Widget>[
                                                                            InkWell(
                                                                              child:
                                                                              AspectRatio(
                                                                                aspectRatio:
                                                                                6 / 8.8,
                                                                                child: Card(
                                                                                  color: Colors
                                                                                      .transparent,
                                                                                  semanticContainer:
                                                                                  true,
                                                                                  clipBehavior:
                                                                                  Clip.antiAliasWithSaveLayer,
                                                                                  elevation:
                                                                                  10,
                                                                                  margin: EdgeInsets
                                                                                      .all(0),
                                                                                  shape:
                                                                                  RoundedRectangleBorder(
                                                                                    borderRadius:
                                                                                    BorderRadius.circular(16),
                                                                                  ),
                                                                                  child:
                                                                                  Stack(
                                                                                    alignment:
                                                                                    Alignment
                                                                                        .bottomLeft,
                                                                                    children: <
                                                                                        Widget>[
                                                                                      GestureDetector(
                                                                                          onTap: () {
                                                                                            var episodes = jsonDecode(snapshot.data[index]['episodes']);
                                                                                            Navigator.push(context, MaterialPageRoute(builder: (context) => Loading(snapshot.data[index]['anime_name'],"", episodes, snapshot.data[index]['totalEpisodes'],0, context)));
                                                                                          },
                                                                                          child: Image.network(
                                                                                            snapshot.data[index]['anime_image'],
                                                                                            height: double.infinity,
                                                                                          )),
                                                                                      hdWidget(context)
                                                                                          .paddingRight(spacing_standard)
                                                                                          .visible(false)
                                                                                          .paddingAll(spacing_standard),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              onTap: () {

                                                                              },
                                                                              radius:
                                                                              spacing_control,
                                                                            ),
                                                                            Flexible(
                                                                              child: new Text(
                                                                                snapshot.data[index]['anime_name'],
                                                                                style: TextStyle(
                                                                                    color: Colors
                                                                                        .white),
                                                                                overflow:
                                                                                TextOverflow
                                                                                    .ellipsis,
                                                                                maxLines: 2,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ));
                                                                  });
                                                            } else {
                                                              return CircularProgressIndicator();
                                                            }
                                                          }),
                                                    ),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    Container(
                                                      width: MediaQuery.of(context).size.width,
                                                      alignment: Alignment.topCenter,
                                                      child: Row(
                                                        children: <Widget>[
                                                          Expanded(child: Container(
                                                            padding:
                                                            EdgeInsets.only(left: 16),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment.start,
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment.start,
                                                              children: <Widget>[
                                                                Row(
                                                                  mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      "Daily",
                                                                      style: TextStyle(
                                                                        color: Colors.white,
                                                                        fontSize: 25,
                                                                        fontWeight:
                                                                        FontWeight.bold,),
                                                                    ),
                                                                    Container(
                                                                        color:
                                                                        muvi_appBackground,
                                                                        padding:
                                                                        EdgeInsets.all(5),
                                                                        child: Image.asset(
                                                                          "images/muvi/images/anime4u.png",
                                                                          width: 100,
                                                                        ))
                                                                  ],
                                                                ),
                                                                Row(children: [
                                                                  Container(
                                                                    padding: EdgeInsets.only(
                                                                        left: 20),
                                                                    child: Text(
                                                                      "3",
                                                                      style: TextStyle(
                                                                          color: Colors.white,
                                                                          fontSize: 35,
                                                                          fontWeight:
                                                                          FontWeight.bold,
                                                                          fontFamily:
                                                                          'Mange'),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 14,
                                                                  ),
                                                                  Flexible(
                                                                    child: Text(
                                                                      "These are Recommendations from Anime4U \n according to your Watching List",
                                                                      overflow: TextOverflow
                                                                          .ellipsis,
                                                                      style: TextStyle(
                                                                        color: Colors.white,
                                                                        fontSize: 11,
                                                                        fontWeight:
                                                                        FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ]),
                                                              ],
                                                            ),
                                                          ))
                                                        ],
                                                      ),
                                                    ),
                                                  ]),
                                                ),
                                              ))
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ):Container(),
                              headingWidViewAll(
                                  context,
                                  keyString(context, "recently_added"),
                                      () {},
                                  false)
                                  .paddingAll(spacing_standard_new),
                              Container(
                                height: (width * 0.38) * 8.8 / 6,
                                child: FutureBuilder(
                                    future: _futureRecent,
                                    builder: (BuildContext context,
                                        AsyncSnapshot snapshot) {
                                      switch (snapshot.connectionState) {
                                        case ConnectionState.waiting:
                                          return FutureBuilder(
                                              future: cacheRecent(),
                                              builder: (BuildContext context, AsyncSnapshot snapshot) {
                                                if(snapshot.hasData){
                                                  return ListView.builder(
                                                      scrollDirection: Axis.horizontal,
                                                      itemCount: snapshot.data.length,
                                                      shrinkWrap: true,
                                                      padding: EdgeInsets.only(
                                                          left: spacing_standard,
                                                          right: spacing_standard_new),
                                                      itemBuilder: (context, index) {
                                                        return AnimeList(snapshot.data[index]['img'], snapshot.data[index]['title'], snapshot.data[index]['link'], snapshot.data[index]['episodes'], snapshot.data[index]['totalEpisodes']);
                                                      });
                                                }else{
                                                  return Container(
                                                      child: Center(child: CircularProgressIndicator())
                                                  );
                                                }
                                              });
                                        default:
                                          if (snapshot.hasData) {
                                            return ListView.builder(
                                                scrollDirection: Axis.horizontal,
                                                itemCount: snapshot.data.length,
                                                shrinkWrap: true,
                                                padding: EdgeInsets.only(
                                                    left: spacing_standard,
                                                    right: spacing_standard_new),
                                                itemBuilder: (context, index) {
                                                  return AnimeList(snapshot.data[index].img, snapshot.data[index].title, snapshot.data[index].link, snapshot.data[index].episodes, snapshot.data[index].totalEpisodes);
                                                });
                                          } else {
                                            return Container(
                                                child: Center(child: CircularProgressIndicator())
                                            );
                                          }}
                                    }),
                              ),
                              // BannerAd(controller: bannerController2,loading: Container(),unitId: adId1,)
                            ])
                    )
                  ],
                ),
              )
            ])));
  }

}