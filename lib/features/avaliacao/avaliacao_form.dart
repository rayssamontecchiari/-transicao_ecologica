import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;

import '../../core/database/app_database.dart';
import '../../core/services/indicadores_service.dart';
import '../../core/services/familia_service.dart';

class CategoriaFormPage extends StatefulWidget {
  final int categoriaId;
  final int? familiaId;
  final Avaliacao? avaliacaoExistente;
  final int? categoriaAtual;
  final int? totalCategorias;

  const CategoriaFormPage({
    super.key,
    required this.categoriaId,
    this.familiaId,
    this.avaliacaoExistente,
    this.categoriaAtual,
    this.totalCategorias,
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
  int? _avaliacaoId; // ID da avaliação em progresso

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

    // Usar parâmetros do widget
    final familiaId = widget.familiaId;
    _categoriaAtual = widget.categoriaAtual ?? 1;
    _totalCategorias = widget.totalCategorias ?? 1;
    _vemDoFluxo = familiaId != null;
    _avaliacaoId = widget.avaliacaoExistente?.id;

    final categoria =
        await _indicadoresService.getCategoriaById(widget.categoriaId);

    final indicadores =
        await _indicadoresService.getIndicadoresByCategoria(widget.categoriaId);

    final isSustentabilidade = categoria != null &&
        categoria.nome ==
            'Análise Multidimensional da Sustentabilidade das Práticas Agrícolas';

    final indicadoresFiltrados = isSustentabilidade
        ? indicadores.where((i) => i.dimensaoId != null).toList()
        : indicadores;

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

    // Se há avaliação existente, carregar dados
    if (widget.avaliacaoExistente != null) {
      await _carregarAvaliacaoExistente(widget.avaliacaoExistente!);
    }

    setState(() {
      _categoria = categoria;
      _indicadores = indicadoresFiltrados;
      _familias = familias;
      _selectedFamilia = familia;

      for (final ind in indicadoresFiltrados) {
        if (_respostas[ind.id] == null) {
          _respostas[ind.id] = null;
        }
      }

      _isLoading = false;
    });
  }

  /// Carrega dados de uma avaliação existente
  Future<void> _carregarAvaliacaoExistente(Avaliacao avaliacao) async {
    try {
      final itens = await _db.select(_db.avaliacaoItens)
        ..where((a) => a.avaliacaoId.equals(avaliacao.id));
      final itensData = await itens.get();

      // Carregar respostas baseado no tipo de categoria
      if (_praticas.isNotEmpty) {
        // Multidimensional: por prática
        for (final item in itensData) {
          if (item.praticaId != null) {
            _respostasPraticas[item.praticaId!]?.add(item.indicadorId);
          }
        }
      } else {
        // Likert: por indicador
        for (final item in itensData) {
          _respostas[item.indicadorId] = item.valorLikert;
        }
      }

      // Carregar dados da avaliação
      _avaliadorController.text = avaliacao.avaliador;
      _observacoesController.text = avaliacao.observacoes ?? '';
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar avaliação: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

  Future<void> _saveDraft() async {
    await _persistAvaliacao(continueFlow: false);
  }

  Future<void> _submit() async {
    await _persistAvaliacao(continueFlow: true);
  }

  Future<void> _persistAvaliacao({required bool continueFlow}) async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFamilia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma família'),
        ),
      );
      return;
    }

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
      int avlId = _avaliacaoId ?? 0;

      if (_avaliacaoId == null) {
        final avaliacao = AvaliacoesCompanion.insert(
          avaliador: _avaliadorController.text.trim().isEmpty
              ? 'Anônimo'
              : _avaliadorController.text.trim(),
          familiaId: _selectedFamilia!.id,
          observacoes: _observacoesController.text.trim().isEmpty
              ? const drift.Value.absent()
              : drift.Value(_observacoesController.text.trim()),
          status: const drift.Value('draft'),
          categoriaAtual: drift.Value(_categoriaAtual ?? 0),
        );

        avlId = await _db.into(_db.avaliacoes).insert(avaliacao);
        _avaliacaoId = avlId;
      } else {
        await _db.update(_db.avaliacoes).replace(
              AvaliacoesCompanion(
                id: drift.Value(_avaliacaoId!),
                familiaId: drift.Value(_selectedFamilia!.id),
                avaliador: drift.Value(
                  _avaliadorController.text.trim().isEmpty
                      ? 'Anônimo'
                      : _avaliadorController.text.trim(),
                ),
                observacoes: drift.Value(
                  _observacoesController.text.trim().isEmpty
                      ? null
                      : _observacoesController.text.trim(),
                ),
                data: drift.Value(DateTime.now()),
                dataAlteracao: drift.Value(DateTime.now()),
                status: drift.Value('draft'),
                categoriaAtual: drift.Value(_categoriaAtual ?? 0),
              ),
            );

        await (_db.delete(_db.avaliacaoItens)
              ..where((a) => a.avaliacaoId.equals(avlId)))
            .go();
      }

