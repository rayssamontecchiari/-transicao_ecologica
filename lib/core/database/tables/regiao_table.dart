import 'package:drift/drift.dart';

@DataClassName('RegiaoData')
class Regiao extends Table {
  @override
  String get tableName => 'regiao';
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text()();
}
