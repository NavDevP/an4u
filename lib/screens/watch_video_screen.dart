import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:Anime4U/integration/Api.dart';
import 'package:Anime4U/resources/colors.dart';
import 'package:Anime4U/resources/size.dart';
import 'package:Anime4U/resources/strings.dart';
import 'package:Anime4U/screens/scrap_video_screen.dart';
import 'package:chewie/chewie.dart';
import 'package:facebook_audience_network/ad/ad_banner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/services.dart';
import 'package:flutter_applovin_max/banner.dart';
import 'package:flutter_applovin_max/flutter_applovin_max.dart';

// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:http/http.dart' as http;
// import 'package:native_admob_flutter/native_admob_flutter.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:better_player/better_player.dart';

//import 'package:video_player_header/video_player_header.dart';
import 'package:laravel_echo/laravel_echo.dart';
import 'package:flutter_pusher_client/flutter_pusher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'flix_signin.dart';

class WatchVideo extends StatefulWidget {
  WatchVideo(
      this.url,
      this.selectQual,
      this.header,
      this.quality,
      this.title,
      this.server,
      this.image,
      this.ep,
      this.local,
      this.totalEpisodes,
      this.genre,
      this.link
      );

  final String url;
  final List quality;
  final String title;
  final List server;
  final String selectQual;
  final header;
  final String image;
  final String ep;
  final int local;
  final int totalEpisodes;
  final List? genre;
  final String link;

  @override
  WatchVideoState createState() => WatchVideoState();
}

class WatchVideoState extends State<WatchVideo> {
  // late VlcPlayerController _videoController;
  bool isControllsShown = false,
      isBuffering = false,
      isVideoPlaying = false,
      isLandscape = false,
      isLoading = false;
  late double _currentPosition, _playBackTime;
  String _currentPositionString = "0.0", _playBackTimeString = "0.0";
  var volume = 0;
  String dropdownValue = "1080p";
  List<String> serVer = [];
  List<String> ser = [];
  int currentEpisode = 0;
  BetterPlayerController? _betterPlayerController;
  String userComment = "";
  int page = 1;

  TextEditingController _commentController = TextEditingController();

  var comments = [];
  // final bannerController = BannerAdController();
  bool loadMore = false, showLoadButton = false;

  double _height = 0;
  bool nextButton = true, previousButton = true;
  late StreamSubscription _subscription;

  List<dynamic> servers = [];

  bool isFetchingServers = false,
      allowNextServer = true,
      isUserLoggedIn = false;

  void listener(AppLovinAdListener? event) {
    // print("LOADED BOY");
    print(event);
  }

  bool isInterstitialVideoAvailable = false;

  void loadAd() async{
    isInterstitialVideoAvailable = (await FlutterApplovinMax.isInterstitialLoaded(listener))!;
    // if (isInterstitialVideoAvailable) {
    //   FlutterApplovinMax.showInterstitialVideo((AppLovinAdListener? event) => listener(event));
    // }
  }

  Future getServers(int epis) async {
    setState(() {
      isLoading = true;
      isFetchingServers = true;
    });
    var episode;
    if (epis == 0) {
      episode = currentEpisode != 0
          ? (currentEpisode - 1)
          : (int.parse(widget.ep) - 1);
    } else {
      episode = currentEpisode != 0
          ? (currentEpisode + 1)
          : (int.parse(widget.ep) + 1);
    }
    if (episode != null) {
      _betterPlayerController!.pause();
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String version = packageInfo.version;
      String finalV = version.replaceAll('.', '');
      final response = await http.get(Uri.parse(ApiUrl.Googl +
          "v$finalV/getServer.php?title=${widget.title.toLowerCase()}&episode=$episode"));
      if (response.statusCode == 200) {
        if (widget.totalEpisodes == episode) {
          setState(() {
            nextButton = false;
          });
        } else {
          setState(() {
            nextButton = true;
          });
        }
        if (episode == 1) {
          setState(() {
            previousButton = false;
          });
        } else {
          setState(() {
            previousButton = true;
          });
        }
        // print("Response: ${response.body}");
        var data = jsonDecode(response.body);
        var video = "";
        // print(data);
        setState(() {
          if (data['data'][0]['url'].length != 0) {
            servers.add({
              'name': data['data'][0]['name'],
              'url': data['data'][0]['url'],
              'episode': episode,
            });
          }
          if (data['data'][0]['next'] != 0) {
            moreServers(data['data'][0]['next'], episode);
          } else {
            isFetchingServers = false;
          }
        });
      }
    }
  }

