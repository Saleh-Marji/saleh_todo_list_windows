import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:saleh_todo_list_windows/constants.dart';

class Dialogs {
  static Future<T?> showChildDialog<T>(
    BuildContext context,
    String title,
    Widget child, [
    Map<String, VoidCallback>? actions,
    VoidCallback? onEnter,
  ]) {
    Widget innerChild = ContentDialog(
      title: Text(
        title,
        style: kTextStyleMain.copyWith(fontSize: 35),
      ),
      content: child,
      actions: actions == null ? null : getButtons(actions),
    );
    if (onEnter != null) {
      innerChild = RawKeyboardListener(
        autofocus: true,
        focusNode: FocusNode(),
        onKey: (event) {
          if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
            onEnter();
          }
        },
        child: innerChild,
      );
    }
    return showDialog<T>(
      context: context,
      builder: (_) {
        return innerChild;
      },
    );
  }

  static Future<T?> showContentDialog<T>(
    BuildContext context,
    String title,
    String content, [
    Map<String, VoidCallback>? actions,
    VoidCallback? onEnter,
  ]) {
    return showChildDialog(
      context,
      title,
      Text(
        content,
        style: kTextStyleMain.copyWith(fontSize: 25),
      ),
      actions,
      onEnter,
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
      () => Navigator.pop(context, true),
    );
  }

  static Widget _button(String label, void Function() onPressed) {
    return Button(
      style: ButtonStyle(
        backgroundColor: ButtonState.all(kColorMain),
      ),
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          label,
          style: kTextStyleMain.copyWith(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  static List<Widget> getButtons(Map<String, void Function()> map) =>
      map.entries.map((e) => _button(e.key, e.value)).toList();

  static Future<void> showAlertDialog(BuildContext context, String content) async {
    return showContentDialog(
      context,
      'Alert',
      content,
      {
        'Ok': () => Navigator.pop(context),
      },
      () => Navigator.pop(context),
    );
  }
}
