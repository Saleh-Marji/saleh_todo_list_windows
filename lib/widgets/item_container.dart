import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:saleh_todo_list_windows/constants.dart';
import 'package:saleh_todo_list_windows/modals/todo_item.dart';
import 'package:saleh_todo_list_windows/utils.dart';
import 'package:saleh_todo_list_windows/widgets/custom_check_box.dart';

class ItemContainer extends StatefulWidget {
  const ItemContainer(
    this.item, {
    Key? key,
    required this.onDoneChanged,
    required this.onEditPressed,
    required this.onLongPressed,
  }) : super(key: key);

  final TodoItem item;
  final void Function(bool done) onDoneChanged;
  final VoidCallback onEditPressed;
  final VoidCallback onLongPressed;

  @override
  State<ItemContainer> createState() => _ItemContainerState();
}

class _ItemContainerState extends State<ItemContainer> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return mat.Material(
      color: Colors.transparent,
      child: mat.ListTile(
        tileColor: kColorMainLight,
        onLongPress: widget.onLongPressed,
        onTap: widget.item.canExpand
            ? () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              }
            : null,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            widget.item.title,
            style: kTextStyleMain.copyWith(
              decoration: widget.item.done ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
        subtitle: isExpanded
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(
                    style: DividerThemeData(
                      horizontalMargin: EdgeInsets.only(right: 10),
                      thickness: 1,
                      decoration: BoxDecoration(
                        color: kColorMain,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  if (widget.item.hasDateTime)
                    Text(
                      Utils.dateTimeToString(widget.item.dateTime!),
                      style: kTextStyleMain.copyWith(
                        fontSize: 20,
                        decoration: widget.item.done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  if (widget.item.hasDescription)
                    Text(
                      widget.item.description!,
                      style: kTextStyleMain.copyWith(
                        fontSize: 20,
                        decoration: widget.item.done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              )
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: kColorMain),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.item.canExpand)
              IconButton(
                icon: Icon(
                  isExpanded ? FluentIcons.chevron_up : FluentIcons.chevron_down,
                  size: 30,
                ),
                onPressed: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
              ),
            if (widget.item.canExpand) const SizedBox(width: 10),
            IconButton(
              icon: Icon(
                FluentIcons.edit,
                size: 30,
              ),
              onPressed: () {
                widget.onEditPressed();
              },
            ),
            SizedBox(width: 10),
            CustomCheckbox(
              checked: widget.item.done,
              onChanged: (val) {
                widget.onDoneChanged(val ?? false);
              },
            )
          ],
        ),
      ),
    );
  }
}
