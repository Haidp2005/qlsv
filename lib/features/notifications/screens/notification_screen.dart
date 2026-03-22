import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  final String role;

  const NotificationScreen({super.key, required this.role});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final data = await NotificationService.getNotifications(widget.role);
    setState(() {
      _notifications = data;
      _isLoading = false;
    });
  }

  void _markAsRead(int index) {
    if (!_notifications[index]['isRead']) {
      setState(() {
        _notifications[index]['isRead'] = true;
      });
      NotificationService.markAsRead(_notifications[index]['id']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(child: Text('Không có thông báo nào.'))
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notif = _notifications[index];
                    final isRead = notif['isRead'] as bool;

                    return ListTile(
                      leading: Icon(
                        Icons.notifications,
                        color: isRead ? Colors.grey : Colors.blue,
                      ),
                      title: Text(
                        notif['title'],
                        style: TextStyle(
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(notif['body']),
                          const SizedBox(height: 4),
                          Text(
                            notif['time'],
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      tileColor: isRead ? Colors.transparent : Colors.blue.withValues(alpha: 0.05),
                      onTap: () => _markAsRead(index),
                    );
                  },
                ),
    );
  }
}
