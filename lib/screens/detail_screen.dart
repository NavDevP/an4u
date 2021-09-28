import 'dart:isolate';
import 'dart:ui';

import 'package:Anime4U/fragments/loading.dart';
import 'package:Anime4U/models/response.dart';
import 'package:Anime4U/screens/home_screen.dart';
// import 'package:Anime4U/utils/flix_data_generator.dart';
import 'package:Anime4U/resources/strings.dart';
import 'package:Anime4U/resources/colors.dart';
import 'package:Anime4U/screens/scrap_video_screen.dart';
import 'package:Anime4U/utils/date_generator.dart';
import 'package:facebook_audience_network/ad/ad_banner.dart';
import 'package:facebook_audience_network/ad/ad_interstitial.dart';
import 'package:flutter/material.dart';
import 'package:Anime4U/resources/colors.dart';
import 'package:flutter_applovin_max/banner.dart';
import 'package:flutter_applovin_max/flutter_applovin_max.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;

// import 'package:native_admob_flutter/native_admob_flutter.dart';
// import 'package:overlay_support/overlay_support.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Anime4U/integration/Api.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'flix_signin.dart';

class MovieDetailsPage extends StatelessWidget {
  MovieDetailsPage(this.movie);

  final AnimeDetail movie;

  //Declare a GlobalKey
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: muvi_appBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            MovieDetailHeader(movie),
            SizedBox(height: 20.0),
            PhotoScroller(
                movie.photoUrls,
                movie.episodes,
                movie.episodeFrom,
                movie.movieTitle,
                movie.bannerUrl,
                movie.posterUrl,
                movie.id,
                movie.totalEp,
                movie.categories,
            _scaffoldKey),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Storyline(
                  movie.storyline,
                  movie.photoUrls!.length,
                  movie.native,
                  movie.english,
                  movie.title,
                  movie.startDate,
                  movie.endDate,
                  movie.type,
                  movie.duration,
                  movie.totalEp),
            ),
            SizedBox(height: 10.0),
            ActorScroller(movie.actors),
            SizedBox(height: 50.0),
          ],
        ),
      ),
    );
  }
}

class MovieDetailHeader extends StatelessWidget {
  MovieDetailHeader(this.movie);

  final AnimeDetail movie;

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    var movieInformation = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            height: 48,
            child: Text(
              movie.movieTitle != "" ? movie.movieTitle! : movie.title!,
              overflow: TextOverflow.clip,
              maxLines: 2,
              style: TextStyle(color: Colors.white, fontSize: 18),
            )),
        RatingInformation(movie),
        SizedBox(height: 10.0),
        Row(children: [
          Expanded(
              child: Container(
                  height: 50,
                  child: ListView(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      children: <Widget>[
                        for (var i = 0; i < movie.categories!.length; i++)
                          GestureDetector(
                              child: Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: Chip(
                                    backgroundColor: muvi_colorAccent,
                                    labelPadding: EdgeInsets.all(2.0),
                                    label: Text(
                                        movie.categories![i]
                                            .toString()
                                            .toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.white,
                                        )),
//                          backgroundColor: colors[math.Random().nextInt(4)],
                                    elevation: 6.0,
                                    shadowColor: Colors.grey[60],
                                    padding: EdgeInsets.all(8.0),
                                  ))),
                      ]))),
        ]),
      ],
    );

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 160.0),
          child: ArcBannerImage(movie.bannerUrl),
        ),
        Positioned(
          bottom: 0.0,
          left: 16.0,
          right: 16.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Poster(
                movie.posterUrl,
                height: 180.0,
              ),
              SizedBox(width: 16.0),
              Expanded(child: movieInformation),
            ],
          ),
        ),
      ],
    );
  }
}

class ArcBannerImage extends StatelessWidget {
  ArcBannerImage(this.imageUrl);

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return ClipPath(
      clipper: ArcClipper(),
      child: imageUrl == null
          ? Image.asset(
        "images/muvi/images/barimage.png",
        width: screenWidth,
        height: 230.0,
        fit: BoxFit.fill,
      )
          : Image.network(
        imageUrl!,
        width: screenWidth,
        height: 230.0,
        fit: BoxFit.cover,
      ),
    );
  }
}

class ArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - 30);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstPoint = Offset(size.width / 2, size.height);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstPoint.dx, firstPoint.dy);

    var secondControlPoint = Offset(size.width - (size.width / 4), size.height);
    var secondPoint = Offset(size.width, size.height - 30);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondPoint.dx, secondPoint.dy);

    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class Poster extends StatelessWidget {
  static const POSTER_RATIO = 0.7;

  Poster(
      this.posterUrl, {
        this.height = 100.0,
      });

  final String? posterUrl;
  final double? height;

  @override
  Widget build(BuildContext context) {
    var width = POSTER_RATIO * height!;

    return Material(
      borderRadius: BorderRadius.circular(10.0),
      elevation: 8.0,
      child: Image.network(
        posterUrl!,
        fit: BoxFit.cover,
        width: width,
        height: height,
      ),
    );
  }
}

class RatingInformation extends StatefulWidget {
  RatingInformation(this.movie);

  final AnimeDetail movie;

  @override
  RatingInformationState createState() => RatingInformationState();
}

class RatingInformationState extends State<RatingInformation> {
  Widget _buildRatingBar(ThemeData theme) {
    var stars = <Widget>[];

    for (var i = 1; i <= 5; i++) {
      var color =
      i <= widget.movie.starRating! ? muvi_colorAccent : Colors.white30;
      var star = Icon(
        Icons.star,
        color: color,
      );

      stars.add(star);
    }

    return Row(children: stars);
  }

