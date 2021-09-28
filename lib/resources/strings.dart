import 'package:Anime4U/utils/app_localizations.dart';

const app_name = "Anime4u";

const adId1 = '589629705535465_589637128868056';
const adId2 = '589629705535465_589672872197815';
const searchAdId = '589629705535465_594616311703471';
const watchAdId = '589629705535465_589646745533761';
const intersAdId = '589629705535465_606749537156815';

const walk_titles = ["Welcome to " + app_name, "Welcome to " + app_name, "Welcome to " + app_name];

const walk_sub_titles = [
  "Look back and reflect on your memories and growth over time",
  "Look back and reflect on your memories and growth over time",
  "Look back and reflect on your memories and growth over time"
];

List<String> getGenders(context) {
  return [
    keyString(context, "male")!,
    keyString(context, "female")!,
  ];
}
