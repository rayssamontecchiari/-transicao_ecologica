import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;

import '../../core/database/app_database.dart';
import '../../core/services/indicadores_service.dart';
import '../../core/services/familia_service.dart';

class CategoriaFormPage extends StatefulWidget {
  final int categoriaId;

  const CategoriaFormPage({
    super.key,
    required this.categoriaId,
  });

  @override
  State<CategoriaFormPage> createState() => _CategoriaFormPageState();
}

class _CategoriaFormPageState extends State<CategoriaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _avaliadorController = TextEditingController();
  final _observacoesController = TextEditingController();

  late AppDatabase _db;
  late IndicadoresService _indicadoresService;
  late FamiliasService _familiasService;

  Categoria? _categoria;
  List<Indicador> _indicadores = [];
  List<Familia> _familias = [];
  List<Pratica> _praticas = [];
  Familia? _selectedFamilia;

  // Controle do fluxo de avaliação
  int? _categoriaAtual;
  int? _totalCategorias;
  bool _vemDoFluxo = false;

  /// respostas para avaliações comuns: indicadorId -> valor (1..5)
  final Map<int, int?> _respostas = {};

  /// respostas para a categoria multidimensional: praticaId -> conjunto de
  /// indicadores observados (cada um vale 1 ponto)
  final Map<int, Set<int>> _respostasPraticas = {};

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _db = await AppDatabase.instance();
    _indicadoresService = IndicadoresService(_db);
    _familiasService = FamiliasService(_db);

    // Obter dados passados via arguments do fluxo de avaliação
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final familiaId = args?['familiaId'] as int?;
    _categoriaAtual = args?['categoriaAtual'] as int?;
    _totalCategorias = args?['totalCategorias'] as int?;
    _vemDoFluxo = familiaId != null;

    final categoria =
        await _indicadoresService.getCategoriaById(widget.categoriaId);

    final indicadores =
        await _indicadoresService.getIndicadoresByCategoria(widget.categoriaId);

    final familias = await _familiasService.getTodas();
    final familia = familiaId != null
        ? familias.firstWhere((f) => f.id == familiaId,
            orElse: () => familias.first)
        : (familias.isNotEmpty ? familias.first : null);

    // if this is the special category, load practices as well
    if (categoria != null &&
        categoria.nome ==
            'Análise Multidimensional da Sustentabilidade das Práticas Agrícolas') {
      _praticas = await (_db.select(_db.praticas)
            ..where((p) => p.categoriaId.equals(widget.categoriaId)))
          .get();
      for (final p in _praticas) {
        _respostasPraticas[p.id] = <int>{};
      }
    }

    setState(() {
      _categoria = categoria;
      _indicadores = indicadores;
      _familias = familias;
      _selectedFamilia = familia;

      for (final ind in indicadores) {
        _respostas[ind.id] = null;
      }

      _isLoading = false;
    });
  }

  /// Valida se todos os indicadores foram preenchidos
  bool _todoIndicadoresPreenchidos() {
    if (_praticas.isNotEmpty) {
      // Modo multidimensional: qualquer aspecto observado é válido
      return true;
    } else {
      // Modo Likert: todos os indicadores devem ter uma nota
      return _respostas.values.every((v) => v != null);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFamilia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma família'),
        ),
      );
      return;
    }

    // Validar que todos os indicadores foram preenchidos
    if (!_todoIndicadoresPreenchidos()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Preencha todos os indicadores antes de continuar'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final avaliacao = AvaliacoesCompanion.insert(
        avaliador: _avaliadorController.text.trim().isEmpty
            ? 'Anônimo'
            : _avaliadorController.text.trim(),
        familiaId: _selectedFamilia!.id,
        observacoes: _observacoesController.text.trim().isEmpty
            ? const drift.Value.absent()
            : drift.Value(
                _observacoesController.text.trim(),
              ),
      );

      final avaliacaoId = await _db.into(_db.avaliacoes).insert(avaliacao);

      if (_praticas.isNotEmpty) {
        // build itens a partir do mapa de respostas por prática
        for (final entry in _respostasPraticas.entries) {
          final praticaId = entry.key;
          for (final indicadorId in entry.value) {
            final item = AvaliacaoItensCompanion.insert(
              avaliacaoId: avaliacaoId,
              indicadorId: indicadorId,
              praticaId: drift.Value(praticaId),
              valorLikert: const drift.Value(1),
            );
            await _db.into(_db.avaliacaoItens).insert(item);
          }
        }
      } else {
        // padrão: notas Likert
        for (final entry in _respostas.entries) {
          final valor = entry.value;

          if (valor != null) {
            final item = AvaliacaoItensCompanion.insert(
              avaliacaoId: avaliacaoId,
              indicadorId: entry.key,
              valorLikert: drift.Value(valor),
            );

            await _db.into(_db.avaliacaoItens).insert(item);
          }
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Avaliação salva com sucesso!'),
          duration: Duration(seconds: 2),
        ),
      );

      // Mostrar resumo da avaliação
      await _mostrarResumoAvaliacao(avaliacaoId);

      // Retornar true para indicar que a avaliação foi salva
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _avaliadorController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _categoria?.nome ?? 'Avaliação',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16),
            ),
            if (_vemDoFluxo &&
                _categoriaAtual != null &&
                _totalCategorias != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Categoria $_categoriaAtual de $_totalCategorias',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.normal),
                ),
              ),
          ],
        ),
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Cabeçalho com instruções
                      Card(
                        color: Theme.of(context).primaryColor.withOpacity(0.05),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Informações da Avaliação',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Preencha os dados abaixo para registrar uma nova avaliação.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Seção: Avaliador
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Dados do Avaliador',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      TextFormField(
                        controller: _avaliadorController,
                        decoration: const InputDecoration(
                          labelText: 'Nome do Avaliador (opcional)',
                          hintText: 'Ex: João Silva',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Seção: Família
                      if (!_vemDoFluxo) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Dados da Família',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        DropdownButtonFormField<Familia>(
                          value: _selectedFamilia,
                          decoration: const InputDecoration(
                            labelText: 'Selecione a Família *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.home),
                          ),
                          items: _familias
                              .map(
                                (f) => DropdownMenuItem(
                                  value: f,
                                  child: Text(
                                      'Família ${f.id} - ${f.nomeResponsavel}'),
                                ),
                              )
                              .toList(),
                          onChanged: (f) =>
                              setState(() => _selectedFamilia = f),
                          validator: (v) =>
                              v == null ? 'Selecione uma família' : null,
                        ),
                        const SizedBox(height: 32),
                      ] else if (_selectedFamilia != null) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Família:',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.grey[50],
                          ),
                          child: Text(
                            'Família ${_selectedFamilia!.id} - ${_selectedFamilia!.nomeResponsavel}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Seção: Indicadores
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _praticas.isEmpty
                              ? 'Indicadores de Avaliação'
                              : 'Matriz de Avaliação',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),

                      if (_praticas.isEmpty) ...[
                        Text(
                          'Avalie cada indicador usando a escala de 1 a 5:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._indicadores.map(_buildIndicadorTile),
                      ] else ...[
                        _buildGridTable(),
                      ],

                      const SizedBox(height: 24),

                      // Seção: Observações
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Observações Adicionais',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      TextFormField(
                        controller: _observacoesController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Observações (opcional)',
                          hintText:
                              'Adicione comentários ou contextos relevantes...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.note),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Botão de submissão
                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _submit,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.check_circle),
                          label: Text(
                            _isSaving
                                ? 'Salvando Avaliação...'
                                : 'Salvar Avaliação',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildIndicadorTile(Indicador indicador) {
    final valor = _respostas[indicador.id];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        indicador.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (indicador.descricao.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            indicador.descricao,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (valor != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Avaliação: $valor',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(5, (i) {
                    final val = i + 1;
                    final isSelected = valor == val;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _respostas[indicador.id] = val;
                        });
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$val',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  isSelected ? Colors.white : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridTable() {
    final columns = _indicadores;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Instruções: Marque os aspectos observados para cada prática',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateColor.resolveWith(
              (states) => Theme.of(context).primaryColor.withOpacity(0.1),
            ),
            columns: [
              const DataColumn(
                label: Text(
                  'Prática Agrícola',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ...columns.map((ind) => DataColumn(
                    label: Expanded(
                      child: Text(
                        ind.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )),
            ],
            rows: _praticas.map((p) {
              final selected = _respostasPraticas[p.id]!;
              return DataRow(
                cells: [
                  DataCell(
                    SizedBox(
                      width: 150,
                      child: Text(
                        p.nome,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  ...columns.map((ind) {
                    final checked = selected.contains(ind.id);
                    return DataCell(
                      Center(
                        child: Checkbox(
                          value: checked,
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                selected.add(ind.id);
                              } else {
                                selected.remove(ind.id);
                              }
                            });
                          },
                        ),
                      ),
                    );
                  }),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Future<void> _mostrarResumoAvaliacao(int avaliacaoId) async {
    try {
      final itens = await _db.select(_db.avaliacaoItens)
        ..where((a) => a.avaliacaoId.equals(avaliacaoId));
      final itensData = await itens.get();

      // Agrupar itens por indicador
      final Map<int, (Indicador?, AvaliacaoItem)> itensAgrupados = {};
      for (final item in itensData) {
        final indicador = _indicadores.firstWhere(
          (i) => i.id == item.indicadorId,
          orElse: () => Indicador(
            id: item.indicadorId,
            nome: 'Indicador ${item.indicadorId}',
            descricao: '',
            peso: 1.0,
            dimensaoId: null,
            categoriaId: widget.categoriaId,
          ),
        );
        itensAgrupados[item.indicadorId] = (indicador, item);
      }

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              const Text('Resumo da Avaliação'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_categoria != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Categoria:',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(_categoria!.nome),
                      const SizedBox(height: 16),
                    ],
                  ),
                Text(
                  'Itens Avaliados:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...itensAgrupados.entries.map((entry) {
                  final indicador = entry.value.$1;
                  final item = entry.value.$2;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          indicador?.nome ?? 'Indicador ${item.indicadorId}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (item.valorLikert != null)
                          Text(
                            'Valor: ${item.valorLikert}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar resumo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
