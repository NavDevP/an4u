import 'dart:convert';


class HomeSlider {
  String? slideImage;
  int? id;
  Object? title;
  bool? isHD = false;

  HomeSlider({this.id, this.slideImage, this.title, this.isHD});
}

class Movie {
  String? slideImage;
  String? title;
  String? subTitle;
  bool? isHD = false;
  double? percent;

  Movie({this.slideImage, this.title, this.isHD, this.percent});
}

class VerticalSlide {
  String? slideImage;
  String? title;
  String? subTitle;
  int? episode;
  int? episodeNo;
  String link;
  String? desc;
  int? id;
  bool? isHD = false;
  double? percent;
  List? genres;
  String? server;
  int? type;

  VerticalSlide({this.slideImage, this.title, this.isHD, this.percent,this.episode,this.episodeNo,required this.link, this.desc, this.id, this.genres, this.server, this.type});
}

class FAQ {
  String? title;
  String? subTitle;
  bool? isExpanded = false;

  FAQ({this.title, this.subTitle, this.isExpanded});
}

class Recommendations {
  int videosId;
  String title;
  String thumbnailUrl;

  Recommendations(this.videosId, this.title, this.thumbnailUrl);
}

class Genre {
  int id;
  String title;
  String image;
  String slug;

  Genre(this.id, this.title, this.image, this.slug);
}

class Anime {
  String title;
  String link;
  String img;
  String synopsis;

//  String genres;
  String category;
  int episode;
  int totalEpisodes;
  int released;
  String status;
  String otherName;
  List episodes;
  List genres;

//  List<Servers> servers;

  Anime(
      this.title,
      this.link,
      this.img,
      this.synopsis,
//        this.genres,
      this.category,
      this.episode,
      this.totalEpisodes,
      this.released,
      this.status,
      this.otherName,
      this.episodes,
      this.genres
//        this.servers
      );
}

class Horizontal {
  String title;
  String img;
  String link;
  String synopsis;

  List genres;
  String category;
  int episode;
  int totalEpisodes;
  int released;
  String status;
  String otherName;

  List server;

  Horizontal(
      this.title,
      this.img,
      this.link,
      this.synopsis,
      this.category,
      this.episode,
      this.totalEpisodes,
      this.released,
      this.status,
      this.genres,
      this.otherName,
      this.server);
}

class Popular {
  String title;
  String img;
  String link;
  String synopsis;

//  String genres;
  String category;
  int episode;
  int totalEpisodes;
  int released;
  String status;
  String otherName;
  List episodes;
  List genres;

//  List<Servers> servers;

  Popular(
      this.title,
      this.img,
      this.link,
      this.synopsis,
//        this.genres,
      this.category,
      this.episode,
      this.totalEpisodes,
      this.released,
      this.status,
      this.otherName,
      this.episodes,
      this.genres
//        this.servers
      );
}

class Search {
  String title;
  String link;
  String img;
  String synopsis;

//  String genres;
  String category;
  int episode;
  int totalEpisodes;
  int released;
  String status;
  String otherName;

//  List<Servers> servers;

  Search(
      this.title,
      this.link,
      this.img,
      this.synopsis,
//        this.genres,
      this.category,
      this.episode,
      this.totalEpisodes,
      this.released,
      this.status,
      this.otherName,
//        this.servers
      );
}

class CurrPopular {
  String title;
  String link;
  String img;
  String synopsis;

  List genres;
  String category;
  int episode;
  List episodes;
  int totalEpisodes;
  int released;
  String status;
  String otherName;

  List servers;

  CurrPopular(
      this.title,
      this.link,
      this.img,
      this.synopsis,
      this.genres,
      this.category,
      this.episode,
      this.totalEpisodes,
      this.released,
      this.status,
      this.otherName,
      this.servers,
      this.episodes);
}

class Servers {
  String name;
  String iframe;

  Servers({required this.name, required this.iframe});
}

class Entries {
  int? id;
  int? progress;
  Media? media;

  Entries({this.id, this.progress, this.media});

  Entries.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    progress = json['progress'];
    media = json['media'] != null ? new Media.fromJson(json['media']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['progress'] = this.progress;
    if (this.media != null) {
      data['media'] = this.media!.toJson();
    }
    return data;
  }
}

class Media {
  int? id;
  String? title;
  String? coverImage;

  Media({this.id, this.title, this.coverImage});

  Media.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    coverImage = json['coverImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.title != null) {
      data['title'] = this.title;
    }
    if (this.coverImage != null) {
      data['coverImage'] = this.coverImage;
    }
    return data;
  }
}

class CachePopular {
  String title;
  String link;
  String img;
  String synopsis;

//  String genres;
  String category;
  int episode;
  int totalEpisodes;
  int released;
  String status;
  String otherName;
  List episodes;
  List genres;

//  List<Servers> servers;

  CachePopular(
      this.title,
      this.link,
      this.img,
      this.synopsis,
//        this.genres,
      this.category,
      this.episode,
      this.totalEpisodes,
      this.released,
      this.status,
      this.otherName,
      this.episodes,
      this.genres
//        this.servers
      );
}

class Download {
  int? id;
  String? poster;
  String? title;
  String? video;
  String? check;
  String? index;
  int? completed;
  String? taskId;
  // CancelToken? cancelToken;

  Download({this.id,  this.title, this.check,  this.poster, this.video, this.index, this.completed, this.taskId});

  factory Download.fromJson(Map<String, dynamic> jsonData) {
    return Download(
      id: jsonData['id'],
      poster: jsonData['poster'],
      check: jsonData['check'],
      title: jsonData['title'],
      video: jsonData['video'],
      index: jsonData['index'],
      completed: jsonData['completed'],
      taskId: jsonData['taskId'],
    );
  }

  static Map<String, dynamic> toMap(Download data) => {
    'id': data.id,
    'title': data.title,
    'poster': data.poster,
    'check': data.check,
    'video': data.video,
    'index': data.index,
    'completed': data.completed,
    'taskId': data.taskId,
  };

  static String encode(List<Download> datas) => json.encode(
    datas.map<Map<String, dynamic>>((data) => Download.toMap(data)).toList(),
  );

  static List<Download> decode(String datas) =>
      (json.decode(datas) as List<dynamic>)
          .map<Download>((item) => Download.fromJson(item))
          .toList();
}