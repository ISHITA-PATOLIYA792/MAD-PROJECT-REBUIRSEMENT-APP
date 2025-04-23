import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:reimbursement_box/services/expense_service.dart';
import 'package:reimbursement_box/models/expense.dart';
import 'dart:async';
import 'package:reimbursement_box/widgets/gradient_card.dart';
import 'package:reimbursement_box/main.dart';

class MyExpensesScreen extends StatefulWidget {
  const MyExpensesScreen({Key? key}) : super(key: key);

  @override
  State<MyExpensesScreen> createState() => _MyExpensesScreenState();
}

class _MyExpensesScreenState extends State<MyExpensesScreen> {
  final supabase = Supabase.instance.client;
  final _expenseService = ExpenseService();
  bool _isLoading = true;
  String _selectedFilter = 'All';
  String _selectedSortBy = 'Date: Newest First';
  StreamSubscription? _expenseSubscription;
  
  // Real data from Supabase
  List<Map<String, dynamic>> _expenses = [];

  // dashboard mock items
  final List<Map<String, dynamic>> _recentDashboardExpenses = [
    {
      'id': -1,
      'title': 'Team lunch',
      'amount': 89.50,
      'date': DateTime.now().subtract(Duration(days: 2)).toIso8601String(),
      'status': 'approved',
      'category': 'Meals',
      'currency': 'USD',
      'project': 'Project A',
      'description': 'Business lunch with team',
      'receipt_urls': [],
      'rejection_reason': null,
    },
    {
      'id': -2,
      'title': 'Taxi to airport',
      'amount': 45.75,
      'date': DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
      'status': 'pending',
      'category': 'Transportation',
      'currency': 'USD',
      'project': 'Project B',
      'description': 'Ride to airport for client meeting',
      'receipt_urls': [],
      'rejection_reason': null,
    },
    {
      'id': -3,
      'title': 'Office supplies',
      'amount': 120.25,
      'date': DateTime.now().subtract(Duration(days: 5)).toIso8601String(),
      'status': 'rejected',
      'category': 'Office',
      'currency': 'USD',
      'project': 'Office Admin',
      'description': 'Supplies purchase for new hire',
      'receipt_urls': [],
      'rejection_reason': null,
    },
    {
      'id': -4,
      'title': 'Client meeting',
      'amount': 65.30,
      'date': DateTime.now().subtract(Duration(days: 7)).toIso8601String(),
      'status': 'approved',
      'category': 'Meals',
      'currency': 'USD',
      'project': 'Project C',
      'description': 'Dinner with client to discuss Q2 goals',
      'receipt_urls': [],
      'rejection_reason': null,
    },
  ];

  final List<String> _filterOptions = [
    'All',
    'Pending',
    'Approved',
    'Rejected',
  ];

  final List<String> _sortOptions = [
    'Date: Newest First',
    'Date: Oldest First',
    'Amount: High to Low',
    'Amount: Low to High',
  ];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  @override
  void dispose() {
    _expenseSubscription?.cancel();
    Supabase.instance.client.removeAllChannels();
    super.dispose();
  }

  // Load expenses from Supabase
  Future<void> _loadExpenses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the current user's ID
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Query expenses from Supabase
      final response = await supabase
          .from('expenses')
          .select('*, receipt_urls')
          .eq('employee_id', userId)
          .order('created_at', ascending: false);

      // generate full mocks with required IDs for fromMap
      final List<Map<String, dynamic>> mockExpenses = _recentDashboardExpenses.map((e) => {
        ...e,
        'tracking_id': 'MOCK-${e['id']}',
        'employee_id': userId,
      }).toList();
      final List<Map<String, dynamic>> realExpenses = List<Map<String, dynamic>>.from(response);
      if (mounted) {
        setState(() {
          _expenses = [...mockExpenses, ...realExpenses];
          _isLoading = false;
        });
      }