  // void loadAd() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   if (prefs.containsKey('ad_status')) {
  //     if (prefs.getInt('ad_status') == 1) {
  //       bannerController.onEvent.listen((e) {
  //         final event = e.keys.first;
  //         // final info = e.values.first;
  //         switch (event) {
  //           case BannerAdEvent.loaded:
  //             // setState(() => _bannerAdHeight = (info as int)?.toDouble());
  //             break;
  //           default:
  //             break;
  //         }
  //       });
  //       bannerController.load();
  //     }
  //   } else {
  //     bannerController.onEvent.listen((e) {
  //       final event = e.keys.first;
  //       // final info = e.values.first;
  //       switch (event) {
  //         case BannerAdEvent.loaded:
  //           // setState(() => _bannerAdHeight = (info as int)?.toDouble());
  //           break;
  //         default:
  //           break;
  //       }
  //     });
  //     bannerController.load();
  //   }
  // }

  Future moreServers(server, episode) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String finalV = version.replaceAll('.', '');
    final response = await http.get(Uri.parse(ApiUrl.Googl +
        'v' +
        finalV +
        "/servers/$server.php?anime=${widget.title.toLowerCase()}&episode=$episode"));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['data'][0]['url'].length != 0 && allowNextServer) {
        setState(() {
          servers.add({
            'name': data['data'][0]['name'],
            'url': data['data'][0]['url'],
            'episode': episode
          });
        });
      }
      setState(() {
        if (data['data'][0]['next'] != 0) {
          moreServers(data['data'][0]['next'], episode);
        } else {
          isFetchingServers = false;
        }
      });
      // return servers;
    }
  }

  Future<void> initPusher() async {
    final PusherOptions options = PusherOptions(
        host: "35.225.107.66", port: 6001, encrypted: false, cluster: 'mt1');
    late FlutterPusher pusher;
    pusher = FlutterPusher('myKey', options, enableLogging: true,
        onConnectionStateChange: (ConnectionStateChange state) async {
      if (pusher != null && state.currentState == 'CONNECTED') {
        final String socketId = pusher.getSocketId();
        final Echo echo = Echo(<String, dynamic>{
          'broadcaster': 'pusher',
          'client': pusher,
        });
        echo.channel('comments').listen('.comments',
            (Map<String, dynamic> datas) {
          // if(widget.title == jsonDecode(datas.toString()).data[0].title) {
          setState(() {
            comments.insert(0, datas['data'][0]);
          });
          // }
        });
      }
    });
  }

  void initVideo(video, header) {
    setState(() {
      allowNextServer = false;
      isLoading = false;
      servers = [];
    });
    setState(() {
      if (video.contains(".m3u8")) {
        if (header != null) {
          BetterPlayerDataSource betterPlayerDataSource =
              BetterPlayerDataSource(
            BetterPlayerDataSourceType.network,
            widget.url,
            headers: {
              HttpHeaders.refererHeader: header != null ? header : '',
            },
            videoFormat: BetterPlayerVideoFormat.hls,
            cacheConfiguration: BetterPlayerCacheConfiguration(useCache: true),
          );
          _betterPlayerController = BetterPlayerController(
              BetterPlayerConfiguration(
                  autoPlay: true,
                  fit: BoxFit.fitHeight,
                  allowedScreenSleep: false),
              betterPlayerDataSource: betterPlayerDataSource);
        } else {
          BetterPlayerDataSource betterPlayerDataSource =
              BetterPlayerDataSource(
            BetterPlayerDataSourceType.network,
            widget.url,
            videoFormat: BetterPlayerVideoFormat.hls,
            cacheConfiguration: BetterPlayerCacheConfiguration(useCache: true),
          );
          _betterPlayerController = BetterPlayerController(
              BetterPlayerConfiguration(
                  autoPlay: true,
                  fit: BoxFit.fitHeight,
                  allowedScreenSleep: false),
              betterPlayerDataSource: betterPlayerDataSource);
        }
      } else {
        BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          video,
          cacheConfiguration: BetterPlayerCacheConfiguration(useCache: true),
        );
        _betterPlayerController = BetterPlayerController(
            BetterPlayerConfiguration(autoPlay: true, fit: BoxFit.fitHeight),
            betterPlayerDataSource: betterPlayerDataSource);
      }
    });
  }

  void addComment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (userComment.isNotEmpty) {
      final response = await http.post(
          Uri.parse(ApiUrl.OurApi +
              "addcomment?anime=${widget.title}&comment=$userComment"),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${prefs.getString('_apiToken')}'
          });
      if (response.statusCode == 200) {
        if (response.body.contains("1")) {
          setState(() {
            _commentController.text = "";
            userComment = "";
          });
        }
      }
    }
  }

  Future getComments(page) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post(Uri.parse(
        ApiUrl.OurApi + "getComments?anime=${widget.title}&page=$page"));
    if (response.statusCode == 200) {
      // print(response.body);
      var data = jsonDecode(response.body);
      if (data['next_page_url'] == null) {
        setState(() {
          showLoadButton = false;
        });
      } else {
        setState(() {
          showLoadButton = true;
        });
      }
      setState(() {
        comments.addAll(data['data']);
        loadMore = false;
      });
    }
  }

  _addWatched(String name, String poster, String episode,String link) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.post(
        Uri.parse(ApiUrl.OurApi +
            "add_WatchHistory?name=${name}&image=$poster&link=$link&episode=$episode&genre=${widget.genre!.length != 0 ? widget.genre![0] : null}"),
        headers: {
          HttpHeaders.authorizationHeader:
              'Bearer ${prefs.getString('_apiToken')}'
        });

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      // print(data);
    }
    // print(response.body);

    if (prefs.containsKey("watchedHistory")) {
      List<History> main = History.decode(prefs.getString("watchedHistory")!);

      main.add(History(title: name, poster: poster, episode: episode));
      final String encodedData = History.encode(main);
      prefs.setString("watchedHistory", encodedData);
    } else {
      List<History> main = [];
      main.add(History(title: name, poster: poster, episode: episode));

      final String encodedData = History.encode(main);
      prefs.setString("watchedHistory", encodedData);
    }
  }

  Future userLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    if (prefs.getString('_apiToken') != null) {
      setState(() {
        initPusher();
        isUserLoggedIn = true;
      });
    } else {
      setState(() {
        isUserLoggedIn = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    FlutterApplovinMax.initInterstitialAd('fea1f84e946505f2');
    loadAd();
    super.initState();
    userLogin();

    _addWatched(widget.title, widget.image, widget.ep,widget.link);

    getComments(page);

    serVer.addAll(ser);
    dropdownValue = widget.selectQual;
    var mainurl = "";
    List<String> requestHeader;
    if (widget.url != null) {
      if (widget.url.contains(".m3u8")) {
        if (widget.header != null) {
    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.url,
      headers: {
        HttpHeaders.refererHeader: widget.header,
        // 'Origin': 'https://streamani.net/',
        // HttpHeaders.userAgentHeader: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36",
      },
      overriddenDuration: Duration(seconds: 1),
      videoFormat: BetterPlayerVideoFormat.hls,
      cacheConfiguration: BetterPlayerCacheConfiguration(useCache: true),
      useAsmsTracks: true,
    );
    _betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(
            autoPlay: true, fit: BoxFit.fitHeight, allowedScreenSleep: false),
        betterPlayerDataSource: betterPlayerDataSource);
    print(_betterPlayerController!.betterPlayerDataSource!.headers);
        }
        else {
          BetterPlayerDataSource betterPlayerDataSource =
              BetterPlayerDataSource(
            BetterPlayerDataSourceType.network,
            widget.url,
            videoFormat: BetterPlayerVideoFormat.hls,
            cacheConfiguration: BetterPlayerCacheConfiguration(useCache: true),
          );
          _betterPlayerController = BetterPlayerController(
              BetterPlayerConfiguration(
                  autoPlay: true,
                  fit: BoxFit.fitHeight,
                  allowedScreenSleep: false),
              betterPlayerDataSource: betterPlayerDataSource);
        }
      }
      else {
        // print("HEader: ${widget.header}");
        // print(Uri.encodeFull(widget.url));
        Map<String, String> map = {
          HttpHeaders.refererHeader: widget.header != null ? widget.header : '',
          HttpHeaders.hostHeader:
              widget.header != null ? widget.header!['host'] : ''
        };
        if (widget.header != null) {
          BetterPlayerDataSource betterPlayerDataSource =
              BetterPlayerDataSource(
            BetterPlayerDataSourceType.network,
            widget.url,
            headers: widget.header != null ? map : {},
            cacheConfiguration: BetterPlayerCacheConfiguration(useCache: true),
          );
          _betterPlayerController = BetterPlayerController(
              BetterPlayerConfiguration(
                  autoPlay: true,
                  fit: BoxFit.fitHeight,
                  allowedScreenSleep: false),
              betterPlayerDataSource: betterPlayerDataSource);
        } else {
          // print("PL this");
          // print(widget.url);
          BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
            BetterPlayerDataSourceType.network,
            widget.url,
             // headers: {
            //   HttpHeaders.refererHeader: 'https://streamani.net/download?id=MTU2NjM5&title=Tokyo+Revengers+Episode+0'
            // },
            cacheConfiguration: BetterPlayerCacheConfiguration(useCache: true),
          );
          _betterPlayerController = BetterPlayerController(
              BetterPlayerConfiguration(
                  autoPlay: true,
                  fit: BoxFit.fitHeight,
                  allowedScreenSleep: false),
              betterPlayerDataSource: betterPlayerDataSource);
        }
      }

      if (widget.totalEpisodes == int.parse(widget.ep)) {
        setState(() {
          nextButton = false;
        });
      } else {
        setState(() {
          nextButton = true;
        });
      }
      if (int.parse(widget.ep) == 1) {
        setState(() {
          previousButton = false;
        });
      } else {
        setState(() {
          previousButton = true;
        });
      }
    }

    // loadAd();
    // _betterPlayerController.enablePictureInPicture(_betterPlayerController.betterPlayerGlobalKey!);
  }

  String _currentDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (twoDigits(duration.inHours) == "00") {
      return "$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
  }


  @override
  void dispose() {
    // TODO: implement dispose
    _betterPlayerController!.dispose();
    super.dispose();
  }
  // late VideoPlayerController videoPlayerController;

  @override
  Widget build(BuildContext context) {
    // final chewieController = ChewieController(
    //   videoPlayerController: videoPlayerController,
    //   autoPlay: true,
    //   looping: true,
    // );
    if (isInterstitialVideoAvailable) {
    FlutterApplovinMax.showInterstitialVideo((AppLovinAdListener? event) => listener(event));
    }
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    // TODO: implement build
    return WillPopScope(
        onWillPop: () async {
          if (isLandscape) {
            // setState(() {
            isLandscape = false;
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]);
            SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
            // });
          } else {
            // await _videoController.pause();
//          await  _videoController.stopRendererScanning();
//          await  _videoController.dispose();
//          if(_videoController != null) {
//            _videoController = null;
//          }else{
            return true;
//          }
//          Navigator.pop(context);
          }
          return false;
        },
        child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Scaffold(
                backgroundColor: muvi_appBackground,
                body: Column(children: [
                  ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height,
                        maxWidth: MediaQuery.of(context).size.width,
                      ),
                      child: Container(
                        color: Colors.black,
                        margin: isLandscape
                            ? EdgeInsets.only(top: 0)
                            : EdgeInsets.only(top: 30),
                        height: isLandscape ? height : 225,
                        child: Container(
                            child: Stack(children: [
                          Center(
                              child: _betterPlayerController != null
                                  ? BetterPlayer(
                                      controller: _betterPlayerController!,
                                    )
                                  : Expanded(
                                      child: Container(
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                    )),
                        ])),
                      )),
                  if (isLandscape)
                    Container()
                  else
                    Expanded(
                        child: SingleChildScrollView(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                          Container(
                              child: Row(
                            children: [
                              Expanded(
                                  child: previousButton
                                      ? GestureDetector(
                                          onTap: () {
                                            var newLink = (int.parse(widget.link.split('-').last)-1).toString();
                                            var mainLink = widget.link.substring(0, widget.link.length - 1);
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ScrapVideo(
                                                            widget.title,
                                                            mainLink+newLink,
                                                            (int.parse(widget
                                                                        .ep) -
                                                                    1)
                                                                .toString(),
                                                            widget.image,
                                                            0,
                                                            widget
                                                                .totalEpisodes,
                                                            widget.genre)));
                                            // setState(() {
                                            //   getServers(0);
                                            // });
                                          },
                                          child: Container(
                                              padding: EdgeInsets.all(15),
                                              color: Colors.white30,
                                              child: Center(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.skip_previous,
                                                      color: Colors.white70,
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text("Previous",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18)),
                                                  ],
                                                ),
                                              )))
                                      : Container(
                                          padding: EdgeInsets.all(15),
                                          color: Colors.white10,
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.skip_previous,
                                                  color: previousButton
                                                      ? Colors.white70
                                                      : Colors.white54,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text("Previous",
                                                    style: TextStyle(
                                                        color: previousButton
                                                            ? Colors.white
                                                            : Colors.white54,
                                                        fontSize: 18)),
                                              ],
                                            ),
                                          ))),
                              SizedBox(
                                width: 2,
                              ),
                              Expanded(
                                  child: nextButton
                                      ? GestureDetector(
                                          onTap: () {
                                            var newLink = (int.parse(widget.link.split('-').last)+1).toString();
                                            var mainLink = widget.link.substring(0, widget.link.length - 1);
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ScrapVideo(
                                                            widget.title,
                                                            mainLink+newLink,
                                                            (int.parse(widget.ep) +1)
                                                                .toString(),
                                                            widget.image,
                                                            0,
                                                            widget
                                                                .totalEpisodes,
                                                            widget.genre)));
                                          },
                                          child: Container(
                                              padding: EdgeInsets.all(15),
                                              color: Colors.white30,
                                              child: Center(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text("Next",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18)),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Icon(
                                                      Icons.skip_next,
                                                      color: Colors.white70,
                                                    )
                                                  ],
                                                ),
                                              )))
                                      : Container(
                                          padding: EdgeInsets.all(15),
                                          color: Colors.white10,
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text("Next",
                                                    style: TextStyle(
                                                        color: nextButton
                                                            ? Colors.white
                                                            : Colors.white54,
                                                        fontSize: 18)),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Icon(
                                                  Icons.skip_next,
                                                  color: nextButton
                                                      ? Colors.white70
                                                      : Colors.white54,
                                                )
                                              ],
                                            ),
                                          )))
                            ],
                          )),
                          Container(
                              margin: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
//                         border: Border.all(color: Colors.white)
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 170,
                                    child: Card(
                                      color: Colors.transparent,
                                      semanticContainer: true,
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      elevation: 30,
                                      margin: EdgeInsets.all(0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            spacing_control),
                                      ),
                                      child: Image.network(
                                        widget.image,
                                        height: double.infinity,
                                      ),
                                    ),
                                  ),
                                  Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                            width: width / 1.4,
                                            padding: EdgeInsets.only(left: 20),
                                            child: Text(
                                              widget.title,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                              maxLines: 3,
                                            )),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Container(
                                            width: width / 1.4,
                                            padding: EdgeInsets.only(left: 20),
                                            child: Text(
                                              "Episode: ${currentEpisode != 0 ? currentEpisode.toString() : widget.ep}",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontFamily: 'MonsterratBold'),
                                              overflow: TextOverflow.ellipsis,
                                            )),
                                        SizedBox(
                                          height: height / 12,
                                        ),
                                      ])
                                ],
                              )),
                                  Container(
                                    alignment: Alignment(0.5, 1),
                                    child: BannerMaxView((AppLovinAdListener? event) => print(event), BannerAdSize.banner, "YOUR_AD_UNIT_ID"),
                                    ),
                          Container(
                              padding: EdgeInsets.only(left: 10, bottom: 20,top: 10),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Comments",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              )),
                          Container(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Column(
                                children: [
                                  isUserLoggedIn
                                      ? Row(
                                          children: [
                                            SizedBox(
                                                height: 50,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    1.3,
                                                child: Container(
                                                    child: TextField(
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                  controller:
                                                      _commentController,
                                                  maxLength: 120,
                                                  cursorColor: Colors.white,
                                                  onChanged: (text) {
                                                    setState(() {
                                                      userComment = text;
                                                    });
                                                  },
                                                  decoration: InputDecoration(
                                                    counterStyle: TextStyle(
                                                      height:
                                                          double.minPositive,
                                                    ),
                                                    counterText: "",
                                                    enabledBorder:
                                                        const OutlineInputBorder(
                                                      borderSide: const BorderSide(
                                                          color:
                                                              muvi_colorPrimaryDark,
                                                          width: 0.0),
                                                    ),
                                                    labelStyle: TextStyle(
                                                        color: Colors.white54),
                                                    border: OutlineInputBorder(
                                                      borderSide: new BorderSide(
                                                          color:
                                                              muvi_colorPrimaryDark),
                                                    ),
                                                    labelText:
                                                        'Enter your Comment',
                                                  ),
                                                ))),
                                            SizedBox(
                                                height: 50,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    6,
                                                child: GestureDetector(
                                                    onTap: () {
                                                      addComment();
                                                    },
                                                    child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              muvi_colorPrimaryDark
                                                                  .withOpacity(
                                                                      0.6),
                                                        ),
                                                        child: Icon(
                                                          Icons.send,
                                                          size: 30,
                                                          color: Colors.white,
                                                        ))))
                                          ],
                                        )
                                      : Container(
                                          child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Column(
                                              children: [
                                                Text(
                                                  "Login now to comment ",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15),
                                                ),
                                                SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.pushReplacement(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        SignInScreen()));
                                                      },
                                                      child: Text(
                                                        "Click here ",
                                                        style: TextStyle(
                                                            color:
                                                                muvi_colorPrimary,
                                                            fontSize: 15),
                                                      ),
                                                    ),
                                                    Text(
                                                      "to Login",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ],
                                        )),
                                  comments.length != 0
                                      ? ListView.builder(
                                          scrollDirection: Axis.vertical,
                                          itemCount: comments.reversed.length,
                                          physics: ScrollPhysics(),
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            return Container(
                                                child: ListTile(
                                              contentPadding: EdgeInsets.all(0),
                                              leading: CircleAvatar(
                                                radius: 30.0,
                                                backgroundImage: NetworkImage(
                                                  comments[index]['user']
                                                          ['image'] ??
                                                      "https://image.winudf.com/v2/image1/Y29tLmNvZGVydWZ1cy5pbWRiYW5pbWVfc2NyZWVuXzFfMTYyNjEwNDMxMV8wNzY/screen-1.jpg?fakeurl=1&type=.jpg",
                                                ),
                                                backgroundColor:
                                                    Colors.transparent,
                                              ),
                                              title: Text(
                                                  comments[index]['user']
                                                          ['name']
                                                      .toString()
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 14)),
                                              subtitle: Text(
                                                  comments[index]['comment'],
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ));
                                          })
                                      : Container(
                                          margin: EdgeInsets.only(top: 20),
                                          padding: EdgeInsets.all(20),
                                          child: Text(
                                            "No Comments",
                                            style: TextStyle(
                                                color: Colors.white54,
                                                fontSize: 22),
                                          )),
                                  showLoadButton
                                      ? GestureDetector(
                                          onTap: () {
                                            page++;
                                            setState(() {
                                              loadMore = true;
                                            });
                                            getComments(page);
                                          },
                                          child: Container(
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                  color: Colors.black87),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    "Load More...",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  loadMore
                                                      ? Container(
                                                          height: 15,
                                                          width: 15,
                                                          child:
                                                              CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: Colors.white,
                                                          ),
                                                        )
                                                      : Container()
                                                ],
                                              )),
                                        )
                                      : Container(),
                                  SizedBox(
                                    height: 15,
                                  )
                                ],
                              ))
                        ])))
                ]))));
  }
}

class History {
  late String poster;
  late String title;
  late String episode;

  History({required this.title, required this.poster, required this.episode});

  factory History.fromJson(Map<String, dynamic> jsonData) {
    return History(
      poster: jsonData['poster'],
      episode: jsonData['episode'],
      title: jsonData['title'],
    );
  }

  static Map<String, dynamic> toMap(History data) => {
        'title': data.title,
        'poster': data.poster,
        'episode': data.episode,
      };

  static String encode(List<History> datas) => json.encode(
        datas.map<Map<String, dynamic>>((data) => History.toMap(data)).toList(),
      );

  static List<History> decode(String datas) =>
      (json.decode(datas) as List<dynamic>)
          .map<History>((item) => History.fromJson(item))
          .toList();
}
