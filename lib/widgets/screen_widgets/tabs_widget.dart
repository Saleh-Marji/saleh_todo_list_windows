import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' as m;
import 'package:get/get.dart';
import 'package:saleh_todo_list_windows/controllers/lists_controller.dart';

import '../../constants.dart';

class TabsWidget extends StatefulWidget {
  const TabsWidget({Key? key}) : super(key: key);

  @override
  State<TabsWidget> createState() => _TabsWidgetState();
}

class _TabsWidgetState extends State<TabsWidget> {
  final scrollController = ScrollController();
  final controller = Get.find<TodoListsController>();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          scrollController.animateTo(scrollController.offset + event.scrollDelta.dy,
              duration: Duration(milliseconds: 2), curve: Curves.bounceIn);
        }
      },
      child: Container(
        color: kColorMain,
        height: 40,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 30,
              child: m.Theme(
                data: m.ThemeData(
                  canvasColor: Colors.transparent,
                ),
                child: GetBuilder<TodoListsController>(
                    init: controller,
                    builder: (controller) {
                      var lists = controller.currentlyInTabs;
                      String? currentTab = controller.currentlySelectedTabTitle;
                      return ReorderableListView.builder(
                        scrollController: scrollController,
                        scrollDirection: Axis.horizontal,
                        buildDefaultDragHandles: false,
                        shrinkWrap: true,
                        itemCount: lists.length,
                        itemBuilder: (_, index) {
                          bool isSelected = currentTab == lists[index].title;
                          return ReorderableDragStartListener(
                            key: ValueKey(lists[index].title),
                            index: index,
                            child: GestureDetector(
                              onTap: () {
                                controller.selectTab(lists[index].title);
                              },
                              child: Container(
                                margin: EdgeInsets.only(right: 2.5, left: index == 0 ? 5 : 2.5),
                                decoration: BoxDecoration(
                                  color: kColorMainLight,
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 1).copyWith(top: 1),
                                child: Container(
                                  width: 200,
                                  height: 30,
                                  padding: EdgeInsets.only(left: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? kColorMainLight : kColorMain,
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          lists[index].title,
                                          style: kTextStyleMain.copyWith(
                                            fontSize: 16,
                                            color: isSelected ? Colors.black : Colors.white.withOpacity(0.8),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          FluentIcons.chrome_close,
                                          color: isSelected ? Colors.black : Colors.white.withOpacity(0.8),
                                        ),
                                        onPressed: () {
                                          controller.removeTabAt(index);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        onReorder: (oldIndex, newIndex) {
                          if (newIndex > oldIndex) newIndex--;
                          controller.moveToIndex(oldIndex, newIndex);
                          // setState(() {});
                        },
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
