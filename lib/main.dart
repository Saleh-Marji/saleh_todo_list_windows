import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:saleh_todo_list_windows/controllers/lists_controller.dart';
import 'package:saleh_todo_list_windows/screens/home_screen.dart';

import 'constants.dart';

void main() {
  Get.put(TodoListsController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Saleh Todo List',
      debugShowCheckedModeBanner: false,
      // scrollBehavior: MyScrollBehavior(),
      initialRoute: kHomeRoute,
      routes: {
        kHomeRoute: (_) => const HomeScreen(),
      },
    );
  }
}

class MyScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.touch,
      };
}
