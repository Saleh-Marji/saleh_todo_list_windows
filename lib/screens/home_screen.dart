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

bool isAdding = false;

void onAddPressed(BuildContext context) async {
  if (isAdding) {
    return;
  }
  isAdding = true;
  TodoItem? result = await showItemDialog(context);
  if (result != null) {
    controller.addItem(result);
  }
  isAdding = false;
}

Future<TodoItem?> showItemDialog(BuildContext context, [TodoItem? initialItem]) async {
  return Dialogs.showChildDialog(
    context,
    initialItem != null ? 'Edit Item' : 'Add Item',
    _TodoItemDialog(
      item: initialItem,
    ),
  );
}

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
          return const _HomeWidget();
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
      children: const [
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
      return const Center(
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Todos:',
                  style: kTextStyleMain.copyWith(fontSize: 40),
                ),
              ),
              IconButton(
                icon: const Icon(FluentIcons.delete, size: 30),
                onPressed: () async {
                  bool? ok = await Dialogs.showConfirmationDialog(
                    context,
                    'Are you sure you want to delete all todos of this list?',
                  );
                  if (!(ok ?? false)) {
                    return;
                  }
                  controller.deleteAllTodosOfCurrentList();
                },
              )
            ],
          ),
          Expanded(
            child: Builder(builder: (context) {
              if (items.isEmpty) {
                return const Center(
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

              int lastNotDoneIndex = notDone.length - 1;

              int count = items.length + (notDone.isNotEmpty ? 1 : 0) + (done.isNotEmpty ? 1 : 0);

              return m.Theme(
                data: m.ThemeData(
                  shadowColor: Colors.transparent,
                  canvasColor: Colors.transparent,
                ),
                child: ReorderableListView.builder(
                  shrinkWrap: true,
                  buildDefaultDragHandles: false,
                  onReorderStart: (index) {
                    index++;
                  },
                  onReorder: (oldIndex, newIndex) {
                    //clear out indices of titles
                    if (newIndex > oldIndex) newIndex--;
                    if (notDone.isNotEmpty) {
                      oldIndex--;
                      newIndex--;
                    }
                    if (oldIndex > lastNotDoneIndex) {
                      oldIndex--;
                    }
                    if (newIndex > lastNotDoneIndex) {
                      newIndex--;
                    }
                    //now compare to see in which case are we
                    //moving forward?
                    //or backwards
                    bool doneOfHeldItem = oldIndex > lastNotDoneIndex;
                    if (doneOfHeldItem && newIndex < (lastNotDoneIndex + 1)) {
                      newIndex = lastNotDoneIndex + 1;
                    } else if (!doneOfHeldItem && newIndex > lastNotDoneIndex) {
                      newIndex = lastNotDoneIndex;
                    }
                    if (newIndex < 0) {
                      newIndex = 0;
                    }
                    if (oldIndex == newIndex) {
                      return;
                    }
                    TodoItem heldItem = items[oldIndex];
                    if (newIndex > oldIndex) {
                      //moving forward
                      String title = items[newIndex].title;
                      controller.moveTaskToAfterTitle(title, heldItem);
                    } else {
                      //moving backwards
                      String title = items[newIndex].title;
                      controller.moveTaskToBeforeTitle(title, heldItem);
                    }
                  },
                  itemCount: count,
                  itemBuilder: (_, index) {
                    int listIndex = index;
                    if (index == 0 && notDone.isNotEmpty) {
                      return _title(
                        'Not Done (${notDone.length})',
                      );
                    } else if (notDone.isNotEmpty) {
                      index--;
                    }
                    if (index == notDone.length && done.isNotEmpty) {
                      return _title(
                        'Done (${done.length})',
                      );
                    } else if (index > notDone.length && done.isNotEmpty) {
                      index--;
                    }
                    var item = items[index];
                    return ReorderableDragStartListener(
                      key: ValueKey('${currentList.title}-${item.title}'),
                      index: listIndex,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ItemContainer(
                          item,
                          onDoneChanged: (done) {
                            controller.toggleDone(item.title);
                          },
                          onEditPressed: () async {
                            TodoItem? result = await showItemDialog(context, item);
                            if (result != null) {
                              controller.editTodo(result, item.title);
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
                      ),
                    );
                  },
                ),
              );
            }),
          ),
          const SizedBox(
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
                      const Icon(FluentIcons.add),
                    ],
                  ),
                ),
                onPressed: () async {
                  onAddPressed(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _title(String title) => Column(
        key: ValueKey(title),
        children: [
          const SizedBox(
            height: 16,
          ),
          Text(
            '$title:',
            style: kTextStyleMain,
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(
            style: DividerThemeData(
              horizontalMargin: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: kColorMain,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      );
}

class _TodoItemDialog extends StatefulWidget {
  const _TodoItemDialog({this.item, Key? key}) : super(key: key);

  final TodoItem? item;

  @override
  State<_TodoItemDialog> createState() => _TodoItemDialogState();
}

bool errorOccurred = false;

class _TodoItemDialogState extends State<_TodoItemDialog> {
  late TodoItem item = widget.item ?? const TodoItem(title: '');
  late final TextEditingController _titleController = TextEditingController(text: widget.item?.title),
      _descriptionController = TextEditingController(text: widget.item?.description);

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  TextStyle get _headerStyle => kTextStyleMain.copyWith(fontSize: 22);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        Text(
          'Title',
          style: _headerStyle,
        ),
        const SizedBox(height: 10),
        TextBox(
          controller: _titleController,
          onChanged: (value) {
            setState(() {
              item = item.copyWith(title: value);
            });
          },
          style: kTextStyleMain.copyWith(fontSize: 20),
          maxLines: 1,
          minLines: 1,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          foregroundDecoration: BoxDecoration(
            border: Border.all(color: kColorMain),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(height: 40),
        Text(
          'Description',
          style: _headerStyle,
        ),
        const SizedBox(height: 10),
        TextBox(
          controller: _descriptionController,
          maxLines: 5,
          minLines: 1,
          onChanged: (value) {
            setState(() {
              item = item.copyWith(
                clearDescription: value.isEmpty,
                description: value,
              );
            });
          },
          style: kTextStyleMain.copyWith(fontSize: 20),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          foregroundDecoration:
              BoxDecoration(border: Border.all(color: kColorMain), borderRadius: BorderRadius.circular(5)),
        ),
        const SizedBox(height: 40),
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
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Date',
                    style: kTextStyleMain.copyWith(fontSize: 22),
                    textAlign: TextAlign.left,
                  ),
                  Button(
                    child: Text(
                      'Clear',
                      style: kTextStyleMain.copyWith(fontSize: 20),
                    ),
                    style: ButtonStyle(
                      backgroundColor: ButtonState.all(kColorMainLight),
                    ),
                    onPressed: () {
                      setState(() {
                        item = item.copyWith(clearDateTime: true);
                      });
                    },
                  )
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: kColorMain),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                child: Text(
                  item.dateTime != null ? Utils.dateTimeToString(item.dateTime!) : 'Tap to select Date',
                  style: kTextStyleMain.copyWith(fontSize: 20),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: Dialogs.getButtons(
            {
              'Ok': () async {
                if (item.title == '') {
                  Dialogs.showAlertDialog(context, 'Please write a title');
                  return;
                }

                bool ok = controller.currentList!.checkIfTitleIsApplicable(item.title);
                if (!ok && !(item.title.toLowerCase() == widget.item?.title.toLowerCase())) {
                  Dialogs.showAlertDialog(
                    context,
                    'An item with this title already exists! Kindly Enter another title',
                  );
                  return;
                }
                if (mounted) Navigator.pop(context, item);
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
        )
      ],
    );
  }
}
