class LogModel {
  final int id;
  final int iduser;
  final String title;
  final String date;
  final String description;
  final String category;

  LogModel({
    required this.id,
    required this.iduser,
    required this.title,
    required this.date,
    required this.description,
    required this.category,
  });

  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      id: map['id'],
      iduser: map['iduser'],
      title: map['title'],
      date: map['date'],
      description: map['description'],
      category: map['category'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'iduser': iduser,
      'title': title,
      'date': date,
      'description': description,
      'category': category,
    };
  }
}
