import 'dart:async';
import 'package:couchbase_lite/couchbase_lite.dart';
import 'package:couchbase_lite_example/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'configs/routes.dart';
import 'configs/theme.dart';
import 'home/providers/home_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [Provider(create: (context) => HomeProvider())],
      child: Consumer(
        builder: (context, value, child) => GetMaterialApp(
          darkTheme: themeNormal(context),
          themeMode: ThemeMode.dark,
          debugShowCheckedModeBanner: false,
          initialRoute: Routes.home,
          getPages: Routes.getPages,
        ),
      ),
    ),
  );
}