      // Setup real-time subscription for updates if not already subscribed
      if (_expenseSubscription == null) {
      _subscribeToExpenseUpdates();
      }
    } catch (e) {
      print('Error loading expenses: $e');
      if (mounted) {
        setState(() {
          final userId = supabase.auth.currentUser!.id;
          _expenses = _recentDashboardExpenses.map((e) => {
            ...e,
            'tracking_id': 'MOCK-${e['id']}',
            'employee_id': userId,
          }).toList();
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading expenses: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Subscribe to real-time updates
  void _subscribeToExpenseUpdates() {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    _expenseSubscription = _expenseService.subscribeToExpenseUpdates().listen(
      (updatedReal) {
        if (mounted) {
          final userId = supabase.auth.currentUser!.id;
          final List<Map<String, dynamic>> mockExpenses = _recentDashboardExpenses.map((e) => {
            ...e,
            'tracking_id': 'MOCK-${e['id']}',
            'employee_id': userId,
          }).toList();
          setState(() {
            _expenses = [...mockExpenses, ...updatedReal];
          });
        }
      },
    );
  }

  List<Map<String, dynamic>> get _filteredExpenses {
    List<Map<String, dynamic>> result = List.from(_expenses);
    
    // Apply status filter
    if (_selectedFilter != 'All') {
      result = result.where((expense) => 
        expense['status'] == _selectedFilter.toLowerCase()
      ).toList();
    }
    
    // Apply sorting
    result.sort((a, b) {
      switch (_selectedSortBy) {
        case 'Date: Newest First':
          return DateTime.parse(b['date'].toString()).compareTo(DateTime.parse(a['date'].toString()));
        case 'Date: Oldest First':
          return DateTime.parse(a['date'].toString()).compareTo(DateTime.parse(b['date'].toString()));
        case 'Amount: High to Low':
          return (b['amount'] as num).compareTo(a['amount'] as num);
        case 'Amount: Low to High':
          return (a['amount'] as num).compareTo(b['amount'] as num);
        default:
          return DateTime.parse(b['created_at'].toString()).compareTo(DateTime.parse(a['created_at'].toString()));
      }
    });
    
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadExpenses,
            tooltip: 'Refresh expenses',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet(context);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadExpenses,
              child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Filter by Status',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          value: _selectedFilter,
                          items: _filterOptions.map((filter) {
                            return DropdownMenuItem(
                              value: filter,
                              child: Text(filter),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedFilter = value;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Sort by',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          value: _selectedSortBy,
                          items: _sortOptions.map((option) {
                            return DropdownMenuItem(
                              value: option,
                              child: Text(option),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedSortBy = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _filteredExpenses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 72,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No expenses found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.add),
                                label: const Text('Add New Expense'),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/add_expense');
                                },
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _filteredExpenses.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final expense = _filteredExpenses[index];
                              return _buildExpenseItem(expense);
                          },
                        ),
                ),
              ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_expense');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Expenses',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Status',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _filterOptions.map((filter) {
                      return ChoiceChip(
                        label: Text(filter),
                        selected: _selectedFilter == filter,
                        onSelected: (selected) {
                          if (selected) {
                            this.setState(() {
                              _selectedFilter = filter;
                            });
                            Navigator.pop(context);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sort By',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _sortOptions.map((option) {
                      return ChoiceChip(
                        label: Text(option),
                        selected: _selectedSortBy == option,
                        onSelected: (selected) {
                          if (selected) {
                            this.setState(() {
                              _selectedSortBy = option;
                            });
                            Navigator.pop(context);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          this.setState(() {
                            _selectedFilter = 'All';
                            _selectedSortBy = 'Date: Newest First';
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Reset'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showExpenseDetails(Map<String, dynamic> expense) {
    Navigator.pushNamed(
      context,
      '/expense_details',
      arguments: Expense.fromMap(expense),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'pending':
        return 'Pending';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  Color getStatusColor(String status) {
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

  // Get icon based on expense category with more descriptive options
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'travel':
        return Icons.flight_takeoff;
      case 'meals':
        return Icons.restaurant;
      case 'supplies':
        return Icons.shopping_cart;
      case 'transportation':
        return Icons.directions_car;
      case 'office':
        return Icons.business_center;
      case 'software':
        return Icons.code;
      case 'hardware':
        return Icons.computer;
      case 'training':
        return Icons.school;
      case 'entertainment':
        return Icons.movie;
      case 'marketing':
        return Icons.campaign;
      case 'utilities':
        return Icons.power;
      case 'rent':
        return Icons.apartment;
      case 'communication':
        return Icons.phone_in_talk;
      case 'healthcare':
        return Icons.health_and_safety;
      default:
        return Icons.receipt_long;
    }
  }

  // Get more visually appealing gradient colors for category
  List<Color> _getGradientColors(String category) {
    switch (category.toLowerCase()) {
      case 'travel':
        return [Color(0xFF4A6FFF), Color(0xFF7A54FF)];
      case 'meals':
        return [Color(0xFFFF9D54), Color(0xFFFF7D54)];
      case 'supplies':
        return [Color(0xFF00C6B3), Color(0xFF00E5A3)];
      case 'transportation':
        return [Color(0xFF42CD85), Color(0xFF00C6B3)];
      case 'office':
        return [Color(0xFF5D6BE2), Color(0xFF7868D9)];
      case 'software':
        return [Color(0xFF6772E5), Color(0xFF9080FF)];
      case 'hardware':
        return [Color(0xFF6D7FFF), Color(0xFF3F56FF)];
      case 'training':
        return [Color(0xFF5DA0F7), Color(0xFF3E7FFF)];
      case 'entertainment':
        return [Color(0xFFED6969), Color(0xFFD84747)];
      case 'marketing':
        return [Color(0xFFFF76A2), Color(0xFFFF4989)];
      case 'utilities':
        return [Color(0xFF4BC5E6), Color(0xFF27A5D9)];
      case 'rent':
        return [Color(0xFF8E8CD8), Color(0xFFA58CD3)];
      case 'communication':
        return [Color(0xFF5D9CEC), Color(0xFF3F81DD)];
      case 'healthcare':
        return [Color(0xFF52C98A), Color(0xFF16A874)];
      default:
        return [Color(0xFF8E8CD8), Color(0xFFA58CD3)];
    }
  }
  
  // Enhanced expense item with modern UI elements
  Widget _buildExpenseItem(Map<String, dynamic> expense) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = getStatusColor(expense['status']);
    final gradientColors = _getGradientColors(expense['category']);
    
    return GestureDetector(
      onTap: () => _showExpenseDetails(expense),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: GradientCard(
          useGradientBorder: true,
          borderWidth: 1.5,
          borderColors: gradientColors,
          elevation: 2,
          gradientColors: isDark 
            ? [Color(0xFF2A2D3E), Color(0xFF1F2130)] 
            : [Colors.white, Color(0xFFF8F9FF)],
          padding: EdgeInsets.zero,
          borderRadius: 16,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        expense['title'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [statusColor.withOpacity(0.8), statusColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            expense['status'].toLowerCase() == 'approved'
                                ? Icons.check_circle
                                : expense['status'].toLowerCase() == 'rejected'
                                    ? Icons.cancel
                                    : Icons.hourglass_top,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            expense['status'].toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              gradientColors[0].withOpacity(0.2),
                              gradientColors[1].withOpacity(0.2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getCategoryIcon(expense['category']),
                          color: gradientColors[0],
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "\$${expense['amount'].toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..shader = LinearGradient(
                                    colors: gradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(Rect.fromLTWH(0, 0, 120, 30)),
                              ),
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: gradientColors[0].withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: gradientColors[0],
                                  ),
                                ),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _formatDate(DateTime.parse(expense['date'])),
                                    style: TextStyle(
                                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: gradientColors[0].withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Icon(
                                    Icons.category,
                                    size: 14,
                                    color: gradientColors[0],
                                  ),
                                ),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    expense['category'],
                                    style: TextStyle(
                                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            if (expense['project'] != null) ...[
                              SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: gradientColors[0].withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Icon(
                                      Icons.work,
                                      size: 14,
                                      color: gradientColors[0],
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      expense['project'],
                                      style: TextStyle(
                                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (expense['receipt_urls'] != null && (expense['receipt_urls'] as List).isNotEmpty)
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage((expense['receipt_urls'] as List).first),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.8),
                                  width: 2,
                                ),
                              ),
                            ),
                          if (expense['receipt_urls'] == null || (expense['receipt_urls'] as List).isEmpty)
                            SizedBox(height: 60), // Placeholder to maintain layout
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [gradientColors[0].withOpacity(0.7), gradientColors[1]],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Details',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 3),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${_getMonthName(date.month)} ${date.day}, ${date.year}";
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1: return "Jan";
      case 2: return "Feb";
      case 3: return "Mar";
      case 4: return "Apr";
      case 5: return "May";
      case 6: return "Jun";
      case 7: return "Jul";
      case 8: return "Aug";
      case 9: return "Sep";
      case 10: return "Oct";
      case 11: return "Nov";
      case 12: return "Dec";
      default: return "";
    }
  }
}

class DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const DetailItem({
    Key? key,
    required this.label,
    required this.value,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: Colors.deepPurple),
              const SizedBox(width: 8),
            ],
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
} 