import 'package:fluent_ui/fluent_ui.dart';
import 'package:saleh_todo_list_windows/screens/home_screen.dart';

import 'constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Saleh Todo List',
      initialRoute: kHomeRoute,
      routes: {
        kHomeRoute: (_) => HomeScreen(),
      },
    );
  }
}
