import 'dart:convert';

class Movies {
  String title;
  String link;
  String img;
  String synopsis;
  List<dynamic> genres;
  int released;
  String? status;
  String? otherName;
  int? totalEpisodes;
  List<dynamic>? episodes;

  Movies(
      this.title,
      this.link,
      this.img,
      this.synopsis,
      this.genres,
      this.released,
      this.status,
      this.otherName,
      this.totalEpisodes,
      this.episodes);

// Movies.fromJson(Map<String, dynamic> json) {
//   title = json['title'];
//   img = json['img'];
//   synopsis = json['synopsis'];
//   genres = json['genres'].cast<String>();
//   released = json['released'];
//   status = json['status'];
//   otherName = json['otherName'];
//   totalEpisodes = json['totalEpisodes'];
//   if (json['episodes'] != null) {
//     episodes = <Episodes>[];
//     json['episodes'].forEach((v) {
//       episodes!.add(new Episodes.fromJson(v));
//     });
//   }
// }
//
// Map<String, dynamic> toJson() {
//   final Map<String, dynamic> data = new Map<String, dynamic>();
//   data['title'] = this.title;
//   data['img'] = this.img;
//   data['synopsis'] = this.synopsis;
//   data['genres'] = this.genres;
//   data['released'] = this.released;
//   data['status'] = this.status;
//   data['otherName'] = this.otherName;
//   data['totalEpisodes'] = this.totalEpisodes;
//   if (this.episodes != null) {
//     data['episodes'] = this.episodes!.map((v) => v.toJson()).toList();
//   }
//   return data;
// }
}

class Episodes {
  String? id;

  Episodes({this.id});

  Episodes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    return data;
  }
}

class Favourite {
//  int id;
  String? poster;
  String? title;

  Favourite({  this.title, this.poster});

  factory Favourite.fromJson(Map<String, dynamic> jsonData) {
    return Favourite(
      poster: jsonData['poster'],
      title: jsonData['title'],
    );
  }

  static Map<String, dynamic> toMap(Favourite data) => {
    'title': data.title,
    'poster': data.poster,
  };

  static String encode(List<Favourite> datas) => json.encode(
    datas.map<Map<String, dynamic>>((data) => Favourite.toMap(data)).toList(),
  );

  static List<Favourite> decode(String datas) =>
      (json.decode(datas) as List<dynamic>)
          .map<Favourite>((item) => Favourite.fromJson(item))
          .toList();
}

