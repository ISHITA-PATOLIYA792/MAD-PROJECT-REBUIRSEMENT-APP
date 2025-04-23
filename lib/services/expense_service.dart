import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:reimbursement_box/services/email_service.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:reimbursement_box/models/expense.dart';

class ExpenseService {
  final supabase = Supabase.instance.client;
  final EmailService _emailService = EmailService();
  final _uuid = const Uuid();
  
  // List to store web receipts (bytes) when on web platform
  final List<Map<String, dynamic>> _webReceipts = [];
  
  /// Adds a web receipt to the list (for web platform)
  void addWebReceipt(String filename, Uint8List bytes) {
    _webReceipts.add({
      'name': filename,
      'bytes': bytes,
    });
  }
  
  /// Get the list of web receipts
  List<Map<String, dynamic>> getWebReceipts() {
    return _webReceipts;
  }
  
  /// Clear web receipts after submission
  void clearWebReceipts() {
    _webReceipts.clear();
  }
  
  /// Check if the expenses table exists and has the required structure
  Future<bool> checkExpensesTable() async {
    try {
      // Try to query the expenses table
      await supabase.from('expenses').select('id').limit(1);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Expenses table check failed: $e');
      }
      return false;
    }
  }
  
  /// Submits a new expense
  /// 
  /// Returns the ID of the submitted expense if successful, null otherwise
  Future<String?> submitExpense({
    required String title,
    required double amount,
    required String currency,
    required DateTime date,
    required String category,
    required String project,
    String? description,
    required List<File> receipts,
  }) async {
    try {
      // Generate a unique tracking ID for the expense
      final trackingId = _generateTrackingId();
      final userId = supabase.auth.currentUser!.id;
      
      // Try to ensure user profile exists, but continue even if it fails
      try {
        await _ensureUserProfileExists(userId);
      } catch (e) {
        // Log the error but continue anyway
        if (kDebugMode) {
          print('Warning: Could not create user profile: $e');
          print('Continuing expense submission without profile');
        }
      }
      
      // Check if expenses table exists and has the necessary columns
      try {
        // Simplified minimal expense data for checking the table
        final expenseData = {
          'title': title.isEmpty ? 'Untitled Expense' : title, // Ensure title is never empty
          'amount': amount,
          'currency': currency,
          'date': date.toIso8601String(),
          'category': category,
          'project': project,
          'employee_id': userId,
          'status': 'pending',
          'tracking_id': trackingId, // Include tracking_id in initial creation
          'description': description,
          'created_at': DateTime.now().toIso8601String(),
        };
        
        // 2. Create expense record in database with all data in a single operation
        final response = await supabase
            .from('expenses')
            .insert(expenseData)
            .select()
            .single();
        
        final expenseId = response['id'] as int;
        
        if (kDebugMode) {
          print('Successfully created expense with ID: $expenseId');
        }
        
        // Only try to upload receipts if creation was successful
        final List<String> receiptUrls = [];
        
        // Handle mobile receipts
        if (!kIsWeb && receipts.isNotEmpty) {
          for (var receipt in receipts) {
            try {
              final fileName = '${trackingId}_${path.basename(receipt.path)}';
              final fileExt = path.extension(receipt.path).replaceAll('.', '');
              String mimeType;
              
              // Set correct mime type based on file extension
              switch (fileExt.toLowerCase()) {
                case 'jpg':
                case 'jpeg':
                  mimeType = 'image/jpeg';
                  break;
                case 'png':
                  mimeType = 'image/png';
                  break;
                case 'pdf':
                  mimeType = 'application/pdf';
                  break;
                default:
                  mimeType = 'application/octet-stream';
              }
              
              final storageResponse = await supabase.storage
                  .from('expense-receipts')
                  .upload(
                    'receipts/$userId/$trackingId/$fileName',
                    receipt,
                    fileOptions: FileOptions(contentType: mimeType),
                  );
              
              if (storageResponse.isNotEmpty) {
                final fileUrl = supabase.storage
                    .from('expense-receipts')
                    .getPublicUrl('receipts/$userId/$trackingId/$fileName');
                receiptUrls.add(fileUrl);
              }
            } catch (e) {
              if (kDebugMode) {
                print('Error uploading receipt: $e');
              }
              // Continue with other receipts if one fails
            }
          }
        }
        
        // Handle web platform receipts if any
        if (kIsWeb && _webReceipts.isNotEmpty) {
          for (var receipt in _webReceipts) {
            try {
              final fileName = '${trackingId}_${receipt['name']}';
              final bytes = receipt['bytes'] as Uint8List;
              final fileExt = path.extension(receipt['name']).replaceAll('.', '');
              
              String mimeType;
              switch (fileExt.toLowerCase()) {
                case 'jpg':
                case 'jpeg':
                  mimeType = 'image/jpeg';
                  break;
                case 'png':
                  mimeType = 'image/png';
                  break;
                case 'pdf':
                  mimeType = 'application/pdf';
                  break;
                default:
                  mimeType = 'application/octet-stream';
              }
              
              final storageResponse = await supabase.storage
                  .from('expense-receipts')
                  .uploadBinary(
                    'receipts/$userId/$trackingId/$fileName',
                    bytes,
                    fileOptions: FileOptions(contentType: mimeType),
                  );
              
              if (storageResponse.isNotEmpty) {
                final fileUrl = supabase.storage
                    .from('expense-receipts')
                    .getPublicUrl('receipts/$userId/$trackingId/$fileName');
                receiptUrls.add(fileUrl);
              }
            } catch (e) {
              if (kDebugMode) {
                print('Error uploading web receipt: $e');
              }
              // Continue with other receipts if one fails
            }
          }
          
          // Clear web receipts after uploading
          clearWebReceipts();
        }
        
        // Update expense with receipt URLs if any were uploaded
        if (receiptUrls.isNotEmpty) {
          await supabase
              .from('expenses')
              .update({'receipt_urls': receiptUrls})
              .eq('id', expenseId);
        }
        
        // Try to send email notification to manager
        try {
          final managerId = await _getProjectManagerId(project);
          
          await _emailService.sendExpenseSubmissionEmail(
            expenseId: expenseId.toString(),
            employeeId: userId,
            managerId: managerId,
            expenseDetails: {
              'title': title.isEmpty ? 'Untitled Expense' : title,
              'amount': amount,
              'currency': currency,
              'date': date.toIso8601String(),
              'category': category,
              'project': project,
              'description': description,
              'tracking_id': trackingId,
              'receipt_url': receiptUrls.isNotEmpty ? receiptUrls.first : null,
            },
          );
        } catch (e) {
          // Don't fail the entire process if just the email fails
          if (kDebugMode) {
            print('Email notification error (expense still saved): $e');
          }
        }
        
        return trackingId;
      } catch (e) {
        if (kDebugMode) {
          print('Error creating or updating expense: $e');
        }
        
        // If the error is related to missing tables, try to create them
        if (e.toString().contains('does not exist') || 
            e.toString().contains('relation') ||
            e.toString().contains('table')) {
          throw Exception('Database tables not properly set up. Please contact administrator.');
        }
        
        throw Exception('Failed to save expense data: ${e.toString()}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error submitting expense: $e');
      }
      return null;
    }
  }
  
  /// Processes an expense approval or rejection
  /// 
  /// [expenseId] - The ID of the expense to update
  /// [trackingId] - The tracking ID of the expense
  /// [approved] - Whether the expense is approved or rejected
  /// [reviewerId] - The ID of the reviewer (manager/HR)
  /// [rejectionReason] - The reason for rejection (if applicable)
  /// [secureToken] - A secure token to validate the action
  Future<bool> processExpenseReview({
    required String expenseId,
    required String trackingId,
    required bool approved,
    required String reviewerId,
    String? rejectionReason,
    required String secureToken,
  }) async {
    try {
      // Verify the secure token (in a real app this would validate against stored tokens)
      final isTokenValid = await _validateSecureToken(trackingId, secureToken, reviewerId);
      if (!isTokenValid) {
        if (kDebugMode) {
          print('Invalid secure token');
        }
        return false;
      }
      
      // Get expense information
      final response = await supabase
          .from('expenses')
          .select('*, employee:employee_id(*)')
          .eq('tracking_id', trackingId)
          .single();
      
      final expense = response as Map<String, dynamic>;
      final employeeId = expense['employee_id'] as String;
      final employeeName = expense['employee']['name'] ?? 'Employee';
      
      // Update expense status
      final status = approved ? 'approved' : 'rejected';
      
      await supabase
          .from('expenses')
          .update({
            'status': status,
            'reviewed_by': reviewerId,
            'reviewed_at': DateTime.now().toIso8601String(),
            'rejection_reason': approved ? null : rejectionReason,
          })
          .eq('tracking_id', trackingId);
      
      // Record the approval action in the activity log
      await supabase
          .from('expense_activities')
          .insert({
            'expense_id': expenseId,
            'tracking_id': trackingId,
            'user_id': reviewerId,
            'action': approved ? 'approved' : 'rejected',
            'comment': approved ? 'Expense approved' : rejectionReason,
            'created_at': DateTime.now().toIso8601String(),
          });
      
      // Get reviewer name
      final reviewerResponse = await supabase
          .from('profiles')
          .select('name')
          .eq('id', reviewerId)
          .single();
      
      final reviewerName = reviewerResponse['name'] ?? 'Reviewer';
      
      // Send email notification to employee
      await _emailService.sendExpenseStatusUpdateEmail(
        expenseId: expenseId,
        employeeId: employeeId,
        status: status,
        approverName: reviewerName,
        rejectionReason: rejectionReason,
      );
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error processing expense review: $e');
      }
      return false;
    }
  }
  
  /// Subscribes to expense status updates for real-time notifications
  /// 
  /// Returns a Stream of expense updates for the current user
  Stream<List<Map<String, dynamic>>> subscribeToExpenseUpdates() {
    final userId = supabase.auth.currentUser!.id;
    
    return supabase
        .from('expenses')
        .stream(primaryKey: ['id'])
        .eq('employee_id', userId)
        .order('created_at', ascending: false)
        .map((event) => event.map((e) => e as Map<String, dynamic>).toList());
  }
  
  // Helper methods
  
  /// Generates a unique tracking ID for an expense
  String _generateTrackingId() {
    final now = DateTime.now();
    final dateString = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final randomString = _uuid.v4().substring(0, 8).toUpperCase();
    return 'EXP-$dateString-$randomString';
  }
  
  /// Gets the project manager ID for a given project
  /// In a real app, this would query the projects table
  Future<String> _getProjectManagerId(String project) async {
    // Mock implementation - in a real app would fetch from database
    try {
      final response = await supabase
          .from('projects')
          .select('manager_id')
          .eq('name', project)
          .single();
      
      return response['manager_id'] as String;
    } catch (e) {
      // Fallback to default manager ID if project not found
      return 'default-manager-id';
    }
  }
  
  /// Validates a secure token for expense approval/rejection
  /// 
  /// In a real app, this would verify against stored tokens in the database
  Future<bool> _validateSecureToken(String trackingId, String token, String reviewerId) async {
    try {
      // In a real implementation, validate token against stored tokens in the database
      // For now, we'll simulate this by checking if the token exists in the tokens table
      
      final response = await supabase
          .from('approval_tokens')
          .select()
          .eq('token', token)
          .eq('tracking_id', trackingId)
          .eq('reviewer_id', reviewerId)
          .single();
      
      // Check if token is expired
      final expiresAt = DateTime.parse(response['expires_at'] as String);
      if (expiresAt.isBefore(DateTime.now())) {
        return false;
      }
      
      return true;
    } catch (e) {
      // For development purposes, return true to simulate valid token
      // In production, would return false if token validation fails
      if (kDebugMode) {
        print('Token validation failed, but returning true for development: $e');
        return true;
      }
      return false;
    }
  }
  
  /// Ensures a user profile exists for a given user
  Future<void> _ensureUserProfileExists(String userId) async {
    try {
      // Check if a profile exists for this user
      try {
        final response = await supabase
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();
        
        // If profile exists, we're good
        if (response != null) {
          if (kDebugMode) {
            print('User profile already exists');
          }
          return;
        }
      } catch (e) {
        // Handle the case where the query fails or returns nothing
        if (kDebugMode) {
          print('Profile check failed: $e');
        }
      }
      
      // Get user email from auth
      final userEmail = supabase.auth.currentUser?.email;
      
      if (kDebugMode) {
        print('Creating profile for user ID: $userId, Email: $userEmail');
      }
      
      // Create a profile for this user if it doesn't exist
      try {
        await supabase
            .from('profiles')
            .insert({
              'id': userId, // Must match auth.uid() for RLS policy
              'name': userEmail?.split('@')[0] ?? 'User',
              'email': userEmail ?? 'unknown@example.com',
              'created_at': DateTime.now().toIso8601String(),
            });
        
        if (kDebugMode) {
          print('Created profile for user $userId');
        }
      } catch (e) {
        if (e.toString().contains('violates row-level security policy')) {
          // RLS policy error - this means we need to configure the RLS policies
          if (kDebugMode) {
            print('RLS policy error. Make sure profiles table has proper RLS policies.');
            print('Continuing with expense submission anyway...');
          }
          // We'll continue submitting the expense, just without profile
          return;
        } else {
          // Re-throw other errors
          rethrow;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error ensuring user profile exists: $e');
      }
      throw Exception('Failed to ensure user profile exists: $e');
    }
  }

  // Get public URL for a receipt by path
  String getReceiptPublicUrl(String path) {
    return supabase.storage.from('expense-receipts').getPublicUrl(path);
  }

  // Delete receipt from storage
  Future<void> deleteReceipt(String path) async {
    try {
      await supabase.storage.from('expense-receipts').remove([path]);
      if (kDebugMode) {
        print('Successfully deleted receipt: $path');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting receipt: $e');
      }
      throw Exception('Failed to delete receipt: $e');
    }
  }

  // Upload receipt to Supabase Storage
  Future<String> uploadReceipt({
    required String expenseId,
    XFile? photo,
    String? filePath,
    Uint8List? bytes,
    String? filename,
  }) async {
    if ((photo == null && filePath == null && bytes == null) || 
        (bytes != null && filename == null) ||
        (filePath != null && filename == null)) {
      throw Exception('Invalid receipt data provided');
    }

    // Prepare file data
    String actualFilename;
    Uint8List? fileBytes;
    File? fileObject;

    if (photo != null) {
      actualFilename = path.basename(photo.path);
      if (kIsWeb) {
        fileBytes = await photo.readAsBytes();
      } else {
        fileObject = File(photo.path);
      }
    } else if (filePath != null && filename != null) {
      actualFilename = filename;
      fileObject = File(filePath);
    } else if (bytes != null && filename != null) {
      actualFilename = filename;
      fileBytes = bytes;
    } else {
      throw Exception('Invalid file data provided');
    }
    
    // Generate a unique filename to avoid collisions
    final String uniqueFilename = '${DateTime.now().millisecondsSinceEpoch}_$actualFilename';
    
    // Upload to Supabase Storage in a folder structure of "receipts/{expenseId}/"
    final String storageFilePath = 'receipts/$expenseId/$uniqueFilename';
    
    try {
      if (fileBytes != null) {
        // Upload bytes (web or prepared bytes)
        await supabase.storage
            .from('expense-receipts')
            .uploadBinary(storageFilePath, fileBytes, fileOptions: FileOptions(contentType: _getContentType(actualFilename)));
      } else if (fileObject != null) {
        // Upload file (mobile)
        await supabase.storage
            .from('expense-receipts')
            .upload(storageFilePath, fileObject, fileOptions: FileOptions(contentType: _getContentType(actualFilename)));
      } else {
        throw Exception('No valid file data available for upload');
      }
      
      // Get public URL
      final String publicUrl = supabase.storage
          .from('expense-receipts')
          .getPublicUrl(storageFilePath);
      
      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload receipt: $e');
    }
  }
  
  // Helper method to determine content type
  String _getContentType(String filename) {
    final ext = path.extension(filename).toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.pdf':
        return 'application/pdf';
      case '.heic':
        return 'image/heic';
      default:
        return 'application/octet-stream';
    }
  }

  // Update an expense's receipt URLs
  Future<void> updateExpenseReceiptUrls({
    required String expenseId,
    required List<String> receiptUrls,
  }) async {
    try {
      await supabase
          .from('expenses')
          .update({'receipt_urls': receiptUrls})
          .eq('id', int.parse(expenseId));
    } catch (e) {
      if (kDebugMode) {
        print('Error updating receipt URLs: $e');
      }
      throw Exception('Failed to update receipt URLs: $e');
    }
  }

  // Update any expense fields
  Future<void> updateExpense(
    String expenseId,
    Map<String, dynamic> data,
  ) async {
    try {
      await supabase
          .from('expenses')
          .update(data)
          .eq('id', int.parse(expenseId));
          
      if (kDebugMode) {
        print('Successfully updated expense $expenseId with data: $data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating expense: $e');
      }
      throw Exception('Failed to update expense: $e');
    }
  }

  // Create expense directly in the database (for sample data)
  Future<bool> createExpenseDirectly({
    required String title,
    required double amount,
    required String currency,
    required DateTime date,
    required String category,
    required String project,
    String? description,
    required String status,
  }) async {
    try {
      final trackingId = _generateTrackingId();
      final userId = supabase.auth.currentUser!.id;
      
      final expenseData = {
        'title': title.isEmpty ? 'Untitled Expense' : title,
        'amount': amount,
        'currency': currency,
        'date': date.toIso8601String(),
        'category': category,
        'project': project,
        'employee_id': userId,
        'status': status,
        'tracking_id': trackingId,
        'description': description,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final response = await supabase
          .from('expenses')
          .insert(expenseData)
          .select();
      
      if (kDebugMode) {
        print('Successfully created sample expense: $title with status: $status');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating sample expense: $e');
      }
      return false;
    }
  }
}