# Tarefas+

Aplicativo Flutter para gerenciamento de tarefas pessoais. O projeto usa
Firebase Authentication, Firebase Realtime Database e SharedPreferences.

## Requisitos

- Flutter estável e Dart compatível com o `pubspec.yaml`
- Um projeto no [Firebase Console](https://console.firebase.google.com/)
- Aplicativos Android e Web registrados no projeto Firebase

## Configuração do Firebase

1. No Firebase Console, habilite **Authentication > E-mail/senha**.
2. Crie um **Realtime Database** e copie a URL exibida na página do banco.
3. Registre os apps Android (`com.example.tarefas_p2`) e Web no projeto.
4. Copie `firebase.env.example.json` para `firebase.env.json` e preencha as
   credenciais do projeto. O arquivo real é ignorado pelo Git.
   - `FIREBASE_API_KEY`: `apiKey` da configuração do app Firebase.
   - `FIREBASE_PROJECT_ID`: ID do projeto.
   - `FIREBASE_DATABASE_URL`: URL completa do Realtime Database.
   - `FIREBASE_MESSAGING_SENDER_ID`: número do projeto Firebase.
   - `FIREBASE_AUTH_DOMAIN`: domínio de autenticação Web, normalmente
     `<project-id>.firebaseapp.com`.
   - `FIREBASE_ANDROID_APP_ID` e `FIREBASE_WEB_APP_ID`: `appId` de cada app
     cadastrado.
5. Publique regras que restrinjam a leitura e a gravação ao usuário autenticado:

```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "auth != null && auth.uid === $uid",
        ".write": "auth != null && auth.uid === $uid"
      }
    }
  }
}
```

As tarefas são armazenadas em `users/<uid>/tasks`; o perfil fica em
`users/<uid>/profile`. As regras são essenciais: a separação na interface não
substitui o controle de acesso do banco.

## Executar

Na raiz do projeto:

```powershell
flutter pub get
flutter run --dart-define-from-file=firebase.env.json
```

Para executar no navegador Edge:

```powershell
flutter run -d edge --dart-define-from-file=firebase.env.json
```

Sem as variáveis do Firebase, o app abre uma tela explicando a configuração
necessária, em vez de simular autenticação ou armazenamento.

## Funcionalidades

- Cadastro, login, sessão persistente e logout com Firebase Authentication.
- Drawer com início, tarefas, configurações, sobre e sair.
- Cadastro, listagem em `ListView`, detalhes, edição, conclusão e exclusão.
- Sincronização em tempo real no Realtime Database, por usuário autenticado.
- Tema claro/escuro persistido com SharedPreferences.

## Testes

```powershell
flutter analyze
flutter test
```

## Roteiro para a demonstração

1. Configure Firebase e crie uma conta.
2. Entre e cadastre pelo menos duas tarefas com prioridades diferentes.
3. Abra uma tarefa, edite-a, altere sua situação e exclua outra.
4. Confira a atualização da lista e dos contadores.
5. Saia e entre novamente para demonstrar a persistência da sessão e dos dados.
6. Selecione o tema escuro, feche e reabra o app para demonstrar a preferência.
