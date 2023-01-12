import 'package:saleh_todo_list_windows/modals/todo_item.dart';

class TodoList {
  final String title;
  List<TodoItem> _items = [];

  TodoList(this.title);

  factory TodoList.fromJson(Map<String, dynamic> json) => TodoList(
        json['title'] as String,
      ).._items = (json['items'] as List<dynamic>).map((e) => TodoItem.fromJson(e)).toList();

  Map<String, dynamic> toJson() => {
        'title': title,
        'items': _items,
      };

  bool addItem(TodoItem item, [int? index]) {
    if (_items.map((e) => e.title).contains(item.title)) {
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

  void toggleDone(int index) {
    _items[index] = _items[index].toggleDone();
  }
}
