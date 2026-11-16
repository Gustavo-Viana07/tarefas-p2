import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../services/firebase_service.dart';
import 'cadastro_tarefa_screen.dart';

class TarefasScreen extends StatelessWidget {
  const TarefasScreen({
    super.key,
    required this.userId,
    required this.firebaseService,
  });

  final String userId;
  final FirebaseService firebaseService;

  Future<void> _openTask(BuildContext context, Tarefa task) async {
    final action = await showModalBottomSheet<_TaskAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => _TaskDetailsSheet(task: task),
    );
    if (!context.mounted || action == null) return;

    try {
      switch (action) {
        case _TaskAction.edit:
          await Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => CadastroTarefaScreen(
                userId: userId,
                firebaseService: firebaseService,
                tarefa: task,
              ),
            ),
          );
        case _TaskAction.toggle:
          await firebaseService.setCompleted(userId, task.id, !task.concluida);
        case _TaskAction.delete:
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Excluir tarefa?'),
              content: Text('A tarefa "${task.titulo}" será removida.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Excluir'),
                ),
              ],
            ),
          );
          if (confirmed == true) {
            await firebaseService.deleteTask(userId, task.id);
          }
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível atualizar a tarefa: $error'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<Tarefa>>(
        stream: firebaseService.watchTasks(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Erro ao carregar tarefas: ${snapshot.error}'),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data ?? const <Tarefa>[];
          if (tasks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_available_outlined,
                      size: 60,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Nenhuma tarefa por aqui',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Toque em + para adicionar sua primeira tarefa.',
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _TaskCard(
                task: task,
                onTap: () => _openTask(context, task),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => CadastroTarefaScreen(
              userId: userId,
              firebaseService: firebaseService,
            ),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nova tarefa'),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, required this.onTap});

  final Tarefa task;
  final VoidCallback onTap;

  Color _priorityColor(BuildContext context) {
    return switch (task.prioridade) {
      Prioridade.baixa => Colors.green,
      Prioridade.media => Colors.orange,
      Prioridade.alta => Theme.of(context).colorScheme.error,
    };
  }

  @override
  Widget build(BuildContext context) {
    final date = MaterialLocalizations.of(context)
        .formatMediumDate(task.dataVencimento);
    final color = _priorityColor(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.14),
          child: Icon(
            task.concluida ? Icons.check : Icons.flag_outlined,
            color: color,
          ),
        ),
        title: Text(
          task.titulo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            decoration: task.concluida ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Wrap(
            spacing: 10,
            runSpacing: 4,
            children: [
              Text('Vence: $date'),
              Text(
                'Prioridade ${task.prioridade.label}',
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
              Text(task.concluida ? 'Concluída' : 'Pendente'),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

enum _TaskAction { edit, toggle, delete }

class _TaskDetailsSheet extends StatelessWidget {
  const _TaskDetailsSheet({required this.task});

  final Tarefa task;

  @override
  Widget build(BuildContext context) {
    final date = MaterialLocalizations.of(context)
        .formatMediumDate(task.dataVencimento);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(task.titulo, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(task.descricao),
            const SizedBox(height: 16),
            Text('Vencimento: $date'),
            Text('Prioridade: ${task.prioridade.label}'),
            Text('Situação: ${task.concluida ? 'Concluída' : 'Pendente'}'),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context, _TaskAction.toggle),
              icon: Icon(task.concluida ? Icons.undo : Icons.done),
              label: Text(
                task.concluida ? 'Marcar como pendente' : 'Concluir tarefa',
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context, _TaskAction.edit),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Editar'),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pop(context, _TaskAction.delete),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Excluir'),
            ),
          ],
        ),
      ),
    );
  }
}
