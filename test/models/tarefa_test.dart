import 'package:flutter_test/flutter_test.dart';
import 'package:tarefas_p2/models/tarefa.dart';

void main() {
  group('Tarefa', () {
    final task = Tarefa(
      id: 'task-1',
      titulo: 'Estudar Flutter',
      descricao: 'Revisar widgets e navegação',
      dataVencimento: DateTime(2026, 11, 12),
      prioridade: Prioridade.alta,
      concluida: true,
    );

    test('converte para mapa e restaura os campos', () {
      final restored = Tarefa.fromMap(task.id, task.toMap());

      expect(restored.id, task.id);
      expect(restored.titulo, task.titulo);
      expect(restored.descricao, task.descricao);
      expect(restored.dataVencimento, task.dataVencimento);
      expect(restored.prioridade, task.prioridade);
      expect(restored.concluida, task.concluida);
    });

    test('rejeita data inválida recebida do banco', () {
      expect(
        () => Tarefa.fromMap('task-1', {
          ...task.toMap(),
          'dataVencimento': 'data-invalida',
        }),
        throwsFormatException,
      );
    });

    test('rejeita prioridade desconhecida recebida do banco', () {
      expect(
        () => Tarefa.fromMap('task-1', {
          ...task.toMap(),
          'prioridade': 'urgente',
        }),
        throwsFormatException,
      );
    });
  });
}
