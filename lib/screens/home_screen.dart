import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../widgets/drawer_menu.dart';
import 'configuracoes_screen.dart';
import 'sobre_screen.dart';
import 'tarefas_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.user,
    required this.authService,
    required this.firebaseService,
    required this.onThemeChanged,
  });

  final User user;
  final AuthService authService;
  final FirebaseService firebaseService;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedPage = 0;
  late final Usuario _usuario = Usuario(
    uid: widget.user.uid,
    nome: widget.user.displayName?.trim().isNotEmpty == true
        ? widget.user.displayName!
        : widget.user.email ?? 'Usuário',
    email: widget.user.email ?? '',
  );

  String get _title => switch (_selectedPage) {
    0 => 'Início',
    1 => 'Minhas tarefas',
    2 => 'Configurações',
    _ => 'Sobre o aplicativo',
  };

  Widget _page() {
    return switch (_selectedPage) {
      0 => _HomeDashboard(
        user: _usuario,
        firebaseService: widget.firebaseService,
        onOpenTasks: () => setState(() => _selectedPage = 1),
      ),
      1 => TarefasScreen(
        userId: _usuario.uid,
        firebaseService: widget.firebaseService,
      ),
      2 => ConfiguracoesScreen(onThemeChanged: widget.onThemeChanged),
      _ => const SobreScreen(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      drawer: DrawerMenu(
        usuario: _usuario,
        selectedIndex: _selectedPage,
        onSelect: (index) => setState(() => _selectedPage = index),
        onSignOut: () async {
          try {
            await widget.authService.signOut();
          } catch (error) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Não foi possível sair: $error')),
              );
            }
          }
        },
      ),
      body: _page(),
    );
  }
}

class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard({
    required this.user,
    required this.firebaseService,
    required this.onOpenTasks,
  });

  final Usuario user;
  final FirebaseService firebaseService;
  final VoidCallback onOpenTasks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<List<Tarefa>>(
      stream: firebaseService.watchTasks(user.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Não foi possível carregar as tarefas: ${snapshot.error}',
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final tasks = snapshot.data!;
        final pending = tasks.where((task) => !task.concluida).length;
        final completed = tasks.length - pending;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Olá, ${user.nome.split(' ').first}!',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text('Aqui está um resumo das suas tarefas.'),
            const SizedBox(height: 22),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatCard(
                  label: 'Total',
                  value: tasks.length,
                  icon: Icons.checklist_rounded,
                  color: theme.colorScheme.primary,
                ),
                _StatCard(
                  label: 'Pendentes',
                  value: pending,
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                ),
                _StatCard(
                  label: 'Concluídas',
                  value: completed,
                  icon: Icons.task_alt,
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 22),
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(18),
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.event_note,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                title: const Text('Mantenha tudo em dia'),
                subtitle: const Text(
                  'Crie uma tarefa ou acompanhe o que ainda precisa fazer.',
                ),
                trailing: const Icon(Icons.arrow_forward),
                onTap: onOpenTasks,
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: onOpenTasks,
              icon: const Icon(Icons.add),
              label: const Text('Ver minhas tarefas'),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 145,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 12),
              Text(
                '$value',
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
