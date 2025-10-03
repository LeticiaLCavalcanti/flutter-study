import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';

class NotificationDetail extends StatefulWidget {
  final Map<String, dynamic> item;

  const NotificationDetail({super.key, required this.item});

  @override
  State<NotificationDetail> createState() => _NotificationDetailState();
}

class _NotificationDetailState extends State<NotificationDetail> {
  bool _marking = false;
  bool _marked = false;

  @override
  void initState() {
    super.initState();
    _tryMarkRead();
  }

  Future<void> _tryMarkRead() async {
    final pushToSend = (widget.item['push_to_send'] as List<dynamic>?) ?? [];
    if (pushToSend.isEmpty) return;
    setState(() => _marking = true);
    bool anySuccess = false;
    for (final p in pushToSend) {
      final id = p['idPushToSend'];
      if (id is int) {
        final ok = await ApiService.markPushAsRead(id);
        if (ok) anySuccess = true;
      }
    }
    setState(() {
      _marking = false;
      _marked = anySuccess;
    });
  }

  String _format(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat.yMMMd().add_jm().format(dt);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.item['titulo']?.toString() ?? 'Sem título';
    final subtitle = widget.item['mensagem']?.toString() ?? '';
    final timeRaw = widget.item['created_at']?.toString() ?? '';
    final curso = widget.item['curso'] as Map<String, dynamic>?;
    final cursoTitulo = curso?['tituloCurso']?.toString();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text('Notificação', style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_none, color: Theme.of(context).iconTheme.color),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 20, backgroundColor: Colors.grey.shade300, child: const Icon(Icons.campaign)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.titleLarge?.color))),
                  if (_marking) const Padding(padding: EdgeInsets.only(left: 8), child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
                  if (_marked) const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.check_circle, color: Colors.green, size: 18)),
                ],
              ),
              const SizedBox(height: 8),
              Text(_format(timeRaw), style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12)),
              const SizedBox(height: 16),
              if (cursoTitulo != null) Text(cursoTitulo, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(subtitle, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.6)),
                      const SizedBox(height: 12),
                      // Placeholder long content to simulate notification body
                      Text(
                        'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Eget ornare quam vel facilisis feugiat ante sagittis arcu, tortor. Sapien, consequat ultrices morbi orci semper sit nulla. Leo auctor ut etiam est, amet aliquet ut vivamus. Odio vulputate est id tincidunt fames.\n\n'
                        'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Eget ornare quam vel facilisis feugiat ante sagittis arcu, tortor. Sapien, consequat ultrices morbi orci semper sit nulla. Leo auctor ut etiam est, amet aliquet ut vivamus. Odio vulputate est id tincidunt fames.',
                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.6),
                      ),
                      const SizedBox(height: 18),
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
