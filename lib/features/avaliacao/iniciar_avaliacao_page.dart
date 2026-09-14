import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift hide Column, Table;

import '../../core/database/app_database.dart';
import '../../core/services/familia_service.dart';
import '../../core/services/categoria_service.dart';
import '../../core/services/resultado_avaliacao_service.dart';
import 'avaliacao_form.dart';
import 'resultado_avaliacao_page.dart';

/// Página inicial do fluxo de avaliação.
/// Permite selecionar uma família e iniciar o fluxo de 4 categorias de avaliação.
class IniciarAvaliacaoPage extends StatefulWidget {
  final int? initialFamiliaId;
  final int? autoResumeAvaliacaoId;

  const IniciarAvaliacaoPage({
    super.key,
    this.initialFamiliaId,
    this.autoResumeAvaliacaoId,
  });

  const IniciarAvaliacaoPage.comAvaliacaoEmRascunho({
    super.key,
    required this.initialFamiliaId,
    required this.autoResumeAvaliacaoId,
  });

  @override
  State<IniciarAvaliacaoPage> createState() => _IniciarAvaliacaoPageState();
}

class _IniciarAvaliacaoPageState extends State<IniciarAvaliacaoPage> {
  late FamiliasService _familiasService;
  late CategoriaService _categoriaService;
  late ResultadoAvaliacaoService _resultadoAvaliacaoService;
  late AppDatabase _db;

  List<FamiliaData> _familias = [];
  List<CategoriaData> _categorias = [];
  List<AvaliacaoData> _avaliacoesDaFamilia = [];
  FamiliaData? _selectedFamilia;
  bool _isLoading = true;
  int _categoriaAtual = 0;
  bool _isProcessing = false;
  int? _avaliacaoIdEmProgresso; // ID da avaliação em draft
  int? _avaliacaoPendenteId;
  int _draftCount = 0;
  bool _autoResumeTriggered = false;
  final TextEditingController _avaliadorController = TextEditingController();
  DateTime _dataAvaliacao = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _avaliadorController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    _db = await AppDatabase.instance();
    _familiasService = FamiliasService(_db);
    _categoriaService = CategoriaService(_db);
    _resultadoAvaliacaoService = ResultadoAvaliacaoService(_db);

    final familias = await _familiasService.getTodas();
    final categorias = await _categoriaService.getTodas();

    setState(() {
      _familias = familias;
      _categorias = categorias;
      _isLoading = false;
      if (familias.isNotEmpty) {
        _selectedFamilia = widget.initialFamiliaId != null
            ? familias.where((familia) => familia.id == widget.initialFamiliaId).cast<FamiliaData?>().firstWhere((familia) => familia != null, orElse: () => familias.first)
            : familias.first;
      }
    });

