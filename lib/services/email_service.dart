import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class EmailService {
  final supabase = Supabase.instance.client;
  
  /// Sends an email notification to the manager/HR when an expense is submitted
  /// 
  /// [expenseId] - The ID of the submitted expense
  /// [employeeId] - The ID of the employee who submitted the expense
  /// [managerId] - The ID of the manager who needs to approve the expense
  /// [expenseDetails] - Map containing expense details (amount, category, date, etc.)
  Future<bool> sendExpenseSubmissionEmail({
    required String expenseId,
    required String employeeId,
    required String managerId,
    required Map<String, dynamic> expenseDetails,
  }) async {
    try {
      // In a real implementation, this would use a server function to send an email
      // Here we'll simulate it with a Supabase Edge Function call
      
      final response = await supabase.functions.invoke(
        'send-expense-notification',
        body: {
          'type': 'submission',
          'expenseId': expenseId,
          'employeeId': employeeId,
          'managerId': managerId,
          'expenseDetails': expenseDetails,
        },
      );
      
      if (kDebugMode) {
        print('Email notification sent to manager: ${response.data}');
      }
      
      return response.status == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error sending expense submission email: $e');
      }
      return false;
    }
  }
  
  /// Sends an email notification to the employee when the expense status changes
  /// 
  /// [expenseId] - The ID of the expense
  /// [employeeId] - The ID of the employee who submitted the expense
  /// [status] - The new status of the expense (approved/rejected)
  /// [approverName] - The name of the person who approved/rejected the expense
  /// [rejectionReason] - The reason for rejection (if applicable)
  Future<bool> sendExpenseStatusUpdateEmail({
    required String expenseId,
    required String employeeId,
    required String status,
    required String approverName,
    String? rejectionReason,
  }) async {
    try {
      // In a real implementation, this would use a server function to send an email
      // Here we'll simulate it with a Supabase Edge Function call
      
      final response = await supabase.functions.invoke(
        'send-expense-notification',
        body: {
          'type': 'status_update',
          'expenseId': expenseId,
          'employeeId': employeeId,
          'status': status,
          'approverName': approverName,
          'rejectionReason': rejectionReason,
        },
      );
      
      if (kDebugMode) {
        print('Status update email sent to employee: ${response.data}');
      }
      
      return response.status == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error sending expense status update email: $e');
      }
      return false;
    }
  }
} 