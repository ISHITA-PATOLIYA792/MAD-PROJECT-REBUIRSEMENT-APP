import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final supabase = Supabase.instance.client;
  
  /// Initializes the notification service and sets up event listeners
  void initialize() {
    // Subscribe to realtime changes for the current user's expenses
    _subscribeToExpenseUpdates();
  }
  
  /// Subscribe to expense updates for the current user
  void _subscribeToExpenseUpdates() {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;
      
      // Subscribe to expense status changes
      supabase
          .channel('public:expenses')
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'expenses',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'employee_id',
              value: userId,
            ),
            callback: (payload) {
              _handleExpenseStatusChange(payload);
            },
          )
          .subscribe();
    } catch (e) {
      if (kDebugMode) {
        print('Error subscribing to expense updates: $e');
      }
    }
  }
  
  /// Handle expense status change events
  void _handleExpenseStatusChange(PostgresChangePayload payload) {
    try {
      final newData = payload.newRecord;
      final oldData = payload.oldRecord;
      
      // Check if status has changed
      if (newData['status'] != oldData['status']) {
        final status = newData['status'];
        final title = newData['title'];
        
        String message;
        if (status == 'approved') {
          message = 'Your expense "$title" has been approved';
        } else if (status == 'rejected') {
          final reason = newData['rejection_reason'] ?? 'No reason provided';
          message = 'Your expense "$title" has been rejected. Reason: $reason';
        } else {
          message = 'Your expense "$title" status has changed to $status';
        }
        
        // Send push notification (in a real app, this would use Firebase Messaging or similar)
        _sendPushNotification(
          title: 'Expense Status Update',
          body: message,
          data: {
            'expense_id': newData['id'].toString(),
            'tracking_id': newData['tracking_id'],
            'status': status,
          },
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling expense status change: $e');
      }
    }
  }
  
  /// Send a push notification to the user
  /// 
  /// In a real app, this would use Firebase Cloud Messaging or a similar service
  void _sendPushNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    // In a real implementation, this would call Firebase Cloud Messaging
    // or another push notification service
    
    // For now, just log the notification
    if (kDebugMode) {
      print('PUSH NOTIFICATION:');
      print('Title: $title');
      print('Body: $body');
      print('Data: $data');
    }
    
    // In a real app, would store notification in database for history
    _storeNotification(title: title, body: body, data: data);
  }
  
  /// Store notification in the database for history
  Future<void> _storeNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;
      
      await supabase.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'body': body,
        'data': data,
        'read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error storing notification: $e');
      }
    }
  }
  
  /// Get unread notification count for the current user
  Future<int> getUnreadNotificationCount() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return 0;
      
      final response = await supabase
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('read', false);
      
      final List<dynamic> data = response;
      return data.length;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting unread notification count: $e');
      }
      return 0;
    }
  }
} 