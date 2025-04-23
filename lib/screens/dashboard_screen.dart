import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:reimbursement_box/main.dart'; // for themeNotifier
import 'package:reimbursement_box/widgets/animated_theme_toggle.dart';
import 'package:reimbursement_box/widgets/gradient_card.dart';
import 'package:reimbursement_box/widgets/shimmer_loading.dart';
import 'package:reimbursement_box/widgets/gradient_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final supabase = Supabase.instance.client;
  String _selectedDateFilter = 'This Month';
  String _selectedProject = 'All Projects';
  
  // Data variables
  int _totalSubmitted = 0;
  int _pendingApprovals = 0;
  int _rejectedExpenses = 0;
  int _approvedExpenses = 0;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  
  final List<String> _dateFilters = ['This Week', 'This Month', 'This Year'];
  List<String> _projectFilters = ['All Projects'];
  
  List<Map<String, dynamic>> _recentExpenses = [];
  
  // Expense category data for charts
  Map<String, double> _expensesByCategory = {};
  List<Map<String, dynamic>> _expensesByMonth = [];

  @override
  void initState() {
    super.initState();
    _checkSession();
    _loadDashboardData();
  }

  void _checkSession() {
    final activeSession = supabase.auth.currentSession;
    if (activeSession == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/auth');
      });
    }
  }

  Future<void> _loadDashboardData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }
    
    try {
      await Future.wait([
        _fetchExpenseStatistics(),
        _fetchRecentExpenses(),
        _fetchExpenseCategories(),
        _fetchExpensesByMonth(),
        _fetchProjects(),
      ]);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading dashboard data: $e');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Failed to load dashboard data. Please try again.';
        });
      }
    }
  }
  
  Future<void> _fetchExpenseStatistics() async {
    try {
      // Remove user filtering - just get all expenses
      final result = await supabase
          .from('expenses')
          .select('status')
          .filter('created_at', 'gte', _getDateFilter());
      
      int submitted = result.length;
      int pending = 0;
      int rejected = 0;
      int approved = 0;
      
      // Count statuses
      for (final row in result) {
        switch (row['status']) {
          case 'pending':
            pending++;
            break;
          case 'rejected':
            rejected++;
            break;
          case 'approved':
            approved++;
            break;
        }
      }
      
      if (mounted) {
        setState(() {
          _totalSubmitted = submitted;
          _pendingApprovals = pending;
          _rejectedExpenses = rejected;
          _approvedExpenses = approved;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching expense statistics: $e');
      }
    }
  }
  
  Future<void> _fetchRecentExpenses() async {
    try {
      // Remove user filtering - just get recent expenses
      final result = await supabase
          .from('expenses')
          .select('id, title, amount, created_at, status, category')
          .order('created_at', ascending: false)
          .limit(5);
      
      List<Map<String, dynamic>> expenses = [];
      for (final row in result) {
        expenses.add({
          'id': row['id'],
          'title': row['title'],
          'amount': (row['amount'] as num).toDouble(),
          'date': DateTime.parse(row['created_at']),
          'status': row['status'],
          'category': row['category'] ?? 'Other',
        });
      }
      
      if (mounted) {
        setState(() {
          _recentExpenses = expenses;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching recent expenses: $e');
      }
    }
  }
  
  Future<void> _fetchExpenseCategories() async {
    try {
      // Remove user filtering - just get all expenses by category
      final result = await supabase
          .from('expenses')
          .select('category, amount')
          .filter('created_at', 'gte', _getDateFilter());
      
      Map<String, double> categories = {};
      for (final row in result) {
        final category = row['category'] ?? 'Other';
        final amount = (row['amount'] as num).toDouble();
        
        if (categories.containsKey(category)) {
          categories[category] = categories[category]! + amount;
        } else {
          categories[category] = amount;
        }
      }
      
      if (mounted) {
        setState(() {
          _expensesByCategory = categories;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching expense categories: $e');
      }
    }
  }
  
  Future<void> _fetchExpensesByMonth() async {
    try {
      // Get expenses for last 6 months
      final endDate = DateTime.now();
      final startDate = DateTime(endDate.year, endDate.month - 5, 1);
      
      // Remove user filtering - just get expenses by date range
      final result = await supabase
          .from('expenses')
          .select('created_at, amount')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());
      
      // Group by month
      Map<String, double> expensesByMonth = {};
      for (final row in result) {
        final date = DateTime.parse(row['created_at']);
        final month = DateFormat('MMM y').format(date);
        final amount = (row['amount'] as num).toDouble();
        
        if (expensesByMonth.containsKey(month)) {
          expensesByMonth[month] = expensesByMonth[month]! + amount;
        } else {
          expensesByMonth[month] = amount;
        }
      }
      
      // Convert to list for chart
      List<Map<String, dynamic>> monthlyData = [];
      for (int i = 0; i < 6; i++) {
        final date = DateTime(endDate.year, endDate.month - i, 1);
        final month = DateFormat('MMM y').format(date);
        monthlyData.add({
          'month': month,
          'amount': expensesByMonth[month] ?? 0.0,
          'index': 5 - i, // Reverse index for chart
        });
      }
      
      // Sort by date
      monthlyData.sort((a, b) => a['index'].compareTo(b['index']));
      
      if (mounted) {
        setState(() {
          _expensesByMonth = monthlyData;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching expenses by month: $e');
      }
    }
  }
  
  Future<void> _fetchProjects() async {
    try {
      final result = await supabase.from('projects').select('name').order('name');
      
      List<String> projects = ['All Projects'];
      for (final row in result) {
        projects.add(row['name']);
      }
      
      if (mounted) {
        setState(() {
          _projectFilters = projects;
        });
      }
    } catch (e) {
      // If we can't get projects, just use the default "All Projects"
      if (kDebugMode) {
        print('Error fetching projects: $e');
      }
    }
  }
  
  String _getDateFilter() {
    final now = DateTime.now();
    switch (_selectedDateFilter) {
      case 'This Week':
        // Get start of week (Monday)
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day).toIso8601String();
      case 'This Month':
        return DateTime(now.year, now.month, 1).toIso8601String();
      case 'This Year':
        return DateTime(now.year, 1, 1).toIso8601String();
      default:
        return DateTime(now.year, now.month, 1).toIso8601String();
    }
  }

  Future<void> _signOut() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        actions: [
          // theme toggle button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: AnimatedThemeToggle(size: 32.0),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildDrawer(user),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: _hasError 
          ? _buildErrorView() 
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark 
                      ? [Theme.of(context).scaffoldBackgroundColor, Color(0xFF1A1A2E)] 
                      : [Colors.white, Color(0xFFF5F7FF)],
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildProfileSummary(user),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(
                        Icons.dashboard_customize,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Employee Dashboard', 
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStatisticsCards(),
                  const SizedBox(height: 24),
                  
                  // Quick Actions Menu - New Section
                  _buildQuickActionsMenu(),
                  const SizedBox(height: 24),
                  
                  _buildFilters(),
                  const SizedBox(height: 24),
                  _buildExpenseCharts(),
                  const SizedBox(height: 24),
                  _buildRecentExpenses(),
                ],
              ),
            ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/add_expense');
        },
        icon: const Icon(Icons.add),
        label: const Text('New Expense'),
        elevation: 2,
      ),
    );
  }
  
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: 'Try Again',
              onPressed: _loadDashboardData,
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(User? user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Drawer(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            decoration: BoxDecoration(
              gradient: isDark ? darkPrimaryGradient : lightPrimaryGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: const Icon(Icons.person, size: 30, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.email?.split('@').first ?? 'User',
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'example@company.com',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  isSelected: true,
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerItem(
                  icon: Icons.receipt_long_rounded,
                  title: 'Submit Expense',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/add_expense');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.list_alt_rounded,
                  title: 'My Expenses',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/my_expenses');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.work_rounded,
                  title: 'My Projects',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/my_projects');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.monetization_on_rounded,
                  title: 'My Compensation',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/my_compensation');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings_rounded,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to settings screen
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  onTap: _signOut,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDrawerItem({
    required IconData icon, 
    required String title, 
    required VoidCallback onTap, 
    bool isSelected = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).primaryColor;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: isSelected ? primary.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon, 
                  color: isSelected ? primary : (isDark ? Colors.white70 : Colors.grey[700]),
                  size: 22,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? primary : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSummary(User? user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GradientCard(
      elevation: 3,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: isDark ? darkPrimaryGradient : lightPrimaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.person, size: 30, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.email?.split('@').first ?? 'User',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'example@company.com',
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Employee ID: ${user?.id?.substring(0, 8) ?? '12345678'}',
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF252542) : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(
                Icons.edit_outlined,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              onPressed: () {
                // Navigate to profile edit screen
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return ShimmerLoading(
      isLoading: _isLoading,
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.8,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildStatCard(
            title: 'Total', 
            value: _totalSubmitted.toString(), 
            icon: Icons.assessment_rounded, 
            gradientColors: [Color(0xFF4A6FFF), Color(0xFF7A54FF)],
          ),
          _buildStatCard(
            title: 'Pending', 
            value: _pendingApprovals.toString(), 
            icon: Icons.hourglass_top_rounded, 
            gradientColors: [Color(0xFFFF9D54), Color(0xFFFF7D54)],
          ),
          _buildStatCard(
            title: 'Rejected', 
            value: _rejectedExpenses.toString(), 
            icon: Icons.highlight_off_rounded, 
            gradientColors: [Color(0xFFFF5454), Color(0xFFFF3D7F)],
          ),
          _buildStatCard(
            title: 'Approved', 
            value: _approvedExpenses.toString(), 
            icon: Icons.verified_rounded, 
            gradientColors: [Color(0xFF42CD85), Color(0xFF00C6B3)],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradientColors,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GradientCard(
      useGradientBorder: true,
      borderColors: gradientColors,
      isPrimary: false,
      borderWidth: 2.0,
      borderRadius: 16,
      elevation: 4,
      margin: const EdgeInsets.all(0),
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          // Gradient overlay in the corner
          Positioned(
            top: -15,
            right: -15,
            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title and icon
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: gradientColors[0].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        icon,
                        size: 14,
                        color: gradientColors[0],
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      title,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey[700],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 6),
                
                // Value with bigger font
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(Rect.fromLTWH(0, 0, 60, 40)),
                  ),
                ),
                
                // Use wrapper with exact height to prevent overflow
                Container(
                  height: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Percentage text as simple row
                      Text(
                        '${_totalSubmitted > 0 ? (int.parse(value) * 100 ~/ _totalSubmitted) : 0}% of total',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      // Progress bar
                      SizedBox(
                        height: 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(1.5),
                          child: LinearProgressIndicator(
                            value: _totalSubmitted > 0 
                                ? int.parse(value) / _totalSubmitted 
                                : 0.0,
                            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              gradientColors[0],
                            ),
                            minHeight: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
            ? const Color(0xFF252542) 
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list,
                color: Theme.of(context).primaryColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Filter Expenses',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Date Filter',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    prefixIcon: Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  value: _selectedDateFilter,
                  items: _dateFilters.map((filter) {
                    return DropdownMenuItem(
                      value: filter,
                      child: Text(filter),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedDateFilter = value;
                      });
                      _loadDashboardData();
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Project Filter',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    prefixIcon: Icon(
                      Icons.work_outline,
                      size: 18,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  value: _selectedProject,
                  items: _projectFilters.map((project) {
                    return DropdownMenuItem(
                      value: project,
                      child: Text(project),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedProject = value;
                      });
                      _loadDashboardData();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCharts() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ShimmerLoading(
      isLoading: _isLoading,
      child: Column(
        children: [
          GradientCard(
            elevation: 4,
            useGradientBorder: true,
            borderWidth: 1.5,
            isPrimary: true,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.pie_chart_outline,
                      color: Theme.of(context).primaryColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Expenses by Category',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _expensesByCategory.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bar_chart_outlined,
                              size: 48,
                              color: isDark ? Colors.grey[600] : Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No expense data available',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: _getMaxCategoryAmount(),
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                final categories = _expensesByCategory.keys.toList();
                                if (groupIndex < categories.length) {
                                  final category = categories[groupIndex];
                                  return BarTooltipItem(
                                    '$category\n\$${rod.toY.toStringAsFixed(2)}',
                                    TextStyle(
                                      color: isDark ? Colors.white : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }
                                return null;
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  final categories = _expensesByCategory.keys.toList();
                                  final index = value.toInt();
                                  if (index >= 0 && index < categories.length) {
                                    final category = categories[index];
                                    // Abbreviated category name
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        category.length > 5 
                                            ? '${category.substring(0, 5)}...' 
                                            : category,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  return Text(
                                    '\$${value.toInt()}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    ),
                                  );
                                },
                                interval: _getMaxCategoryAmount() / 4,
                              ),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: _getMaxCategoryAmount() / 4,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                                strokeWidth: 1,
                                dashArray: [5, 5],
                              );
                            },
                          ),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          barGroups: _getBarGroups(),
                        ),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GradientCard(
            elevation: 4,
            useGradientBorder: true,
            borderWidth: 1.5,
            isPrimary: false,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Expenses Over Time',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _expensesByMonth.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.show_chart,
                              size: 48,
                              color: isDark ? Colors.grey[600] : Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No expense data available',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                                strokeWidth: 1,
                                dashArray: [5, 5],
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  final index = value.toInt();
                                  if (index >= 0 && index < _expensesByMonth.length) {
                                    final month = _expensesByMonth[index]['month'].toString().split(' ')[0];
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        month, 
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  return Text(
                                    '\$${value.toInt()}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    ),
                                  );
                                },
                                interval: _getMaxMonthlyAmount() / 4,
                              ),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          minX: 0,
                          maxX: _expensesByMonth.length - 1.0,
                          minY: 0,
                          maxY: _getMaxMonthlyAmount(),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _getLineSpots(),
                              isCurved: true,
                              color: Theme.of(context).colorScheme.secondary,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 5,
                                    color: Theme.of(context).colorScheme.secondary,
                                    strokeWidth: 2,
                                    strokeColor: isDark ? Colors.black : Colors.white,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                              ),
                            ),
                          ],
                        ),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  double _getMaxCategoryAmount() {
    if (_expensesByCategory.isEmpty) return 100.0;
    return _expensesByCategory.values.reduce((max, value) => max > value ? max : value) + 50.0;
  }
  
  List<BarChartGroupData> _getBarGroups() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = _expensesByCategory.keys.toList();
    final List<BarChartGroupData> barGroups = [];
    
    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      final amount = _expensesByCategory[category] ?? 0.0;
      
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: amount,
              color: Theme.of(context).primaryColor,
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: _getMaxCategoryAmount(),
                color: isDark ? Colors.grey[800] : Colors.grey[200],
              ),
            ),
          ],
        ),
      );
    }
    
    return barGroups;
  }
  
  double _getMaxMonthlyAmount() {
    if (_expensesByMonth.isEmpty) return 1000.0;
    final amounts = _expensesByMonth.map((e) => e['amount'] as double).toList();
    return amounts.reduce((max, value) => max > value ? max : value) + 100.0;
  }
  
  List<FlSpot> _getLineSpots() {
    final List<FlSpot> spots = [];
    
    for (int i = 0; i < _expensesByMonth.length; i++) {
      final amount = _expensesByMonth[i]['amount'] as double;
      spots.add(FlSpot(i.toDouble(), amount));
    }
    
    return spots;
  }

  Widget _buildRecentExpenses() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ShimmerLoading(
      isLoading: _isLoading,
      child: GradientCard(
        elevation: 4,
        useGradientBorder: true,
        borderWidth: 1.5,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.receipt_outlined,
                      color: Theme.of(context).primaryColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Recent Expenses',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: isDark ? darkPrimaryGradient : lightPrimaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/my_expenses');
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'View All',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _recentExpenses.isEmpty
              ? Container(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No recent expenses found',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GradientButton(
                        text: 'Add Expense',
                        onPressed: () => Navigator.pushNamed(context, '/add_expense'),
                        icon: Icons.add,
                        height: 40,
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _recentExpenses.length,
                  separatorBuilder: (context, index) => Divider(
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                  ),
                  itemBuilder: (context, index) {
                    final expense = _recentExpenses[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _getStatusColor(expense['status']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Icon(
                          _getCategoryIcon(expense['category']),
                          color: _getStatusColor(expense['status']),
                        ),
                      ),
                      title: Text(
                        expense['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        '${expense['category']} • ${DateFormat('MMM d, yyyy').format(expense['date'])}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${expense['amount'].toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(expense['status']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getStatusColor(expense['status']).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _getStatusText(expense['status']),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(expense['status']),
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        // Navigate to expense details with an expense object
                        // We'd need to convert this to an Expense model
                        // Navigator.pushNamed(context, '/expense_details', arguments: expense);
                      },
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Meals':
        return Icons.restaurant;
      case 'Transportation':
        return Icons.directions_car;
      case 'Office':
        return Icons.business_center;
      case 'Travel':
        return Icons.flight;
      default:
        return Icons.receipt;
    }
  }

  // Build the quick actions menu with modern styling
  Widget _buildQuickActionsMenu() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.grid_view_rounded,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Quick Actions',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildActionCard(
              title: 'Submit Expense',
              icon: Icons.receipt_long_rounded,
              customIcon: Icons.add_circle,
              description: 'Add new expense',
              gradientColors: [Color(0xFF4A6FFF), Color(0xFF7A54FF)],
              onTap: () => Navigator.pushNamed(context, '/add_expense'),
            ),
            _buildActionCard(
              title: 'My Expenses',
              icon: Icons.list_alt_rounded,
              customIcon: Icons.receipt_outlined,
              description: 'View history',
              gradientColors: [Color(0xFF00C6B3), Color(0xFF00E5A3)],
              onTap: () => Navigator.pushNamed(context, '/my_expenses'),
            ),
            _buildActionCard(
              title: 'My Projects',
              icon: Icons.work_rounded,
              customIcon: Icons.folder_special_rounded,
              description: 'Manage projects',
              gradientColors: [Color(0xFFFF9D54), Color(0xFFFF7D54)],
              onTap: () => Navigator.pushNamed(context, '/my_projects'),
            ),
            _buildActionCard(
              title: 'My Compensation',
              icon: Icons.monetization_on_rounded,
              customIcon: Icons.account_balance_wallet_rounded,
              description: 'View details',
              gradientColors: [Color(0xFF42CD85), Color(0xFF00C6B3)],
              onTap: () => Navigator.pushNamed(context, '/my_compensation'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required IconData customIcon,
    required String description,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GradientCard(
      useGradientBorder: true,
      borderColors: gradientColors,
      isPrimary: false,
      borderWidth: 2.0,
      borderRadius: 16,
      elevation: 4,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Decorative corner circle with gradient
              Positioned(
                top: -15,
                right: -15,
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[0].withOpacity(0.3),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    customIcon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            gradientColors[0].withOpacity(0.2),
                            gradientColors[1].withOpacity(0.2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: gradientColors[0].withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: gradientColors[0].withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        color: gradientColors[0],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.arrow_right_alt_rounded,
                                size: 14,
                                color: gradientColors[0].withOpacity(0.8),
                              ),
                              SizedBox(width: 4),
                              Text(
                                description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: gradientColors[0].withOpacity(0.8),
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
            ],
          ),
        ),
      ),
    );
  }
} 