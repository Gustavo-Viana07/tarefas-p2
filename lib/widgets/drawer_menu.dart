import 'package:flutter/material.dart';

import '../models/usuario.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({
    super.key,
    required this.usuario,
    required this.selectedIndex,
    required this.onSelect,
    required this.onSignOut,
  });

  final Usuario usuario;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onSignOut;

  static const _items = [
    (label: 'Início', icon: Icons.home_outlined),
    (label: 'Minhas tarefas', icon: Icons.checklist_outlined),
    (label: 'Configurações', icon: Icons.settings_outlined),
    (label: 'Sobre o aplicativo', icon: Icons.info_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(usuario.nome),
              accountEmail: Text(usuario.email),
              currentAccountPicture: CircleAvatar(
                child: Text(
                  usuario.nome.isEmpty ? '?' : usuario.nome[0].toUpperCase(),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return ListTile(
                    leading: Icon(item.icon),
                    title: Text(item.label),
                    selected: selectedIndex == index,
                    onTap: () {
                      Navigator.of(context).pop();
                      onSelect(index);
                    },
                  );
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () {
                Navigator.of(context).pop();
                onSignOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
