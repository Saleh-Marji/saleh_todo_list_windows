import 'package:flutter/material.dart';
import 'package:saleh_todo_list_windows/constants.dart';

class CustomCheckbox extends StatelessWidget {
  const CustomCheckbox({
    Key? key,
    this.width = 40.0,
    this.height = 40.0,
    this.color,
    this.iconSize = 30,
    this.onChanged,
    this.checkColor,
    required this.checked,
  }) : super(key: key);

  final double width;
  final double height;
  final Color? color;
  final bool checked;
  final double? iconSize;
  final Color? checkColor;
  final Function(bool?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged?.call(!checked);
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: checked ? kColorMain : kColorMainLight,
          border: Border.all(
            color: kColorMain,
            // width: 2.0,
          ),
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: checked
            ? Icon(
                Icons.check,
                size: iconSize,
                color: checkColor ?? Colors.white,
              )
            : null,
      ),
    );
  }
}
