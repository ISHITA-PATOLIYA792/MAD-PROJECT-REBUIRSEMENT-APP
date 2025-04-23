import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'dart:io';
import 'dart:async';
import 'package:reimbursement_box/services/expense_service.dart';
import 'package:reimbursement_box/services/notification_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'package:reimbursement_box/models/expense.dart';

class ExpenseDetailsScreen extends StatefulWidget {
  final Expense expense;

  const ExpenseDetailsScreen({Key? key, required this.expense}) : super(key: key);

  @override
  _ExpenseDetailsScreenState createState() => _ExpenseDetailsScreenState();
}

class _ExpenseDetailsScreenState extends State<ExpenseDetailsScreen> {
  final supabase = Supabase.instance.client;
  final _expenseService = ExpenseService();
  final _notificationService = NotificationService();
  bool _isLoading = false;
  late Expense _expense;
  StreamSubscription? _expenseSubscription;
  final _picker = ImagePicker();
  bool _isUploadingReceipt = false;

  // Mock approval chain data (replace with actual from Supabase later)
  final List<Map<String, dynamic>> _approvalChain = [
    {
      'name': 'John Smith',
      'role': 'Manager',
      'status': 'approved',
      'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      'comment': 'Approved as per company policy.',
      'avatar': 'https://randomuser.me/api/portraits/men/1.jpg',
    },
    {
      'name': 'Sarah Johnson',
      'role': 'Finance Director',
      'status': 'pending',
      'timestamp': null,
      'comment': null,
      'avatar': 'https://randomuser.me/api/portraits/women/2.jpg',
    },
    {
      'name': 'Robert Lee',
      'role': 'CFO',
      'status': 'pending',
      'timestamp': null,
      'comment': null,
      'avatar': 'https://randomuser.me/api/portraits/men/3.jpg',
    },
  ];

  // Mock timeline data (replace with actual from Supabase later)
  final List<Map<String, dynamic>> _timeline = [
    {
      'action': 'Expense Submitted',
      'timestamp': DateTime.now().subtract(const Duration(days: 2, hours: 5)),
      'user': 'You',
      'icon': Icons.receipt_long,
    },
    {
      'action': 'Received by Manager',
      'timestamp': DateTime.now().subtract(const Duration(days: 2, hours: 2)),
      'user': 'System',
      'icon': Icons.inbox,
    },
    {
      'action': 'Reviewed by Manager',
      'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      'user': 'John Smith',
      'icon': Icons.remove_red_eye,
    },
    {
      'action': 'Approved by Manager',
      'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      'user': 'John Smith',
      'icon': Icons.check_circle,
    },
    {
      'action': 'Pending Finance Approval',
      'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      'user': 'System',
      'icon': Icons.hourglass_empty,
    },
  ];

  // Mock receipt images (replace with actual from Supabase later)
  final List<String> _receiptImages = [
    'https://media.istockphoto.com/id/1072626580/photo/restaurant-bill-with-credit-card-on-table.jpg?s=612x612&w=0&k=20&c=RX3KStRsh-BtsnSMJ_PMkOldwJKQZGnQHYM_wXR-qgA=',
    'https://media.istockphoto.com/id/1127969551/photo/travel-trip-vacation-tourism-shopping-concept-close-up-of-blank-paper-bill-or-receipt-with.jpg?s=612x612&w=0&k=20&c=KmKs-TeZdOG1CXdq7yZLVnPNVmrZAXJ0UkEYgVgpKdY=',
  ];

  int _currentReceiptIndex = 0;

  @override
  void initState() {
    super.initState();
    _expense = widget.expense;
    _loadExpenseDetails();
    _subscribeToUpdates();
  }

  @override
  void dispose() {
    _expenseSubscription?.cancel();
    super.dispose();
  }