  bool isFavAdded = false;
  bool isLog = false;
  List<Favourite> favList = [];

//  var numericRating = Column(
//    crossAxisAlignment: CrossAxisAlignment.start,
//    mainAxisAlignment: MainAxisAlignment.spaceBetween,
//    children: [
//      Text(
//        widget.movie.rating.toString(),
//        style: textTheme.title.copyWith(
//          fontWeight: FontWeight.w400,
//          color: muvi_colorAccent,
//        ),
//      ),
//      SizedBox(height: 4.0),
//      Text(
//        'Ratings',
//        style: ratingCaptionStyle,
//      ),
//    ],
//  );

  void isLoged() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.containsKey('_apiToken')) {
      setState(() {
        isLog = true;
      });
    }
  }

  void initState() {
    isLoged();
    getFav(widget.movie.link!);
    super.initState();
  }

  Future getFav(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // print(prefs.getString('_apiToken'));
    final response = await http.post(Uri.parse(ApiUrl.OurApi + "check_favourite_new?link=$name"),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ${prefs.getString('_apiToken')}'
        });
    print(response.body);
    if (response.statusCode == 200) {
      if (response.body == "1") {
        setState(() {
          isFavAdded = true;
        });
      } else {
        setState(() {
          isFavAdded = false;
        });
      }
    }
  }

//  var starRating = Column(

  void _addFav(String name, String image,String link) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.post(
        Uri.parse(ApiUrl.OurApi + "add_favourite_new?name=$name&image=$image&link=$link"),
        headers: {
          HttpHeaders.authorizationHeader:
          'Bearer ${prefs.getString('_apiToken')}'
        });
    // print(response.body);
    if (response.statusCode == 200) {
      setState(() {
        isFavAdded = !isFavAdded;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    var ratingCaptionStyle = textTheme.caption!.copyWith(color: Colors.white54);

//    return Row(
//      children: [
//        numericRating,s
//        starRating,
//      ],
//    );
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              border: Border.all(color: muvi_colorPrimary),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Text(
            widget.movie.type!,
            style: TextStyle(color: Colors.white, fontSize: 17),
          )),
      SizedBox(
        width: 20,
      ),
      isLog != false
          ? GestureDetector(
          onTap: () {
            _addFav(widget.movie.title!, widget.movie.posterUrl!,widget.movie.link!);
            final snackBar = new SnackBar(
                content: new Text("Removed From Favorite"),
                backgroundColor: selected_number);
            final snackBar2 = new SnackBar(
                content: new Text("Added to Favorites"),
                backgroundColor: selected_number);
            isFavAdded
                ? Scaffold.of(context).showSnackBar(snackBar)
                : Scaffold.of(context).showSnackBar(snackBar2);
          },
          child: Container(
              margin: EdgeInsets.only(right: 20),
              child: isFavAdded
                  ? Icon(
                Icons.favorite,
                color: Colors.red,
                size: 40,
              )
                  : Icon(
                Icons.favorite_border,
                color: Colors.white,
                size: 40,
              )))
          : Container()
    ]);
  }
}

class Storyline extends StatefulWidget {
  Storyline(
      this.storyline,
      this.episodes,
      this.native,
      this.english,
      this.romaji,
      this.startD,
      this.endD,
      this.type,
      this.duration,
      this.count);

  final String? storyline;
  final int? episodes;
  final String? native;
  final String? english;
  final String? romaji;
  final String? startD;
  final String? endD;
  final String? type;
  final int? duration;
  final int? count;

  @override
  StorylineState createState() => StorylineState();
}

class StorylineState extends State<Storyline> {
  bool isSynopsHide = true;
  bool isLogged = true, disableAdforUser = false;