      if (_praticas.isNotEmpty) {
        for (final entry in _respostasPraticas.entries) {
          final praticaId = entry.key;
          for (final indicadorId in entry.value) {
            final item = AvaliacaoItensCompanion.insert(
              avaliacaoId: avlId,
              indicadorId: indicadorId,
              praticaId: drift.Value(praticaId),
              valorLikert: const drift.Value(1),
            );
            await _db.into(_db.avaliacaoItens).insert(item);
          }
        }
      } else {
        for (final entry in _respostas.entries) {
          final valor = entry.value;
          if (valor != null) {
            final item = AvaliacaoItensCompanion.insert(
              avaliacaoId: avlId,
              indicadorId: entry.key,
              valorLikert: drift.Value(valor),
            );
            await _db.into(_db.avaliacaoItens).insert(item);
          }
        }
      }

      if (!mounted) return;

      final isUltima = _categoriaAtual == _totalCategorias;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isUltima
              ? '✓ Última categoria salva! Exibindo resultados...'
              : continueFlow
                  ? '✓ Categoria salva! Prosseguindo...'
                  : '✓ Rascunho salvo! Você pode continuar depois.'),
          duration: const Duration(seconds: 2),
        ),
      );

      if (mounted && continueFlow) {
        Navigator.pop(context, avlId);
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
    return WillPopScope(
      onWillPop: () async {
        if (_vemDoFluxo) {
          // Durante o fluxo, mostrar confirmação
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Cancelar avaliação?'),
              content: const Text(
                'Você está no meio de uma avaliação. Deseja realmente cancelar e voltar? Os dados da categoria atual serão perdidos.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Não'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Sim'),
                ),
              ],
            ),
          );
          return confirm ?? false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F8F3),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black87,
          iconTheme: const IconThemeData(color: Colors.black87),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Avaliação',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (_vemDoFluxo &&
                  _categoriaAtual != null &&
                  _totalCategorias != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Categoria $_categoriaAtual de $_totalCategorias',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                  ),
                ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary),
            ),
          ],
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
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.12),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.16),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.info_outline,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Informações da Avaliação',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Preencha os dados abaixo para registrar uma nova avaliação.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Colors.grey[700],
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Dados do Avaliador (opcional)',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        TextFormField(
                          controller: _avaliadorController,
                          decoration: InputDecoration(
                            hintText: 'Nome do Avaliador',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide:
                                  const BorderSide(color: Colors.transparent),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey[200]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.8),
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.person,
                              color: Theme.of(context).colorScheme.primary,
                            ),
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
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
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),

                        if (_praticas.isEmpty) ...[
                          Text(
                            'Avalie cada indicador usando a escala abaixo.',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[700],
                                    ),
                          ),
                          const SizedBox(height: 16),
                          _buildScaleLegend(context),
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
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
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

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _isSaving ? null : _saveDraft,
                                icon: const Icon(Icons.save_outlined),
                                label: Text(
                                  _isSaving ? 'Salvando...' : 'Salvar rascunho',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isSaving ? null : _submit,
                                icon: _isSaving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : const Icon(Icons.arrow_forward),
                                label: Text(
                                  _isSaving ? 'Salvando...' : 'Salvar',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildIndicadorTile(Indicador indicador) {
    final valor = _respostas[indicador.id];
    final steps = ['Muito baixo', 'Baixo', 'Regular', 'Alto', 'Muito alto'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getIndicadorIcon(indicador.nome),
                    color: Theme.of(context).colorScheme.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        indicador.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (indicador.descricao.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            indicador.descricao,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _buildLikertScale(indicador),
          ],
        ),
      ),
    );
  }

  Widget _buildLikertScale(Indicador indicador) {
    final valor = _respostas[indicador.id] ?? 0;
    final labels = ['Muito baixo', 'Baixo', 'Regular', 'Alto', 'Muito alto'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 58,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  final value = index + 1;
                  final isSelected = valor == value;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _respostas[indicador.id] = value;
                      });
                    },
                    child: Container(
                      width: isSelected ? 32 : 22,
                      height: isSelected ? 32 : 22,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[400]!,
                          width: isSelected ? 2 : 1,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.18),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '$value',
                          style: TextStyle(
                            fontSize: isSelected ? 14 : 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: labels
              .map(
                (label) => Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  IconData _getIndicadorIcon(String nome) {
    final lower = nome.toLowerCase();
    if (lower.contains('energia')) return Icons.bolt;
    if (lower.contains('insumos') || lower.contains('fertiliz'))
      return Icons.grass;
    if (lower.contains('solo') ||
        lower.contains('água') ||
        lower.contains('agua')) return Icons.water;
    if (lower.contains('produção') || lower.contains('producao'))
      return Icons.agriculture;
    return Icons.leaderboard;
  }

  Widget _buildScaleLegend(BuildContext context) {
    final labels = ['Muito baixo', 'Baixo', 'Regular', 'Alto', 'Muito alto'];
    final colors = [
      Colors.red.shade400,
      Colors.orange.shade600,
      Colors.amber.shade600,
      Colors.green.shade400,
      Colors.green.shade700,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(labels.length, (index) {
          return Expanded(
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors[index],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGridTable() {
    final columns = _indicadores;

    if (_praticas.isEmpty) {
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

    final maxCheckboxWidth =
        MediaQuery.of(context).size.width > 760 ? 320.0 : double.infinity;

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
        ..._praticas.map((p) {
          final selected = _respostasPraticas[p.id]!;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.nome,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: columns.map((ind) {
                      final checked = selected.contains(ind.id);
                      return SizedBox(
                        width: maxCheckboxWidth,
                        child: CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: checked,
                          title: Text(
                            ind.nome,
                            style: const TextStyle(fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
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
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
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
