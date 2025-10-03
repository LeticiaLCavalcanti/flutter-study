import 'package:flutter/material.dart';
import 'theme_controller.dart';
import 'api_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, dynamic>? _me;

  @override
  void initState() {
    super.initState();
    _loadMe();
  }

  Future<void> _loadMe() async {
    final me = await ApiService.getMe();
    setState(() => _me = me);
  }
  @override
  Widget build(BuildContext context) {
    final actionBlue = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
                    ),
                  ),
                  const Spacer(),
                  const Text('Configurações', style: TextStyle(fontWeight: FontWeight.w700)),
                  const Spacer(flex: 2),
                ],
              ),

              const SizedBox(height: 22),
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Theme.of(context).cardColor,
                    child: ClipOval(
                      child: _me != null && _me!['avatar'] != null
                          ? Image.network(
                              _me!['avatar'].toString(),
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              'https://avatars.githubusercontent.com/u/9919?s=200&v=4',
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_me?['nome']?.toString() ?? 'Exemplo', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(_me?['email']?.toString() ?? 'exemplo@fiap.com.br', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                        const SizedBox(height: 2),
                        Text('Aluno', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              Text('Acesso', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyMedium?.color)),
              const SizedBox(height: 10),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notifications_none),
                title: const Text('Notificações', style: TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),

              const SizedBox(height: 10),
              Text('Segurança', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyMedium?.color)),
              const SizedBox(height: 10),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.lock_outline),
                title: const Text('Alterar Senha', style: TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),

              const SizedBox(height: 10),
              Text('Sobre', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyMedium?.color)),
              const SizedBox(height: 10),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.shield_outlined),
                title: const Text('Política de Privacidade', style: TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.dark_mode_outlined),
        title: const Text('Dark Modo', style: TextStyle(fontWeight: FontWeight.w600)),
        trailing: ValueListenableBuilder<ThemeMode>(
                  valueListenable: themeNotifier,
                    builder: (context, mode, _) {
                    return Switch(
                      value: mode == ThemeMode.dark,
                      onChanged: (v) {
                        final newMode = v ? ThemeMode.dark : ThemeMode.light;
                        themeNotifier.value = newMode;
                        saveTheme(newMode);
                      },
                    );
                  },
                ),
                onTap: null,
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    await ApiService.clearToken();
                    navigator.pushNamedAndRemoveUntil('/', (route) => false);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: actionBlue),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Sair', style: TextStyle(color: actionBlue)),
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}
