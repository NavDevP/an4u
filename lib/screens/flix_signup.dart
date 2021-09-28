import 'dart:convert';
import 'dart:io';

import 'package:Anime4U/integration/Api.dart';
import 'package:Anime4U/resources/colors.dart';
import 'package:Anime4U/resources/images.dart';
import 'package:Anime4U/resources/size.dart';
import 'package:Anime4U/utils/app_localizations.dart';
import 'package:Anime4U/utils/app_widgets.dart';
import 'package:Anime4U/utils/constants.dart';
import 'package:Anime4U/utils/widget_extensions.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'flix_signin.dart';
import 'home_screen.dart';


class SignUpScreen extends StatefulWidget {
  static String tag = '/SignUpScreen';

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  String _selectedKnow = 'How you get to know about our app?';
  FocusNode passFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode nameFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();
  TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String email;
  late String name;
  late String firebaseToken;
  late String password;
  bool _autoValidate = false;
  bool passwordVisible = false;
  bool isLoading = false;
  var isSuccess = false;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  _register() {
    _firebaseMessaging.subscribeToTopic('all');
    _firebaseMessaging.getToken().then((token) => firebaseToken = token.toString());
  }

  var _array;

  late List<DropdownMenuItem<String>> dropSelect;

  showLoading(bool show) {
    setState(() {
      isLoading = show;
    });
  }

  @override
  void initState() {
    super.initState();
    isLoading = true;
    getToken();
    _register();
//    checkData();
  }

  void onSignInTap() async {
    GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
      'email',
    ]);
//    if(_selectedKnow  == "How you get to know about our app?"){
//      _showAlert(context);
//    }else {
      googleSignIn.signOut();
      await googleSignIn.signIn().then((res) async {
        await res.authentication.then((accessToken) async {
          registerUser(res.displayName, res.email, ApiUrl.Google_P, _selectedKnow, res.photoUrl,"Google");
//        print('Access Token: ${accessToken.accessToken.toString()}');
        }).catchError((error) {
          isSuccess = false;
          setState(() {});
          throw (error.toString());
        });
      }).catchError((error) {
        isSuccess = false;
        setState(() {});
        throw (error.toString());
      });
