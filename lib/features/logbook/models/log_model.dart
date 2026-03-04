import 'package:mongo_dart/mongo_dart.dart';

class LogModel {
  final String? id;
  final int iduser;
  final String title;
  final String date;
  final String description;
  final String category;

  LogModel({
    this.id,
    required this.iduser,
    required this.title,
    required this.date,
    required this.description,
    required this.category,
  });

  factory LogModel.fromMap(Map<String, dynamic> map) {
    final rawId = map['_id'];

    String? idString;

    if (rawId is ObjectId) {
      idString = rawId.toHexString();
    } else if (rawId is String) {
      idString = rawId;
    }

    return LogModel(
      id: idString,
      iduser: map['iduser'],
      title: map['title'],
      date: map['date'],
      description: map['description'],
      category: map['category'],
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'iduser': iduser,
      'title': title,
      'date': date,
      'description': description,
      'category': category,
    };

    if (id != null) {
      map['_id'] = ObjectId.fromHexString(id!);
    }

    return map;
  }
}
