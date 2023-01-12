import 'package:fluent_ui/fluent_ui.dart';
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
      decoration: BoxDecoration(
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
            padding: EdgeInsets.all(50),
            child: wGetLogoWidget(),
          ),
          Divider(
            style: DividerThemeData(
                horizontalMargin: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: kColorMainLight,
                )),
          ),
          ListTile(
            leading: Icon(FluentIcons.add),
            title: Text('Add List'),
            onPressed: () async {
              String? title = await Dialogs.showChildDialog(context, 'Add List', const _AddListDialog());
              if (title != null) {
                controller.addList(title);
              }
            },
          ),
          ListTile(
            leading: Icon(FluentIcons.list),
            title: Text('Todo Lists'),
          ),
          GetBuilder<TodoListsController>(
            init: controller,
            builder: (controller) {
              List<TodoList> lists = controller.lists;
              return Expanded(
                child: ListView.builder(
                  itemCount: lists.length,
                  itemBuilder: (_, index) {
                    return ListTile(
                      title: Text('- ${lists[index].title}'),
                      onPressed: () {
                        controller.openListInTab(index);
                      },
                      trailing: IconButton(
                        icon: Icon(FluentIcons.delete),
                        onPressed: () async {
                          bool? ok = await Dialogs.showConfirmationDialog(
                            context,
                            'Are you sure you want to delete this todo list?',
                          );

                          if (!(ok ?? false)) {
                            return;
                          }

                          controller.deleteList(lists[index].title);
                        },
                      ),
                    );
                  },
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
  const _AddListDialog({Key? key}) : super(key: key);

  @override
  State<_AddListDialog> createState() => _AddListDialogState();
}

class _AddListDialogState extends State<_AddListDialog> {
  String title = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 20),
        TextBox(
          header: 'Title',
          headerStyle: kTextStyleMain.copyWith(fontSize: 22),
          initialValue: title,
          onChanged: (value) {
            setState(() {
              title = value;
            });
          },
          style: kTextStyleMain.copyWith(fontSize: 20),
          maxLines: 1,
          minLines: 1,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          foregroundDecoration:
              BoxDecoration(border: Border.all(color: kColorMain), borderRadius: BorderRadius.circular(5)),
        ),
        SizedBox(height: 20),
        Row(
          children: Dialogs.getButtons(
            {
              'Ok': () async {
                if (title == '') {
                  Dialogs.showAlertDialog(context, 'Please write a title');
                  return;
                }

                bool ok = !controller.checkIfListTitleExists(title);
                if (!ok) {
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
              SizedBox(
                width: 10,
              ),
            ),
        ),
      ],
    );
  }
}