//    }
  }

  Future checkData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('know_more');

    if (prefs.containsKey('know_more')) {
      knowArray();
      checkChange();
    } else {
      checkChange();
    }
  }

  Future checkChange() async {
    final response = await http.post(
        Uri.parse(ApiUrl.CheckChange),
    );

    // print("Response: ${response.body}");
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['success']['change'] == 1) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('know_more', jsonEncode(data['success']['know_more']));
        // print("KnowMore: ${data['success']['know_more']}");
        knowArray();
      }
    } else {
      throw Exception('Failed to Login');
    }
  }

  void getToken() async{
    final response = await http.post(Uri.parse(ApiUrl.OurApi + "create_token"));
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (response.statusCode == 200) {
      // print(response.body);
      var data = jsonDecode(response.body);
      pref.setString('okNow', data['ok']);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<String>> knowArray() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('know_more')!;

    var value = jsonDecode(data);
    var sList = List<String>.from(value);
//          dropSelect.add(sList);
//     print("DropSelect: $sList");
    return sList;
  }

  Future registerUser(String name, String email, String password, String selectKnow, String image, String acctype) async {
    showLoading(true);

    Map data = {
      'name': name,
      'email': email,
      'password': password,
      'know_from': selectKnow,
      'account_type': acctype,
      'image': image,
      'firebase_token': ApiUrl.FireToken
    };
    SharedPreferences prefr = await SharedPreferences.getInstance();
    final response = await http.post(Uri.parse(ApiUrl.Register),
      body: data,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ${prefr.getString('okNow')}',
      },
    );
    // print(response.body);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['success'] == 1) {
        _showEmailSent(context);
      } else if(data['success']['exist'] == true) {
          showLoading(false);
          _showExistAlert(context);
      }else{
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.remove('okNow');
        prefs.setString('name', data['success']['NAME']);
        prefs.setString('_apiToken', data['success']['token']);
        prefs.setString('email', data['success']['EMAIL']);
        if(image != "" || image != null) {
          prefs.setString('userImage', image);
        }
        // print("UserData: ${data['success']}");
        if (prefs != null) {
//          signNek();
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeScreen()));
        }
        return true;
      }
    } else {
      throw Exception('Failed to Signup');
    }
  }

  void _showAlert(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Select How you Know About Us"),
              content: Text("Let us know how you know about us!"),
              actions: [
                FlatButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  void _showEmailSent(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Verify Email!"),
          content: Text("Verification Email has been sent to you Email!"),
          actions: [
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => SignInScreen()));
              },
            ),
          ],
        ));
  }

  void _showExistAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("User Already Exist"),
              content: Text("User Already exist from this email Id!"),
              actions: [
                FlatButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
//    var form = FutureBuilder(
//        future: knowArray(),
//    // ignore: missing_return
//    builder: (BuildContext context, AsyncSnapshot snapshot) {
//    if (snapshot.hasData) {
       var form = Form(
        key: _formKey,
        autovalidate: _autoValidate,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              cursorColor: muvi_colorPrimary,
              maxLines: 1,
              keyboardType: TextInputType.name,
              validator: (value) {
                return value!.isEmpty
                    ? keyString(context, "name_requires_err")
                    : null;
              },
              onSaved: (value) {
                name = value!;
              },
              textInputAction: TextInputAction.next,
              focusNode: nameFocus,
              onFieldSubmitted: (arg) {
                FocusScope.of(context).requestFocus(passFocus);
              },
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: muvi_colorPrimary),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: muvi_textColorPrimary),
                ),
                labelText: keyString(context, "hint_name"),
                labelStyle: TextStyle(
                    fontSize: ts_normal, color: muvi_textColorPrimary),
                suffixIcon: Icon(
                  Icons.account_box,
                  color: muvi_colorPrimary,
                  size: 20,
                ),
                contentPadding: new EdgeInsets.only(bottom: 1.5),
              ),
              style: TextStyle(
                  fontSize: ts_normal,
                  color: muvi_textColorPrimary,
                  fontFamily: font_regular),
            ).paddingBottom(spacing_standard_new),
            TextFormField(
              cursorColor: muvi_colorPrimary,
              maxLines: 1,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                return value!.validateEMail(context);
              },
              onSaved: (value) {
                email = value!;
              },
              textInputAction: TextInputAction.next,
              focusNode: emailFocus,
              onFieldSubmitted: (arg) {
                FocusScope.of(context).requestFocus(passFocus);
              },
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: muvi_colorPrimary),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: muvi_textColorPrimary),
                ),
                labelText: keyString(context, "hint_email"),
                labelStyle: TextStyle(
                    fontSize: ts_normal, color: muvi_textColorPrimary),
                suffixIcon: Icon(
                  Icons.mail_outline,
                  color: muvi_colorPrimary,
                  size: 20,
                ),
                contentPadding: new EdgeInsets.only(bottom: 1.5),
              ),
              style: TextStyle(
                  fontSize: ts_normal,
                  color: muvi_textColorPrimary,
                  fontFamily: font_regular),
            ).paddingBottom(spacing_standard_new),
            TextFormField(
              controller: _controller,
              obscureText: passwordVisible,
              cursorColor: muvi_colorPrimary,
              style: TextStyle(
                  fontSize: ts_normal,
                  color: muvi_textColorPrimary,
                  fontFamily: font_regular),
              validator: (value) {
                return value!.isEmpty
                    ? keyString(context, "error_pwd_requires")
                    : null;
              },
              focusNode: passFocus,
              onSaved: (value) {
                password = value!;
              },
              textInputAction: TextInputAction.done,
              decoration: new InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: muvi_colorPrimary),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: muvi_textColorPrimary),
                  ),
                  labelText: keyString(context, "hint_password"),
                  labelStyle: TextStyle(
                      fontSize: ts_normal, color: muvi_textColorPrimary),
                  contentPadding: new EdgeInsets.only(bottom: 1.5),
                  suffixIcon: new GestureDetector(
                    onTap: () {
                      setState(() {
                        passwordVisible = !passwordVisible;
                      });
                    },
                    child: new Icon(
                      passwordVisible ? Icons.visibility : Icons.visibility_off,
                      color: muvi_colorPrimary,
                      size: 20,
                    ),
                  )),
            ).paddingBottom(spacing_standard_new),
            TextFormField(
                obscureText: passwordVisible,
                cursorColor: muvi_colorPrimary,
                style: TextStyle(
                    fontSize: ts_normal,
                    color: muvi_textColorPrimary,
                    fontFamily: font_regular),
                focusNode: confirmPasswordFocus,
                validator: (value) {
                  if (value!.isEmpty) {
                    return keyString(
                        context, "error_confirm_password_required");
                  }
                  return _controller.text == value
                      ? null
                      : keyString(context, "error_password_not_match");
                },
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (arg) {
                  FocusScope.of(context).requestFocus(passFocus);
                },
                decoration: new InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: muvi_colorPrimary),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: muvi_textColorPrimary),
                  ),
                  labelText: keyString(context, "hint_confirm_password"),
                  labelStyle: TextStyle(
                      fontSize: ts_normal, color: muvi_textColorPrimary),
                  contentPadding:
                      EdgeInsets.only(bottom: 1.5, top: spacing_control),
                  suffixIcon: new GestureDetector(
                    onTap: () {
                      setState(() {
                        passwordVisible = !passwordVisible;
                      });
                    },
                    child: new Icon(
                      passwordVisible ? Icons.visibility : Icons.visibility_off,
                      color: muvi_colorPrimary,
                      size: 20,
                    ),
                  ),
                )),
