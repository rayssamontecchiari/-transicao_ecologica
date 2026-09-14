import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transicao_ecologica/core/database/app_database.dart';

class _TestDbUser implements QueryExecutorUser {
  @override
  int get schemaVersion => 1;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {}
}

void main() {
  test('repara colunas de data antigas armazenadas como texto', () async {
    final db = NativeDatabase.memory();
    await db.ensureOpen(_TestDbUser());

    await db.runCustom(
      "CREATE TABLE familia (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, nome TEXT NOT NULL)",
    );
    await db.runCustom(
      "CREATE TABLE avaliacao (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, data TEXT NOT NULL, data_alteracao TEXT NOT NULL, avaliador TEXT NOT NULL, observacoes TEXT, status TEXT NOT NULL DEFAULT 'draft', familia_id INTEGER NOT NULL REFERENCES familia(id))",
    );
    await db.runCustom(
      "INSERT INTO familia (id, nome) VALUES (1, 'Familia Teste')",
    );
    await db.runCustom(
      "INSERT INTO avaliacao (id, data, data_alteracao, avaliador, observacoes, status, familia_id) VALUES (1, '2026-08-09 22:16:06', '2026-08-09 22:20:00', 'Ana', 'obs', 'draft', 1)",
    );

    await AppDatabase.repairLegacyDateColumns(db);

    final rows = await db.runSelect(
      'SELECT data, data_alteracao FROM avaliacao WHERE id = ?',
      [1],
    );

    expect(rows, isNotEmpty);
    expect(rows.first['data'], isA<int>());
    expect(rows.first['data_alteracao'], isA<int>());

    final data = DateTime.fromMillisecondsSinceEpoch(rows.first['data'] as int);
    final dataAlteracao =
        DateTime.fromMillisecondsSinceEpoch(rows.first['data_alteracao'] as int);

    expect(data.year, 2026);
    expect(data.month, 8);
    expect(data.day, 9);
    expect(data.hour, 22);
    expect(dataAlteracao.hour, 22);
  });
}
