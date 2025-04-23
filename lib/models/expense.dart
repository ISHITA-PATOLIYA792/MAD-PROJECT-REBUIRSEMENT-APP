import 'package:flutter/foundation.dart';

class Expense {
  final int id;
  final String? title;
  final double? amount;
  final String? currency;
  final DateTime? date;
  final String? category;
  final String? project;
  final String? description;
  final String? status;
  final String trackingId;
  final String? rejectionReason;
  final List<String>? receiptUrls;
  final String employeeId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  Expense({
    required this.id,
    this.title,
    this.amount,
    this.currency,
    this.date,
    this.category,
    this.project,
    this.description,
    this.status,
    required this.trackingId,
    this.rejectionReason,
    this.receiptUrls,
    required this.employeeId,
    this.createdAt,
    this.updatedAt,
  });
  
  // create a copy with updated values
  Expense copyWith({
    int? id,
    String? title,
    double? amount,
    String? currency,
    DateTime? date,
    String? category,
    String? project,
    String? description,
    String? status,
    String? trackingId,
    String? rejectionReason,
    List<String>? receiptUrls,
    String? employeeId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      date: date ?? this.date,
      category: category ?? this.category,
      project: project ?? this.project,
      description: description ?? this.description,
      status: status ?? this.status,
      trackingId: trackingId ?? this.trackingId,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      receiptUrls: receiptUrls ?? this.receiptUrls,
      employeeId: employeeId ?? this.employeeId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  // create from map (database)
  factory Expense.fromMap(Map<String, dynamic> map) {
    try {
      // handle the receipt_urls field which might be a JSON string or a list
      List<String> processReceiptUrls(dynamic receiptUrlsData) {
        if (receiptUrlsData == null) return [];
        
        if (receiptUrlsData is List) {
          return List<String>.from(receiptUrlsData);
        }
        
        if (receiptUrlsData is String) {
          try {
            // if it's a JSON string (but this should be handled by Supabase)
            return [];
          } catch (e) {
            if (kDebugMode) {
              print('Error parsing receipt_urls: $e');
            }
            return [];
          }
        }
        
        return [];
      }
    
      return Expense(
        id: map['id'],
        title: map['title'],
        amount: map['amount'] is int 
            ? (map['amount'] as int).toDouble() 
            : map['amount'],
        currency: map['currency'],
        date: map['date'] != null 
            ? DateTime.parse(map['date']) 
            : null,
        category: map['category'],
        project: map['project'],
        description: map['description'],
        status: map['status'],
        trackingId: map['tracking_id'],
        rejectionReason: map['rejection_reason'],
        receiptUrls: processReceiptUrls(map['receipt_urls']),
        employeeId: map['employee_id'],
        createdAt: map['created_at'] != null 
            ? DateTime.parse(map['created_at']) 
            : null,
        updatedAt: map['updated_at'] != null 
            ? DateTime.parse(map['updated_at']) 
            : null,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error creating Expense from map: $e');
        print('Map data: $map');
      }
      // create a minimal expense object with required fields
      return Expense(
        id: map['id'] ?? 0,
        trackingId: map['tracking_id'] ?? 'unknown',
        employeeId: map['employee_id'] ?? 'unknown',
      );
    }
  }
  
  // convert to map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'currency': currency,
      'date': date?.toIso8601String(),
      'category': category,
      'project': project,
      'description': description,
      'status': status,
      'tracking_id': trackingId,
      'rejection_reason': rejectionReason,
      'receipt_urls': receiptUrls,
      'employee_id': employeeId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
} 