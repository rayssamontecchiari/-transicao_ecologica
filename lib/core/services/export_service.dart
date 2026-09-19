import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../database/app_database.dart';
import 'resultado_cache_service.dart';

class ExportService {
  final AppDatabase database;
  final ResultadoCacheService _cacheService = ResultadoCacheService();

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

    final directory = await getBackupsDirectory();
    final backupPath = '${directory.path}/$backupName';

    final backupFile = await sourceFile.copy(backupPath);
    return backupFile;
  }

  /// Exporta dados como JSON
  Future<File> exportAsJson() async {
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
    final fileName = 'exportacao_$timestamp.json';

    final directory = await getExportsDirectory();
    final filePath = '${directory.path}/$fileName';

    // Coleta dados de todas as tabelas (usando nomes no singular)
    final data = {
      'comunidade': await database.select(database.comunidade).get(),
      'familia': await database.select(database.familia).get(),
      'categoria': await database.select(database.categoria).get(),
      'dimensao': await database.select(database.dimensao).get(),
      'pratica': await database.select(database.pratica).get(),
      'indicador': await database.select(database.indicador).get(),
      'avaliacao': await database.select(database.avaliacao).get(),
      'avaliacao_item': await database.select(database.avaliacaoItem).get(),
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

    final directory = await getExportsDirectory();
    final filePath = '${directory.path}/$fileName';

    List<List<dynamic>> data = [];

    final t = tableName.toLowerCase();
    switch (t) {
      case 'comunidades':
      case 'comunidade':
        final rows = await database.select(database.comunidade).get();
        if (rows.isNotEmpty) {
          data.add(['ID', 'Nome']);
          for (var row in rows) {
            data.add([row.id, row.nome]);
          }
        }
        break;

      case 'familias':
      case 'familia':
        final rows = await database.select(database.familia).get();
        if (rows.isNotEmpty) {
          data.add(['ID', 'Nome Responsável', 'Comunidade ID']);
          for (var row in rows) {
            data.add([row.id, row.nomeResponsavel, row.comunidadeId]);
          }
        }
        break;

      case 'categorias':
      case 'categoria':
        final rows = await database.select(database.categoria).get();
        if (rows.isNotEmpty) {
          data.add(['ID', 'Nome', 'Descrição']);
          for (var row in rows) {
            data.add([row.id, row.nome, row.descricao ?? '']);
          }
        }
        break;

      case 'indicadores':
      case 'indicador':
        final rows = await database.select(database.indicador).get();
        if (rows.isNotEmpty) {
          data.add([
            'ID',
            'Nome',
            'Descrição',
            'Descrição Nível 1',
            'Descrição Nível 5',
            'Peso',
            'Categoria ID',
          ]);
          for (var row in rows) {
            data.add([
              row.id,
              row.nome,
              row.descricao,
              row.descricaoNivel1 ?? '',
              row.descricaoNivel5 ?? '',
              row.peso,
              row.categoriaId,
            ]);
          }
        }
        break;

      case 'avaliacoes':
      case 'avaliacao':
        final rows = await database.select(database.avaliacao).get();
        if (rows.isNotEmpty) {
          data.add(['ID', 'Família ID', 'Data']);
          for (var row in rows) {
            data.add([
              row.id,
              row.familiaId,
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

    final directory = await getExportsDirectory();
    final filePath = '${directory.path}/$fileName';

    StringBuffer csvBuffer = StringBuffer();

    // Comunidades
    csvBuffer.writeln('=== COMUNIDADES ===');
    final comunidades = await database.select(database.comunidade).get();
    csvBuffer.writeln('ID,Nome');
    for (var row in comunidades) {
      csvBuffer.writeln('${row.id},${_escapeCsv(row.nome)}');
    }
    csvBuffer.writeln();

    // Famílias
    csvBuffer.writeln('=== FAMÍLIAS ===');
    final familias = await database.select(database.familia).get();
    csvBuffer.writeln('ID,Nome Responsável,Telefone,Endereço,Comunidade ID');
    for (var row in familias) {
      csvBuffer.writeln(
          '${row.id},${_escapeCsv(row.nomeResponsavel)},${_escapeCsv(row.telefone)},${_escapeCsv(row.endereco)},${row.comunidadeId}');
    }
    csvBuffer.writeln();

    // Categorias
    csvBuffer.writeln('=== CATEGORIAS ===');
    final categorias = await database.select(database.categoria).get();
    csvBuffer.writeln('ID,Nome,Descrição');
    for (var row in categorias) {
      csvBuffer.writeln(
        '${row.id},${_escapeCsv(row.nome)},${_escapeCsv(row.descricao ?? '')}',
      );
    }
    csvBuffer.writeln();

    // Indicadores
    csvBuffer.writeln('=== INDICADORES ===');
    final indicadores = await database.select(database.indicador).get();
    csvBuffer.writeln(
        'ID,Nome,Descrição,Descrição Nível 1,Descrição Nível 5,Peso,Categoria ID,Dimensão ID');
    for (var row in indicadores) {
      csvBuffer.writeln(
        '${row.id},${_escapeCsv(row.nome)},${_escapeCsv(row.descricao)},${_escapeCsv(row.descricaoNivel1 ?? '')},${_escapeCsv(row.descricaoNivel5 ?? '')},${row.peso},${row.categoriaId},${row.dimensaoId ?? ''}',
      );
    }
    csvBuffer.writeln();

    // Dimensões
    csvBuffer.writeln('=== DIMENSÕES ===');
    final dimensoes = await database.select(database.dimensao).get();
    csvBuffer.writeln('ID,Nome,Categoria ID');
    for (var row in dimensoes) {
      csvBuffer.writeln(
        '${row.id},${_escapeCsv(row.nome)},${row.categoriaId}',
      );
    }
    csvBuffer.writeln();

    // Práticas
    csvBuffer.writeln('=== PRÁTICAS ===');
    final praticas = await database.select(database.pratica).get();
    csvBuffer.writeln('ID,Nome,Categoria ID');
    for (var row in praticas) {
      csvBuffer.writeln(
        '${row.id},${_escapeCsv(row.nome)},${row.categoriaId}',
      );
    }
    csvBuffer.writeln();

    // Avaliações
    csvBuffer.writeln('=== AVALIAÇÕES ===');
    final avaliacoes = await database.select(database.avaliacao).get();
    csvBuffer.writeln('ID,Família ID,Data,Avaliador,Status');
    for (var row in avaliacoes) {
      csvBuffer.writeln(
        '${row.id},${row.familiaId},${row.data.toIso8601String()},${_escapeCsv(row.avaliador)},${row.status}',
      );
    }
    csvBuffer.writeln();

    // Itens de Avaliação
    csvBuffer.writeln('=== ITENS DE AVALIAÇÃO ===');
    final avaliacaoItens = await database.select(database.avaliacaoItem).get();
    csvBuffer.writeln(
        'ID,Avaliação ID,Indicador ID,Prática ID,Valor Likert,Valor Fuzzy');
    for (var row in avaliacaoItens) {
      csvBuffer.writeln(
        '${row.id},${row.avaliacaoId},${row.indicadorId},${row.praticaId ?? ''},${row.valorLikert ?? ''},${row.valorFuzzy ?? ''}',
      );
    }

    final file = File(filePath);
    await file.writeAsString(csvBuffer.toString());

    return file;
  }

  /// Restaura o banco de dados a partir de um backup existente
  Future<File> restoreDatabaseBackup(File backupFile) async {
    if (!backupFile.existsSync()) {
      throw Exception('Backup não encontrado: ${backupFile.path}');
    }

    await AppDatabase.resetInstance();

    final dbPath = await _getDatabasePath();
    final currentFile = File(dbPath);
    if (currentFile.existsSync()) {
      await currentFile.delete();
    }

    final restored = await backupFile.copy(dbPath);
    return restored;
  }

  /// Importa dados de um arquivo JSON e substitui o conteúdo atual do banco.
  Future<void> importFromJson(File jsonFile) async {
    if (!jsonFile.existsSync()) {
      throw Exception('Arquivo JSON não encontrado: ${jsonFile.path}');
    }

    final raw = await jsonFile.readAsString();
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Formato JSON inválido para importação.');
    }

    List<dynamic> readList(String key) {
      final value = decoded[key];
      if (value is List<dynamic>) return value;
      return <dynamic>[];
    }

    await database.transaction(() async {
      // Limpeza em ordem de dependência (filho -> pai).
      await database.delete(database.avaliacaoItem).go();
      await database.delete(database.avaliacao).go();
      await database.delete(database.indicador).go();
      await database.delete(database.pratica).go();
      await database.delete(database.dimensao).go();
      await database.delete(database.familia).go();
      await database.delete(database.categoria).go();
      await database.delete(database.comunidade).go();

      for (final row in readList('comunidade')) {
        final map = _asMap(row);
        await database.into(database.comunidade).insert(
              ComunidadeCompanion(
                id: Value(_asInt(map['id']) ?? 0),
                nome: Value(_asString(map['nome']) ?? ''),
              ),
            );
      }

      for (final row in readList('categoria')) {
        final map = _asMap(row);
        await database.into(database.categoria).insert(
              CategoriaCompanion(
                id: Value(_asInt(map['id']) ?? 0),
                nome: Value(_asString(map['nome']) ?? ''),
                descricao: Value(_asString(map['descricao'])),
              ),
            );
      }

      for (final row in readList('dimensao')) {
        final map = _asMap(row);
        await database.into(database.dimensao).insert(
              DimensaoCompanion(
                id: Value(_asInt(map['id']) ?? 0),
                nome: Value(_asString(map['nome']) ?? ''),
                categoriaId: Value(_asInt(map['categoriaId']) ?? 0),
              ),
            );
      }

      for (final row in readList('pratica')) {
        final map = _asMap(row);
        await database.into(database.pratica).insert(
              PraticaCompanion(
                id: Value(_asInt(map['id']) ?? 0),
                nome: Value(_asString(map['nome']) ?? ''),
                categoriaId: Value(_asInt(map['categoriaId']) ?? 0),
              ),
            );
      }

      for (final row in readList('familia')) {
        final map = _asMap(row);
        await database.into(database.familia).insert(
              FamiliaCompanion(
                id: Value(_asInt(map['id']) ?? 0),
                nomeResponsavel: Value(_asString(map['nomeResponsavel']) ?? ''),
                telefone: Value(_asString(map['telefone']) ?? ''),
                endereco: Value(_asString(map['endereco']) ?? ''),
                comunidadeId: Value(_asInt(map['comunidadeId']) ?? 0),
              ),
            );
      }

      for (final row in readList('indicador')) {
        final map = _asMap(row);
        await database.into(database.indicador).insert(
              IndicadorCompanion(
                id: Value(_asInt(map['id']) ?? 0),
                nome: Value(_asString(map['nome']) ?? ''),
                descricao: Value(_asString(map['descricao']) ?? ''),
                descricaoNivel1: Value(_asString(map['descricaoNivel1'])),
                descricaoNivel5: Value(_asString(map['descricaoNivel5'])),
                peso: Value(_asDouble(map['peso']) ?? 1.0),
                categoriaId: Value(_asInt(map['categoriaId']) ?? 0),
                dimensaoId: Value(_asInt(map['dimensaoId'])),
              ),
            );
      }

      for (final row in readList('avaliacao')) {
        final map = _asMap(row);
        await database.into(database.avaliacao).insert(
              AvaliacaoCompanion(
                id: Value(_asInt(map['id']) ?? 0),
                data: Value(_asDateTime(map['data']) ?? DateTime.now()),
                dataAlteracao:
                    Value(_asDateTime(map['dataAlteracao']) ?? DateTime.now()),
                avaliador: Value(_asString(map['avaliador']) ?? ''),
                observacoes: Value(_asString(map['observacoes'])),
                status: Value(_asString(map['status']) ?? 'draft'),
                familiaId: Value(_asInt(map['familiaId']) ?? 0),
              ),
            );
      }

      for (final row in readList('avaliacao_item')) {
        final map = _asMap(row);
        await database.into(database.avaliacaoItem).insert(
              AvaliacaoItemCompanion(
                id: Value(_asInt(map['id']) ?? 0),
                avaliacaoId: Value(_asInt(map['avaliacaoId']) ?? 0),
                indicadorId: Value(_asInt(map['indicadorId']) ?? 0),
                praticaId: Value(_asInt(map['praticaId'])),
                valorLikert: Value(_asInt(map['valorLikert'])),
                valorFuzzy: Value(_asDouble(map['valorFuzzy'])),
              ),
            );
      }
    });

    await _cacheService.invalidarTodosResultados();
  }

  /// Obtem o caminho do banco de dados usado pelo aplicativo
  Future<String> _getDatabasePath() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    return '${documentsDir.path}/db.sqlite';
  }

  /// Escapa caracteres especiais em CSV
  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Retorna uma pasta pública visível ao usuário, em Downloads.
  /// Em Android isso aparece no gestor de ficheiros e no celular do usuário.
  Future<Directory> _getPublicRootDirectory() async {
    if (Platform.isAndroid) {
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null) {
        final rootDir = Directory('${downloadsDir.path}/transicao_ecologica');
        if (!rootDir.existsSync()) {
          rootDir.createSync(recursive: true);
        }
        return rootDir;
      }
    }

    final appDir = await getApplicationDocumentsDirectory();
    final fallbackDir = Directory('${appDir.path}/transicao_ecologica');
    if (!fallbackDir.existsSync()) {
      fallbackDir.createSync(recursive: true);
    }
    return fallbackDir;
  }

  /// Retorna a pasta de exportações
  Future<Directory> getExportsDirectory() async {
    final publicRoot = await _getPublicRootDirectory();
    final exportsDir = Directory('${publicRoot.path}/exports');
    if (!exportsDir.existsSync()) {
      exportsDir.createSync(recursive: true);
    }
    return exportsDir;
  }

  /// Retorna a pasta de backups
  Future<Directory> getBackupsDirectory() async {
    final publicRoot = await _getPublicRootDirectory();
    final backupsDir = Directory('${publicRoot.path}/backups');
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

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  String? _asString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  DateTime? _asDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