  void isLog() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.containsKey('_apiToken')) {
      setState(() {
        isLogged = false;
      });
    }
  }

  double adHeight = 0;

  // final bannerController = BannerAdController();
  //
  // void loadAd() async{
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   if(prefs.containsKey('ad_status')){
  //     if(prefs.getInt('ad_status') == 1) {
  //       bannerController.onEvent.listen((e) {
  //         final event = e.keys.first;
  //         // final info = e.values.first;
  //         switch (event) {
  //           case BannerAdEvent.loaded:
  //           // setState(() => _bannerAdHeight = (info as int)?.toDouble());
  //             break;
  //           default:
  //             break;
  //         }
  //       });
  //       bannerController.load();
  //     }
  //   } else{
  //     bannerController.onEvent.listen((e) {
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
  //     bannerController.load();
  //   }
  // }
  //
  // final bannerController2 = BannerAdController();

  // void loadAd2() async{
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   if(prefs.containsKey('ad_status')){
  //     if(prefs.getInt('ad_status') == 1) {
  //       bannerController2.onEvent.listen((e) {
  //         final event = e.keys.first;
  //         // final info = e.values.first;
  //         switch (event) {
  //           case BannerAdEvent.loaded:
  //           // setState(() => _bannerAdHeight = (info as int)?.toDouble());
  //             break;
  //           default:
  //             break;
  //         }
  //       });
  //       bannerController2.load();
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
  //   }
  // }

  @override
  void initState() {
    isLog();
    // TODO: implement initState
    super.initState();
    checkUser();
    // loadAd();
    // loadAd2();
  }

  void checkUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('ad_status')) {
      if (prefs.getInt('ad_status') == 1) {
        setState(() {
          disableAdforUser = true;
        });
      } else {
        setState(() {
          disableAdforUser = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = Theme.of(context).textTheme;
    var width = MediaQuery.of(context).size.width;


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // isLogged ?
        // Container(
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.start,
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children:[
        //     Text("Login to Sync",style: TextStyle(color: Colors.white, fontSize: 18),),
        //     SizedBox(height: 10,),
        //     Container(
        //         margin: EdgeInsets.all(10),
        //       child: Stack(children: [
        //     Container(
        //       width: width / 2.2,
        //         padding: EdgeInsets.all(14),
        //         margin: EdgeInsets.only(top:5),
        //         alignment: Alignment.centerRight,
        //         color: Color(0xff00324A),
        //         child: Text(
        //           "Sync Anilist",
        //           style: TextStyle(color: Colors.white, fontSize: 18),
        //         )),
        //     Container(
        //         width: 60,
        //         alignment: Alignment.centerLeft,
        //         decoration: BoxDecoration(
        //             boxShadow: [BoxShadow(
        //               color: Colors.grey,
        //               blurRadius: 5.0,
        //             ),]
        //         ),
        //         child: Image.network(
        //           "https://anilist.co/img/icons/android-chrome-512x512.png",
        //         ))
        //   ]))
        //   ])
        // ):Container(),
        Container(
          alignment: Alignment(0.5, 1),
          child: BannerMaxView((AppLovinAdListener? event) => print(event), BannerAdSize.banner, "55df996a4f267ec4"),
        ),
        Text(
          'Synopsis',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        SizedBox(height: 8.0),
        Container(
            child: Stack(children: [
              isSynopsHide
                  ? GestureDetector(
                  onTap: () {
                    setState(() {
                      isSynopsHide = !isSynopsHide;
                    });
                  },
                  child: Container(
                    height: 150,
                    width: width,
                    child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 50,
                        color: Colors.black.withOpacity(0.5),
                        child: Padding(
                            padding: EdgeInsets.all(20),
                            child: HtmlWidget(
                                widget.storyline != null
                                    ? widget.storyline!
                                    : "No Synopsis",
                                textStyle: TextStyle(
                                    fontSize: 14, color: Colors.white38)))),
                  ))
                  : Container(
                width: MediaQuery.of(context).size.width,
                child: Column(children: [
                  Container(
                      width: width,
                      child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 50,
                          color: Colors.black.withOpacity(0.5),
                          child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    HtmlWidget(
                                        widget.storyline != null
                                            ? widget.storyline!
                                            : "No Synopsis",
                                        textStyle: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white54)),
                                  ])))),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 50,
                          color: Colors.black.withOpacity(0.5),
                          child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Anime Details",
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Text("Episodes:",
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      widget.count.toString(),
                                      style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 14),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text("Romaji:",
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    Text(
                                      widget.romaji!,
                                      style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 14),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text("Japanese:",
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    Text(
                                      widget.native!,
                                      style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 14),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text("English:",
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    Text(
                                      widget.english ?? "...",
                                      style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 14),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text("Start Date:",
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      widget.endD != null
                                          ? jsonDecode(
                                          widget.endD!)['year'] !=
                                          null
                                          ? jsonDecode(widget.startD!)[
                                      'day']
                                          .toString() +
                                          "-" +
                                          jsonDecode(widget.startD!)[
                                          'month']
                                              .toString() +
                                          "-" +
                                          jsonDecode(widget.startD!)[
                                          'year']
                                              .toString()
                                          : "..."
                                          : "...",
                                      style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 14),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text("End Date:",
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    Text(
                                      widget.endD != null
                                          ? jsonDecode(
                                          widget.endD!)['year'] !=
                                          null
                                          ? jsonDecode(
                                          widget.endD!)['day']
                                          .toString() +
                                          "-" +
                                          jsonDecode(widget.endD!)[
                                          'month']
                                              .toString() +
                                          "-" +
                                          jsonDecode(widget.endD!)[
                                          'year']
                                              .toString()
                                          : "Not Ended"
                                          : "Not Ended",
                                      style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 14),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text("Type:",
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    Text(
                                      widget.type!,
                                      style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 14),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text("Duration:",
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    Text(
                                      widget.duration != null
                                          ? widget.duration.toString() +
                                          " Minutes"
                                          : "...",
                                      style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 14),
                                    ),
                                  ]))))
                ]),
              ),
              Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Container(
                    width: 80,
//                color: Colors.black.withOpacity(0.5),
                    height: 50,
                  )),
              Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isSynopsHide = !isSynopsHide;
                        });
                      },
                      child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  elevation: 30,
                                  child: Icon(
                                    isSynopsHide
                                        ? Icons.keyboard_arrow_down
                                        : Icons.keyboard_arrow_up,
                                    size: 35.0,
                                    color: muvi_colorAccent,
                                  )),
                            ],
                          )))),
            ])),
        SizedBox(height: 14.0),
        Container(
          alignment: Alignment(0.5, 1),
          child: BannerMaxView((AppLovinAdListener? event) => print(event), BannerAdSize.banner, "9e0563324ca99c68"),
        ),
      ],
    );
  }
}

class PhotoScroller extends StatefulWidget {
  PhotoScroller(this.photoUrls,this.episodes, this.ep, this.Atitle, this.banner, this.poster,
      this.animeId, this.count, this.genre,this.scaffoldKey);

  final List<dynamic>? photoUrls;
  final List<dynamic>? episodes;
  final int? ep;
  final int? animeId;
  final int? count;
  final String? Atitle;
  final String? banner;
  final String? poster;
  final List? genre;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  PhotoScrollerState createState() => PhotoScrollerState();
}