  // Load full expense details from the database
  Future<void> _loadExpenseDetails() async {
    // skip fetch for mock items (tracking IDs generated locally)
    if (_expense.trackingId.startsWith('MOCK-')) {
      setState(() { _isLoading = false; });
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final trackingId = _expense.trackingId;
      final response = await supabase
          .from('expenses')
          .select('*, employee:employee_id(*)')
          .eq('tracking_id', trackingId)
          .single();
      
      setState(() {
        _expense = Expense.fromMap(response);
        _isLoading = false;
      });
    } catch (e) {
      // If there's an error, keep using the data passed from the previous screen
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading expense details: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Subscribe to real-time updates for this expense
  void _subscribeToUpdates() {
    final trackingId = _expense.trackingId;
    
    _expenseSubscription = supabase
        .from('expenses')
        .stream(primaryKey: ['id'])
        .eq('tracking_id', trackingId)
        .listen((List<Map<String, dynamic>> data) {
          if (data.isNotEmpty && mounted) {
            setState(() {
              _expense = Expense.fromMap(data.first);
            });
            
            // Check for status change
            final oldStatus = widget.expense.status;
            final newStatus = data.first['status'];
            
            if (oldStatus != newStatus) {
              _showStatusChangeNotification(newStatus);
            }
          }
        });
  }

  // Show a notification when the status changes
  void _showStatusChangeNotification(String newStatus) {
    String message;
    Color backgroundColor;
    
    if (newStatus == 'approved') {
      message = 'This expense has been approved!';
      backgroundColor = Colors.green;
    } else if (newStatus == 'rejected') {
      final reason = _expense.rejectionReason ?? 'No reason provided';
      message = 'This expense has been rejected. Reason: $reason';
      backgroundColor = Colors.red;
    } else {
      message = 'Expense status updated to: $newStatus';
      backgroundColor = Colors.blue;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Format date
    final formattedDate = _expense.date != null
        ? "${_expense.date!.day}/${_expense.date!.month}/${_expense.date!.year}"
        : "N/A";

    // Format amount
    final formattedAmount = _expense.amount != null
        ? "\$${_expense.amount!.toStringAsFixed(2)}"
        : "N/A";

    // Extract receipt URLs
    final List<String> receiptUrls = _expense.receiptUrls ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        actions: [
          // Only show edit button if status is 'pending'
          if (_expense.status?.toLowerCase() == 'pending')
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Navigate to edit expense screen
                Navigator.pushNamed(
                  context,
                  '/edit_expense',
                  arguments: _expense,
                );
              },
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle menu item selection
              if (value == 'delete') {
                _showDeleteConfirmation();
              } else if (value == 'download') {
                _downloadReceipt();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'download',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Download Receipts'),
                ),
              ),
              if (_expense.status?.toLowerCase() == 'pending')
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Stack(
      children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  // Status card
                  Card(
                    elevation: 2,
                    color: _getStatusColor(_expense.status),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info_outline, color: Colors.white),
                          const SizedBox(width: 8),
              Text(
                            'Status: ${_expense.status ?? "Pending"}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                              color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        ),
                  const SizedBox(height: 16),

                  // Expense Details
                  const Text(
                    'Expense Details',
                style: TextStyle(
                      fontSize: 18,
                  fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
                          DetailItem(
                            label: 'Title',
                            value: _expense.title ?? 'N/A',
                          ),
                          const Divider(),
                          DetailItem(
                            label: 'Amount',
                            value: formattedAmount,
                            icon: Icons.attach_money,
                          ),
                          const Divider(),
                          DetailItem(
                            label: 'Category',
                            value: _expense.category ?? 'N/A',
                            icon: Icons.category,
                          ),
                          const Divider(),
                          DetailItem(
                            label: 'Date',
                            value: formattedDate,
                            icon: Icons.calendar_today,
                          ),
                          const Divider(),
                          DetailItem(
                            label: 'Project',
                            value: _expense.project ?? 'N/A',
                            icon: Icons.work,
                          ),
                          if (_expense.description != null &&
                              _expense.description!.isNotEmpty) ...[
                            const Divider(),
                            DetailItem(
                              label: 'Description',
                              value: _expense.description ?? 'N/A',
                              icon: Icons.description,
                              isMultiLine: true,
                            ),
                          ],
          ],
        ),
      ),
                  ),
                  const SizedBox(height: 24),

                  // Receipt Images Section
                  if (receiptUrls.isNotEmpty ||
                      _expense.status?.toLowerCase() == 'pending') ...[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
                          'Receipt Images',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
                        if (_expense.status?.toLowerCase() == 'pending')
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.camera_alt),
                                onPressed: _takePhoto,
                                tooltip: 'Take Photo',
                              ),
                              IconButton(
                                icon: const Icon(Icons.upload_file),
                                onPressed: _pickImages,
                                tooltip: 'Upload Images',
            ),
          ],
        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: receiptUrls.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'No receipts have been uploaded',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            )
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: receiptUrls.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () => _openReceiptGallery(index),
          child: Stack(
                                    fit: StackFit.expand,
            children: [
                                      // Add a card to show a loading indicator
                                      Card(
                                        elevation: 2,
                                        child: Center(
                                          child: Image.network(
                                            receiptUrls[index],
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Center(
                                                child: CircularProgressIndicator(
                                                  value: loadingProgress.expectedTotalBytes != null
                                                      ? loadingProgress.cumulativeBytesLoaded /
                                                          loadingProgress.expectedTotalBytes!
                                                      : null,
                                                ),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Center(
                                                child: Icon(Icons.error, color: Colors.red),
                                              );
                                            },
                      ),
                    ),
                  ),
                                      // Show delete button if expense is pending
                                      if (_expense.status?.toLowerCase() == 'pending')
                Positioned(
                  top: 0,
                                          right: 0,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(8),
                                              ),
                                            ),
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.white,
                                              ),
                                              onPressed: () => _showDeleteReceiptConfirmation(
                                                  index, receiptUrls[index]),
                                              iconSize: 20,
                                              padding: const EdgeInsets.all(4),
                                              constraints: const BoxConstraints(),
                                            ),
          ),
        ),
      ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Show loading overlay when uploading
          if (_isUploadingReceipt)
                            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                            Text(
                      'Uploading receipt...',
                      style: TextStyle(color: Colors.white),
                    ),
                        ],
                      ),
                    ),
            ),
        ],
      ),
    );
  }
  
  // Get appropriate icon for expense category
  IconData getCategoryIcon(String? category) {
    switch (category) {
      case 'Meals':
        return Icons.restaurant;
      case 'Transportation':
        return Icons.directions_car;
      case 'Office':
        return Icons.business_center;
      case 'Travel':
        return Icons.flight;
      case 'Accommodation':
        return Icons.hotel;
      case 'Supplies':
        return Icons.shopping_bag;
      default:
        return Icons.category;
    }
  }
  
  // Get color based on status
  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  // Get status icon based on status
  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'pending':
        return Icons.hourglass_empty;
      default:
        return Icons.help_outline;
    }
  }
  
  // Open receipt gallery in fullscreen
  void _openReceiptGallery(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptGalleryScreen(
          receiptUrls: _expense.receiptUrls ?? [],
          initialIndex: index,
        ),
      ),
    );
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteExpense();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
    );
  }
  
  // Delete the expense
  Future<void> _deleteExpense() async {
    // Implement delete functionality
    // This is a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Delete functionality not implemented yet'),
      ),
    );
  }
  
  // Download receipt
  void _downloadReceipt() {
    // Implement download functionality
    // This is a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Download functionality not implemented yet'),
      ),
    );
  }

  // Show confirmation dialog for deleting a receipt
  void _showDeleteReceiptConfirmation(int index, String receiptUrl) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
        title: const Text('Delete Receipt'),
        content: const Text('Are you sure you want to delete this receipt? This action cannot be undone.'),
                  actions: [
                    TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
              Navigator.pop(context);
              _deleteReceipt(index, receiptUrl);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
  }
  
  // Delete a receipt from storage and update expense
  Future<void> _deleteReceipt(int index, String receiptUrl) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get current receipt URLs
      List<String> currentUrls = [];
      if (_expense.receiptUrls != null) {
        currentUrls = List<String>.from(_expense.receiptUrls!);
      }
      
      // Try to delete from storage if possible
      try {
        // Extract path from URL
        final uri = Uri.parse(receiptUrl);
        final pathComponents = uri.path.split('/');
        final storagePath = pathComponents.sublist(2).join('/'); // Skip /storage/v1
        
        await _expenseService.deleteReceipt(storagePath);
      } catch (e) {
        if (kDebugMode) {
          print('Could not delete from storage: $e');
        }
        // Continue anyway to update the expense record
      }
      
      // Remove URL from the list
      currentUrls.removeAt(index);
      
      // Update expense in database
      await _expenseService.updateExpense(
        _expense.id.toString(),
        {'receipt_urls': currentUrls},
      );
      
      // Update local state
      setState(() {
        _expense = _expense.copyWith(receiptUrls: currentUrls);
        _isUploadingReceipt = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Receipt deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete receipt: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Take a photo with the camera
  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      
      if (photo != null) {
        _uploadReceipt(photo: photo);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Pick images from gallery
  Future<void> _pickImages() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: kIsWeb,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final files = result.files;
        
        for (final file in files) {
          if (kIsWeb) {
            if (file.bytes != null) {
              await _uploadReceipt(
                bytes: file.bytes!,
                fileName: file.name,
              );
            }
          } else {
            if (file.path != null) {
              await _uploadReceipt(
                filePath: file.path!,
                fileName: file.name,
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking images: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Upload receipt to Supabase
  Future<void> _uploadReceipt({
    XFile? photo,
    String? filePath,
    Uint8List? bytes,
    String? fileName,
  }) async {
    try {
      setState(() {
        _isUploadingReceipt = true;
      });
      
      if (kDebugMode) {
        print('Starting receipt upload for expense ID: ${_expense.id}');
        print('Data sources: Photo: ${photo != null}, FilePath: ${filePath != null}, Bytes: ${bytes != null}');
      }
      
      final String receiptUrl = await _expenseService.uploadReceipt(
        expenseId: _expense.id.toString(),
        photo: photo,
        filePath: filePath,
        bytes: bytes,
        filename: fileName,
      );

      // Add new receipt URL to the expense's receipt URLs list
      final List<String> updatedReceiptUrls = List<String>.from(_expense.receiptUrls ?? []);
      updatedReceiptUrls.add(receiptUrl);

      if (kDebugMode) {
        print('Receipt URL obtained: $receiptUrl');
        print('Updating expense with new receipt URLs');
      }

      // Update the expense in the database
      await _expenseService.updateExpense(
        _expense.id.toString(),
        {'receipt_urls': updatedReceiptUrls},
      );

      setState(() {
        _expense = _expense.copyWith(receiptUrls: updatedReceiptUrls);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Receipt uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error uploading receipt: $error');
        if (error.toString().contains('bucket_id')) {
          print('Storage bucket issue: make sure "expense_receipts" bucket exists in Supabase');
        }
      }
      
      if (mounted) {
        String errorMessage = error.toString();
        // Simplify technical error messages for users
        if (errorMessage.contains('bucket') || errorMessage.contains('storage')) {
          errorMessage = 'Storage configuration error. Please contact administrator.';
        } else if (errorMessage.contains('permission') || errorMessage.contains('not allowed')) {
          errorMessage = 'You don\'t have permission to upload files. Please contact administrator.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading receipt: $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingReceipt = false;
        });
      }
    }
  }
}

// Receipt gallery screen for fullscreen viewing
class ReceiptGalleryScreen extends StatefulWidget {
  final List<String> receiptUrls;
  final int initialIndex;

  const ReceiptGalleryScreen({
    Key? key,
    required this.receiptUrls,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<ReceiptGalleryScreen> createState() => _ReceiptGalleryScreenState();
}

class _ReceiptGalleryScreenState extends State<ReceiptGalleryScreen> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Receipt ${_currentIndex + 1}/${widget.receiptUrls.length}'),
        elevation: 0,
      ),
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(widget.receiptUrls[index]),
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 4,
            heroAttributes: PhotoViewHeroAttributes(tag: 'receipt_$index'),
          );
        },
        itemCount: widget.receiptUrls.length,
        pageController: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        loadingBuilder: (context, event) => Center(
          child: CircularProgressIndicator(
            value: event == null 
                ? 0 
                : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
          ),
        ),
        backgroundDecoration: const BoxDecoration(
          color: Colors.black,
        ),
      ),
    );
  }
}

// Widget for displaying expense detail items
class DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final bool isMultiLine;

  const DetailItem({
    Key? key,
    required this.label,
    required this.value,
    this.icon,
    this.isMultiLine = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        if (isMultiLine) ...[
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ] else ...[
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: Colors.deepPurple),
                const SizedBox(width: 8),
              ],
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
} 