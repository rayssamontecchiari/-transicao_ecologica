import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import '../../core/database/app_database.dart';
import '../../core/services/export_service.dart';
import '../../core/theme/app_theme.dart';
import '../home_page.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  ExportService? exportService;
  bool isLoading = false;
  String? message;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    final db = await AppDatabase.instance();
    setState(() {
      exportService = ExportService(db);
    });
  }

  void _showMessage(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppTheme.danger : AppTheme.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _exportBackup() async {
    if (exportService == null) return;
    setState(() => isLoading = true);
    try {
      final file = await exportService!.exportDatabaseBackup();
      _showMessage('Backup criado com sucesso!\n${file.path}');
    } catch (e) {
      _showMessage('Erro ao criar backup: $e', isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _exportJSON() async {
    if (exportService == null) return;
    setState(() => isLoading = true);
    try {
      final file = await exportService!.exportAsJson();
      _showMessage('Exportação JSON concluída!\n${file.path}');
      if (mounted) {
        _showShareDialog(file);
      }
    } catch (e) {
      _showMessage('Erro ao exportar JSON: $e', isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _exportAllCSV() async {
    if (exportService == null) return;
    setState(() => isLoading = true);
    try {
      final file = await exportService!.exportAllAsCSV();
      _showMessage('Exportação CSV concluída!\n${file.path}');
      if (mounted) {
        _showShareDialog(file);
      }
    } catch (e) {
      _showMessage('Erro ao exportar CSV: $e', isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<bool> _isValidDatabaseFile(File file) async {
    final path = file.path.toLowerCase();
    return path.endsWith('.db') ||
        path.endsWith('.sqlite') ||
        path.endsWith('.sqlite3');
  }

  Future<void> _importDatabase() async {
    if (exportService == null) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      dialogTitle: 'Selecione o arquivo de banco de dados (.db ou .sqlite)',
    );

    if (result == null ||
        result.files.isEmpty ||
        result.files.single.path == null) {
      return;
    }

    final file = File(result.files.single.path!);
    if (!await _isValidDatabaseFile(file)) {
      _showMessage('Selecione um arquivo .db ou .sqlite válido.',
          isError: true);
      return;
    }

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Importar Banco de Dados'),
          content: const Text(
            'Importar este arquivo irá substituir o banco de dados atual e pode causar perda de dados recentes. Deseja continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Importar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => isLoading = true);
    try {
      await exportService!.restoreDatabaseBackup(file);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Banco importado com sucesso! Reiniciando app...'),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 300));
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } catch (e) {
      _showMessage('Erro ao importar banco: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _exportTableCSV(String tableName) async {
    if (exportService == null) return;
    setState(() => isLoading = true);
    try {
      final file = await exportService!.exportAsCSV(tableName);
      _showMessage('Tabela "$tableName" exportada!\n${file.path}');
      if (mounted) {
        _showShareDialog(file);
      }
    } catch (e) {
      _showMessage('Erro ao exportar: $e', isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _restoreBackup(File file) async {
    if (exportService == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Restaurar Backup'),
          content: const Text(
            'Restaurar esse backup irá substituir o banco de dados atual e pode causar perda de dados recentes. Deseja continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Restaurar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => isLoading = true);
    try {
      final restored = await exportService!.restoreDatabaseBackup(file);
      _showMessage(
          'Backup restaurado com sucesso! Reinicie o app para aplicar.\n${restored.path}');
      await _initializeService();
    } catch (e) {
      _showMessage('Erro ao restaurar backup: $e', isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildImportButton() {
    return ElevatedButton.icon(
      onPressed: isLoading || exportService == null ? null : _importDatabase,
      icon: const Icon(Icons.upload_file),
      label: const Text('Importar BD externo'),
    );
  }

  Widget _buildBackupsList() {
    if (exportService == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<List<FileSystemEntity>>(
      future: exportService!.listBackups(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Nenhum backup encontrado. Crie um backup antes de restaurar.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        final files = snapshot.data!;
        return Column(
          children: files.map((file) {
            final fileName = p.basename(file.path);
            final stat = File(file.path).statSync();
            final size = _formatBytes(stat.size);
            final modified =
                DateFormat('dd/MM/yyyy HH:mm').format(stat.modified);

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.storage),
                title: Text(fileName),
                subtitle: Text('$size • $modified'),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'restore') {
                      await _restoreBackup(File(file.path));
                    } else if (value == 'share') {
                      Share.shareXFiles([XFile(file.path)], text: fileName);
                    } else if (value == 'delete') {
                      _deleteFile(file.path);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'restore', child: Text('Restaurar')),
                    const PopupMenuItem(
                        value: 'share', child: Text('Compartilhar')),
                    const PopupMenuItem(
                        value: 'delete', child: Text('Deletar')),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showShareDialog(File file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compartilhar arquivo'),
        content: const Text('Deseja compartilhar este arquivo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Share.shareXFiles(
                [XFile(file.path)],
                text: 'Exportação de dados - ${p.basename(file.path)}',
              );
              Navigator.pop(context);
            },
            child: const Text('Compartilhar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exportar Dados'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ========================
                // SEÇÃO DE BACKUP
                // ========================
                _buildSectionTitle('📦 Backup de Banco de Dados'),
                const SizedBox(height: 8),
                Text(
                  'Crie uma cópia completa do banco de dados para restauração futura.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed:
                      isLoading || exportService == null ? null : _exportBackup,
                  icon: const Icon(Icons.backup),
                  label: const Text('Criar Backup'),
                ),
                const SizedBox(height: 24),

                // ========================
                // SEÇÃO DE EXPORTAÇÕES
                // ========================
                _buildSectionTitle('📊 Exportar Dados'),
                const SizedBox(height: 8),
                Text(
                  'Exporte os dados em diferentes formatos.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),

                // JSON
                ElevatedButton.icon(
                  onPressed:
                      isLoading || exportService == null ? null : _exportJSON,
                  icon: const Icon(Icons.data_object),
                  label: const Text('Exportar como JSON'),
                ),
                const SizedBox(height: 12),

                // CSV Completo
                ElevatedButton.icon(
                  onPressed:
                      isLoading || exportService == null ? null : _exportAllCSV,
                  icon: const Icon(Icons.table_chart),
                  label: const Text('Exportar como CSV (Completo)'),
                ),
                const SizedBox(height: 24),

                _buildSectionTitle('📥 Restaurar Backup'),
                const SizedBox(height: 8),
                Text(
                  'Restaure um backup anterior. Isso substitui os dados atuais do aplicativo.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                _buildImportButton(),
                const SizedBox(height: 16),
                _buildBackupsList(),
                const SizedBox(height: 24),

                // ========================
                // TABELAS INDIVIDUAIS
                // ========================
                _buildSectionTitle('📋 Exportar Tabelas Individuais'),
                const SizedBox(height: 8),
                Text(
                  'Exporte tabelas específicas em CSV.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),

                _buildTableButton('Regiões', 'regioes'),
                const SizedBox(height: 8),
                _buildTableButton('Famílias', 'familias'),
                const SizedBox(height: 8),
                _buildTableButton('Categorias', 'categorias'),
                const SizedBox(height: 8),
                _buildTableButton('Indicadores', 'indicadores'),
                const SizedBox(height: 8),
                _buildTableButton('Avaliações', 'avaliacoes'),
                const SizedBox(height: 24),

                // ========================
                // HISTÓRICO
                // ========================
                _buildSectionTitle('📁 Histórico de Exportações'),
                const SizedBox(height: 16),
                _buildExportsList(),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  Widget _buildTableButton(String label, String tableName) {
    return OutlinedButton.icon(
      onPressed: isLoading || exportService == null
          ? null
          : () => _exportTableCSV(tableName),
      icon: const Icon(Icons.file_present),
      label: Text(label),
    );
  }

  Widget _buildExportsList() {
    if (exportService == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<List<FileSystemEntity>>(
      future: exportService!.listExports(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Nenhuma exportação realizada ainda.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        final files = snapshot.data!;
        return Column(
          children: files.map((file) {
            final fileName = p.basename(file.path);
            final stat = File(file.path).statSync();
            final size = _formatBytes(stat.size);
            final modified =
                DateFormat('dd/MM/yyyy HH:mm').format(stat.modified);

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.description),
                title: Text(fileName),
                subtitle: Text('$size • $modified'),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Compartilhar'),
                      onTap: () {
                        Share.shareXFiles(
                          [XFile(file.path)],
                          text: fileName,
                        );
                      },
                    ),
                    PopupMenuItem(
                      child: const Text('Deletar'),
                      onTap: () {
                        _deleteFile(file.path);
                      },
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _deleteFile(String path) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente deletar este arquivo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              File(path).deleteSync();
              Navigator.pop(context);
              setState(() {});
              _showMessage('Arquivo deletado com sucesso!');
            },
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