class PhotoScrollerState extends State<PhotoScroller> {
  // var dio = Dio();
  var servers = [];
  var downloads = [];
  late Future _fetchServers;
  var dataHistory;
  late Directory directory;
  int downloadProgress = 0;

  //Declare a GlobalKey
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future _downloadHistory = Future.value([]);
  List<Download> downList = [];
  bool _contains = false;
  double downloaded = 0;
  bool updateDownloaded=false;
  // ReceivePort _port = ReceivePort();

//   void showDownloadProgress(received, total) {
//     if (total != -1) {
//       setState(() {
//         downloaded = double.parse((received / total * 100).toStringAsFixed(0));
//         if(downloaded == 100.0){
//           updateDownloaded = true;
//         }
//       });
//       print((received / total * 100).toStringAsFixed(0) + "%");
//     }
//   }
//
//   static void downloadCallback(received, total) {
//     final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
//     send!.send([double.parse((received / total * 100).toStringAsFixed(0)), total]);
//   }
//
//   void _bindBackgroundIsolate() {
//     IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
//   }
//
//   Future download(Dio dio, String url, String savePath) async {
//     try {
//       Response response = await dio.get(
//         url,
//         cancelToken: cancelToken,
//         onReceiveProgress: downloadCallback,
//         //Received data with List<int>
//         options: Options(
//             responseType: ResponseType.bytes,
//             followRedirects: false,
//             validateStatus: (status) {
//               return status! < 500;
//             }),
//       );
//       // print(response.headers);
//       File file = File(savePath);
//       var raf = file.openSync(mode: FileMode.write);
//       // response.data is List<int> type
//       raf.writeFromSync(response.data);
//       await raf.close();
//
//     } catch (e) {
//       print(e);
//     }
//   }
//
//   void downloadVideo(link, name, index, context) async {
//     print(link);
//     if (downloads.isNotEmpty) {
//       _showAlertAlreadyFirstDownload(context);
//     } else {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       if (prefs.getString('name') == null) {
//         _showAlertDownload(context);
//       } else {
//         if (prefs.getInt('download') == 1) {
//           final status = await Permission.storage.request();
//           if (status.isGranted) {
//             final storage = await getExternalStorageDirectory();
//             String formatedName = name+".mp4";
//             print(storage!.path + '/Download/${formatedName}');
//             download(dio,link,storage.path + '/Download/${formatedName}');
//             if (prefs.containsKey("downloadHistory")) {
//               List<Download> main =
//               Download.decode(prefs.getString("downloadHistory")!);
//               main.add(Download(
//                   cancelToken: cancelToken,
//                   title: name,
//                   poster: widget.poster,
//                   video: formatedName,
//                   index: index.toString(),
//                   completed: 0));
//               final String encodedData = Download.encode(main);
//               prefs.setString("downloadHistory", encodedData);
//
//               final snackBar = new SnackBar(
//                   content: new Text(
//                     "Download Started",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                   backgroundColor: muvi_colorPrimaryDark);
//               widget.scaffoldKey.currentState!.showSnackBar(snackBar);
//             }
//             else{
//               downList.add(Download(
//                   cancelToken: cancelToken,
//                   title: name,
//                   poster: widget.poster,
//                   video: formatedName,
//                   index: index.toString(),
//                   completed: 0));
//               final String encodedData = Download.encode(downList);
//               prefs.setString("downloadHistory", encodedData);
//             }
//           }
//         } else {
//           if (prefs.getInt('userDownload') != null) {
//             if (prefs.getInt('userDownload') == 1) {
//               var status = await Permission.storage.status;
//               if (!status.isGranted) {
//                 await Permission.storage.request();
//               } else {
//                 Directory directory;
//                 try {
//                   if (Platform.isAndroid) {
//                     directory = (await getExternalStorageDirectory())!;
//                     String newPath = "";
// //                    print(directory);
//                     newPath = directory.path + "/Download";
//                     directory = Directory(newPath);
//
//                     if (!await directory.exists()) {
//                       await directory.create(recursive: true);
//                     }
//                     if (await directory.exists()) {
// //        File saveFile = File(directory.path);
//                       SharedPreferences prefs =
//                       await SharedPreferences.getInstance();
//
//                       if (prefs.containsKey("downloadHistory")) {
//                         List<Download> main =
//                         Download.decode(prefs.getString("downloadHistory")!);
//                         var product = main.firstWhere(
//                                 (product) =>
//                             product.video ==
//                                 name.toString().replaceAll(
//                                     new RegExp(r'[^\w\s]+'), "_") +
//                                     "_" +
//                                     index.toString() +
//                                     ".mp4",
//                             orElse: () => Download());
//
//                         if (product == null) {
//                           final taskId = await FlutterDownloader.enqueue(
//                             url: link,
//                             fileName: name
//                                 .toString()
//                                 .replaceAll(new RegExp(r'[^\w\s]+'), "_") +
//                                 "_" +
//                                 index.toString() +
//                                 ".mp4",
//                             savedDir: directory.path,
//                             showNotification: true,
//                             // show download progress in status bar (for Android)
//                             openFileFromNotification:
//                             true, // click on notification to open downloaded file (for Android)
//                           );
//                           main.add(Download(
//                               taskId: taskId,
//                               title: name,
//                               poster: widget.poster,
//                               video: name
//                                   .toString()
//                                   .replaceAll(new RegExp(r'[^\w\s]+'), "_") +
//                                   "_" +
//                                   index.toString() +
//                                   ".mp4",
//                               index: index.toString(),
//                               completed: 0));
//                           final String encodedData = Download.encode(main);
//                           prefs.setString("downloadHistory", encodedData);
//
//                           _downloadHistory = getDownload();
//                           final snackBar = new SnackBar(
//                               content: new Text(
//                                 "Download Started",
//                                 style: TextStyle(color: Colors.white),
//                               ),
//                               backgroundColor: muvi_colorPrimaryDark);
//                           widget.scaffoldKey.currentState!.showSnackBar(snackBar);
//                         } else {
//                           _showAlertAlreadyDownload(context);
//                         }
//                       } else {
//                         final taskId = await FlutterDownloader.enqueue(
//                           url: link,
//                           fileName: name
//                               .toString()
//                               .replaceAll(new RegExp(r'[^\w\s]+'), "_") +
//                               "_" +
//                               index.toString() +
//                               ".mp4",
//                           savedDir: directory.path,
//                           showNotification: true,
//                           // show download progress in status bar (for Android)
//                           openFileFromNotification:
//                           true, // click on notification to open downloaded file (for Android)
//                         );
//                         downList.add(Download(
//                             taskId: taskId,
//                             title: name,
//                             poster: widget.poster,
//                             video: name
//                                 .toString()
//                                 .replaceAll(new RegExp(r'[^\w\s]+'), "_") +
//                                 "_" +
//                                 index.toString() +
//                                 ".mp4",
//                             index: index.toString(),
//                             completed: 0));
//                         final String encodedData = Download.encode(downList);
//                         prefs.setString("downloadHistory", encodedData);
//
//                         _downloadHistory = getDownload();
//                         final snackBar = new SnackBar(
//                             content: new Text(
//                               "Download Started",
//                               style: TextStyle(color: Colors.white),
//                             ),
//                             backgroundColor: muvi_colorPrimaryDark);
//                         Scaffold.of(context).showSnackBar(snackBar);
//                       }
//                     }
//
//                   }
//                 } catch (e) {
//                   print(e);
//                 }
//               }
//             } else {
//               _showAlertDownloadNot(context);
//             }
//           }
//           else {
//             _showAlertDownloadNot(context);
//           }
//         }
//       }
//     }
//   }
//
//   Future getDownload() async {
//     List<Download> DataMain = [];
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     var list;
//     if (prefs.containsKey("downloadHistory")) {
//       setState(() {
//         _contains = true;
//       });
//       list = jsonDecode(prefs.getString('downloadHistory')!);
//     }
//     return list.reversed.toList();
//   }
//
//   void _showAlertAlreadyDownload(BuildContext context) {
//     showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           backgroundColor: muvi_appBackground,
//           title: Text(
//             "Episode Already Downloaded!",
//             style: TextStyle(color: Colors.white),
//           ),
//           content: Text(
//             "This Episode is Already Downloaded.\n Click the button to view Downloads",
//             style: TextStyle(color: Colors.white),
//           ),
//           actions: [
//             FlatButton(
//               child: Text("View Downloads",style: TextStyle(color: selected_number),),
//               onPressed: () async {
//
//                 Navigator.pop(context);
//               },
//             ),
//           ],
//         ));
//   }
//
//   void _showAlertDownload(BuildContext context) {
//     showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           backgroundColor: muvi_appBackground,
//           title: Text(
//             "Login Now to Download",
//             style: TextStyle(color: Colors.white),
//           ),
//           content: Text(
//             "An Account is needed to Download Video and Watch Offline",
//             style: TextStyle(color: Colors.white),
//           ),
//           actions: [
//             FlatButton(
//               child: Text(
//                 "Login Now",
//                 style: TextStyle(color: selected_number, fontSize: 16),
//               ),
//               onPressed: () async {
//                 Navigator.of(context).push(MaterialPageRoute(
//                     builder: (context) => SignInScreen()));
//               },
//             ),
//           ],
//         ));
//   }
//
//   void _showAlertAlreadyFirstDownload(BuildContext context) {
//     showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           backgroundColor: muvi_appBackground,
//           title: Text(
//             "No able to Download!",
//             style: TextStyle(color: Colors.white),
//           ),
//           content: Text(
//             "Finish Previous Download First and then start new One!",
//             style: TextStyle(color: Colors.white),
//           ),
//           actions: [
//             FlatButton(
//               child: Text(
//                 "OK",
//                 style: TextStyle(color: selected_number),
//               ),
//               onPressed: () async {
//                 Navigator.pop(context);
//               },
//             ),
//           ],
//         ));
//   }
//
//   void _showAlertDownloadNot(BuildContext context) {
//     showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           backgroundColor: muvi_appBackground,
//           title: Text(
//             "Important Information!",
//             style: TextStyle(color: Colors.white),
//           ),
//           content: Text(
//             "Now Download Option is only Available for Donors. Donate Now to Get the Download Option.",
//             style: TextStyle(color: Colors.white),
//           ),
//           actions: [
//             FlatButton(
//               child: Text(
//                 "Cancel",
//                 style: TextStyle(color: selected_number),
//               ),
//               onPressed: () async {
//                 Navigator.pop(context);
//               },
//             ),
//             FlatButton(
//               child: Text(
//                 "Donate Now",
//                 style: TextStyle(color: selected_number),
//               ),
//               onPressed: () async {
//                 const url = "https://imdbanime.com/donate-us";
//                 if (await canLaunch(url))
//                   await launch(url);
//                 else
//                   throw "Could not launch $url";
//               },
//             ),
//           ],
//         ));
//   }
//
//
//   Future getServers(name, episode) async {
//     PackageInfo packageInfo = await PackageInfo.fromPlatform();
//     String version = packageInfo.version;
//     String finalV = version.replaceAll('.', '');
//     final response = await http.get(Uri.parse(ApiUrl.Googl + 'v' + finalV + "/getServer.php?title=${name}"));
//     var urls = [];
//     if (response.statusCode == 200) {
//       var data = jsonDecode(response.body);
//       for (var i = 0; i < data['data'].length; i++) {
//         servers.add({
//           'name': data['data'][i]['name'],
//           'url': data['data'][i]['url'],
//         });
//       }
//       return servers;
//     }
//   }

