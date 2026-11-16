class Usuario {
  const Usuario({required this.uid, required this.nome, required this.email});

  final String uid;
  final String nome;
  final String email;

  factory Usuario.fromMap(String uid, Map<Object?, Object?> data) {
    return Usuario(
      uid: uid,
      nome: data['nome'] as String? ?? '',
      email: data['email'] as String? ?? '',
    );
  }

  Map<String, Object?> toMap() => {'nome': nome, 'email': email};
}
