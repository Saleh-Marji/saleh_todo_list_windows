class TodoItem {
  final String title;
  final String? description;
  final DateTime? dateTime;
  final bool done;

  const TodoItem({
    required this.title,
    this.description,
    this.dateTime,
    this.done = false,
  });

  TodoItem copyWith({
    String? title,
    String? description,
    DateTime? dateTime,
    bool? done,
  }) =>
      TodoItem(
        title: title ?? this.title,
        description: description ?? this.description,
        dateTime: dateTime ?? this.dateTime,
        done: done ?? this.done,
      );

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
        title: json['title'] as String,
        description: json['description'] as String?,
        dateTime: (json['dateTime'] == null ? null : DateTime.parse(json['dateTime'] as String)),
        done: json['done'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        if (description != null) 'description': description,
        if (dateTime != null) 'dateTime': dateTime!.toIso8601String(),
        'done': done,
      };

  TodoItem toggleDone() => copyWith(done: !done);
}
