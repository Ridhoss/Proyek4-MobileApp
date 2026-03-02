import 'package:mongo_dart/mongo_dart.dart';

class LogModel {
  final ObjectId? id;
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
    return LogModel(
      id: map['_id'] as ObjectId?,
      iduser: map['iduser'],
      title: map['title'],
      date: map['date'],
      description: map['description'],
      category: map['category'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id ?? ObjectId(),
      'iduser': iduser,
      'title': title,
      'date': date,
      'description': description,
      'category': category,
    };
  }
}
