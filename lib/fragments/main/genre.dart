import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:Anime4U/fragments/see_more.dart';
import 'package:Anime4U/integration/Api.dart';
import 'package:Anime4U/models/response.dart';
import 'package:Anime4U/resources/colors.dart';
import 'package:Anime4U/resources/size.dart';
import 'package:Anime4U/screens/flix_signin.dart';
import 'package:Anime4U/screens/watch_video_screen.dart';
import 'package:Anime4U/utils/app_widgets.dart';
import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Anime4U/utils/widget_extensions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class GenreFragment extends StatefulWidget {
  @override
  GenreFragmentState createState() => GenreFragmentState();
}

class GenreFragmentState extends State<GenreFragment> {
  Future<List<Genre>> _futureGenre = Future.value(<Genre>[]);
  TabController? _tabController;

  double downloadProgress = 0;

  var downloads = [];
  Future _downloadHistory = Future.value([]);
  List<Download> downList = [];
  bool _contains = false;

  ReceivePort _port = ReceivePort();

  static const List<Tab> myTabs = <Tab>[
    Tab(text: 'Genres', icon: Icon(Icons.category)),
    // Tab(text: 'Downloads', icon: Icon(Icons.file_download)),
  ];

  final AsyncMemoizer _memoizerGenre = AsyncMemoizer();

  Future<List<Genre>> getGenre() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.get(Uri.parse(ApiUrl.GenreList));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List<Genre> list = [];

      for (var u in data) {
        Genre categroies = Genre(u['id'], u['title'], u['image'], u['slug']);
        list.add(categroies);
      }

      return list;
    } else {
      throw Exception('Failed to load album');
    }
  }

