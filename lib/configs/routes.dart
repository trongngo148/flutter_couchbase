import 'package:get/get.dart';

import '../home/screens/home_screen.dart';

class Routes {
  static const String home = '/';

  static final List<GetPage> getPages = [
    GetPage(name: home, page: () => HomeScreen()),
  ];
}
