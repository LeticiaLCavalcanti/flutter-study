import 'package:flutter/material.dart';

class NotificationDetail extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;

  const NotificationDetail({super.key, required this.title, required this.subtitle, required this.time});

  @override
  Widget build(BuildContext context) {
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
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.titleLarge?.color)),
              const SizedBox(height: 8),
              Text(time, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12)),
              const SizedBox(height: 16),
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
                      Text('Changes to the Service:', style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.titleLarge?.color)),
                      const SizedBox(height: 8),
                      Text(
                        'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Eget ornare quam vel facilisis feugiat ante sagittis arcu, tortor. Sapien, consequat ultrices morbi orci semper sit nulla. Leo auctor ut etiam est, amet aliquet ut vivamus. Odio vulputate est id tincidunt fames.',
                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.6),
                      ),
                      const SizedBox(height: 28),
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
