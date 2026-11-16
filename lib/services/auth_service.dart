import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/usuario.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseDatabase? database})
    : _auth = auth ?? FirebaseAuth.instance,
      _database = database ?? FirebaseDatabase.instance;

  final FirebaseAuth _auth;
  final FirebaseDatabase _database;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<Usuario> register({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
    final user = credential.user;
    if (user == null) {
      throw StateError('O Firebase não retornou o usuário criado.');
    }

    await user.updateDisplayName(nome.trim());
    await _database.ref('users/${user.uid}/profile').set({
      'nome': nome.trim(),
      'email': email.trim(),
    });

    return Usuario(uid: user.uid, nome: nome.trim(), email: email.trim());
  }

  Future<void> signIn({required String email, required String senha}) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
  }

  Future<void> signOut() => _auth.signOut();
}
