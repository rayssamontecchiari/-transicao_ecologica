import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../database/app_database.dart';

class ExportService {
  final AppDatabase database;

  ExportService(this.database);

  /// Exporta o banco de dados como backup (.db)
  Future<File> exportDatabaseBackup() async {
    final dbPath = await _getDatabasePath();
    final sourceFile = File(dbPath);

    if (!sourceFile.existsSync()) {
      throw Exception('Arquivo de banco de dados não encontrado');
    }

    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
    final backupName = 'backup_$timestamp.db';

    final directory = await getApplicationDocumentsDirectory();
    final backupPath = '${directory.path}/backups/$backupName';

    // Cria pasta de backups se não existir
    await Directory('${directory.path}/backups').create(recursive: true);

    final backupFile = await sourceFile.copy(backupPath);
    return backupFile;
  }

  /// Exporta dados como JSON
  Future<File> exportAsJson() async {
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
    final fileName = 'exportacao_$timestamp.json';

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/exports/$fileName';

    // Cria pasta de exports se não existir
    await Directory('${directory.path}/exports').create(recursive: true);

    // Coleta dados de todas as tabelas
    final data = {
      'regioes': await database.select(database.regioes).get(),
      'familias': await database.select(database.familias).get(),
      'categorias': await database.select(database.categorias).get(),
      'dimensoes': await database.select(database.dimensoes).get(),
      'praticas': await database.select(database.praticas).get(),
      'indicadores': await database.select(database.indicadores).get(),
      'avaliacoes': await database.select(database.avaliacoes).get(),
      'avaliacao_itens': await database.select(database.avaliacaoItens).get(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    final jsonString = jsonEncode(data);
    final file = File(filePath);
    await file.writeAsString(jsonString);

    return file;
  }

  /// Exporta dados como CSV
  Future<File> exportAsCSV(String tableName) async {
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
    final fileName = '${tableName}_$timestamp.csv';

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/exports/$fileName';

    // Cria pasta de exports se não existir
    await Directory('${directory.path}/exports').create(recursive: true);

    List<List<dynamic>> data = [];

    switch (tableName.toLowerCase()) {
      case 'regioes':
        final rows = await database.select(database.regioes).get();
        if (rows.isNotEmpty) {
          data.add(['ID', 'Nome']);
          for (var row in rows) {
            data.add([row.id, row.nome]);
          }
        }
        break;

      case 'familias':
        final rows = await database.select(database.familias).get();
        if (rows.isNotEmpty) {
          data.add(['ID', 'Nome Responsável', 'Região ID']);
          for (var row in rows) {
            data.add([row.id, row.nomeResponsavel, row.regiaoId]);
          }
        }
        break;

      case 'categorias':
        final rows = await database.select(database.categorias).get();
        if (rows.isNotEmpty) {
          data.add(['ID', 'Nome', 'Descrição']);
          for (var row in rows) {
            data.add([row.id, row.nome, row.descricao ?? '']);
          }
        }
        break;

      case 'indicadores':
        final rows = await database.select(database.indicadores).get();
        if (rows.isNotEmpty) {
          data.add(['ID', 'Nome', 'Descrição', 'Peso', 'Categoria ID']);
          for (var row in rows) {
            data.add([
              row.id,
              row.nome,
              row.descricao ?? '',
              row.peso,
              row.categoriaId,
            ]);
          }
        }
        break;

      case 'avaliacoes':
        final rows = await database.select(database.avaliacoes).get();
        if (rows.isNotEmpty) {
          data.add(['ID', 'Família ID', 'Categoria Atual', 'Data']);
          for (var row in rows) {
            data.add([
              row.id,
              row.familiaId,
              row.categoriaAtual,
              row.data.toIso8601String(),
            ]);
          }
        }
        break;

      default:
        throw Exception('Tabela não suportada: $tableName');
    }

    if (data.isEmpty) {
      throw Exception('Nenhum dado encontrado para a tabela: $tableName');
    }

    final csv = const ListToCsvConverter().convert(data);
    final file = File(filePath);
    await file.writeAsString(csv);

    return file;
  }

  /// Exporta todas as tabelas como CSV em um arquivo consolidado
  Future<File> exportAllAsCSV() async {
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
    final fileName = 'exportacao_completa_$timestamp.csv';

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/exports/$fileName';

    await Directory('${directory.path}/exports').create(recursive: true);

    StringBuffer csvBuffer = StringBuffer();

    // Regiões
    csvBuffer.writeln('=== REGIÕES ===');
    final regioes = await database.select(database.regioes).get();
    csvBuffer.writeln('ID,Nome');
    for (var row in regioes) {
      csvBuffer.writeln('${row.id},${_escapeCsv(row.nome)}');
    }
    csvBuffer.writeln();

    // Famílias
    csvBuffer.writeln('=== FAMÍLIAS ===');
    final familias = await database.select(database.familias).get();
    csvBuffer.writeln('ID,Nome Responsável,Telefone,Endereço,Região ID');
    for (var row in familias) {
      csvBuffer.writeln(
          '${row.id},${_escapeCsv(row.nomeResponsavel)},${_escapeCsv(row.telefone)},${_escapeCsv(row.endereco)},${row.regiaoId}');
    }
    csvBuffer.writeln();

    // Categorias
    csvBuffer.writeln('=== CATEGORIAS ===');
    final categorias = await database.select(database.categorias).get();
    csvBuffer.writeln('ID,Nome,Descrição');
    for (var row in categorias) {
      csvBuffer.writeln(
        '${row.id},${_escapeCsv(row.nome)},${_escapeCsv(row.descricao ?? '')}',
      );
    }
    csvBuffer.writeln();

    // Indicadores
    csvBuffer.writeln('=== INDICADORES ===');
    final indicadores = await database.select(database.indicadores).get();
    csvBuffer.writeln('ID,Nome,Descrição,Peso,Categoria ID');
    for (var row in indicadores) {
      csvBuffer.writeln(
        '${row.id},${_escapeCsv(row.nome)},${_escapeCsv(row.descricao ?? '')},${row.peso},${row.categoriaId}',
      );
    }
    csvBuffer.writeln();

    // Avaliações
    csvBuffer.writeln('=== AVALIAÇÕES ===');
    final avaliacoes = await database.select(database.avaliacoes).get();
    csvBuffer.writeln('ID,Família ID,Categoria Atual,Data');
    for (var row in avaliacoes) {
      csvBuffer.writeln(
        '${row.id},${row.familiaId},${row.categoriaAtual},${row.data.toIso8601String()}',
      );
    }

    final file = File(filePath);
    await file.writeAsString(csvBuffer.toString());

    return file;
  }

  /// Obtem o caminho do banco de dados
  Future<String> _getDatabasePath() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    return '${documentsDir.path}/app_database.db';
  }

  /// Escapa caracteres especiais em CSV
  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Retorna a pasta de exportações
  Future<Directory> getExportsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final exportsDir = Directory('${directory.path}/exports');
    if (!exportsDir.existsSync()) {
      exportsDir.createSync(recursive: true);
    }
    return exportsDir;
  }

  /// Retorna a pasta de backups
  Future<Directory> getBackupsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final backupsDir = Directory('${directory.path}/backups');
    if (!backupsDir.existsSync()) {
      backupsDir.createSync(recursive: true);
    }
    return backupsDir;
  }

  /// Lista todos os backups disponíveis
  Future<List<FileSystemEntity>> listBackups() async {
    final backupsDir = await getBackupsDirectory();
    try {
      return backupsDir
          .listSync()
          .where((file) => file.path.endsWith('.db'))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Lista todos os arquivos exportados
  Future<List<FileSystemEntity>> listExports() async {
    final exportsDir = await getExportsDirectory();
    try {
      return exportsDir.listSync().toList();
    } catch (e) {
      return [];
    }
  }
}
