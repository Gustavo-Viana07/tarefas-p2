import 'package:flutter/material.dart';

class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text('Tarefas+', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text(
              'Um aplicativo para organizar tarefas pessoais, '
              'acompanhar prazos e manter seus dados sincronizados.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text('Desenvolvido com Flutter e Firebase.'),
          ],
        ),
      ),
    );
  }
}
