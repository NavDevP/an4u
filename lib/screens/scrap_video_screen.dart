import 'dart:async';
import 'dart:convert';

import 'package:Anime4U/integration/Api.dart';
import 'package:Anime4U/resources/colors.dart';
import 'package:Anime4U/screens/watch_video_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScrapVideo extends StatefulWidget {
  ScrapVideo(this.anime, this.link, this.episode, this.poster, this.animeId,
      this.totalEpisodes, this.genre);

  final String anime;
  final String link;
  final String episode;
  final String poster;
  final int animeId;
  final int totalEpisodes;
  final List? genre;

  @override
  ScrapVideoState createState() => ScrapVideoState();
}

class ScrapVideoState extends State<ScrapVideo> {
  final GlobalKey<ExpansionTileCardState> cardA = new GlobalKey();

  List<dynamic> servers = [];

  late Future _getData;

  bool isFetchingServers = true;

  @override
  void initState() {
    super.initState();
    print(widget.link);
    _getData = getServers();
//    Timer(const Duration(seconds: 2), () {
//      if(servers.isEmpty){
//        _getData = getServers();
//      }
//    });
  }

  Future getServers() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String finalV = version.replaceAll('.', '');
    final response = await http.get(Uri.parse(
        ApiUrl.Googl + 'v' + finalV + "/getServer.php?title=${widget.link}"));
    var urls = [];
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      // for (var i = 0; i < data['data'].length; i++) {
      setState(() {
        if (data['data'][0]['url'].length != 0) {
          servers.add({
            'name': data['data'][0]['name'],
            'url': data['data'][0]['url'],
          });
        }
        if (data['data'][0]['next'] != 0) {
          moreServers(data['data'][0]['next']);
        } else {
          isFetchingServers = false;
        }
      });
      // }
      return servers;
    }
  }

  Future moreServers(server) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String finalV = version.replaceAll('.', '');
    final response = await http.get(Uri.parse(ApiUrl.Googl +
        'v' +
        finalV +
        "/servers/$server.php?anime=${widget.link}"));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['data'][0]['url'].length != 0) {
        setState(() {
          servers.add({
            'name': data['data'][0]['name'],
            'url': data['data'][0]['url'],
          });
        });
        if (data['data'][0]['next'] != 0) {
          moreServers(data['data'][0]['next']);
        } else {
          setState(() {
            isFetchingServers = false;
          });
        }
      }
      // return servers;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: new Text("Fetching Servers", textAlign: TextAlign.center),
          backgroundColor: muvi_appBackground,
        ),
        backgroundColor: muvi_appBackground,
        body: Padding(
            padding: EdgeInsets.all(20),
            child: Column(children: [
              Material(
                  elevation: 10,
                  // shadowColor: muvi_colorPrimaryDark.withOpacity(0.4),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Name:",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(width: 10),
                                  Flexible(
                                      child: Text(
                                    widget.anime,
                                    style: TextStyle(color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                  ))
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Episode:",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    widget.episode,
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                            ],
                          )))),
              SizedBox(
                height: 10,
              ),
              servers.isNotEmpty
                  ? Container(
                      child: ListView.builder(
                          itemCount: servers.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.only(top: 10),
                              child: ExpansionTileCard(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25)),
                                  baseColor: Colors.black54,
                                  expandedColor: Colors.black54,
                                  initiallyExpanded: true,
                                  trailing: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.white,
                                  ),
                                  title: Text(
                                    servers[index]['name'],
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                  children: <Widget>[
                                    Divider(
                                      thickness: 1.0,
                                      height: 1.0,
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                          vertical: 8.0,
                                        ),
                                        child: Row(
                                          children: [
                                            for (var v = 0;
                                                v <
                                                    servers[index]['url']
                                                        .length;
                                                v++)
                                              GestureDetector(
                                                  onTap: () {
                                                    Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => WatchVideo(
                                                                servers[index]
                                                                        ['url']
                                                                    [v]['file'],
                                                                servers[index][
                                                                        'url'][v]
                                                                    ['quality'],
                                                                servers[index][
                                                                        'url'][v]
                                                                    ['header'],
                                                                servers[index]
                                                                    ['url'],
                                                                widget.anime,
                                                                servers[index]
                                                                    ['url'],
                                                                widget.poster,
                                                                widget.episode,
                                                                0,
                                                                widget
                                                                    .totalEpisodes,
                                                                widget.genre,
                                                                widget.link)));
                                                  },
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                          right: 15),
                                                      child: Chip(
                                                        labelPadding:
                                                            EdgeInsets.only(
                                                                left: 5.0,
                                                                right: 5.0),
                                                        label: Text(
                                                          servers[index]['url']
                                                                  [v]['quality']
                                                              .toString(),
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        backgroundColor:
                                                            muvi_appBackgroundLight,
                                                        elevation: 6.0,
                                                        shadowColor:
                                                            Colors.grey[60],
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                      ))),
                                          ],
                                        ),
                                      ),
                                    )
                                  ]),
                            );
                          }))
                  : Container(),
              isFetchingServers
                  ? Container(
                      width: 300,
                      child: Column(children: [
                        Center(
                          child: LinearProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(
                                muvi_colorPrimaryDark),
                            backgroundColor: muvi_appBackground,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text("Fetching Servers",
                            style: TextStyle(color: Colors.white, fontSize: 18))
                      ]))
                  : Container()
            ])));
  }
}
