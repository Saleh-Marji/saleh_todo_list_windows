import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'package:get/get.dart';
import 'package:saleh_todo_list_windows/controllers/lists_controller.dart';
import 'package:saleh_todo_list_windows/modals/todo_item.dart';
import 'package:saleh_todo_list_windows/modals/todo_list.dart';
import 'package:saleh_todo_list_windows/utils.dart';
import 'package:saleh_todo_list_windows/widgets/dialogs.dart';

import '../constants.dart';
import '../widgets/item_container.dart';
import '../widgets/screen_widgets/drawer.dart';
import '../widgets/screen_widgets/tabs_widget.dart';

final controller = Get.find<TodoListsController>();

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kColorMainLight,
      child: GetBuilder(
        init: controller,
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(
              child: m.CircularProgressIndicator(
                color: kColorMain,
              ),
            );
          }
          return _HomeWidget();
        },
      ),
    );
  }
}

class _HomeWidget extends StatelessWidget {
  const _HomeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Drawer(),
        Expanded(child: _MainWidget()),
      ],
    );
  }
}

class _MainWidget extends StatelessWidget {
  const _MainWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TodoListsController>(
      init: controller,
      builder: (controller) {
        TodoList? currentList = controller.currentList;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TabsWidget(),
            Expanded(child: _currentList(context, currentList)),
          ],
        );
      },
    );
  }

  Widget _currentList(BuildContext context, TodoList? currentList) {
    if (currentList == null) {
      return Center(
        child: Text(
          'Select a list or add one!',
          style: kTextStyleMain,
        ),
      );
    }

    List<TodoItem> items = currentList.items;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Todos:',
            style: kTextStyleMain.copyWith(fontSize: 40),
          ),
          Expanded(
            child: Builder(builder: (context) {
              if (items.isEmpty) {
                return Center(
                  child: Text(
                    'No Todos Yet! Please add some todos!',
                    style: kTextStyleMain,
                    textAlign: TextAlign.center,
                  ),
                );
              }

              List<TodoItem> notDone = items.where((element) => element.isNotDone).toList();

              List<TodoItem> done = items.where((element) => element.isDone).toList();

              items = [...notDone, ...done];

              int count = items.length + (notDone.isNotEmpty ? 1 : 0) + (done.isNotEmpty ? 1 : 0);

              return ListView.builder(
                itemCount: count,
                itemBuilder: (_, index) {
                  if (index == 0 && notDone.isNotEmpty) {
                    return _title('Not Done (${notDone.length})');
                  } else if (notDone.isNotEmpty) {
                    index--;
                  }
                  if (index == notDone.length && done.isNotEmpty) {
                    return _title('Done (${done.length})');
                  } else if (index > notDone.length && done.isNotEmpty) {
                    index--;
                  }
                  var item = items[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: ItemContainer(
                      item,
                      onDoneChanged: (done) {
                        controller.toggleDone(item.title);
                      },
                      onPressed: () async {
                        TodoItem? result = await showItemDialog(context, item);
                        if (result != null) {
                          controller.editTodo(result, forceEdit: true);
                        }
                      },
                      onLongPressed: () async {
                        bool? ok = await Dialogs.showConfirmationDialog(
                          context,
                          'Are you sure you want to delete this todo?',
                        );

                        if (!(ok ?? false)) {
                          return;
                        }

                        controller.deleteTodo(item.title);
                      },
                    ),
                  );
                },
              );
            }),
          ),
          SizedBox(
            height: 16,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Button(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Add Todo',
                          style: kTextStyleMain.copyWith(
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Icon(FluentIcons.add),
                    ],
                  ),
                ),
                onPressed: () async {
                  TodoItem? result = await showItemDialog(context);
                  if (result != null) {
                    controller.addItem(result);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _title(String title) => Column(
        children: [
          SizedBox(
            height: 16,
          ),
          Text(
            '$title:',
            style: kTextStyleMain,
          ),
          SizedBox(
            height: 10,
          ),
          Divider(
            style: DividerThemeData(
              horizontalMargin: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: kColorMain,
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      );

  Future<TodoItem?> showItemDialog(BuildContext context, [TodoItem? initialItem]) async {
    return Dialogs.showChildDialog(
      context,
      initialItem != null ? 'Edit Item' : 'Add Item',
      _TodoItemDialog(
        item: initialItem,
      ),
    );
  }
}

class _TodoItemDialog extends StatefulWidget {
  const _TodoItemDialog({this.item, Key? key}) : super(key: key);

  final TodoItem? item;

  @override
  State<_TodoItemDialog> createState() => _TodoItemDialogState();
}

class _TodoItemDialogState extends State<_TodoItemDialog> {
  late TodoItem item;

  @override
  void initState() {
    super.initState();
    item = widget.item ?? TodoItem(title: '');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 20),
        TextBox(
          header: 'Title',
          headerStyle: kTextStyleMain.copyWith(fontSize: 22),
          initialValue: widget.item?.title,
          onChanged: (value) {
            setState(() {
              item = item.copyWith(title: value);
            });
          },
          style: kTextStyleMain.copyWith(fontSize: 20),
          maxLines: 1,
          minLines: 1,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          foregroundDecoration:
              BoxDecoration(border: Border.all(color: kColorMain), borderRadius: BorderRadius.circular(5)),
        ),
        SizedBox(height: 40),
        TextBox(
          // expands: true,
          header: 'Description',
          headerStyle: kTextStyleMain.copyWith(fontSize: 22),
          initialValue: widget.item?.description,
          maxLines: 10,
          minLines: 1,
          onChanged: (value) {
            setState(() {
              item = item.copyWith(description: value);
            });
          },
          style: kTextStyleMain.copyWith(fontSize: 20),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          foregroundDecoration:
              BoxDecoration(border: Border.all(color: kColorMain), borderRadius: BorderRadius.circular(5)),
        ),
        SizedBox(height: 40),
        GestureDetector(
          onTap: () async {
            DateTime? result = await m.showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(3000),
              builder: (context, child) {
                return m.Theme(
                  data: m.Theme.of(context).copyWith(
                    colorScheme: m.ColorScheme.light(
                      primary: kColorMain,
                      onPrimary: Colors.white.withOpacity(0.9),
                      // onSurface: kColorMainLight, // <-- SEE HERE
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (result != null) {
              setState(() {
                item = item.copyWith(dateTime: result);
              });
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Date',
                style: kTextStyleMain.copyWith(fontSize: 22),
                textAlign: TextAlign.left,
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: kColorMain),
                ),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                child: Text(
                  item.dateTime != null ? Utils.dateTimeToString(item.dateTime!) : 'Tap to select Date',
                  style: kTextStyleMain.copyWith(fontSize: 20),
                ),
              )
            ],
          ),
        ),
        SizedBox(height: 20),
        Row(
          children: Dialogs.getButtons(
            {
              'Ok': () async {
                if (item.title == '') {
                  Dialogs.showAlertDialog(context, 'Please write a title');
                  return;
                }

                bool ok = controller.currentList!.checkIfTitleIsApplicable(item.title);
                if (!ok && !item.matches(widget.item) && widget.item?.title != item.title) {
                  bool? ok = await Dialogs.showConfirmationDialog(
                    context,
                    'This title already exists. Are you sure you want to override it?',
                  );
                  if (!(ok ?? false)) {
                    return;
                  }
                }
                if (mounted) Navigator.pop(context, item);
              },
              'Cancel': () => Navigator.pop(context),
            },
          ).map<Widget>((e) => Expanded(child: e)).toList()
            ..insert(
              1,
              SizedBox(
                width: 10,
              ),
            ),
        )
      ],
    );
  }
}
