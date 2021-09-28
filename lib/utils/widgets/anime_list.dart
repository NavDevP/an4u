import 'package:Anime4U/fragments/loading.dart';
import 'package:Anime4U/resources/size.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Anime4U/utils/widget_extensions.dart';

import '../app_widgets.dart';

class AnimeList extends StatelessWidget{

  AnimeList(this.imageUrl,this.title,this.link,this.episodes,this.totalEpisodes);

  final String imageUrl;
  final String title;
  final String link;
  final episodes;
  final totalEpisodes;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    // TODO: implement build
    return Container(
        margin: EdgeInsets.only(
            left: spacing_standard),
        width: width * 0.28,
        child: Column(
          children: <Widget>[
            InkWell(
              child: AspectRatio(
                aspectRatio: 6 / 8.8,
                child: Card(
                  color: Colors
                      .transparent,
                  semanticContainer:
                  true,
                  clipBehavior: Clip
                      .antiAliasWithSaveLayer,
                  elevation: 30,
                  margin:
                  EdgeInsets.all(
                      0),
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius
                        .circular(
                        15),
                  ),
                  child: Stack(
                    alignment: Alignment
                        .bottomLeft,
                    children: <
                        Widget>[
                      Card(
                        color: Colors
                            .transparent,
                        semanticContainer:
                        true,
                        clipBehavior:
                        Clip.antiAliasWithSaveLayer,
                        elevation: 50,
                        margin:
                        EdgeInsets
                            .all(
                            0),
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(
                              spacing_control),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          height: double
                              .infinity,
                        ),
                      ),
                      hdWidget(
                          context)
                          .paddingRight(
                          spacing_standard)
                          .visible(
                          false)
                          .paddingAll(
                          spacing_standard),
                    ],
                  ),
                ),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Loading(
                            title,
                            link,
                            episodes,
                            totalEpisodes,
                            0,
                            context)
                    ));
              },
              radius: spacing_control,
            ),
            Flexible(
              child: new Text(
                title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13
                ),
                maxLines: 2,
              ),
            ),
          ],
        ));
  }

}