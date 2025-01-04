import 'package:hive/hive.dart';

part 'user_email.g.dart';

@HiveType(typeId: 2) // Уникальный ID для модели Hive
class UserEmail {
  @HiveField(0)
  final String email;

  UserEmail({required this.email});
}