  void _modalBottomSheetMenu(BuildContext context, String aTitle, String fT,
      String poster, int? length,String link) {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return new Container(
              height: 150.0,
              color: Colors.transparent,
              //could change this to Color(0xFF737373),
              //so you don't have to change MaterialApp canvasColor
              child: new Container(
                  decoration: new BoxDecoration(
                    color: muvi_appBackground,
                    border: Border.all(color: muvi_appBackground),
//                    borderRadius: new BorderRadius.only(
//                        topLeft: const Radius.circular(10.0),
//                        topRight: const Radius.circular(10.0))
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 50,
                        ),
                        Center(
                            child: Container(
                                padding: EdgeInsets.only(left: 30, right: 30),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    GestureDetector(
                                        onTap: () async {
                                          // _fetchServers = getServers(link, fT);
                                          // _modalBottomSelectQuality(context,link, fT);
                                          // if (await canLaunch("https://imdbanime.com/anime-details.php?anime=${widget.Atitle}&download=1"))
                                            await launch("https://imdbanime.com/anime-details.php?anime=${widget.Atitle}&download=1");
                                          // else
                                            // can't launch url, there is some error
                                            // throw "Could not launch";
                                        },
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                                  2.4,
                                              padding: EdgeInsets.only(
                                                  top: 25,
                                                  bottom: 25,
                                                  left: 20,
                                                  right: 20),
                                              decoration: BoxDecoration(
                                                  color: muvi_colorPrimary,
                                                  borderRadius:
                                                  BorderRadius.all(
                                                      Radius.circular(20))),
                                              child: Center(
                                                child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
                                                    children: [
                                                      Icon(
                                                        Icons.file_download,
                                                        color: Colors.white,
                                                        size: 26,
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text(
                                                        "Download",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16),
                                                      )
                                                    ]),
                                              ),
                                            ),
                                            // Container(
                                            //   alignment: Alignment.topRight,
                                            //   padding: EdgeInsets.all(3),
                                            //   decoration: BoxDecoration(
                                            //       color: muvi_appBackground.withOpacity(0.8),
                                            //       borderRadius: BorderRadius.only(bottomRight: Radius.circular(10))),
                                            //   child: Center(
                                            //     child: Row(
                                            //         mainAxisAlignment:
                                            //         MainAxisAlignment.end,
                                            //         children: [
                                            //           SizedBox(height: 20,),
                                            //           Text(
                                            //             "Coming Soon",
                                            //             style: TextStyle(
                                            //                 color: Colors.white,
                                            //                 fontSize: 14),
                                            //           )
                                            //         ]),
                                            //   ),
                                            // )
                                          ],
                                        )),
                                    GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ScrapVideo(
                                                          aTitle,
                                                          link,
                                                          fT,
                                                          widget.poster!,
                                                          widget.animeId!,
                                                          length!,
                                                          widget.genre)));
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context)
                                              .size
                                              .width /
                                              2.4,
                                          padding: EdgeInsets.only(
                                              top: 25,
                                              bottom: 25,
                                              left: 20,
                                              right: 20),
                                          decoration: BoxDecoration(
                                              color: muvi_colorPrimary,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20))),
                                          child: Center(
                                              child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.videocam,
                                                      color: Colors.white,
                                                      size: 26,
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      "Stream",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 18),
                                                    )
                                                  ])),
                                        ))
                                  ],
                                )))
                      ])));
        });
  }

  void _modalBottomSheetEpisode() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (builder) {
          return new Container(
              height: MediaQuery.of(context).size.height / 1.2,
              decoration: new BoxDecoration(
                  color: muvi_appBackground,
                  border: Border.all(color: muvi_appBackground),
                  borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(20.0),
                      topRight: const Radius.circular(20.0))),
              //could change this to Color(0xFF737373),
              //so you don't have to change MaterialApp canvasColor
              child: widget.count != 0
                  ? Container(
                  margin: EdgeInsets.only(top: 20),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2),
                    itemCount: widget.count,
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    padding: const EdgeInsets.only(top: 8.0, left: 20.0),
                    itemBuilder: _buildPhotoBottom,
                  ))
                  : Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(20),
                child: Center(
                    child: Text(
                      "No Episodes Currently!",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    )),
              ));
        });
  }

