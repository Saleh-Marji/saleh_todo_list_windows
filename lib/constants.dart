import 'package:fluent_ui/fluent_ui.dart';
import 'package:path_provider/path_provider.dart';

Future<String> get kFilePath async =>
    '${(await getApplicationDocumentsDirectory()).absolute.path}\\SalehTodoList\\lists.json';

const //text styles
    kTextStyleMain = TextStyle(fontSize: 30, color: kColorMainText);

const //colors
    kColorMain = Color(0xFF6B2FA5),
    kColorMainLight = Color(0xFFC3B0DA),
    kColorMainText = Color(0xff030438);

const //routes
    kHomeRoute = 'home';
