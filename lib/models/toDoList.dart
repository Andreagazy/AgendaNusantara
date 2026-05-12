class ToDo {
  int? id;
  String task;
  String description;
  String dueDate;
  String category;
  bool isDone;
  String createdAt;
  String? completedAt;

  ToDo({
    this.id,
    required this.task,
    required this.description,
    required this.dueDate,
    required this.category,
    this.isDone = false,
    required this.createdAt,
    this.completedAt,
    
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task': task,
      'description': description,
      'dueDate': dueDate,
      'category': category,
      'isDone': isDone ? 1 : 0,
      'createdAt': createdAt,
      'completedAt': completedAt,
    };
  }

  factory ToDo.fromMap(Map<String, dynamic> map) {
    return ToDo(
      id: map['id'],
      task: map['task'],
      description: map['description'],
      dueDate: map['dueDate'],
      category: map['category'],
      isDone: map['isDone'] == 1,
      createdAt: map['createdAt'],
      completedAt: map['completedAt'], 
    );
  }
}
