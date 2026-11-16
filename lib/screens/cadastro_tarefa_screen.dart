import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../services/firebase_service.dart';

class CadastroTarefaScreen extends StatefulWidget {
  const CadastroTarefaScreen({
    super.key,
    required this.userId,
    required this.firebaseService,
    this.tarefa,
  });

  final String userId;
  final FirebaseService firebaseService;
  final Tarefa? tarefa;

  @override
  State<CadastroTarefaScreen> createState() => _CadastroTarefaScreenState();
}

class _CadastroTarefaScreenState extends State<CadastroTarefaScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _dueDate;
  late Prioridade _priority;
  late bool _completed;
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEditing => widget.tarefa != null;

  @override
  void initState() {
    super.initState();
    final task = widget.tarefa;
    _titleController = TextEditingController(text: task?.titulo ?? '');
    _descriptionController = TextEditingController(text: task?.descricao ?? '');
    _dueDate = task?.dataVencimento ?? DateTime.now();
    _priority = task?.prioridade ?? Prioridade.media;
    _completed = task?.concluida ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 10),
      helpText: 'Selecione a data de vencimento',
    );
    if (selected != null) {
      setState(() {
        _dueDate = DateTime(selected.year, selected.month, selected.day);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final previous = widget.tarefa;
    final task = Tarefa(
      id: previous?.id ?? '',
      titulo: _titleController.text.trim(),
      descricao: _descriptionController.text.trim(),
      dataVencimento: _dueDate,
      prioridade: _priority,
      concluida: _completed,
    );

    try {
      await widget.firebaseService.saveTask(widget.userId, task);
      if (mounted) Navigator.of(context).pop();
    } on FirebaseException catch (error) {
      setState(
        () => _errorMessage =
            'Não foi possível salvar a tarefa: ${error.message ?? error.code}',
      );
    } catch (error) {
      setState(
        () => _errorMessage = 'Não foi possível salvar a tarefa: $error',
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = MaterialLocalizations.of(context).formatMediumDate(_dueDate);
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar tarefa' : 'Nova tarefa')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Título',
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Informe o título.'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _descriptionController,
                        textCapitalization: TextCapitalization.sentences,
                        minLines: 3,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Descrição',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(Icons.notes),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Informe a descrição.'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        onPressed: _selectDate,
                        icon: const Icon(Icons.calendar_month),
                        label: Text('Vencimento: $date'),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<Prioridade>(
                        initialValue: _priority,
                        decoration: const InputDecoration(
                          labelText: 'Prioridade',
                          prefixIcon: Icon(Icons.flag_outlined),
                        ),
                        items: Prioridade.values
                            .map(
                              (priority) => DropdownMenuItem(
                                value: priority,
                                child: Text(priority.label),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => _priority = value);
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Tarefa concluída'),
                        value: _completed,
                        onChanged: (value) =>
                            setState(() => _completed = value),
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _isSaving ? null : _save,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isEditing
                                    ? 'Salvar alterações'
                                    : 'Criar tarefa',
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
