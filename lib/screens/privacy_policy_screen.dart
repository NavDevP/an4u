import 'dart:convert';

import 'package:Anime4U/integration/Api.dart';
import 'package:Anime4U/resources/colors.dart';
import 'package:Anime4U/resources/size.dart';
import 'package:Anime4U/utils/app_localizations.dart';
import 'package:Anime4U/utils/app_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'package:Anime4U/utils/widget_extensions.dart';


class PrivacyPolicy extends StatefulWidget {
  static String tag = '/PrivacyPolicy';

  @override
  PrivacyPolicyState createState() => PrivacyPolicyState();
}

Future<String> fetchPrivacy() async {
  final response = await http.get(Uri.parse(ApiUrl.Privacy));

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);

    String terms = data[0]['privacy'];

    return terms;
  } else {
    throw Exception('Failed to load album');
  }
}

class PrivacyPolicyState extends State<PrivacyPolicy> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: muvi_appBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
    child:appBarLayout(context, keyString(context, "privacy_policy"))),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            itemTitle(context, "IMDB Anime - Privacy & Policy").paddingBottom(spacing_standard),
            FutureBuilder(
              future: fetchPrivacy(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return HtmlWidget(snapshot.data,
                  customStylesBuilder: (element) {
                    if (element.classes.contains('p')) {
                      return {'color': 'white'};
                    }else if (element.classes.contains('h1')) {
                      return {'color': 'white'};
                    }else if (element.classes.contains('h2')) {
                      return {'color': 'white'};
                    }else if (element.classes.contains('br')) {
                      return {'color': 'white'};
                    }
                    return null;
                  },
                  textStyle: TextStyle(fontSize: 14,color: Colors.white,letterSpacing: 1),
                );
              }
              return Container(
                  height: height / 2,
                  child: Center(
                    child: CircularProgressIndicator() ,
                  ));
            }),
          ],
        ).paddingAll(spacing_standard_new),
      ),
    );
  }
}