//   void _unbindBackgroundIsolate() {
//     IsolateNameServer.removePortNameMapping('downloader_send_port');
//   }
//
//   void _bindBackgroundIsolate() {
//     bool isSuccess = IsolateNameServer.registerPortWithName(
//         _port.sendPort, 'downloader_send_port');
//     if (!isSuccess) {
//       _unbindBackgroundIsolate();
//       _bindBackgroundIsolate();
//       return;
//     }
//
//     _port.listen((dynamic data) {
//       double progress = data[0];
//       print(progress);
//       setState(() {
//         downloadProgress = progress;
//       });
//       if (downloadProgress == 100) {
//         checkDownloaded();
//       }
//     });
//   }
//
//   void checkDownloaded() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     List<Download> main = Download.decode(prefs.getString("downloadHistory")!);
//     var product =
//     main.firstWhere((product) => product.completed == 0, orElse: () => Download());
// //    print(product.completed);
//     if (product != null) {
//       setState(() {
//         product.completed = 1;
//         // downloads.remove(title);
//       });
//       final String encodedData = Download.encode(main);
//       prefs.setString("downloadHistory", encodedData);
//     }
//     setState(() {
//       _downloadHistory = getDownload();
//     });
//   }

 // static void downloadEpisode(String link,name,id,index,context){
   // downloadVideo();
 // }

  // Future getDownload() async {
  //   List<Download> DataMain = [];
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var list;
  //   if (prefs.containsKey("downloadHistory")) {
  //     setState(() {
  //       _contains = true;
  //     });
  //     list = jsonDecode(prefs.getString('downloadHistory')!);
  //     return list.reversed.toList();
  //   }
  //   return list.reversed.toList();
  // }
  //
  // void _cancelDownload() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //
  //   List<Download> main = Download.decode(prefs.getString("downloadHistory")!);
  //   var product = main.firstWhere((product) => product.completed == 0, orElse: () => Download());
  //   if(product != null){
  //     // print("cancel");
  //     _unbindBackgroundIsolate();
  //     if(product.cancelToken != null) {
  //       setState(() {
  //         product.cancelToken!.cancel();
  //       });
  //     }
  //     main.removeWhere((product) => product.completed == 0);
  //
  //     final String encodedData = Download.encode(main);
  //     prefs.setString("downloadHistory", encodedData);
  //     setState(() {
  //       _downloadHistory = getDownload();
  //     });
  //   }
  // }
  //
  // void _showAlertAlreadyDownload(BuildContext context) {
  //   showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         backgroundColor: muvi_appBackground,
  //         title: Text(
  //           "Episode Already Downloaded!",
  //           style: TextStyle(color: Colors.white),
  //         ),
  //         content: Text(
  //           "This Episode is Already Downloaded.\n Click the button to view Downloads",
  //           style: TextStyle(color: Colors.white),
  //         ),
  //         actions: [
  //           FlatButton(
  //             child: Text("View Downloads",style: TextStyle(color: selected_number),),
  //             onPressed: () async {
  //
  //               Navigator.pop(context);
  //             },
  //           ),
  //         ],
  //       ));
  // }
  //
  // void _showAlertAlreadyFirstDownload(BuildContext context) {
  //   showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         backgroundColor: muvi_appBackground,
  //         title: Text(
  //           "No able to Download!",
  //           style: TextStyle(color: Colors.white),
  //         ),
  //         content: Text(
  //           "Finish Previous Download First and then start new One!",
  //           style: TextStyle(color: Colors.white),
  //         ),
  //         actions: [
  //           FlatButton(
  //             child: Text("OK",style: TextStyle(color: selected_number),),
  //             onPressed: () async {
  //               Navigator.pop(context);
  //             },
  //           ),
  //         ],
  //       ));
  // }
  //
  // void _showAlertDownload(BuildContext context) {
  //   showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         backgroundColor: muvi_appBackground,
  //         title: Text(
  //           "Login Now to Download",
  //           style: TextStyle(color: Colors.white),
  //         ),
  //         content: Text(
  //           "An Account is needed to Download Video and Watch Offline",
  //           style: TextStyle(color: Colors.white),
  //         ),
  //         actions: [
  //           FlatButton(
  //             child: Text(
  //               "Login Now",
  //               style: TextStyle(color: selected_number, fontSize: 16),
  //             ),
  //             onPressed: () async {
  //               Navigator.of(context).push(MaterialPageRoute(
  //                   builder: (context) => SignInScreen()));
  //             },
  //           ),
  //         ],
  //       ));
  // }
  //
  // void _showAlertDownloadNot(BuildContext context) {
  //   showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         backgroundColor: muvi_appBackground,
  //         title: Text(
  //           "Important Information!",
  //           style: TextStyle(color: Colors.white),
  //         ),
  //         content: Text(
  //           "Now Download Option is only Available for Donors. Donate Now to Get the Download Option.",
  //           style: TextStyle(color: Colors.white),
  //         ),
  //         actions: [
  //           FlatButton(
  //             child: Text("Cancel",style: TextStyle(color: selected_number),),
  //             onPressed: () async {
  //               Navigator.pop(context);
  //             },
  //           ),
  //           FlatButton(
  //             child: Text("Donate Now",style: TextStyle(color: selected_number),),
  //             onPressed: () async {
  //               const url = "https://imdbanime.com/donate-us";
  //               // if (await canLaunch(url))
  //                 await launch(url);
  //               // else
  //               //   throw "Could not launch $url";
  //             },
  //           ),
  //         ],
  //       ));
  // }

  @override
  void initState() {
    // TODO: implement initState
    // _downloadHistory = getDownload();
    // _bindBackgroundIsolate();
    _memoizerGenre.runOnce(() => _futureGenre = getGenre());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    // TODO: implement build
    return Scaffold(
      body: DefaultTabController(
          length: 1,
          child: Scaffold(
              backgroundColor: muvi_appBackground,
              appBar: AppBar(
                backgroundColor: muvi_appBackground,
                bottom: TabBar(controller: _tabController, tabs: myTabs),
                title: Container(
                  child: Image.asset(
                    'images/muvi/images/barimage.png',
                    height: 50,
                  ),
                ),
              ),
              body: TabBarView(controller: _tabController, children: [
                Container(
                    child: SingleChildScrollView(
                        child: Column(children: <Widget>[
                  FutureBuilder(
                    future: _futureGenre,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        return GridView.builder(
                          itemCount: snapshot.data.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.only(
                              left: 11, right: 21, top: spacing_standard_new),
                          physics: BouncingScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3),
                          scrollDirection: Axis.vertical,
                          controller: ScrollController(keepScrollOffset: false),
                          itemBuilder: (context, index) {
//          Movie bookDetail = list[index];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SeeMore(
                                            title: snapshot.data[index].slug,
                                            index: 3)));
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
                                        borderRadius: BorderRadius.circular(
                                            spacing_control),
                                      ),
                                      child: CachedNetworkImage(
                                          placeholder: (context, url) =>
                                              Image.asset(
                                                  "images/muvi/images/series-back.png",
                                                  fit: BoxFit.cover),
                                          imageUrl: snapshot.data[index].image,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  itemTitle(
                                      context, snapshot.data[index].title),
                                ],
                              ),
                            ).paddingOnly(
                                left: 5,
                                right: 5,
                                bottom: spacing_standard_new);
                          },
                        );
                      }
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ]))),
//                 Container(
//                     margin: EdgeInsets.only(top: 15),
//                     child: FutureBuilder(
//                       future: _downloadHistory,
//                       builder: (BuildContext context, AsyncSnapshot snapshot) {
//                         if (snapshot.hasData) {
//                           if(snapshot.data.length == 0){
//                             return Container(
//                               child: Center(
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
// //                                  Image.asset(""),
//                                       Text(
//                                         "No Downloads",
//                                         style: TextStyle(
//                                             color: Colors.white, fontSize: 25),
//                                       )
//                                     ],
//                                   )),
//                             );
//                           }
//                           return ListView.builder(
//                               scrollDirection: Axis.vertical,
//                               itemCount: snapshot.data.length,
//                               shrinkWrap: true,
//                               padding: EdgeInsets.only(
//                                   left: spacing_standard,
//                                   right: spacing_standard_new),
//                               itemBuilder: (context, index) {
//                                 return GestureDetector(
//                                     onTap: () async {
//                                       // Navigator.push(
//                                       //     context,
//                                       //     MaterialPageRoute(
//                                       //         builder: (context) =>
//                                       // WatchVideo(snapshot.data[index]['video'],"1080",["1080"],snapshot.data[index]['title'],[],snapshot.data[index]['poster'],snapshot.data[index]['index'],1)));
//                                     },
//                                     child: Container(
//                                         margin: EdgeInsets.only(bottom: 20),
//                                         height: 70,
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             CachedNetworkImage(
//                                               imageUrl: snapshot.data[index]
//                                                   ['poster'],
//                                               fit: BoxFit.cover,
//                                               width: 100,
//                                               height: 100,
//                                             ),
//                                             Column(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.start,
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: <Widget>[
//                                                 SizedBox(
//                                                     width: width / 1.9,
//                                                     child: Text(
//                                                         snapshot.data[index]
//                                                             ['title'],
//                                                         maxLines: 1,
//                                                         softWrap: false,
//                                                         overflow: TextOverflow
//                                                             .ellipsis,
//                                                         style: TextStyle(
//                                                             color: Colors.white,
//                                                             fontSize: 16))),
//                                                 SizedBox(
//                                                   height: 15,
//                                                 ),
//                                                 Row(
//                                                   children: [
//                                                     Text("Episode:  ",
//                                                         style: TextStyle(
//                                                             color: Colors.white,
//                                                             fontSize: 14)),
//                                                     Container(
//                                                         padding:
//                                                             EdgeInsets.only(
//                                                                 left: 5,
//                                                                 right: 5),
//                                                         decoration: BoxDecoration(
//                                                             color:
//                                                                 Colors.purple,
//                                                             borderRadius:
//                                                                 BorderRadius
//                                                                     .circular(
//                                                                         5)),
//                                                         child: Text(
//                                                           (int.parse(snapshot
//                                                                           .data[
//                                                                       index]
//                                                                   ['index']))
//                                                               .toString(),
//                                                           style: TextStyle(
//                                                               color:
//                                                                   Colors.white,
//                                                               fontSize: 14),
//                                                         )),
//                                                   ],
//                                                 ),
//                                               ],
//                                             ).paddingOnly(
//                                                 top: 5, bottom: 5, left: 10),
//                                             snapshot.data[index]['completed'] ==
//                                                     0
//                                                 ? GestureDetector(
//                                                     onTap: () {
//                                                       _cancelDownload();
//                                                     },
//                                                     child: Stack(children: [
//                                                       CircularProgressIndicator(
//                                                         backgroundColor:
//                                                             Colors.white,
//                                                         valueColor:
//                                                             AlwaysStoppedAnimation<
//                                                                     Color>(
//                                                                 selected_number),
//                                                         value: downloadProgress / 100,
//                                                         strokeWidth: 6,
//                                                       ),
//                                                       Container(
//                                                         padding:
//                                                             EdgeInsets.only(
//                                                                 left: 6,
//                                                                 top: 6),
//                                                         child: Icon(
//                                                           Icons.stop,
//                                                           color: Colors.white,
//                                                         ),
//                                                       ),
//                                                       Container(
//                                                         alignment: Alignment.bottomCenter,
//                                                         margin: EdgeInsets.all(0),
//                                                         padding: EdgeInsets.all(0),
//                                                         child: Text(downloadProgress.toString()+'%',style: TextStyle(color: Colors.white),),),
//                                                     ]))
//                                                 : Container(),
//                                           ],
//                                         )));
//                               });
//                         }
//                         else if (snapshot.hasError) {
//                           return Container(
//                             child: Center(
//                                 child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
// //                                  Image.asset(""),
//                                 Text(
//                                   "No Downloads",
//                                   style: TextStyle(
//                                       color: Colors.white, fontSize: 25),
//                                 )
//                               ],
//                             )),
//                           );
//                         }
//                         return Center(
//                           child: CircularProgressIndicator(),
//                         );
//                       },
//                     ))
              ]))),
    );
  }
}
