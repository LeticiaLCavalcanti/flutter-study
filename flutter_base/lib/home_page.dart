import 'package:flutter/material.dart';
import 'notification_detail.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = true;
  List<dynamic> _pushes = [];
  String? _error;
  Map<String, dynamic>? _me;
  bool _markingAll = false;

  Future<void> _markAllAsRead() async {
    if (_pushes.isEmpty) return;
    setState(() => _markingAll = true);

    final List<int> ids = [];
    for (final item in _pushes) {
      final pushList = (item['push_to_send'] as List<dynamic>?) ?? [];
      for (final p in pushList) {
        if (p is Map<String, dynamic>) {
          // collect id if available
          final id = p['idPushToSend'] ?? p['id'];
          if (id is int) ids.add(id);
          // mark locally
          p['enviado'] = true;
        }
      }
    }

    setState(() {});

    for (final id in ids) {
      try {
        await ApiService.markPushAsRead(id);
      } catch (_) {}
    }

    setState(() => _markingAll = false);
  }

  @override
  void initState() {
    super.initState();
    _loadMeAndPushes();
  }

  Future<void> _loadMeAndPushes() async {
    final me = await ApiService.getMe();
    setState(() => _me = me);
    await _loadPushes();
  }

  Future<void> _loadPushes() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await ApiService.getPushList();
    if (res.containsKey('data')) {
      setState(() {
        _pushes = res['data'] as List<dynamic>;
      });
    } else {
      setState(() {
        _error = res['error']?.toString() ?? 'Erro desconhecido';
      });
    }
    setState(() => _loading = false);
  }

  Widget _notificationTile(BuildContext context, Map<String, dynamic> item) {
    final titulo = item['titulo']?.toString() ?? 'Sem título';
    final mensagem = item['mensagem']?.toString() ?? '';
    final createdRaw = item['created_at']?.toString() ?? '';
    String created;
    try {
      created = DateFormat.jm().format(DateTime.parse(createdRaw).toLocal());
    } catch (_) {
      created = createdRaw;
    }
    final pushToSend = (item['push_to_send'] as List<dynamic>?) ?? [];
    final unread = pushToSend.any((e) => e['enviado'] == false);

    return Column(
      children: [
        InkWell(
          onTap: () async {
            setState(() {
              final pushList = (item['push_to_send'] as List<dynamic>?) ?? [];
              for (final p in pushList) {
                if (p is Map<String, dynamic>) p['enviado'] = true;
              }
            });

            await Navigator.of(context).push(MaterialPageRoute(builder: (_) => NotificationDetail(item: item)));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(radius: 22, backgroundColor: Colors.grey.shade300),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(mensagem, style: const TextStyle(color: Color(0xFF6B7280))),
                      const SizedBox(height: 6),
                      Text(created, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                    ],
                  ),
                ),
                if (unread) ...[
                  const SizedBox(width: 8),
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.red.shade700, shape: BoxShape.circle)),
                ],
              ],
            ),
          ),
        ),
        Divider(
          height: 1,
          indent: 72,
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).dividerColor.withAlpha(31)
              : Colors.grey.shade200,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header
          Container(
            color: const Color(0xFF8C0000),
            padding: const EdgeInsets.only(top: 28, left: 16, right: 16, bottom: 20),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed('/settings'),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Theme.of(context).cardColor,
                      backgroundImage: _me != null && _me!['avatar'] != null
                          ? NetworkImage(_me!['avatar'].toString())
                          : const NetworkImage('https://avatars.githubusercontent.com/u/9919?s=200&v=4'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Olá bem-vindo, 👋', style: TextStyle(color: Colors.white, fontSize: 13)),
                        const SizedBox(height: 8),

                        // Student name (prefer 'nomeAluno' from API, fallback to 'nome', otherwise 'Aluno')
                        Text(
                          _me != null
                              ? (_me!['nomeAluno']?.toString() ?? _me!['nome']?.toString() ?? 'Aluno')
                              : 'Aluno',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22, height: 1.02),
                        ),
                        const SizedBox(height: 6),

                        // Hardcoded course title for now
                        const Text(
                          'Técnico em Informática',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  IconButton(onPressed: _loadPushes, icon: Icon(Icons.notifications_none, color: Theme.of(context).colorScheme.onPrimary)),
                ],
              ),
            ),
          ),

          // Notifications list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadPushes,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? ListView(padding: const EdgeInsets.symmetric(vertical: 16), children: [Center(child: Padding(padding: EdgeInsets.all(20), child: Text(_error!)))])
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          itemCount: _pushes.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Hoje', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                                   
                                    InkWell(
                                      onTap: _markingAll ? null : _markAllAsRead,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                        child: _markingAll
                                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                            : Text('Marcar todas como lida', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700)),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            final item = _pushes[index - 1] as Map<String, dynamic>;
                            return _notificationTile(context, item);
                          },
                        ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(top: BorderSide(color: Theme.of(context).dividerColor, width: 1)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Home (selected)
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.home, color: Color(0xFF2563EB)),
                    ],
                  ),
                ),
              ),

              // Espaço central (para futuro FAB/ícone)
              const SizedBox(width: 8),

              // Menu (não selecionado)
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.menu, color: Theme.of(context).iconTheme.color?.withAlpha(204)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
