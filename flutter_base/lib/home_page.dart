import 'package:flutter/material.dart';
import 'notification_detail.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _notificationTile(BuildContext context, {required String title, required String subtitle, required String time, bool unread = false}) {
  return Column(
      children: [
        InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => NotificationDetail(title: title, subtitle: subtitle, time: time))),
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
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(subtitle, style: const TextStyle(color: Color(0xFF6B7280))),
                      const SizedBox(height: 6),
                      Text(time, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
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
                    child: const CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://avatars.githubusercontent.com/u/9919?s=200&v=4')),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Olá bem-vindo, 👋', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('Aluno', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text('Técnico em Informática', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary.withAlpha(230), fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () {}, icon: Icon(Icons.notifications_none, color: Theme.of(context).colorScheme.onPrimary)),
                ],
              ),
            ),
          ),

          // Notifications list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Hoje', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      Text('Marcar todas como lida', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                _notificationTile(context, title: 'Lorem ipsum dolor sit amet,', subtitle: 'consectetur adipisicing', time: '10:24 AM', unread: true),
                _notificationTile(context, title: 'Lorem ipsum dolor sit amet,', subtitle: 'consectetur adipisicing....', time: '09:11 AM', unread: true),
                _notificationTile(context, title: 'Lorem ipsum dolor sit amet,', subtitle: 'consectetur adipisicing', time: '09:00 AM', unread: false),
                _notificationTile(context, title: 'Bessie Cooper and Kristin Watson', subtitle: 'updated class : Forex Trading ...', time: '08:32 AM', unread: false),

                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Antigas', style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color)),
                ),
                const SizedBox(height: 12),
                _notificationTile(context, title: 'Annette Black updated class', subtitle: 'Photography - Become Photogra ...', time: '11:24 AM', unread: false),
                _notificationTile(context, title: 'Devon Lane updated information', subtitle: 'Learn Basic Animation Using Afte ...', time: '09:15 AM', unread: false),
                const SizedBox(height: 80),
              ],
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
