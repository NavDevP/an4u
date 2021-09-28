import 'dart:convert';
import 'dart:io';

import 'package:Anime4U/integration/Api.dart';
import 'package:Anime4U/resources/colors.dart';
import 'package:Anime4U/resources/images.dart';
import 'package:Anime4U/resources/size.dart';
import 'package:Anime4U/screens/DonationScreen.dart';
import 'package:Anime4U/screens/flix_signin.dart';
import 'package:Anime4U/screens/privacy_policy_screen.dart';
import 'package:Anime4U/screens/terms_conditions_screen.dart';
import 'package:Anime4U/utils/app_localizations.dart';
import 'package:Anime4U/utils/app_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Anime4U/utils/widget_extensions.dart';
import 'package:http/http.dart' as http;

class SettingScreen extends StatefulWidget{

  @override
  SettingScreenState createState() => SettingScreenState();
}

class SettingScreenState extends State<SettingScreen> {

  bool isSettingImage = false;
  var settingImage,settingLink;
  bool isUserLoggedIn = false;

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
  final snackBar = SnackBar(content: Text('Thank You for Your Feedback'),backgroundColor: muvi_appBackground);
  void _addReview(stars,comment,context) async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    final response = await http.post(Uri.parse(ApiUrl.OurApi + "addReview?stars=$stars&comment=$comment"),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ${pref.getString('_apiToken')}'
        });
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }


  Future<List<dynamic>> getSocialList() async {
    List<dynamic> list = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('social')) {
      list = jsonDecode(prefs.getString("social")!);
    }
    return list;
  }

  @override
  void initState() {
    // TODO: implement initState
    getSocialList();
    userLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: muvi_appBackground,
      appBar: AppBar(
        title: toolBarTitle(context, keyString(context, "more")!),
        backgroundColor: muvi_appBackground,
        elevation: 0,
      ),
      body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              isSettingImage ? GestureDetector(
                  onTap: () async{
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    if (settingLink != null || settingLink != "") {
                      if(isUserLoggedIn) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Donation(settingLink, prefs.getString('_apiToken'))));
                      }else{
                        _showAlertDonation(context);
                      }
                    }
                  },
                  child: Container(
                      child: CachedNetworkImage(
                        imageUrl: settingImage,
                        fit: BoxFit.cover,)
                  )):Container(),
              itemSubTitle(context, keyString(context, "follow_us"),
                  colorThird: false)
                  .paddingOnly(
                  left: spacing_standard_new,
                  right: spacing_standard_new,
                  top: 12,
                  bottom: 12),
              FutureBuilder(
                  future: getSocialList(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                              child: Container(
                                  width: double.infinity / snapshot.data.length,
                                  height: 40,
                                  child: Center(
                                      child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: snapshot.data.length,
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            String valueString = snapshot
                                                .data[index]['color']
                                                .split('0x')[1]
                                                .split(')')[0]; // kind of hacky..
                                            int value =
                                            int.parse(valueString, radix: 16);
                                            IconData getIconForName(
                                                String iconName) {
                                              switch (iconName) {
                                                case 'facebook':
                                                  {
                                                    return FontAwesomeIcons
                                                        .facebookF;
                                                  }
                                                  break;

                                                case 'twitter':
                                                  {
                                                    return FontAwesomeIcons.twitter;
                                                  }
                                                  break;
                                                case 'youtube':
                                                  {
                                                    return FontAwesomeIcons.youtube;
                                                  }
                                                  break;
                                                case 'linkedin':
                                                  {
                                                    return FontAwesomeIcons
                                                        .linkedinIn;
                                                  }
                                                  break;
                                                case 'telegram':
                                                  {
                                                    return FontAwesomeIcons
                                                        .telegram;
                                                  }
                                                  break;
                                                case 'instagram':
                                                  {
                                                    return FontAwesomeIcons
                                                        .instagram;
                                                  }
                                                  break;
                                                default:
                                                  {
                                                    return FontAwesomeIcons.home;
                                                  }
                                              }
                                            }

                                            return GestureDetector(
                                                onTap: () async {
                                                  var url =
                                                  snapshot.data[index]['link'];
                                                  // if (await canLaunch(url))
                                                    await launch(url);
                                                  // else
                                                    // can't launch url, there is some error
                                                    // throw "Could not launch $url";
                                                },
                                                child: Center(
                                                    child: Container(
                                                      width: width /
                                                          1.5 /
                                                          snapshot.data.length,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.all(
                                                            Radius.circular(10)),
                                                        color: Color(value),
                                                        shape: BoxShape.rectangle,
                                                      ),
                                                      child: Center(
                                                        child: Icon(
                                                          getIconForName(snapshot
                                                              .data[index]['icon']),
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                      ),
                                                    ).paddingRight(20)));
                                          })))),
                        ],
                      ).paddingAll(10);
                    }
                    return CircularProgressIndicator();
                  }),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  itemSubTitle(context, keyString(context, "help_share"),
                      colorThird: false)
                      .paddingOnly(
                      left: spacing_standard_new,
                      right: spacing_standard_new,
                      top: 12,
                      bottom: 12),
                  GestureDetector(
                      onTap:() async{
                        // if (await canLaunch("https://imdbanime.com/help"))
                          await launch("mailto:imdbanime@gmail.com");
                        // else
                          // can't launch url, there is some error
                          // throw "Could not launch https://imdbanime.com/help";
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            ic_help,
                            width: 20,
                            height: 20,
                            color: muvi_textColorPrimary,
                          ).paddingRight(spacing_standard),
                          Expanded(child: itemTitle(context, keyString(context, "help"))),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: muvi_textColorThird,
                          )
                        ],
                      ).paddingOnly(
                          left: spacing_standard_new,
                          right: 12,
                          top: spacing_standard_new,
                          bottom: spacing_standard_new)
                  ),
                  GestureDetector(
                      onTap: () {
                        Share.share(
                            "Download IMDB Anime to watch your favourite anime for Free.\n Download Now -> http://imdbanime.com");
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            ic_share,
                            width: 20,
                            height: 20,
                            color: muvi_textColorPrimary,
                          ).paddingRight(spacing_standard),
                          Expanded(child: itemTitle(context, keyString(context, "share"))),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: muvi_textColorThird,
                          )
                        ],
                      ).paddingOnly(
                          left: spacing_standard_new,
                          right: 12,
                          top: spacing_standard_new,
                          bottom: spacing_standard_new)
                  ),
                  isUserLoggedIn ? GestureDetector(
                      onTap: () {
                        _showRatingAppDialog();
                      },
                      child: Container(
                          padding: EdgeInsets.only(
                              left: spacing_standard_new,
                              right: 12,
                              top: spacing_standard_new,
                              bottom: spacing_standard_new),
                          color: muvi_appBackgroundLight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.star,
                                size: 20,
                                color: muvi_textColorPrimary,
                              ).paddingRight(spacing_standard),
                              Expanded(child: itemTitle(context, keyString(context, "share_your_thoughts"))),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: muvi_textColorThird,
                              )
                            ],
                          ))
                  ):Container(),
                  itemSubTitle(context, keyString(context, "terms"))
                      .paddingOnly(
                      left: spacing_standard_new,
                      right: 12,
                      top: spacing_standard_new,
                      bottom: spacing_control),
                  new GestureDetector(
                      onTap:() {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TermsConditionsScreen()));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(),
                          Expanded(child: itemTitle(context, keyString(context, "terms_conditions"))),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: muvi_textColorThird,
                          )
                        ],
                      ).paddingOnly(
                          left: spacing_standard_new,
                          right: 12,
                          top: spacing_standard_new,
                          bottom: spacing_standard_new)
                  ),
                  new GestureDetector(
                      onTap:() {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PrivacyPolicy()));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(),
                          Expanded(child: itemTitle(context, keyString(context, "privacy_policy"))),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: muvi_textColorThird,
                          )
                        ],
                      ).paddingOnly(
                          left: spacing_standard_new,
                          right: 12,
                          top: spacing_standard_new,
                          bottom: spacing_standard_new)),
                  isUserLoggedIn ?
                  GestureDetector(
                      onTap:() => showAlertDialog(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(),
                          Expanded(child: itemTitle(context, keyString(context, "logout"))),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: muvi_textColorThird,
                          )
                        ],
                      ).paddingOnly(
                          left: spacing_standard_new,
                          right: 12,
                          top: spacing_standard_new,
                          bottom: spacing_standard_new)
                  ):Container(),
                ],
              ).paddingBottom(spacing_large),
            ],
          )),
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    // ignore: deprecated_member_use
    Widget cancelButton = FlatButton(
      textColor: muvi_colorPrimary,
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop(); // dismiss dialog
      },
    );
    // ignore: deprecated_member_use
    Widget continueButton = FlatButton(
      textColor: muvi_colorPrimary,
      child: Text("Yes"),
      onPressed: () {
        removeValues();
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: muvi_appBackground,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      contentTextStyle: TextStyle(color: Colors.white, fontSize: 16),
      title: Text("Logout!"),
      content: Text("Are you sure you want to Logout?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  removeValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Remove String
    prefs.remove('_apiToken');
    setState(() {
      userLogin();
    });
  }

  _showAlertDonation(BuildContext context) {
    // set up the buttons
    // ignore: deprecated_member_use
    Widget cancelButton = FlatButton(
      textColor: muvi_colorPrimary,
      child: Text("Ignore"),
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    Donation(settingLink, null)));
        // dismiss dialog
      },
    );
    // ignore: deprecated_member_use
    Widget continueButton = FlatButton(
      textColor: muvi_colorPrimary,
      child: Text("SignIn"),
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    SignInScreen()));
        // Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: muvi_appBackground,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      contentTextStyle: TextStyle(color: Colors.white, fontSize: 16),
      title: Text("Important Information"),
      content: Text("If You Donate without Login we will not able to give you Donators Benefits. So Please Login or Ignore this message"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _showRatingAppDialog() {
    final _ratingDialog = RatingDialog(
      title: 'Rate and tell Us',
      message: 'Tell us your experience on our App.\n'
          'This will help us to improve our App',
      image: Image.asset("assets/images/logo.png",
        height: 100,),
      submitButton: 'Submit',
      onCancelled: () => print('cancelled'),
      onSubmitted: (response) {
        _addReview(response.rating,response.comment,context);
        // print('rating: ${response.rating}, '
        //     'comment: ${response.comment}');
      },
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _ratingDialog,
    );
  }
}

class Social {
  String name;
  String link;
  String color;
  String icon;

  Social({required this.name, required this.link, required this.color, required this.icon});

  factory Social.fromJson(Map<String, dynamic> jsonData) {
    return Social(
      name: jsonData['name'],
      link: jsonData['link'],
      color: jsonData['color'],
      icon: jsonData['icon'],
    );
  }

  static Map<String, dynamic> toMap(Social data) => {
    'name': data.name,
    'link': data.link,
    'color': data.color,
    'icon': data.icon,
  };

  static String encode(List<Social> datas) => json.encode(
    datas.map<Map<String, dynamic>>((data) => Social.toMap(data)).toList(),
  );

  static List<Social> decode(String datas) =>
      (json.decode(datas) as List<dynamic>)
          .map<Social>((item) => Social.fromJson(item))
          .toList();
}