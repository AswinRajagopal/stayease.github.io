import 'package:hive/hive.dart';

part 'cat_model.g.dart';

@HiveType(typeId: 0)
class CatModel {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String age;

  @HiveField(2)
  final bool isMale;

  @HiveField(3)
  final String city;

  @HiveField(4)
  final String state;

  const CatModel(this.name, this.age, this.isMale, this.city, this.state);
}
