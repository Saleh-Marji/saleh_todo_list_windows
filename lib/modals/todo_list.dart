import 'dart:math';

import 'package:saleh_todo_list_windows/modals/todo_item.dart';

class TodoList {
  String title;
  List<TodoItem> _items = [];

  TodoList(this.title);

  factory TodoList.fromJson(Map<String, dynamic> json) => TodoList(
        json['title'] as String,
      ).._items = (json['items'] as List<dynamic>).map((e) => TodoItem.fromJson(e)).toList();

  List<TodoItem> get items => [..._items];

  int get unDoneCount => _items.where((element) => !element.done).length;

  Map<String, dynamic> toJson() => {
        'title': title,
        'items': _items,
      };

  bool addItem(TodoItem item, [int? index]) {
    String title = item.title.toLowerCase();
    if (_containsTitle(title)) {
      return false;
    }
    if (index == null) {
      _items.add(item);
    } else {
      _items.insert(index, item);
    }
    return true;
  }

  void remove(String title) {
    _items.removeWhere((element) => element.title == title);
  }

  TodoItem removeAt(int index) {
    return _items.removeAt(index);
  }

  void toggleDone(String title) {
    int index = _items.indexWhere((element) => element.title == title);
    _items[index] = _items[index].toggleDone();
  }

  bool _containsTitle(String title) => _items.map((e) => e.title.toLowerCase()).contains(title);

  bool checkIfTitleIsApplicable(String title) {
    return !_containsTitle(title);
  }

  void editItem(TodoItem newItem, String oldTitle) {
    _items[_items.indexWhere((element) => element.title == oldTitle)] = newItem;
  }

  void addAfter(String titleAfter, TodoItem item) {
    _items.insert(_items.indexWhere((element) => element.title == titleAfter) + 1, item);
  }

  void addBefore(String titleBefore, TodoItem item) {
    _items.insert(max(0, _items.indexWhere((element) => element.title == titleBefore)), item);
  }

  void empty() {
    _items.clear();
  }
}
