import 'dart:convert';

import 'package:Anime4U/integration/Api.dart';
import 'package:Anime4U/resources/colors.dart';
import 'package:Anime4U/resources/images.dart';
import 'package:Anime4U/resources/size.dart';
import 'package:Anime4U/utils/app_localizations.dart';
import 'package:Anime4U/utils/app_widgets.dart';
import 'package:Anime4U/utils/constants.dart';
import 'package:Anime4U/utils/widget_extensions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'flix_signup.dart';
import 'home_screen.dart';

class SignInScreen extends StatefulWidget {
  static String tag = '/SignInScreen';

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  FocusNode passFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String email;
  late String password;
  late String firebaseToken;
  bool _autoValidate = false;
  bool passwordVisible = false;
  bool isLoading = false;
  var isSuccess = false;
  var name = 'UserName';
  var emailS = 'Email id';
  var photoUrl = '';
  var registerShow = true;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  _register() {
    _firebaseMessaging.subscribeToTopic('all');
    _firebaseMessaging
        .getToken()
        .then((token) => ApiUrl.FireToken = firebaseToken = token.toString());
  }

  showLoading(bool show) {
    setState(() {
      isLoading = show;
    });
  }

  hideLoading(bool hide) {
    setState(() {
      isLoading = hide;
    });
  }

  @override
  void initState() {
    super.initState();
    _register();
    checkLogin();
//    checkChange();
    donationChange();
  }