    if (_selectedFamilia != null) {
      await _carregarAvaliacoesDaFamilia();
      _maybeAutoResumeDraft();
    }
  }

  void _maybeAutoResumeDraft() {
    if (_autoResumeTriggered || widget.autoResumeAvaliacaoId == null) return;
    _autoResumeTriggered = true;

    final avaliacao = _avaliacoesDaFamilia.where(
      (item) => item.id == widget.autoResumeAvaliacaoId,
    );

    if (avaliacao.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isProcessing) return;
      _iniciarAvaliacao(avaliacaoExistente: avaliacao.first);
    });
  }

  Future<void> _carregarAvaliacoesDaFamilia() async {
    if (_selectedFamilia == null) return;

    final avaliacoes = await (_db.select(_db.avaliacao)
          ..where((a) =>
              a.familiaId.equals(_selectedFamilia!.id) &
              a.status.equals('draft')))
        .get();

    final todasAvaliacoes = await (_db.select(_db.avaliacao)
          ..where((a) => a.familiaId.equals(_selectedFamilia!.id))
          ..orderBy([
            (a) =>
                drift.OrderingTerm(expression: a.dataAlteracao, mode: drift.OrderingMode.desc)
          ]))
        .get();

    final avaliacaoPendente = avaliacoes.isNotEmpty ? avaliacoes.first : null;

    if (!mounted) return;

    setState(() {
      _avaliacaoPendenteId = avaliacaoPendente?.id;
      _draftCount = avaliacoes.length;
      _avaliacoesDaFamilia = todasAvaliacoes;
      _avaliadorController.text = avaliacaoPendente?.avaliador ?? '';
      _dataAvaliacao = avaliacaoPendente != null
          ? DateTime(avaliacaoPendente.data.year, avaliacaoPendente.data.month)
          : DateTime(DateTime.now().year, DateTime.now().month, 1);
    });

    _maybeAutoResumeDraft();
  }

  Future<void> _selecionarMesAno() async {
    const meses = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];

    final anos = List.generate(
      11,
      (index) => DateTime.now().year - 5 + index,
    );

    final resultado = await showDialog<Map<String, int>>(
      context: context,
      builder: (context) {
        var mesSelecionado = _dataAvaliacao.month;
        var anoSelecionado = _dataAvaliacao.year;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Selecione o mês e o ano'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: mesSelecionado,
                    decoration: const InputDecoration(
                      labelText: 'Mês',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(
                      meses.length,
                      (index) => DropdownMenuItem<int>(
                        value: index + 1,
                        child: Text(meses[index]),
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setStateDialog(() => mesSelecionado = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: anoSelecionado,
                    decoration: const InputDecoration(
                      labelText: 'Ano',
                      border: OutlineInputBorder(),
                    ),
                    items: anos
                        .map(
                          (ano) => DropdownMenuItem<int>(
                            value: ano,
                            child: Text('$ano'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setStateDialog(() => anoSelecionado = value);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(
                    context,
                    {'mes': mesSelecionado, 'ano': anoSelecionado},
                  ),
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (resultado == null) return;

    setState(() {
      _dataAvaliacao = DateTime(
        resultado['ano']!,
        resultado['mes']!,
        1,
      );
    });
  }

  String _formatarMesAno(DateTime data) {
    final mes = data.month.toString().padLeft(2, '0');
    return '$mes/${data.year}';
  }

  DateTime _normalizarMesAno(DateTime data) {
    return DateTime(data.year, data.month, 1);
  }

  Future<void> _iniciarAvaliacao({AvaliacaoData? avaliacaoExistente}) async {
    if (_selectedFamilia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma família')),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isProcessing = true);

    try {
      int avaliacaoIdExistente;

      if (avaliacaoExistente != null) {
        avaliacaoIdExistente = avaliacaoExistente.id;
        await (_db.update(_db.avaliacao)
              ..where((a) => a.id.equals(avaliacaoIdExistente)))
            .write(
          AvaliacaoCompanion(
            data: drift.Value(_normalizarMesAno(_dataAvaliacao)),
            dataAlteracao: drift.Value(DateTime.now()),
            avaliador: drift.Value(_avaliadorController.text.trim()),
            status: drift.Value(
              avaliacaoExistente.status == 'completed'
                  ? 'draft'
                  : avaliacaoExistente.status,
            ),
          ),
        );
      } else {
        // Criar uma nova avaliação
        avaliacaoIdExistente = await _db.avaliacao.insertOne(
          AvaliacaoCompanion.insert(
            familiaId: _selectedFamilia!.id,
            avaliador: _avaliadorController.text,
            data: drift.Value(_normalizarMesAno(_dataAvaliacao)),
            status: const drift.Value('draft'),
          ),
        );
      }

      _avaliacaoIdEmProgresso = avaliacaoIdExistente;

      var completouTodasCategorias = true;

      for (int i = 0; i < _categorias.length; i++) {
        if (!mounted) break;

        setState(() => _categoriaAtual = i);

        final categoria = _categorias[i];

        final completed = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => CategoriaFormPage(
              categoriaId: categoria.id,
              familiaId: _selectedFamilia!.id,
              avaliacaoId: _avaliacaoIdEmProgresso!,
              categoriaAtual: i + 1,
              totalCategorias: _categorias.length,
            ),
          ),
        );

        if (completed != true) {
          // User cancelled or did not complete the category
          completouTodasCategorias = false;
          break;
        }

        // Não atualizamos mais `categoriaAtual` no banco; apenas registramos
        // a data de alteração para referência.
        if (_avaliacaoIdEmProgresso != null) {
          await (_db.update(_db.avaliacao)
                ..where((a) => a.id.equals(_avaliacaoIdEmProgresso!)))
              .write(
            AvaliacaoCompanion(
              dataAlteracao: drift.Value(DateTime.now()),
            ),
          );
        }
      }

      if (mounted) {
        // Verificar se completou todas as categorias
        if (completouTodasCategorias && _categoriaAtual == _categorias.length - 1) {
          // Marca avaliação como finalizada quando todas as categorias foram preenchidas.
          await (_db.update(_db.avaliacao)
                ..where((a) => a.id.equals(_avaliacaoIdEmProgresso!)))
              .write(AvaliacaoCompanion(
            status: const drift.Value('completed'),
            dataAlteracao: drift.Value(DateTime.now()),
          ));

          // Precalcula e persiste cache dos resultados ao finalizar a avaliacao.
          await _resultadoAvaliacaoService
              .calcularResultadosCompletos(_avaliacaoIdEmProgresso!);

          // Avaliação foi completada - ir para página de resultados
          navigator.pushReplacement(
            MaterialPageRoute(
              builder: (_) => ResultadoAvaliacaoPage(
                avaliacaoId: _avaliacaoIdEmProgresso!,
                familia: _selectedFamilia!,
              ),
            ),
          );
        } else {
          // Avaliação foi cancelada - voltar
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Avaliação cancelada. Dados salvos em rascunho.'),
              duration: Duration(seconds: 2),
            ),
          );
          navigator.pop();
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: primary,
        iconTheme: IconThemeData(color: primary),
        title: Text(
          'Iniciar avaliação',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: primary,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nova avaliação agroecológica',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Preencha os dados básicos para iniciar o fluxo.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '1. Família',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<FamiliaData>(
                          value: _selectedFamilia,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            hintText: 'Selecionar família',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          items: _familias
                              .map(
                                (f) => DropdownMenuItem(
                                  value: f,
                                  child: Text(
                                    f.nomeResponsavel,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: _isProcessing
                              ? null
                              : (f) async {
                                  setState(() => _selectedFamilia = f);
                                  await _carregarAvaliacoesDaFamilia();
                                },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '2. Avaliador',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _avaliadorController,
                          enabled: !_isProcessing,
                          decoration: const InputDecoration(
                            hintText: 'Nome do avaliador',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '3. Mês e ano',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: _isProcessing ? null : _selecionarMesAno,
                          icon: const Icon(Icons.calendar_month_outlined, size: 18),
                          label: Text(_formatarMesAno(_dataAvaliacao)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_draftCount > 0) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Você possui $_draftCount avaliação(ões) em rascunho para esta família.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (_avaliacaoPendenteId != null)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isProcessing
                                ? null
                                : () => _iniciarAvaliacao(
                                    avaliacaoExistente: _avaliacoesDaFamilia
                                        .firstWhere((a) => a.id == _avaliacaoPendenteId),
                                  ),
                            icon: const Icon(Icons.play_arrow_outlined),
                            label: const Text('Retomar rascunho'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isProcessing
                                ? null
                                : () => _iniciarAvaliacao(),
                            icon: const Icon(Icons.add),
                            label: const Text('Nova'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primary,
                              side: BorderSide(color: primary),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: _isProcessing
                          ? null
                          : () => _iniciarAvaliacao(),
                      icon: const Icon(Icons.play_arrow_outlined),
                      label: Text(
                        _isProcessing ? 'Iniciando...' : 'Iniciar avaliação',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  const SizedBox(height: 14),
                  if (_avaliacoesDaFamilia.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Avaliações da família',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._avaliacoesDaFamilia.map((avaliacao) {
                            final isDraft = avaliacao.status == 'draft';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDraft
                                      ? primary.withOpacity(0.06)
                                      : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDraft
                                        ? primary.withOpacity(0.18)
                                        : Colors.grey.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isDraft
                                          ? Icons.edit_note_outlined
                                          : Icons.fact_check_outlined,
                                      color: isDraft ? primary : Colors.grey[700],
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${_formatarMesAno(avaliacao.data)} • ${avaliacao.avaliador}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            isDraft ? 'Rascunho' : 'Concluída',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDraft
                                                  ? primary
                                                  : Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: _isProcessing
                                          ? null
                                          : () => _iniciarAvaliacao(
                                              avaliacaoExistente: avaliacao,
                                            ),
                                      icon: Icon(
                                        isDraft ? Icons.play_arrow : Icons.edit,
                                        size: 18,
                                      ),
                                      label: Text(isDraft ? 'Retomar' : 'Editar'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Categorias a serem avaliadas',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_categorias.isEmpty)
                          const Center(child: CircularProgressIndicator())
                        else
                          ..._categorias.asMap().entries.map((entry) {
                            final index = entry.key;
                            final categoria = entry.value;
                            final iconData = [
                              Icons.agriculture,
                              Icons.eco,
                              Icons.group,
                              Icons.bar_chart,
                            ][index % 4];

                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(iconData, color: primary, size: 22),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        categoria.nome,
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
