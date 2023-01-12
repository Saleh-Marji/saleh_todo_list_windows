import 'package:fluent_ui/fluent_ui.dart';
import 'package:saleh_todo_list_windows/constants.dart';

class Dialogs {
  static Future<T?> showChildDialog<T>(
    BuildContext context,
    String title,
    Widget child, [
    Map<String, VoidCallback>? actions,
  ]) {
    return showDialog<T>(
      context: context,
      builder: (_) {
        return ContentDialog(
          title: Text(
            title,
            style: kTextStyleMain.copyWith(fontSize: 35),
          ),
          content: child,
          actions: actions == null ? null : getButtons(actions),
        );
      },
    );
  }

  static Future<T?> showContentDialog<T>(
    BuildContext context,
    String title,
    String content, [
    Map<String, VoidCallback>? actions,
  ]) {
    return showChildDialog(
      context,
      title,
      Text(
        content,
        style: kTextStyleMain.copyWith(fontSize: 25),
      ),
      actions,
    );
  }

  static Future<bool?> showConfirmationDialog(BuildContext context, String content) {
    return showContentDialog<bool>(
      context,
      'Confirmation',
      content,
      {
        'Ok': () {
          Navigator.pop(context, true);
        },
        'Cancel': () {
          Navigator.pop(context);
        }
      },
    );
  }

  static Widget _button(String label, void Function() onPressed) {
    return Button(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          label,
          style: kTextStyleMain.copyWith(fontSize: 16, color: Colors.white),
        ),
      ),
      style: ButtonStyle(
        backgroundColor: ButtonState.all(kColorMain),
      ),
      onPressed: onPressed,
    );
  }

  static List<Widget> getButtons(Map<String, void Function()> map) =>
      map.entries.map((e) => _button(e.key, e.value)).toList();

  static Future<void> showAlertDialog(BuildContext context, String content) async {
    return showContentDialog(context, 'Alert', content, {
      'Ok': () => Navigator.pop(context),
    });
  }
}