//   void _modalBottomSelectQuality(BuildContext context, String title, String ep) {
//     showModalBottomSheet(
//         context: context,
//         builder: (builder) {
//           return new Container(
//               height: 200.0,
//               color: Colors.transparent,
//               //could change this to Color(0xFF737373),
//               //so you don't have to change MaterialApp canvasColor
//               child: new Container(
//                   decoration: new BoxDecoration(
//                     color: muvi_appBackground,
//                     border: Border.all(color: muvi_appBackground),
// //                    borderRadius: new BorderRadius.only(
// //                        topLeft: const Radius.circular(10.0),
// //                        topRight: const Radius.circular(10.0))
//                   ),
//                   child: Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: <Widget>[
//                         Container(
//                             padding: EdgeInsets.all(10),
//                             child: Text(
//                               "Select Quality",
//                               style:
//                               TextStyle(color: Colors.white, fontSize: 20),
//                             )),
//                         SizedBox(
//                           height: 20,
//                         ),
//                         Center(
//                             child: Container(
//                                 padding: EdgeInsets.only(left: 30, right: 30),
//                                 child: Container(
//                                   width: MediaQuery.of(context).size.width,
//                                   margin: EdgeInsets.only(top: 10),
//                                   child: FutureBuilder(
//                                       future: _fetchServers,
//                                       builder: (BuildContext context,
//                                           AsyncSnapshot snapshot) {
//                                         if (snapshot.hasData) {
//                                           if (servers[0]['noserver'] == 1) {
//                                             return Container(
//                                                 child: Center(
//                                                     child: Text(
//                                                       "No Server Available",
//                                                       style: TextStyle(
//                                                           color: Colors.white,
//                                                           fontSize: 18),
//                                                     )));
//                                           } else {
//                                             return SingleChildScrollView(
//                                                 child: Row(
//                                                     mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .center,
//                                                     children: [
//                                                       for (var v = 0;
//                                                       v <
//                                                           servers[0]['url']
//                                                               .length;
//                                                       v++)
//                                                         GestureDetector(
//                                                             onTap: () {
//                                                               downloadVideo(
//                                                                   servers[0]['url']
//                                                                       [v]['file'],
//                                                                   title,
//                                                                   ep,
//                                                                 context);
//                                                               Navigator.pop(
//                                                                   context);
//                                                               Navigator.pop(
//                                                                   context);
//                                                             },
//                                                             child: Padding(
//                                                                 padding:
//                                                                 EdgeInsets.only(
//                                                                     right: 15),
//                                                                 child: Chip(
//                                                                   labelPadding:
//                                                                   EdgeInsets.only(
//                                                                       left: 6.0,
//                                                                       right:
//                                                                       7.0),
//                                                                   label: Text(
//                                                                     servers[0]['url']
//                                                                     [v]
//                                                                     ['quality'],
//                                                                     style:
//                                                                     TextStyle(
//                                                                       color: Colors
//                                                                           .white,
//                                                                     ),
//                                                                   ),
//                                                                   backgroundColor:
//                                                                   muvi_colorAccent,
//                                                                   elevation: 6.0,
//                                                                   shadowColor:
//                                                                   Colors
//                                                                       .grey[60],
//                                                                   padding:
//                                                                   EdgeInsets
//                                                                       .all(
//                                                                       10.0),
//                                                                 ))),
//                                                     ]));
//                                           }
//                                         }
//                                         return Container(
//                                             child: Center(
//                                                 child:
//                                                 CircularProgressIndicator()));
//                                       }),
//                                 )))
//                       ])));
//         });
//   }

  void downloadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('downloadHistory')) {
      setState(() {
        dataHistory = prefs.getString('downloadHistory');
      });
    }
  }

  Widget _buildPhoto(BuildContext context, int index) {
    var photo;
    var fTitle;
    var Ft;
    var link;
    bool isDownload = false;
    print(widget.photoUrls);
    if (widget.ep == 1) {
      link = widget.episodes![index]['id'];
      photo = "images/muvi/images/episodeback.png";
      fTitle = "";
      Ft = (index + 1).toString();
    } else {
      link = widget.episodes![index]['id'];
      if (widget.photoUrls!.length <= index) {
        photo = "images/muvi/images/episodeback.png";
        fTitle = "";
        Ft = (index + 1).toString();
      } else {
        photo = widget.photoUrls![index]["thumbnail"];
        var title = widget.photoUrls![index]["title"];
        if (title.toString().contains('-')) {
          fTitle = title.toString().split("-");
          Ft = fTitle[0].toString().split(" ")[1];
          Ft = Ft.toString().split(".")[0];
        } else {
          fTitle = title;
          Ft = fTitle.toString().split(" ")[1];
        }
        // Ft = fTitle[0].toString().split(" ")[1];
        // Ft = Ft.toString().split(".")[0];
        Ft = (index + 1).toString();
      }
    }
    return Container(
      padding: const EdgeInsets.only(right: 16.0),
      child: GestureDetector(
          onTap: () {
            _modalBottomSheetMenu(context, widget.Atitle!, Ft, widget.poster!, widget.count,link);
           // Navigator.push(
           //     context,
           //     MaterialPageRoute(
           //         builder: (context) =>
           //             ScrapVideo(widget.Atitle, Ft,widget.poster)));
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: Stack(children: [
              Container(
                width: 200,
                height: 180,
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    image: DecorationImage(
                      colorFilter: new ColorFilter.mode(
                          Colors.black.withOpacity(0.5), BlendMode.dstATop),
                      fit: BoxFit.cover,
                      image: (fTitle == ""
                          ? AssetImage(photo)
                          : NetworkImage(photo == null
                          ? "images/muvi/images/barimage.png"
                          : photo) as ImageProvider),
                    )),
              ),
              Container(
                alignment: Alignment.bottomLeft,
                child: Container(
                  padding: EdgeInsets.all(10),
                  width: 200,
                  child: Text(
                    fTitle == ""
                        ? ""
                        : fTitle[1] != null
                        ? fTitle[1]
                        : fTitle[0],
                    style: TextStyle(color: Colors.white),
                    maxLines: 2,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.all(10),
                  width: 200,
                  child: Center(
                      child: Text(
                        Ft,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      )),
                ),
              ),
              isDownload
                  ? Container(
                alignment: Alignment.topRight,
                child: Container(
                    color: muvi_colorPrimary,
                    padding: EdgeInsets.all(5),
                    child: Icon(
                      Icons.file_download,
                      color: Colors.white,
                    )),
              )
                  : Container()
            ]),
          )),
    );
  }

  Widget _buildPhotoBottom(BuildContext context, int index) {
    var photo;
    var fTitle;
    var Ft;
    var link;
    bool isDownload = false;
    if (widget.ep == 1) {
      link = widget.episodes![index]['id'];
      photo = "images/muvi/images/episodeback.png";
      fTitle = "";
      Ft = (index + 1).toString();
    } else {
      link = widget.episodes![index]['id'];
      if (widget.photoUrls!.length <= index) {
        photo = "images/muvi/images/episodeback.png";
        fTitle = "";
        Ft = (index + 1).toString();
      } else {
        photo = widget.photoUrls![index]["thumbnail"];
        var title = widget.photoUrls![index]["title"];
        if (title.toString().contains('-')) {
          fTitle = title.toString().split("-");
          Ft = fTitle[0].toString().split(" ")[1];
          Ft = Ft.toString().split(".")[0];
        } else {
          fTitle = title;
          Ft = fTitle.toString().split(" ")[1];
        }
        // Ft = fTitle[0].toString().split(" ")[1];
        // Ft = Ft.toString().split(".")[0];
        Ft = (index + 1).toString();
      }
    }

    return Container(
      padding: const EdgeInsets.only(right: 16.0),
      child: GestureDetector(
          onTap: () {
            _modalBottomSheetMenu(
                context, widget.Atitle!, Ft, widget.poster!, widget.count,link);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: Stack(children: [
              Container(
                width: 200,
                height: 180,
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    image: DecorationImage(
                      colorFilter: new ColorFilter.mode(
                          Colors.black.withOpacity(0.5), BlendMode.dstATop),
                      fit: BoxFit.cover,
                      image: (fTitle == ""
                          ? AssetImage(photo)
                          : NetworkImage(photo == null
                          ? "images/muvi/images/barimage.png"
                          : photo) as ImageProvider),
                    )),
              ),
              Container(
                alignment: Alignment.bottomLeft,
                child: Container(
                  padding: EdgeInsets.all(20),
                  width: 200,
                  child: Text(
                    fTitle == "" ? "" : fTitle[1],
                    style: TextStyle(color: Colors.white),
                    maxLines: 1,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.all(20),
                  width: 200,
                  child: Center(
                      child: Text(
                        Ft,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      )),
                ),
              ),
              isDownload
                  ? Container(
                alignment: Alignment.topRight,
                child: Container(
                    color: muvi_colorPrimary,
                    padding: EdgeInsets.all(5),
                    child: Icon(
                      Icons.file_download,
                      color: Colors.white,
                    )),
              )
                  : Container()
            ]),
          )),
    );
  }

  void initState() {
    super.initState();
    downloadData();
  }

  @override
  Widget build(BuildContext mainContext) {
    var textTheme = Theme.of(mainContext).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 5.0),
                  child: Text(
                    'Episodes:',
                    style: textTheme.subhead!
                        .copyWith(fontSize: 18.0, color: Colors.white),
                  ),
                ),
                widget.count != 0
                    ? Container(
                    padding: EdgeInsets.only(left: 5, right: 5),
                    decoration: BoxDecoration(
                      color: muvi_colorPrimaryDark,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Text(
                      widget.count.toString(),
                      style: textTheme.subhead!
                          .copyWith(fontSize: 17.0, color: Colors.white),
                    ))
                    : Container(),
              ],
            ),
            widget.count != 0
                ? GestureDetector(
                onTap: () {
                  _modalBottomSheetEpisode();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'VIEW ALL',
                    style: textTheme.subhead!
                        .copyWith(fontSize: 14.0, color: Colors.white),
                  ),
                ))
                : Container(),
          ],
        ),
        widget.count != 0
            ? Container(
            child: SizedBox.fromSize(
              size: const Size.fromHeight(130.0),
              child: ListView.builder(
                itemCount: widget.count,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                padding: const EdgeInsets.only(top: 8.0, left: 20.0),
                itemBuilder: _buildPhoto,
              ),
            ))
            : Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(20),
          child: Center(
              child: Text(
                "No Episodes Currently!",
                style: TextStyle(color: Colors.white, fontSize: 20),
              )),
        )
      ],
    );
  }
}

class ActorScroller extends StatefulWidget {
  ActorScroller(this.actors);

  final List<Actor> actors;

  @override
  ActorScrollerState createState() => ActorScrollerState();
}

class ActorScrollerState extends State<ActorScroller> {
  //

  void initState() {
    super.initState();
    // loadAd();
  }

  Widget _buildActor(BuildContext ctx, int index) {
    var actor = widget.actors[index];

    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(actor.avatarUrl!),
            radius: 40.0,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              actor.name!,
              style: TextStyle(color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(
              actor.role!,
              style: TextStyle(
                  color: muvi_colorAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return widget.actors.length != 0
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Characters',
            style: textTheme.subtitle1!
                .copyWith(color: Colors.white, fontSize: 18.0),
          ),
        ),
        SizedBox.fromSize(
          size: const Size.fromHeight(160.0),
          child: ListView.builder(
            itemCount: widget.actors.length,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(top: 12.0, left: 20.0),
            itemBuilder: _buildActor,
          ),
        ),
      ],
    )
        : Container();
  }
}

