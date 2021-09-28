import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:Anime4U/utils/AppConstant.dart';
// import 'package:Anime4U/imdbanime/models/flix_response.dart';
import 'package:Anime4U/resources/colors.dart';
import 'package:Anime4U/resources/images.dart';
import 'package:Anime4U/resources/size.dart';
import 'package:Anime4U/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'app_localizations.dart';
import 'constants.dart';
import 'widget_extensions.dart';

Widget text(context, var text,
    {var fontSize = ts_medium,
    textColor = muvi_textColorSecondary,
    var fontFamily = 'Monsterrat',
    var isCentered = false,
    var maxLine = 1,
    var latterSpacing = 0.1,
    var isLongText = false,
    var isJustify = false,
    var aDecoration}) {
  return Text(
    text,
    textAlign: isCentered
        ? TextAlign.center
        : isJustify
            ? TextAlign.justify
            : TextAlign.start,
    maxLines: isLongText ? 20 : maxLine,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
        fontFamily: 'Monsterrat',
        fontWeight: FontWeight.w600,
        decoration: aDecoration != null ? aDecoration : null,
        fontSize: double.parse(fontSize.toString()).toDouble(),
        height: 1.5,
        color: textColor == muvi_textColorSecondary
            ? muvi_textColorSecondary
            : textColor.toString().isNotEmpty
                ? textColor
                : null,
        letterSpacing: latterSpacing),
  );
}

Widget toolBarTitle(BuildContext context, String title) {
  return text(context, title,
      fontSize: ts_large,
      textColor: muvi_textColorPrimary,
      fontFamily: font_bold);
}

Widget screenTitle(BuildContext context, var aHeadingText) {
  return text(context, aHeadingText,
      fontSize: ts_xlarge,
      fontFamily: font_bold,
      textColor: muvi_textColorPrimary);
}

Widget itemTitle(BuildContext context, var titleText,
    {var fontfamily = font_medium}) {
  return text(context, titleText,
      fontSize: ts_normal,
      fontFamily: fontfamily,
      textColor: muvi_textColorPrimary);
}

Widget itemSubTitle(BuildContext context, var titleText,
    {var fontFamily = font_regular,
    var fontsize = ts_normal,
    var colorThird = false,
    isLongText = true}) {
  return text(context, titleText,
      fontSize: fontsize,
      fontFamily: fontFamily,
      isLongText: isLongText,
      textColor: colorThird ? muvi_textColorThird : muvi_textColorSecondary);
}

class MoreLessText extends StatefulWidget {
  var titleText;
  var fontFamily = font_regular;
  var fontsize = ts_normal;
  var colorThird = false;

  MoreLessText(this.titleText,
      {this.fontFamily = font_regular,
      this.fontsize = ts_normal,
      this.colorThird = false});

  @override
  MoreLessTextState createState() => MoreLessTextState();
}

class MoreLessTextState extends State<MoreLessText> {
  var isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        text(context, widget.titleText,
            fontSize: widget.fontsize,
            fontFamily: widget.fontFamily,
            isLongText: isExpanded,
            maxLine: 2,
            textColor: widget.colorThird
                ? muvi_textColorThird
                : muvi_textColorSecondary),
        text(
          context,
          isExpanded ? "Read less" : "Read more",
          textColor: muvi_textColorPrimary,
          fontSize: widget.fontsize,
        ).onTap(() {
          setState(() {
            isExpanded = !isExpanded;
          });
        })
      ],
    );
  }
}

Widget headingText(BuildContext context, var titleText) {
  return text(context, titleText,
      fontSize: 22,
      fontFamily: font_bold,
      textColor: Colors.white);
}

Widget headingWidViewAll(BuildContext context, var titleText, callback, bool isShow) {
  return Row(
    children: <Widget>[
      Expanded(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(width: 20,height: 5,margin: EdgeInsets.only(top: 7),decoration: BoxDecoration(color: muvi_colorPrimary),),
              SizedBox(width: 10,),
              headingText(context, titleText),
            ])
      ),
      isShow ? InkWell(onTap: callback, child: itemSubTitle(context, keyString(context, "view_more"), fontsize: ts_medium, fontFamily: font_medium, colorThird: true).paddingAll(spacing_control_half)):
          Container()
    ],
  );
}

Widget appBarLayout(context, text, {darkBackground = true}) {
  return AppBar(
    elevation: 0,
    iconTheme: IconThemeData(color: muvi_colorPrimary),
    title: toolBarTitle(context, text),
    backgroundColor:
        darkBackground ? muvi_appBackground : Colors.transparent,
  );
}

BoxDecoration boxDecoration(BuildContext context,
    {double radius = 2,
    Color color = Colors.transparent,
    Color bgColor = muvi_white,
    var showShadow = false}) {
  return BoxDecoration(
      //gradient: LinearGradient(colors: [bgColor, whiteColor]),
      color: bgColor == muvi_white ? muvi_navigationBackground : bgColor,
      boxShadow: showShadow
          ? [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 5,
                  spreadRadius: 3,
                  offset: Offset(1, 3))
            ]
          : [BoxShadow(color: Colors.transparent)],
      border: Border.all(color: color),
      borderRadius: BorderRadius.all(Radius.circular(radius)));
}

Widget button(BuildContext context, buttonText, VoidCallback callback) {
  return MaterialButton(
    textColor: muvi_textColorPrimary,
    color: muvi_navigationBackground,
    splashColor: Colors.grey.withOpacity(0.2),
    padding: EdgeInsets.only(top: 12, bottom: 12),
    child: text(context, buttonText,
        fontSize: ts_normal, fontFamily: font_medium, textColor: muvi_textColorPrimary),
    shape: RoundedRectangleBorder(
      borderRadius: new BorderRadius.circular(spacing_control),
      side: BorderSide(color: muvi_navigationBackground),
    ),
    onPressed: callback,
  );
}

