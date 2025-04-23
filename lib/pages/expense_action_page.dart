import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reimbursement_box/services/expense_service.dart';

class ExpenseActionPage extends StatefulWidget {
  final String action;
  final String expenseId;
  final String trackingId;
  final String token;
  
  const ExpenseActionPage({
    Key? key,
    required this.action,
    required this.expenseId,
    required this.trackingId,
    required this.token,
  }) : super(key: key);

  @override
  State<ExpenseActionPage> createState() => _ExpenseActionPageState();
}

class _ExpenseActionPageState extends State<ExpenseActionPage> {
  final supabase = Supabase.instance.client;
  final _expenseService = ExpenseService();
  final _rejectionReasonController = TextEditingController();
  
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _errorMessage;
  Map<String, dynamic>? _expenseData;
  
  @override
  void initState() {
    super.initState();
    _loadExpenseDetails();
  }
  
  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }
  
  // Load expense details
  Future<void> _loadExpenseDetails() async {
    try {
      final response = await supabase
          .from('expenses')
          .select('*, employee:employee_id(*)')
          .eq('tracking_id', widget.trackingId)
          .single();
      
      setState(() {
        _expenseData = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading expense details: $e';
        _isLoading = false;
      });
    }
  }
  
  // Process expense approval
  Future<void> _processApproval() async {
    setState(() {
      _isProcessing = true;
    });
    
    try {
      final reviewerId = supabase.auth.currentUser?.id ?? 'system-reviewer';
      
      final success = await _expenseService.processExpenseReview(
        expenseId: widget.expenseId,
        trackingId: widget.trackingId,
        approved: true,
        reviewerId: reviewerId,
        secureToken: widget.token,
      );
      
      if (success) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense approved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Failed to approve expense');
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        setState(() {
          _errorMessage = 'Error approving expense: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
  
  // Show rejection dialog
  void _showRejectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reason for Rejection'),
        content: TextField(
          controller: _rejectionReasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Please provide a reason for rejecting this expense',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processRejection(_rejectionReasonController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
  
  // Process expense rejection
  Future<void> _processRejection(String rejectionReason) async {
    if (rejectionReason.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a reason for rejection'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      final reviewerId = supabase.auth.currentUser?.id ?? 'system-reviewer';
      
      final success = await _expenseService.processExpenseReview(
        expenseId: widget.expenseId,
        trackingId: widget.trackingId,
        approved: false,
        reviewerId: reviewerId,
        rejectionReason: rejectionReason,
        secureToken: widget.token,
      );
      
      if (success) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense rejected successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Failed to reject expense');
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        setState(() {
          _errorMessage = 'Error rejecting expense: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Action'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _expenseData?['title'] ?? 'Unknown Expense',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tracking ID: ${_expenseData?['tracking_id'] ?? 'Unknown'}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              const Divider(height: 24),
                              _buildInfoRow('Amount', '${_expenseData?['currency'] ?? 'USD'} ${_expenseData?['amount']?.toStringAsFixed(2) ?? '0.00'}'),
                              _buildInfoRow('Category', _expenseData?['category'] ?? 'Unknown'),
                              _buildInfoRow('Project', _expenseData?['project'] ?? 'Unknown'),
                              _buildInfoRow('Date', _formatDate(_expenseData?['date'])),
                              _buildInfoRow('Submitted By', _expenseData?['employee']?['name'] ?? 'Unknown Employee'),
                              if (_expenseData?['description'] != null)
                                _buildInfoRow('Description', _expenseData?['description']),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_expenseData?['receipt_urls'] != null && (_expenseData?['receipt_urls'] as List).isNotEmpty)
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Receipt Images',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 200,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: (_expenseData?['receipt_urls'] as List).length,
                                    itemBuilder: (context, index) {
                                      final receiptUrl = (_expenseData?['receipt_urls'] as List)[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            receiptUrl,
                                            width: 150,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              width: 150,
                                              color: Colors.grey[200],
                                              child: const Center(
                                                child: Icon(Icons.broken_image),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isProcessing
                                ? null
                                : () {
                                    if (widget.action == 'approve') {
                                      _processApproval();
                                    } else {
                                      _processApproval();
                                    }
                                  },
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Approve'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _isProcessing
                                ? null
                                : () {
                                    if (widget.action == 'reject') {
                                      _showRejectionDialog();
                                    } else {
                                      _showRejectionDialog();
                                    }
                                  },
                            icon: const Icon(Icons.cancel),
                            label: const Text('Reject'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_isProcessing)
                        const Padding(
                          padding: EdgeInsets.only(top: 24.0),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
  
  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'Not specified',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
} 