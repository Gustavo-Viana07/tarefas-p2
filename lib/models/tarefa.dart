enum Prioridade { baixa, media, alta }

extension PrioridadeLabel on Prioridade {
  String get label => switch (this) {
    Prioridade.baixa => 'Baixa',
    Prioridade.media => 'Média',
    Prioridade.alta => 'Alta',
  };

  static Prioridade fromValue(Object? value) {
    for (final prioridade in Prioridade.values) {
      if (prioridade.name == value) return prioridade;
    }
    throw FormatException('Prioridade desconhecida: $value');
  }
}

class Tarefa {
  const Tarefa({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.dataVencimento,
    required this.prioridade,
    required this.concluida,
  });

  final String id;
  final String titulo;
  final String descricao;
  final DateTime dataVencimento;
  final Prioridade prioridade;
  final bool concluida;

  factory Tarefa.fromMap(String id, Map<Object?, Object?> data) {
    final title = data['titulo'];
    final description = data['descricao'];
    final completed = data['concluida'];
    final rawDate = data['dataVencimento'];
    final parsedDate = rawDate is String ? DateTime.tryParse(rawDate) : null;
    if (title is! String || title.trim().isEmpty) {
      throw const FormatException('Título de tarefa inválido.');
    }
    if (description is! String) {
      throw const FormatException('Descrição de tarefa inválida.');
    }
    if (parsedDate == null) {
      throw const FormatException('Data de vencimento inválida.');
    }
    if (completed is! bool) {
      throw const FormatException('Situação da tarefa inválida.');
    }

    return Tarefa(
      id: id,
      titulo: title,
      descricao: description,
      dataVencimento: parsedDate,
      prioridade: PrioridadeLabel.fromValue(data['prioridade']),
      concluida: completed,
    );
  }

  Map<String, Object?> toMap() => {
    'titulo': titulo,
    'descricao': descricao,
    'dataVencimento': dataVencimento.toIso8601String(),
    'prioridade': prioridade.name,
    'concluida': concluida,
  };

  Tarefa copyWith({
    String? titulo,
    String? descricao,
    DateTime? dataVencimento,
    Prioridade? prioridade,
    bool? concluida,
  }) {
    return Tarefa(
      id: id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      dataVencimento: dataVencimento ?? this.dataVencimento,
      prioridade: prioridade ?? this.prioridade,
      concluida: concluida ?? this.concluida,
    );
  }
}
