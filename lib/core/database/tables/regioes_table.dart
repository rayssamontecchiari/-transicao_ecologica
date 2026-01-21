import 'package:drift/drift.dart';

class Regioes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text()();
}