Widget iconButton(context, buttonText, icon, callBack,
    {backgroundColor,
    borderColor,
    buttonTextColor,
    iconColor,
    padding = 12.0}) {
  return MaterialButton(
    color: backgroundColor == null ? muvi_colorPrimary : backgroundColor,
    splashColor: Colors.grey.withOpacity(0.2),
    padding: EdgeInsets.only(top: padding, bottom: padding),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        iconColor == null
            ? Image.asset(
                icon,
                width: 16,
                height: 16,
              )
            : Image.asset(
                icon,
                width: 16,
                height: 16,
                color: iconColor,
              ),
        text(context, buttonText,
                fontSize: ts_normal,
                fontFamily: font_medium,
                textColor:
                    buttonTextColor == null ? Colors.black : buttonTextColor)
            .paddingLeft(spacing_standard),
      ],
    ),
    shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(spacing_control),
        side: BorderSide(
            width: 0.8,
            color: borderColor == null ? muvi_colorPrimary : borderColor)),
    onPressed: callBack,
  );
}

// DotsDecorator dotsDecorator(context) {
//   return DotsDecorator(
//       color: Colors.grey.withOpacity(0.5),
//       activeColor: muvi_colorPrimary,
//       activeSize: Size.square(5.0),
//       size: Size.square(5.0),
//       spacing: EdgeInsets.all(spacing_control_half));
// }

Widget flixTitle(context) {
  return Container(
    decoration: BoxDecoration(
      boxShadow: [
//        BoxShadow(color: muvi_appBackground, blurRadius: 50),
      ]
    ),
      child: Image.asset(
    ic_logo,
    width: 150,
//    height: 100,
  ));
}

Widget loadingWidgetMaker() {
  return Container(
    alignment: Alignment.center,
    child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: spacing_control,
        margin: EdgeInsets.all(4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: Container(
          width: 45,
          height: 45,
          padding: const EdgeInsets.all(8.0),
          child: CircularProgressIndicator(
            strokeWidth: 3,
          ),
        )),
  );
}

Widget notificationIcon(context, cartCount) {
  return InkWell(
    child: Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          width: 30,
          height: 30,
          margin: EdgeInsets.only(right: 12),
          child: Icon(
            Icons.notifications_none,
            color: muvi_textColorPrimary,
            size: 28,
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Container(
            margin: EdgeInsets.only(top: spacing_standard),
            padding: EdgeInsets.all(4),
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: muvi_navigationBackground),
            child: Text(cartCount.toString(),style: TextStyle(fontSize: 12, color: muvi_white)),
          ).visible(cartCount != 0),
        )
      ],
    ),
    onTap: () {
      // launchScreen(context, NotificationScreen.tag,);
    },
  );
}

Widget subType(context, key, VoidCallback callback, icon) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      icon != null
          ? Image.asset(
              icon,
              width: 20,
              height: 20,
              color: muvi_textColorPrimary,
            ).paddingRight(spacing_standard)
          : SizedBox(),
      Expanded(child: itemTitle(context, keyString(context, key))),
      Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: muvi_textColorThird,
      )
    ],
  )
      .paddingOnly(
          left: spacing_standard_new,
          right: 12,
          top: spacing_standard_new,
          bottom: spacing_standard_new)
      .onTap(callback);
}

Widget hdWidget(context) {
  return Container(
    decoration: BoxDecoration(
        color: muvi_colorPrimary,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(spacing_control_half))),
    padding: EdgeInsets.only(
        top: 0, bottom: 0, left: spacing_control, right: spacing_control),
    child: text(context, "HD",
        textColor: Colors.black, fontSize: ts_medium, fontFamily: font_bold),
  );
}

Widget formField(context, hint,
    {isEnabled = true,
    isDummy = false,
    controller,
    isPasswordVisible = false,
    isPassword = false,
    keyboardType = TextInputType.text,
    FormFieldValidator<String>? validator,
    onSaved,
    textInputAction = TextInputAction.next,
    FocusNode? focusNode,
    FocusNode? nextFocus,
    IconData? suffixIcon,
    maxLine = 1,
    suffixIconSelector}) {
  return TextFormField(
    controller: controller,
    obscureText: isPassword && isPasswordVisible,
    cursorColor: muvi_colorPrimary,
    maxLines: maxLine,
    keyboardType: keyboardType,
    validator: validator,
    onSaved: onSaved,
    textInputAction: textInputAction,
    focusNode: focusNode,
    onFieldSubmitted: (arg) {
      if (nextFocus != null) {
        FocusScope.of(context).requestFocus(nextFocus);
      }
    },
    decoration: InputDecoration(
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: muvi_colorPrimary),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: muvi_textColorPrimary),
      ),
      labelText: keyString(context, hint),
      labelStyle: TextStyle(fontSize: ts_normal, color: muvi_textColorPrimary),
      suffixIcon: isPassword && isPasswordVisible
          ? GestureDetector(
              onTap: suffixIconSelector,
              child: new Icon(
                suffixIcon,
                color: muvi_colorPrimary,
                size: 20,
              ),
            )
          : Icon(
              suffixIcon,
              color: muvi_colorPrimary,
              size: 20,
            ),
      contentPadding: new EdgeInsets.only(bottom: 2.0),
    ),
    style: TextStyle(
        fontSize: ts_normal,
        color: isDummy ? Colors.transparent : muvi_textColorPrimary,
        fontFamily: font_regular),
  );
}
