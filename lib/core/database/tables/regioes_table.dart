import 'package:drift/drift.dart';

@DataClassName('Regiao')
class Regioes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text()();
}