//            Container(
//              decoration: BoxDecoration(
//                border: Border(bottom: BorderSide(color: Colors.white)),
//              ),
//              width: double.infinity,
//              child: DropdownButtonHideUnderline(
//                  child: DropdownButton<String>(
//                              dropdownColor: muvi_appBackground,
////                          value: _selectedKnow,
//                              items: snapshot.data.map<DropdownMenuItem<String>>((value) =>
//                                      new DropdownMenuItem<String>(
//                                        value: value,
//                                        child: new Text(value,
//                                            style: TextStyle(
//                                                color: muvi_textColorPrimary,
//                                                fontFamily: font_regular)),
//                                      ))
//                                  .toList(),
//                              hint: new Text(
//                                _selectedKnow,
//                                style:
//                                    new TextStyle(color: muvi_textColorPrimary),
//                              ),
//                              onChanged: (newValue) {
//                                setState(() {
//                                  _selectedKnow = newValue;
//                                });
//                              }).paddingTop(spacing_standard_new),
//              ),
//            ),
          ],
        ));
//    }
//    return Center(child: CircularProgressIndicator());
//        });
    var signUpButton = SizedBox(
      width: double.infinity,
      child: button(context, keyString(context, "sign_up"), () {
        final form = _formKey.currentState;
        if (form!.validate()) {
          form.save();
          if (_selectedKnow != null || _selectedKnow != "") {
            registerUser(name, email, password, _selectedKnow,"","Static");
//            _showAlert(context);
          } else {
            showLoading(false);
            _showAlert(context);
          }
        } else {
          setState(() => _autoValidate = true);
        }
      }),
    );

    var loginWithGoogle = iconButton(
            context, keyString(context, "signup_with_google"), ic_google, () {
      onSignInTap();
    }, backgroundColor: Colors.white)
        .paddingOnly(left: spacing_standard_new, right: spacing_standard_new);

    return WillPopScope(
        onWillPop: () async{
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => SignInScreen()));
      return false;
    },
    child: Scaffold(
      backgroundColor: muvi_appBackground,
      appBar: PreferredSize(
    preferredSize: const Size.fromHeight(100),
    child:appBarLayout(context, keyString(context, "register"),
          darkBackground: false)),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Align(
                    alignment: Alignment.center,
                    child: flixTitle(context).paddingAll(spacing_large)),
                text(context, keyString(context, "register_desc"),
                        fontSize: ts_normal,
                        textColor: muvi_textColorPrimary,
                        maxLine: 2,
                        isCentered: true)
                    .paddingOnly(
                        top: spacing_control,
                        left: spacing_large,
                        right: spacing_large),
                form.paddingOnly(
                    left: spacing_standard_new,
                    right: spacing_standard_new,
                    top: spacing_large),
                signUpButton.paddingOnly(
                    left: spacing_standard_new,
                    right: spacing_standard_new,
                    top: spacing_large),
//                Align(
//                    alignment: Alignment.center,
//                    child: text(context, keyString(context, "signup_with"),
//                            fontSize: ts_medium)
//                        .paddingAll(spacing_standard_new)),
//                loginWithGoogle
//                  ..paddingOnly(
//                      left: spacing_standard_new, right: spacing_standard_new,bottom: 50),
                SizedBox(height: 20,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    text(context, keyString(context, "already_have_account"),
                        fontSize: ts_medium, textColor: muvi_textColorPrimary)
                        .paddingAll(spacing_control),
                    GestureDetector(
                      onTap: (){
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignInScreen()));
                      },
                      child: text(context, keyString(context, "login"),
                        fontSize: ts_medium,
                        fontFamily: font_medium,
                        textColor: muvi_colorPrimary)
                        .paddingAll(spacing_control)
                    ),
                  ],
                ).onTap(() {
                  finish(context);
                  launchScreen(context, SignInScreen.tag);
                }),
              ],
            ).paddingOnly(bottom: 120),
          ),
//          Container(
//            margin: EdgeInsets.all(spacing_standard_new),
//            height: double.infinity,
//            child: Align(
//              alignment: Alignment.bottomCenter,
//              child: Row(
//                crossAxisAlignment: CrossAxisAlignment.center,
//                mainAxisAlignment: MainAxisAlignment.center,
//                children: <Widget>[
//                  text(context, keyString(context, "already_have_account"),
//                          fontSize: ts_medium, textColor: muvi_textColorPrimary)
//                      .paddingAll(spacing_control),
//                  text(context, keyString(context, "login"),
//                          fontSize: ts_medium,
//                          fontFamily: font_medium,
//                          textColor: muvi_colorPrimary)
//                      .paddingAll(spacing_control)
//                      .onTap(() {
//                    finish(context);
//                    launchScreen(context, SignInScreen.tag);
//                  })
//                ],
//              ).onTap(() {
//                finish(context);
//                launchScreen(context, SignInScreen.tag);
//              }),
//            ),
//          ),
          Center(child: loadingWidgetMaker().visible(isLoading))
        ],
      ),
    ));
  }

  onForgotPasswordClicked(context) {}

  doSignUp(context) {
    finish(context);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen()
        ),
        ModalRoute.withName("/HomeScreen")
    );
  }
}
