import 'package:firebase_database/firebase_database.dart';

import '../models/tarefa.dart';

class FirebaseService {
  FirebaseService({FirebaseDatabase? database})
    : _database = database ?? FirebaseDatabase.instance;

  final FirebaseDatabase _database;

  DatabaseReference _tasksRef(String uid) => _database.ref('users/$uid/tasks');

  Stream<List<Tarefa>> watchTasks(String uid) {
    return _tasksRef(uid).onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) return <Tarefa>[];
      if (value is! Map) {
        throw const FormatException(
          'Formato inválido para a lista de tarefas.',
        );
      }

      final tasks = <Tarefa>[];
      for (final entry in value.entries) {
        if (entry.value is! Map) {
          throw const FormatException('Registro de tarefa inválido.');
        }
        tasks.add(
          Tarefa.fromMap(
            entry.key.toString(),
            Map<Object?, Object?>.from(entry.value as Map),
          ),
        );
      }
      tasks.sort((a, b) => a.dataVencimento.compareTo(b.dataVencimento));
      return tasks;
    });
  }

  Future<void> saveTask(String uid, Tarefa task) async {
    final reference = task.id.isEmpty
        ? _tasksRef(uid).push()
        : _tasksRef(uid).child(task.id);
    if (reference.key == null) {
      throw StateError(
        'Não foi possível gerar um identificador para a tarefa.',
      );
    }
    await reference.set(task.toMap());
  }

  Future<void> deleteTask(String uid, String taskId) async {
    await _tasksRef(uid).child(taskId).remove();
  }

  Future<void> setCompleted(String uid, String taskId, bool completed) async {
    await _tasksRef(uid).child(taskId).child('concluida').set(completed);
  }
}
