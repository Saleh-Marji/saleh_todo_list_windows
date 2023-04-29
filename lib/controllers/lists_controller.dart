import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:get/get.dart';
import 'package:saleh_todo_list_windows/modals/todo_item.dart';

import '../constants.dart';
import '../modals/todo_list.dart';

class TodoListsController extends GetxController {
  final List<TodoList> _list = [];

  final List<TodoList> _currentlyInTabs = [];

  String? _currentlySelectedTabTitle;

  bool _isLoading = false;

  List<TodoList> get currentlyInTabs => [..._currentlyInTabs];

  String? get currentlySelectedTabTitle => _currentlySelectedTabTitle;

  TodoList? get currentList {
    try {
      return _currentlyInTabs.firstWhere((element) => element.title == currentlySelectedTabTitle);
    } catch (e) {
      return null;
    }
  }

  List<TodoList> get lists => [..._list];

  set isLoading(bool isLoading) {
    _isLoading = isLoading;
    update();
  }

  bool get isLoading => _isLoading;

  @override
  void onInit() {
    super.onInit();
    _loadLists();
  }

  @override
  void update([List<Object>? ids, bool condition = true]) {
    _saveLists();
    super.update(ids, condition);
  }

  void _loadLists() async {
    _isLoading = true;
    super.update();
    File file = File(await kFilePath);
    if (file.existsSync()) {
      Map<String, dynamic> json = jsonDecode(file.readAsStringSync());
      for (Map<String, dynamic> listJson in json['lists'] as List<dynamic>) {
        _list.add(TodoList.fromJson(listJson));
      }
      Set<String> tabs = {};
      for (String title in json['tabs']) {
        tabs.add(title);
      }
      for (TodoList list in _list) {
        if (tabs.contains(list.title)) {
          _currentlyInTabs.add(list);
        }
      }
      _currentlySelectedTabTitle = json['currentTab'] as String?;
    } else {
      await file.create(recursive: true);
      file.writeAsString('{"lists" : [], "tabs" : []}');
      _list.clear();
    }
    _isLoading = false;
    update();
  }

  void _saveLists() async {
    File file = File(await kFilePath);
    String json =
        '{"lists" : ${jsonEncode(_list)}, "tabs" : ${jsonEncode(_currentlyInTabs.map((e) => e.title).toList())}, "currentTab" : "$_currentlySelectedTabTitle"}';
    file.writeAsStringSync(json);
  }

  bool addItem(TodoItem item) {
    isLoading = true;
    if (currentList == null) {
      isLoading = false;
      return false;
    }
    bool result = _list.firstWhere((element) => element.title == currentList!.title).addItem(item);
    isLoading = false;
    return result;
  }

  bool addList(String title, {int? index}) {
    if (_containsTitle(title)) {
      isLoading = false;
      return false;
    }
    _list.insert(index ?? _list.length, TodoList(title));
    openListInTab(_list.length - 1);

    return true;
  }

  void addToTabs(TodoList list) {
    if (_containsTitle(list.title, _currentlyInTabs)) {
      _currentlySelectedTabTitle = _currentlyInTabs.firstWhere((element) => element.title == list.title).title;
    } else {
      _currentlyInTabs.add(list);
    }
    update();
  }

  void removeTabAt(int index) {
    String title = _currentlyInTabs.removeAt(index).title;
    if (title == currentlySelectedTabTitle) {
      if (_currentlyInTabs.isEmpty) {
        _currentlySelectedTabTitle = null;
      } else {
        _currentlySelectedTabTitle = _currentlyInTabs[min(index, _currentlyInTabs.length - 1)].title;
      }
    }
    update();
  }

  bool _containsTitle(String title, [List<TodoList>? list]) {
    title = title.toLowerCase();
    return (list ?? _list).map((e) => e.title.toLowerCase()).contains(title);
  }

  void moveTabToIndex(int oldIndex, int newIndex) {
    TodoList list = _currentlyInTabs.removeAt(oldIndex);
    _currentlyInTabs.insert(newIndex, list);
    update();
  }

  void moveTaskToAfterTitle(String titleAfter, TodoItem itemToAdd) {
    TodoList? list = currentList;
    if (list == null) {
      return;
    }
    list.remove(itemToAdd.title);
    list.addAfter(titleAfter, itemToAdd);
    update();
  }

  void moveTaskToBeforeTitle(String titleBefore, TodoItem itemToAdd) {
    TodoList? list = currentList;
    if (list == null) {
      return;
    }
    list.remove(itemToAdd.title);
    list.addBefore(titleBefore, itemToAdd);
    update();
  }

  void selectTab(String title) {
    _currentlySelectedTabTitle = title;
    update();
  }

  void toggleDone(String title) {
    if (currentlySelectedTabTitle == null) {
      return;
    }
    TodoList todoList = _currentlyInTabs.firstWhere((element) => element.title == currentlySelectedTabTitle);
    todoList.toggleDone(title);
    update();
  }

  void deleteTodo(String title) {
    if (currentlySelectedTabTitle == null) {
      return;
    }
    TodoList todoList = _currentlyInTabs.firstWhere((element) => element.title == currentlySelectedTabTitle);
    todoList.remove(title);
    update();
  }

  void editTodo(TodoItem result, String oldTitle) {
    if (currentList == null) {
      return;
    }
    // currentList!.editItem(result);
    _list[_list.indexWhere((element) => element.title == currentlySelectedTabTitle)].editItem(result, oldTitle);
    update();
  }

  bool checkIfListTitleExists(String title) {
    return _containsTitle(title);
  }

  void openListInTab(int inputIndex) {
    TodoList list = _list[inputIndex];
    int index = _currentlyInTabs.indexWhere((element) => element.title == list.title);
    if (index == -1) {
      _currentlyInTabs.add(list);
    }
    _currentlySelectedTabTitle = list.title;
    update();
  }

  void deleteList(String title) {
    _list.removeWhere((element) => element.title == title);
    int index = _currentlyInTabs.indexWhere((element) => element.title == title);
    if (index == -1) {
      update();
      return;
    }
    _currentlyInTabs.removeAt(index);
    if (title == currentlySelectedTabTitle) {
      if (_currentlyInTabs.isEmpty) {
        _currentlySelectedTabTitle = null;
      } else {
        _currentlySelectedTabTitle = _currentlyInTabs[min(index, _currentlyInTabs.length - 1)].title;
      }
    }
    update();
  }

  void reorderList(int oldIndex, int newIndex) {
    TodoList list = _list.removeAt(oldIndex);
    _list.insert(newIndex, list);
    update();
  }

  void editListTitle(String oldTitle, String newTitle) {
    bool isSelected = _currentlySelectedTabTitle == oldTitle;
    _list[_list.indexWhere((element) => element.title == oldTitle)].title = newTitle;
    if (isSelected) _currentlySelectedTabTitle = newTitle;
    update();
  }

  void deleteAllLists() {
    _list.clear();
    _currentlyInTabs.clear();
    _currentlySelectedTabTitle = null;
    update();
  }

  void deleteAllTodosOfCurrentList() {
    var current = currentList;
    if (current == null) return;
    current.empty();
    update();
  }
}