  Future donationChange() async {
    final response = await http.get(Uri.parse(ApiUrl.Donation));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
//      print("Donation: ${data[0]['donation']}");
      String user = data[0]['donation'];
      prefs.setString('donation', user);
    } else {
      throw Exception('Failed to load album');
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
//        print("KnowMore: ${data['success']['know_more']}");
      }
    } else {
      throw Exception('Failed to Login');
    }
  }

  void onSignInTap() async {
    setState(() {
      isLoading = true;
    });
    GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
      'email',
    ]);
    googleSignIn.signOut();
    await googleSignIn.signIn().then((res) async {
      await res.authentication.then((accessToken) async {
        fetchUsers(res.displayName, res.email, ApiUrl.Google_P, res.photoUrl,'google');
//        print('Access Token: ${accessToken.accessToken.toString()}');
      }).catchError((error) {
        isSuccess = false;
        setState(() {});
        throw (error.toString());
      });
    }).catchError((error) {
      hideLoading(false);
      isSuccess = false;
      setState(() {});
      throw (error.toString());
    });
  }

  checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    if (prefs.getString('_apiToken') != null) {
      doSignIn(context);
    }
  }

  void _showAlert(BuildContext context) {
    hideLoading(false);
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Login Error!"),
              content: Text("Username & Password is not Correct"),
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

  void _showAlertWrong(BuildContext context) {
    hideLoading(false);
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Something Went Wrong"),
              content: Text("Please Try again later!"),
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

  void _showAlertBlock(BuildContext context) {
    hideLoading(false);
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Account Blocked"),
              content: Text(
                  "Your Account has been Blocked by Admin. Please Contact Admin"),
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

  void _showEmailNotVerified(BuildContext context) {
    hideLoading(false);
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Email Not Verified!"),
              content: Text(
                  "Please Verify your Email. Verification link has been sent to your mail."),
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

  Future fetchUsers(String name, String email, String password, String image,String type) async {
    setState(() {
      isLoading = true;
    });
    // print("name: $name,Email: $email, Password: $password, Firebase: $firebaseToken");
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    Map data = {
      'name': name,
      'email': email,
      'password': password,
      'firebase': firebaseToken,
      'type': type,
      'version': version
    };
    final response = await http.post(
      Uri.parse(ApiUrl.Login),
      body: data,
    );
    print(response.body);
    if (response.statusCode == 200) {
      var data;
      if (response.body != "Unauthorised") {
        data = jsonDecode(response.body);
      }
      if (response.body == "Unauthorised") {
        hideLoading(false);
        _showAlert(context);
      } else if (response.body == "0") {
        hideLoading(false);
        _showAlertWrong(context);
      } else if (data['success'] == "blocked") {
        _showAlertBlock(context);
      } else if (data['success'] == 0) {
        _showEmailNotVerified(context);
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('name', data['success']['NAME']);
        prefs.setString('_apiToken', data['success']['token']);
        prefs.setString('email', email);
        if (image != "" || image != null) {
          prefs.setString('userImage', image);
        }
//      print("UserData: ${data['success']['token']}");
        hideLoading(false);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen()
            ));
        return true;
      }
    } else {
      throw Exception('Failed to Login');
    }
  }

  @override
  Widget build(BuildContext context) {
    var form = Form(
      key: _formKey,
      autovalidate: _autoValidate,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          formField(
            context,
            "hint_email",
            maxLine: 1,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              return value!.validateEMail(context);
            },
            onSaved: (String value) {
              setState(() {
                email = value;
              });
            },
            textInputAction: TextInputAction.next,
            focusNode: emailFocus,
            nextFocus: passFocus,
            suffixIcon: Icons.mail_outline,
          ).paddingBottom(spacing_standard_new),
          formField(
            context,
            "hint_password",
            isPassword: true,
            isPasswordVisible: passwordVisible,
            validator: (value) {
              return value!.isEmpty
                  ? keyString(context, "error_pwd_requires")
                  : null;
            },
            focusNode: passFocus,
            onSaved: (String value) {
              setState(() {
                password = value;
              });
            },
            textInputAction: TextInputAction.done,
            suffixIconSelector: () {
              setState(() {
                passwordVisible = !passwordVisible;
              });
            },
            suffixIcon:
                passwordVisible ? Icons.visibility : Icons.visibility_off,
          )
        ],
      ),
    );
    var signinButton = SizedBox(
        width: double.infinity,
        child: GestureDetector(
            onTap: () {
              final form = _formKey.currentState;
              if (form!.validate()) {
                form.save();
                isLoading = true;
                fetchUsers("", email, password, "",'static');
//          FutureBuilder(
//              future: fetchUsers(email, password),
//              builder: (BuildContext context, AsyncSnapshot snapshot) {
//                if (snapshot.hasData) {
//                  doSignIn(context);
//                }
//                return Container();
//              });
              } else {}
            },
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: muvi_colorPrimaryDark,
                borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              child: Center(
                child: Text(
                "Sign In",
                style: TextStyle(color: Colors.white,fontSize: 20),
              )),
            )));
    var loginWithGoogle = iconButton(
            context, keyString(context, "signin_with_google"), ic_google, () {
      onSignInTap();
    }, backgroundColor: Colors.white)
        .paddingOnly(left: spacing_standard_new, right: spacing_standard_new);

    return WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeScreen()));
          return false;
        },
        child: Scaffold(
          backgroundColor: muvi_appBackground,
          appBar: PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: appBarLayout(context, keyString(context, "login"),
                  darkBackground: true)),
          body: Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Align(
                        alignment: Alignment.center,
                        child: flixTitle(context).paddingAll(spacing_large)),
                    text(context, keyString(context, "login_desc"),
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
//                text(context, keyString(context, "forgot_pswd"),
//                        fontSize: ts_medium, textColor: muvi_colorPrimary)
//                    .paddingAll(spacing_standard_new)
//                    .onTap(() {
//                  onForgotPasswordClicked(context);
//                }),
                    signinButton.paddingOnly(
                        top: spacing_standard_new * 2,
                        left: spacing_standard_new,
                        right: spacing_standard_new),
                    Align(
                        alignment: Alignment.center,
                        child: text(context, keyString(context, "signin_with"),
                                fontSize: ts_medium)
                            .paddingAll(spacing_standard_new)),
                    loginWithGoogle
                      ..paddingOnly(
                          left: spacing_standard_new,
                          right: spacing_standard_new),
                    SizedBox(
                      height: 40,
                    ),
                    registerShow
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              text(context,
                                      keyString(context, "not_have_account"),
                                      fontSize: ts_medium,
                                      textColor: muvi_textColorPrimary)
                                  .paddingAll(spacing_control),
                              GestureDetector(
                                onTap: (){
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SignUpScreen()));
                                },
                                child: text(context, keyString(context, "register"),
                                      fontSize: ts_medium,
                                      fontFamily: font_medium,
                                      textColor: muvi_colorPrimary)
                                  .paddingAll(spacing_control)
                              ),
                            ],
                          )
                        : Container(),
                  ],
                ),
              ),
              Center(child: loadingWidgetMaker().visible(isLoading))
            ],
          ),
        ));
  }

  onForgotPasswordClicked(context) {}

  doSignIn(context) {
    finish(context);
    launchScreen(context, HomeScreen.tag);
  }
}

class Users {
  final String id;
  final String name;
  final String token;

  Users(this.id, this.name, this.token);
}
