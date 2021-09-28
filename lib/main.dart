import 'package:Anime4U/screens/splash_screen.dart';
import 'package:Anime4U/utils/app_localizations.dart';
// import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:wakelock/wakelock.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

   await Firebase.initializeApp();
  //  FacebookAudienceNetwork.init();
  // await FlutterDownloader.initialize(debug: true);
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  Wakelock.enable();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Observer(
        builder: (_) => MaterialApp(
              debugShowCheckedModeBanner: false,
              localizationsDelegates: [MuviAppLocalizations.delegate],
              supportedLocales: [Locale('en', '')],
              home: SplashScreen(),
            ));
  }
}
