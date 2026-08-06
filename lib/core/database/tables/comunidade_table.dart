import 'package:drift/drift.dart';

@DataClassName('ComunidadeData')
class Comunidade extends Table {
  @override
  String get tableName => 'comunidade';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text()();
}
