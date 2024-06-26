// ignore_for_file: public_member_api_docs, sort_constructors_first

class Task {
  int? id;
  String? title;
  String? description;
  String? category;
  String? dateAdded;
  String? deadline;
  int? isVeryUrgent;
  int? hasNotification;
  int? remind;
  int? isCompleted;
  Task({
    this.isCompleted,
    this.id,
    this.title,
    this.description,
    this.category,
    this.dateAdded,
    this.deadline,
    this.isVeryUrgent,
    this.hasNotification,
    this.remind,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'dateAdded': dateAdded,
      'deadline': deadline,
      'isVeryUrgent': isVeryUrgent,
      'hasNotification': hasNotification,
      'remind': remind,
      'isCompleted': isCompleted,
    };
  }

  Task.fromJson(Map<String, dynamic> json) {
    id = json['id'] != null ? json['id'] as int : null;
    title = json['title'] != null ? json['title'] as String : null;
    description =
        json['description'] != null ? json['description'] as String : null;
    category = json['category'] != null ? json['category'] as String : null;
    dateAdded = json['dateAdded'] != null ? json['dateAdded'] as String : null;
    deadline = json['deadline'] != null ? json['deadline'] as String : null;
    isVeryUrgent =
        json['isVeryUrgent'] != null ? json['isVeryUrgent'] as int : null;
    hasNotification =
        json['hasNotification'] != null ? json['hasNotification'] as int : null;
    remind = json['remind'] != null ? json['remind'] as int : null;
    isCompleted =
        json['isCompleted'] != null ? json['isCompleted'] as int : null;
  }
}
