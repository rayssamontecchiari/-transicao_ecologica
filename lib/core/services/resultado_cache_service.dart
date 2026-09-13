import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/resultado_avaliacao.dart';

/// Cache persistente dos resultados fuzzy por avaliacao.
///
/// Os resultados sao considerados validos quando:
/// - dataAlteracao da avaliacao nao mudou
/// - versao de configuracao (pesos/indicadores) nao mudou
class ResultadoCacheService {
  static const String _calculoVersion =
      'fuzzy_media_ponderada_v3_cat2_agregado';
  static ResultadoCacheService? _instance;

  ResultadoCacheService._();

  factory ResultadoCacheService() {
    _instance ??= ResultadoCacheService._();
    return _instance!;
  }

  Future<File> _getCacheFile() async {
    final folder = await getApplicationDocumentsDirectory();
    return File(p.join(folder.path, 'resultados_cache.json'));
  }

  Future<Map<String, dynamic>> _readCache() async {
    final file = await _getCacheFile();
    if (!await file.exists()) {
      return {
        'configVersion': DateTime.now().toIso8601String(),
        'avaliacoes': <String, dynamic>{},
      };
    }

    try {
      final content = await file.readAsString();
      final data = jsonDecode(content);
      if (data is Map<String, dynamic>) {
        data.putIfAbsent(
            'configVersion', () => DateTime.now().toIso8601String());
        data.putIfAbsent('avaliacoes', () => <String, dynamic>{});
        return data;
      }
    } catch (_) {
      // Se o cache estiver corrompido, reconstroi estrutura base.
    }

    return {
      'configVersion': DateTime.now().toIso8601String(),
      'avaliacoes': <String, dynamic>{},
    };
  }

  Future<void> _writeCache(Map<String, dynamic> data) async {
    final file = await _getCacheFile();
    await file.writeAsString(jsonEncode(data));
  }

  Future<String> obterVersaoConfiguracao() async {
    final data = await _readCache();
    final value = data['configVersion'];
    if (value is String && value.isNotEmpty) {
      return value;
    }

    final now = DateTime.now().toIso8601String();
    data['configVersion'] = now;
    await _writeCache(data);
    return now;
  }

  Future<void> invalidarTodosResultados() async {
    final data = await _readCache();
    data['configVersion'] = DateTime.now().toIso8601String();
    data['avaliacoes'] = <String, dynamic>{};
    await _writeCache(data);
  }

  Future<void> removerResultadosDaAvaliacao(int avaliacaoId) async {
    final data = await _readCache();
    final avaliacoes = _asMap(data['avaliacoes']);
    avaliacoes.remove(avaliacaoId.toString());
    data['avaliacoes'] = avaliacoes;
    await _writeCache(data);
  }

  Future<List<ResultadoAvaliacao>?> obterResultadosSeValidos({
    required int avaliacaoId,
    required DateTime dataAlteracao,
    required String configVersion,
  }) async {
    final data = await _readCache();
    final avaliacoes = _asMap(data['avaliacoes']);
    final entry = _asMap(avaliacoes[avaliacaoId.toString()]);

    if (entry.isEmpty) return null;

    final cachedDataAlteracao = entry['dataAlteracao'];
    final cachedConfigVersion = entry['configVersion'];
    final cachedCalculoVersion = entry['calculoVersion'];
    final rawResultados = entry['resultados'];

    if (cachedDataAlteracao != dataAlteracao.toIso8601String()) return null;
    if (cachedConfigVersion != configVersion) return null;
    if (cachedCalculoVersion != _calculoVersion) return null;
    if (rawResultados is! List) return null;

    final resultados = <ResultadoAvaliacao>[];

    for (final raw in rawResultados) {
      final map = _asMap(raw);
      if (map.isEmpty) continue;

      resultados.add(
        ResultadoAvaliacao(
          avaliacaoId: _asInt(map['avaliacaoId']) ?? avaliacaoId,
          categoriaId: _asInt(map['categoriaId']) ?? 0,
          valorFuzzyFinal: _asDouble(map['valorFuzzyFinal']) ?? 0.0,
          sumD: _asDouble(map['sumD']) ?? 0.0,
          sumA: _asDouble(map['sumA']) ?? 0.0,
          sumB: _asDouble(map['sumB']) ?? 0.0,
          sumC: _asDouble(map['sumC']) ?? 0.0,
          centroid: _asDouble(map['centroid']) ?? 0.0,
          base: _asDouble(map['base']) ?? 0.0,
        ),
      );
    }

    return resultados;
  }

  Future<void> salvarResultados({
    required int avaliacaoId,
    required DateTime dataAlteracao,
    required String configVersion,
    required List<ResultadoAvaliacao> resultados,
  }) async {
    final data = await _readCache();
    final avaliacoes = _asMap(data['avaliacoes']);

    avaliacoes[avaliacaoId.toString()] = {
      'dataAlteracao': dataAlteracao.toIso8601String(),
      'configVersion': configVersion,
      'calculoVersion': _calculoVersion,
      'resultados': resultados
          .map(
            (r) => {
              'avaliacaoId': r.avaliacaoId,
              'categoriaId': r.categoriaId,
              'valorFuzzyFinal': r.valorFuzzyFinal,
              'sumD': r.sumD,
              'sumA': r.sumA,
              'sumB': r.sumB,
              'sumC': r.sumC,
              'centroid': r.centroid,
              'base': r.base,
            },
          )
          .toList(),
    };

    data['avaliacoes'] = avaliacoes;
    await _writeCache(data);
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map(
        (key, val) => MapEntry(key.toString(), val),
      );
    }
    return <String, dynamic>{};
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  double? _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
