import 'dart:convert';

import 'package:Anime4U/integration/Api.dart';
import 'package:Anime4U/resources/colors.dart';
import 'package:Anime4U/screens/detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Loading extends StatefulWidget {
  Loading(this.movie,this.link, this.episodes, this.totalEp,this.fetchFrom, this.context);

  final BuildContext context;
  final String movie;
  final String link;
  final int? totalEp;
  final List<dynamic>? episodes;
  final int? fetchFrom;

  @override
  LoadingState createState() => LoadingState();
}

class LoadingState extends State<Loading> {

  bool goneError = false;

  @override
  void initState() {
    super.initState();
    widget.fetchFrom == 0 ?
    getData():
    fetchGogo();
  }

  bool isNumericUsing_tryParse(String string) {
    // Null or empty string is not a number
    if (string == null || string.isEmpty) {
      return false;
    }

    // Try to parse input string to number.
    // Both integer and double work.
    // Use int.tryParse if you want to check integer only.
    // Use double.tryParse if you want to check double only.
    final number = num.tryParse(string);

    if (number == null) {
      return false;
    }

    return true;
  }

  Future getData() async {
    // print("NAME" +
    //     widget.movie
    //         .replaceAll("[^\\p{ASCII}]", "")
    //         .replaceAll(" Movie", "")
    //         .replaceAll("☆", "")
    //         .split(" (Dub)")[0]);
    try {
      final response = await http.get(Uri.parse(ApiUrl.Googl +
          "teribhe/getAnime.php?title=" +
          widget.movie
              .replaceAll("[^\\p{ASCII}]", "")
              .replaceAll(" Movie", "")
              .replaceAll("☆", "")
              .split(" (Dub)")[0]));
      List<Actor> actor = [];
      print(response.body);
      if (response.statusCode == 200) {
        if (response.body.toString() != "False") {
          var data = jsonDecode(response.body);
          for (var i = 0;
          i < data['data']['Media']['characters']['nodes'].length;
          i++) {
            actor.add(Actor(
              name: data['data']['Media']['characters']['nodes'][i]['name']
              ['full'],
              role: data['data']['Media']['characters']['edges'][i]['role'],
              avatarUrl: data['data']['Media']['characters']['nodes'][i]['image']
              ['medium'],
            ));
          }
          var totalEpisodes = 0;
          if (widget.totalEp == null) {
            final responses = await http.get(Uri.parse(ApiUrl.GOGOApi +
                "Search/${widget.movie.replaceAll("/", " ").replaceAll(
                    "[^\\p{ASCII}]", "").replaceAll(" Movie", "").replaceAll(
                    "☆", "")}"));
            if (responses.statusCode == 200) {
              var datas = jsonDecode(responses.body);
              totalEpisodes = datas['search'][0]['totalEpisodes'];
            }
          }
          // data['data']['Media']['streamingEpisodes'].length == 0
          //     ? widget.episodes
          //     : data['data']['Media']['streamingEpisodes']
          //     .reversed
          //     .toList()
          var phorotUrl;
          if (data['data']['Media']['streamingEpisodes'].length > 0) {
            var stremingLast = data['data']['Media']['streamingEpisodes']
            [data['data']['Media']['streamingEpisodes'].length - 1]
            ['title']
                .toString()
                .split("-")[0]
                .toString()
                .split(" ")[1]
                .toString()
                .split(".")[0];
            var stremingOne = data['data']['Media']['streamingEpisodes'][0]
            ['title']
                .toString()
                .split("-")[0]
                .toString()
                .split(" ")[1]
                .toString()
                .split(".")[0];
            if (isNumericUsing_tryParse(stremingOne)) {
              if (int.parse(stremingLast) > int.parse(stremingOne)) {
                phorotUrl = data['data']['Media']['streamingEpisodes'];
              } else {
                phorotUrl =
                    data['data']['Media']['streamingEpisodes'].reversed
                        .toList();
              }
            } else {
              phorotUrl = data['data']['Media']['streamingEpisodes'];
            }
          } else {
            phorotUrl = [];
          }
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      MovieDetailsPage(AnimeDetail(
                          id: data['data']['Media']['id'],
                          bannerUrl: data['data']['Media']['bannerImage'],
                          posterUrl: data['data']['Media']['coverImage']['large'],
                          native: data['data']['Media']['title']['native'],
                          english: data['data']['Media']['title']['english'],
                          link: widget.link,
                          title: data['data']['Media']['title']['romaji'],
                          movieTitle: widget.movie,
                          rating: 8.0,
                          starRating: 4,
                          categories: data['data']['Media']['genres'],
                          storyline: data['data']['Media']['description'],
                          totalEp:
                          widget.totalEp != null
                              ? widget.totalEp
                              : totalEpisodes,
                          photoUrls: phorotUrl,
                          episodes: widget.episodes,
                          episodeFrom:
                          data['data']['Media']['streamingEpisodes'].length == 0
                              ? 1
                              : 2,
                          actors: actor,
                          startDate: jsonEncode(
                              data['data']['Media']['startDate']),
                          endDate: jsonEncode(data['data']['Media']['endDate']),
                          type: data['data']['Media']['type'],
                          duration: data['data']['Media']['duration']))));
        } else {
          // print(widget.movie
          //     .replaceAll("/", " ")
          //     .replaceAll("[^\\p{ASCII}]", "")
          //     .replaceAll(" Movie", "")
          //     .replaceAll("☆", ""));
          final response = await http.get(Uri.parse(ApiUrl.GOGOApi + "Search/" +widget.link));
          if (response.statusCode == 200) {
            var data = jsonDecode(response.body);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        MovieDetailsPage(AnimeDetail(
                            id: 0,
                            bannerUrl: null,
                            posterUrl: data['search'][0]['img'],
                            native: "",
                            english: "",
                            link: widget.link,
                            title: data['search'][0]['title'],
                            movieTitle: data['search'][0]['title'],
                            rating: 8.0,
                            starRating: 4,
                            categories: data['search'][0]['genres'],
                            storyline: data['search'][0]['synopsis'],
                            totalEp: data['search'][0]['totalEpisodes'],
                            photoUrls: data['search'][0]['episodes'],
                            episodes: widget.episodes != null ? widget.episodes :data['search'][0]['episodes'],
                            episodeFrom: 1,
                            actors: <Actor>[],
                            startDate: data['search'][0]['released'].toString(),
                            endDate: null,
                            type: "Anime",
                            duration: null))));
          }
        }
      } else {
        setState(() {
          goneError = true;
        });
        throw Exception('Failed to Fetch Anime');
      }
    }catch(err){
      print("Catch Data");
      final response = await http.get(Uri.parse(ApiUrl.GOGOApi+"Search/${widget.link}"));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    MovieDetailsPage(AnimeDetail(
                        id: 0,
                        bannerUrl: null,
                        posterUrl: data['search'][0]['img'],
                        native: "",
                        english: "",
                        link: widget.link,
                        title: data['search'][0]['title'],
                        movieTitle: data['search'][0]['title'],
                        rating: 8.0,
                        starRating: 4,
                        categories: data['search'][0]['genres'],
                        storyline: data['search'][0]['synopsis'],
                        totalEp: data['search'][0]['totalEpisodes'],
                        photoUrls: data['search'][0]['episodes'],
                        episodes: widget.episodes != null ? widget.episodes :data['search'][0]['episodes'],
                        episodeFrom: 1,
                        actors: <Actor>[],
                        startDate: data['search'][0]['released'].toString(),
                        endDate: null,
                        type: "Anime",
                        duration: null))));
      }
    }
  }

  Future fetchGogo() async{
    final response = await http.get(Uri.parse(ApiUrl.GOGOApi+"Search/${widget.link}"));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  MovieDetailsPage(AnimeDetail(
                      id: 0,
                      bannerUrl: null,
                      posterUrl: data['search'][0]['img'],
                      native: "",
                      english: "",
                      link: widget.link,
                      title: data['search'][0]['title'],
                      movieTitle: data['search'][0]['title'],
                      rating: 8.0,
                      starRating: 4,
                      categories: data['search'][0]['genres'],
                      storyline: data['search'][0]['synopsis'],
                      totalEp: data['search'][0]['totalEpisodes'],
                      photoUrls: data['search'][0]['episodes'],
                      episodes: widget.episodes != null ? widget.episodes :data['search'][0]['episodes'],
                      episodeFrom: 1,
                      actors: <Actor>[],
                      startDate: data['search'][0]['released'].toString(),
                      endDate: null,
                      type: "Anime",
                      duration: null))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: muvi_appBackground,
        body: Container(
            child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
              CircularProgressIndicator(
                valueColor:
                    new AlwaysStoppedAnimation<Color>(muvi_colorPrimary),
              ),
              SizedBox(height: 20),
              Text(
                "Fetching Anime",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              SizedBox(height: 20),
              goneError ?
              Column(children: [
                Text(
                  "Taking Much Time than Expected!",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 5),
                Text(
                  "Try Opening Again if problem persist Please Complain us on Our Instagram!",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ]):Container(),
            ]))));
  }
}

class AnimeDetail {
  AnimeDetail(
      {this.id,
      this.bannerUrl,
      this.posterUrl,
      this.title,
      this.link,
      this.rating,
      this.starRating,
      this.categories,
      this.storyline,
      this.photoUrls,
      this.episodes,
      required this.actors,
      this.episodeFrom,
      this.native,
      this.english,
      this.startDate,
      this.endDate,
      this.type,
      this.duration,
      this.movieTitle,
      this.totalEp});

  final String? bannerUrl;
  final int? id;
  final String? posterUrl;
  final String? movieTitle;
  final String? title;
  final String? link;
  final double? rating;
  final int? starRating;
  final List<dynamic>? categories;
  final String? storyline;
  final int? totalEp;
  final List<dynamic>? photoUrls;
  final List<dynamic>? episodes;
  final List<Actor> actors;
  final String? startDate;
  final String? endDate;
  final int? episodeFrom;
  final String? native;
  final String? english;
  final String? type;
  final int? duration;
}

class Actor {
  Actor({
    this.name,
    this.role,
    this.avatarUrl,
  });

  final String? name;
  final String? role;
  final String? avatarUrl;
}
