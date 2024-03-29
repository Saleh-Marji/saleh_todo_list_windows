import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'package:get/get.dart';
import 'package:saleh_todo_list_windows/controllers/lists_controller.dart';
import 'package:saleh_todo_list_windows/widgets/dialogs.dart';

import '../../constants.dart';
import '../../modals/todo_list.dart';
import '../common_widgets.dart';

final controller = Get.find<TodoListsController>();

class Drawer extends StatefulWidget {
  const Drawer({Key? key}) : super(key: key);

  @override
  State<Drawer> createState() => DrawerState();
}

class DrawerState extends State<Drawer> {
  // bool isOpen = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: kColorMain)),
      ),
      // duration: const Duration(milliseconds: 150),
      width: 250,
      child: Column(
        children: [
          Container(
            height: 250,
            color: kColorMainLight.withOpacity(0.4),
            padding: const EdgeInsets.all(50),
            child: wGetLogoWidget(),
          ),
          const Divider(
            style: DividerThemeData(
                horizontalMargin: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: kColorMainLight,
                )),
          ),
          ListTile(
            leading: const Icon(FluentIcons.add),
            title: const Text('Add List'),
            onPressed: () async {
              String? title = await Dialogs.showChildDialog(context, 'Add List', const _AddListDialog());
              if (title != null) {
                controller.addList(title);
              }
            },
          ),
          ListTile(
            leading: const Icon(FluentIcons.list),
            title: const Text('Todo Lists'),
            trailing: IconButton(
              icon: const Icon(FluentIcons.delete),
              onPressed: () async {
                bool? ok = await Dialogs.showConfirmationDialog(
                  context,
                  'Are you sure you want to delete all lists?',
                );
                if (!(ok ?? false)) {
                  return;
                }
                ok = await Dialogs.showConfirmationDialog(
                  context,
                  'Dead sure??',
                );
                if (!(ok ?? false)) {
                  return;
                }
                controller.deleteAllLists();
              },
            ),
          ),
          GetBuilder<TodoListsController>(
            init: controller,
            builder: (controller) {
              List<TodoList> lists = controller.lists;
              return Expanded(
                child: m.Material(
                  color: Colors.transparent,
                  child: GetBuilder<TodoListsController>(
                      init: Get.find<TodoListsController>(),
                      builder: (controller) {
                        return ReorderableListView.builder(
                          buildDefaultDragHandles: false,
                          onReorder: (oldIndex, newIndex) {
                            if (newIndex > oldIndex) newIndex--;
                            controller.reorderList(oldIndex, newIndex);
                          },
                          itemCount: lists.length,
                          itemBuilder: (_, index) {
                            return ReorderableDragStartListener(
                              index: index,
                              key: ValueKey(lists[index].title),
                              child: m.ListTile(
                                title: Text('- ${lists[index].title} (${lists[index].unDoneCount})'),
                                onTap: () {
                                  controller.openListInTab(index);
                                },
                                onLongPress: () async {
                                  bool? ok = await Dialogs.showConfirmationDialog(
                                    context,
                                    'Are you sure you want to delete this todo list?',
                                  );

                                  if (!(ok ?? false)) {
                                    return;
                                  }

                                  controller.deleteList(lists[index].title);
                                },
                                trailing: IconButton(
                                  icon: const Icon(FluentIcons.edit),
                                  onPressed: () async {
                                    String oldTitle = lists[index].title;
                                    String? newTitle = await Dialogs.showChildDialog(
                                      context,
                                      'Edit List Name',
                                      _AddListDialog(
                                        initialTitle: oldTitle,
                                      ),
                                    );
                                    if (newTitle != null) {
                                      controller.editListTitle(oldTitle, newTitle);
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      }),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

class _AddListDialog extends StatefulWidget {
  const _AddListDialog({
    Key? key,
    this.initialTitle,
  }) : super(key: key);

  final String? initialTitle;

  @override
  State<_AddListDialog> createState() => _AddListDialogState();
}

class _AddListDialogState extends State<_AddListDialog> {
  late final TextEditingController _titleController = TextEditingController(text: widget.initialTitle);

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        // Text(
        //   'Title',
        //   style: _headerStyle,
        // ),
        // const SizedBox(height: 10),
        TextBox(
          controller: _titleController,
          style: kTextStyleMain.copyWith(fontSize: 20),
          maxLines: 1,
          minLines: 1,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          foregroundDecoration:
              BoxDecoration(border: Border.all(color: kColorMain), borderRadius: BorderRadius.circular(5)),
        ),
        const SizedBox(height: 20),
        Row(
          children: Dialogs.getButtons(
            {
              'Ok': () async {
                String title = _titleController.text;
                if (title.isBlank ?? true) {
                  Dialogs.showAlertDialog(context, 'Please write a title');
                  return;
                }

                bool ok = !controller.checkIfListTitleExists(title);
                if (!ok && (title.toLowerCase() != widget.initialTitle?.toLowerCase())) {
                  Dialogs.showAlertDialog(
                    context,
                    'This list already exists. Please write another title!',
                  );
                  return;
                }
                if (mounted) Navigator.pop(context, title);
              },
              'Cancel': () => Navigator.pop(context),
            },
          ).map<Widget>((e) => Expanded(child: e)).toList()
            ..insert(
              1,
              const SizedBox(
                width: 10,
              ),
            ),
        ),
      ],
    );
  }
}
