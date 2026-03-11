import 'package:hive/hive.dart';

part 'log_model.g.dart';

@HiveType(typeId: 0)
class LogModel {
  @HiveField(0)
  final String? id;
  @HiveField(1)
  final int iduser;
  @HiveField(2)
  final String title;
  @HiveField(3)
  final String date;
  @HiveField(4)
  final String description;
  @HiveField(5)
  final String category;
  @HiveField(6)
  final int teamId;
  @HiveField(7)
  final bool isSynced;
  @HiveField(8)
  final bool isDeleted;

  LogModel({
    this.id,
    required this.iduser,
    required this.title,
    required this.date,
    required this.description,
    required this.category,
    required this.teamId,
    this.isSynced = false,
    this.isDeleted = false
  });

  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      id: map['_id']?.toString(),
      iduser: map['iduser'] ?? 0,
      title: map['title'] ?? '',
      date: map['date'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      teamId: map['teamId'] ?? 0,
      isSynced: map['isSynced'] ?? true,
      isDeleted: map['isDeleted'] ?? false
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      "_id": id,
      'iduser': iduser,
      'title': title,
      'date': date,
      'description': description,
      'category': category,
      'teamId': teamId,
    };

    return map;
  }
}
