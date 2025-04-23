import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:reimbursement_box/services/expense_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({Key? key}) : super(key: key);

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;
  final _expenseService = ExpenseService();
  
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Meals';
  String _selectedProject = 'Project A';
  String _selectedCurrency = 'USD';
  
  bool _isSubmitting = false;
  bool _savingDraft = false;
  
  final List<String> _categories = [
    'Meals',
    'Transportation',
    'Office',
    'Travel',
    'Accommodation',
    'Supplies',
    'Other',
  ];
  
  List<Map<String, dynamic>> _projects = [];
  
  final Map<String, String> _currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'CAD': 'C\$',
    'AUD': 'A\$',
  };
  
  List<File> _receipts = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _checkDatabaseConnection();
    _loadProjects();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Check database connection and tables
  Future<void> _checkDatabaseConnection() async {
    try {
      final hasTable = await _expenseService.checkExpensesTable();
      if (!hasTable && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('WARNING: Database tables may not be properly set up. Contact your administrator if you encounter errors.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking database: $e');
      }
    }
  }

  // Load projects from MyProjectsScreen
  Future<void> _loadProjects() async {
    try {
      // In a real app, this would come from a service or database
      // For now, we'll populate with the same data as MyProjectsScreen
      final projectsData = [
        {'id': 'proj-001', 'name': 'Project A'},
        {'id': 'proj-002', 'name': 'Project B'},
        {'id': 'proj-003', 'name': 'Project C'},
        {'id': 'proj-004', 'name': 'AI Chatbot'},
        {'id': 'proj-005', 'name': 'Smart City Initiative'},
        {'id': 'proj-006', 'name': 'Financial App Redesign'},
        {'id': 'proj-007', 'name': 'Supply Chain Optimization'},
      ];
      
      setState(() {
        _projects = projectsData;
        _selectedProject = _projects[0]['name'];
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading projects: $e');
      }
    }
  }

  // Take a photo using the camera
  Future<void> _takePhoto() async {
    try {
      if (kIsWeb) {
        // For web, use the picker with bytes
        final XFile? photo = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 70,
        );
        
        if (photo != null) {
          final bytes = await photo.readAsBytes();
          _expenseService.addWebReceipt(photo.name, bytes);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo captured successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // For mobile, use the file system
        final XFile? photo = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 70,
        );
        
        if (photo != null) {
          setState(() {
            _receipts.add(File(photo.path));
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error taking photo: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Pick images from gallery
  Future<void> _pickImages() async {
    try {
      // Use withData parameter for web platform
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: kIsWeb, // Get bytes for web
      );
      
      if (result != null && result.files.isNotEmpty) {
        if (kIsWeb) {
          // Web implementation - handle bytes
          setState(() {
            for (var file in result.files) {
              if (file.bytes != null) {
                // For web, we'll store the bytes in ExpenseService
                // This is a temporary solution to make it work on web
                _expenseService.addWebReceipt(file.name, file.bytes!);
              }
            }
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Images selected successfully for upload'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Mobile implementation - handle paths
          setState(() {
            _receipts.addAll(
              result.paths.map((path) => File(path!)).toList(),
            );
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking images: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Remove a receipt from the list
  void _removeReceipt(int index) {
    setState(() {
      _receipts.removeAt(index);
    });
  }
  
  // Remove a web receipt
  void _removeWebReceipt(int index) {
    setState(() {
      final webReceipts = _expenseService.getWebReceipts();
      if (index >= 0 && index < webReceipts.length) {
        _expenseService.getWebReceipts().removeAt(index);
      }
    });
  }
  
  // Build receipt preview item
  Widget _buildReceiptItem({required Widget image, required VoidCallback onRemove}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: image,
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Save as draft
  Future<void> _saveDraft() async {
    setState(() {
      _savingDraft = true;
    });
    
    try {
      // TODO: Implement actual saving to local storage or database
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Draft saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save draft: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _savingDraft = false;
        });
      }
    }
  }

  // Submit expense
  Future<void> _submitExpense() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      
      try {
        // Parse amount to double, default to 0 if parsing fails
        double amount;
        try {
          amount = double.parse(_amountController.text.trim());
        } catch (e) {
          amount = 0.0; // Default value
        }
        
        // Ensure title is not empty
        String title = _titleController.text.trim();
        if (title.isEmpty) {
          // Use category as title if empty
          title = _selectedCategory;
        }
        
        // Show progress indicator during upload
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Submitting expense and uploading receipts...'),
            duration: Duration(seconds: 5),
          ),
        );
        
        // Log debugging info
        if (kDebugMode) {
          print('Submitting expense: $title, $amount, $_selectedCurrency');
          print('User ID: ${supabase.auth.currentUser?.id}');
          print('User Email: ${supabase.auth.currentUser?.email}');
        }
        
        // Submit expense through the service
        final trackingId = await _expenseService.submitExpense(
          title: title,
          amount: amount,
          currency: _selectedCurrency,
          date: _selectedDate,
          category: _selectedCategory,
          project: _selectedProject,
          description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
          receipts: _receipts, // For mobile, this will have files. For web, service will use stored bytes
        );
        
        if (trackingId != null) {
          if (mounted) {
            // Clear all previous snackbars
            ScaffoldMessenger.of(context).clearSnackBars();
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Expense submitted successfully! Tracking ID: $trackingId'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
            
            // Refresh expenses list by triggering a reload in My Expenses screen
            await Future.delayed(const Duration(seconds: 1));
            
            // Navigate to my_expenses screen to see the newly added expense
            Navigator.pushNamedAndRemoveUntil(
              context, 
              '/my_expenses', 
              (route) => route.settings.name == '/home',
            );
          }
        } else {
          throw Exception('Failed to submit expense');
        }
      } catch (e) {
        if (mounted) {
          // Extract more helpful error message 
          String errorMessage = e.toString();
          if (errorMessage.contains('expense_receipts')) {
            errorMessage = 'Problem uploading receipts. Please try again.';
          } else if (errorMessage.contains('insert') || errorMessage.contains('relation') || errorMessage.contains('does not exist')) {
            errorMessage = 'Database error. Please contact administrator.';
          } else if (errorMessage.contains('user profile exists')) {
            errorMessage = 'User profile error. Please log out and log in again.';
          } else if (errorMessage.contains('Failed to submit expense')) {
            errorMessage = 'Submission failed. Check your connection and try again.';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to submit expense: $errorMessage'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Expense'),
        actions: [
          TextButton(
            onPressed: _savingDraft ? null : _saveDraft,
            child: _savingDraft 
              ? const SizedBox(
                  width: 16, 
                  height: 16, 
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save Draft', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Expense Title',
                    hintText: 'Enter expense title',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Project selection
                Material(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Project',
                      prefixIcon: Icon(Icons.work),
                    ),
                    value: _selectedProject,
                    items: _projects.map<DropdownMenuItem<String>>((project) {
                      return DropdownMenuItem<String>(
                        value: project['name'],
                        child: Text(project['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedProject = value;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Category selection
                Material(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category),
                    ),
                    value: _selectedCategory,
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Amount with currency
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          hintText: 'Enter amount',
                          prefixIcon: Icon(Icons.attach_money),
                          suffixText: _selectedCurrency,
                          prefixText: _currencySymbols[_selectedCurrency],
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an amount';
                          }
                          try {
                            final amount = double.parse(value);
                            if (amount <= 0) {
                              return 'Amount must be greater than zero';
                            }
                          } catch (e) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Material(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Currency',
                          ),
                          value: _selectedCurrency,
                          items: _currencySymbols.entries.map((entry) {
                            return DropdownMenuItem(
                              value: entry.key,
                              child: Text('${entry.value} ${entry.key}'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedCurrency = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Date picker
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('MMM d, yyyy').format(_selectedDate),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Description
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter additional details',
                    prefixIcon: Icon(Icons.description),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),
                // Receipt upload section
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Receipt Upload',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Camera button
                            ElevatedButton.icon(
                              onPressed: _takePhoto,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Camera'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                            ),
                            // Gallery button
                            ElevatedButton.icon(
                              onPressed: _pickImages,
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Gallery'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Receipt preview section
                        if (_receipts.isNotEmpty || (kIsWeb && _expenseService.getWebReceipts().isNotEmpty)) ...[
                          const Text(
                            'Uploaded Receipts:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 120,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                // Display mobile receipts
                                if (!kIsWeb)
                                  ..._receipts.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final receipt = entry.value;
                                    return _buildReceiptItem(
                                      image: Image.file(
                                        receipt,
                                        height: 120,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      ),
                                      onRemove: () => _removeReceipt(index),
                                    );
                                  }).toList(),
                                
                                // Display web receipts
                                if (kIsWeb)
                                  ..._expenseService.getWebReceipts().asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final webReceipt = entry.value;
                                    return _buildReceiptItem(
                                      image: Image.memory(
                                        webReceipt['bytes'] as Uint8List,
                                        height: 120,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      ),
                                      onRemove: () => _removeWebReceipt(index),
                                    );
                                  }).toList(),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Placeholder when no receipts are uploaded
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.receipt_long,
                                    size: 32,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No receipts uploaded',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Submit button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitExpense,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting 
                    ? const CircularProgressIndicator() 
                    : const Text('Submit Expense'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 