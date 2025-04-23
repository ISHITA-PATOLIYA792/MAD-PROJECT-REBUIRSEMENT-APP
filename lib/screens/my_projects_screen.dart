import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:reimbursement_box/widgets/gradient_card.dart';
import 'package:reimbursement_box/main.dart';

class MyProjectsScreen extends StatefulWidget {
  const MyProjectsScreen({Key? key}) : super(key: key);

  @override
  State<MyProjectsScreen> createState() => _MyProjectsScreenState();
}

class _MyProjectsScreenState extends State<MyProjectsScreen> {
  final supabase = Supabase.instance.client;
  bool _isLoading = false;
  
  // Mock data for projects (would be fetched from Supabase in a real app)
  final List<Map<String, dynamic>> _projects = [
    {
      'id': 'proj-001',
      'name': 'Project A',
      'description': 'Mobile app development for finance sector',
      'startDate': DateTime.now().subtract(const Duration(days: 90)),
      'endDate': DateTime.now().add(const Duration(days: 120)),
      'budget': 25000.00,
      'spent': 12780.50,
      'status': 'active',
      'client': 'XYZ Financial',
      'teamMembers': [
        {
          'id': 'user-001',
          'name': 'John Smith',
          'role': 'Project Manager',
          'avatar': 'https://randomuser.me/api/portraits/men/1.jpg',
        },
        {
          'id': 'user-002',
          'name': 'Sarah Johnson',
          'role': 'Designer',
          'avatar': 'https://randomuser.me/api/portraits/women/2.jpg',
        },
        {
          'id': 'user-003',
          'name': 'Michael Wong',
          'role': 'Developer',
          'avatar': 'https://randomuser.me/api/portraits/men/3.jpg',
        },
        {
          'id': 'user-004',
          'name': 'Lisa Chen',
          'role': 'QA Engineer',
          'avatar': 'https://randomuser.me/api/portraits/women/4.jpg',
        },
      ],
      'expenseSummary': [
        {'category': 'Travel', 'amount': 3450.75},
        {'category': 'Accommodation', 'amount': 4200.00},
        {'category': 'Meals', 'amount': 1830.50},
        {'category': 'Equipment', 'amount': 2650.00},
        {'category': 'Office', 'amount': 650.25},
      ],
    },
    {
      'id': 'proj-002',
      'name': 'Project B',
      'description': 'E-commerce platform redesign and feature enhancements',
      'startDate': DateTime.now().subtract(const Duration(days: 45)),
      'endDate': DateTime.now().add(const Duration(days: 90)),
      'budget': 18000.00,
      'spent': 8250.75,
      'status': 'active',
      'client': 'Retail Solutions Inc.',
      'teamMembers': [
        {
          'id': 'user-001',
          'name': 'John Smith',
          'role': 'Project Manager',
          'avatar': 'https://randomuser.me/api/portraits/men/1.jpg',
        },
        {
          'id': 'user-005',
          'name': 'Emma Davis',
          'role': 'UX Designer',
          'avatar': 'https://randomuser.me/api/portraits/women/5.jpg',
        },
        {
          'id': 'user-006',
          'name': 'James Wilson',
          'role': 'Backend Developer',
          'avatar': 'https://randomuser.me/api/portraits/men/6.jpg',
        },
      ],
      'expenseSummary': [
        {'category': 'Transportation', 'amount': 1250.00},
        {'category': 'Accommodation', 'amount': 3200.00},
        {'category': 'Meals', 'amount': 1575.50},
        {'category': 'Software', 'amount': 2225.25},
      ],
    },
    {
      'id': 'proj-003',
      'name': 'Project C',
      'description': 'Healthcare management system for rural clinics',
      'startDate': DateTime.now().subtract(const Duration(days: 180)),
      'endDate': DateTime.now().add(const Duration(days: 30)),
      'budget': 35000.00,
      'spent': 28750.60,
      'status': 'active',
      'client': 'Health Connect Foundation',
      'teamMembers': [
        {
          'id': 'user-001',
          'name': 'John Smith',
          'role': 'Project Manager',
          'avatar': 'https://randomuser.me/api/portraits/men/1.jpg',
        },
        {
          'id': 'user-007',
          'name': 'Robert Lee',
          'role': 'Systems Architect',
          'avatar': 'https://randomuser.me/api/portraits/men/7.jpg',
        },
        {
          'id': 'user-008',
          'name': 'Rachel Green',
          'role': 'UI Developer',
          'avatar': 'https://randomuser.me/api/portraits/women/8.jpg',
        },
        {
          'id': 'user-009',
          'name': 'Thomas Brown',
          'role': 'Database Engineer',
          'avatar': 'https://randomuser.me/api/portraits/men/9.jpg',
        },
        {
          'id': 'user-010',
          'name': 'Jennifer Lopez',
          'role': 'QA Lead',
          'avatar': 'https://randomuser.me/api/portraits/women/10.jpg',
        },
      ],
      'expenseSummary': [
        {'category': 'Travel', 'amount': 7450.75},
        {'category': 'Accommodation', 'amount': 8200.00},
        {'category': 'Meals', 'amount': 3830.50},
        {'category': 'Equipment', 'amount': 6250.00},
        {'category': 'Training', 'amount': 3020.35},
      ],
    },
    {
      'id': 'proj-004',
      'name': 'AI Chatbot',
      'description': 'Developing an AI-powered customer service chatbot for enterprise clients',
      'startDate': DateTime.now().subtract(const Duration(days: 30)),
      'endDate': DateTime.now().add(const Duration(days: 180)),
      'budget': 42000.00,
      'spent': 12450.25,
      'status': 'active',
      'client': 'TechForward Solutions',
      'teamMembers': [
        {
          'id': 'user-012',
          'name': 'David Miller',
          'role': 'AI Specialist',
          'avatar': 'https://randomuser.me/api/portraits/men/12.jpg',
        },
        {
          'id': 'user-013',
          'name': 'Sophia Chen',
          'role': 'Full Stack Developer',
          'avatar': 'https://randomuser.me/api/portraits/women/13.jpg',
        },
        {
          'id': 'user-014',
          'name': 'Raj Patel',
          'role': 'DevOps Engineer',
          'avatar': 'https://randomuser.me/api/portraits/men/14.jpg',
        },
        {
          'id': 'user-015',
          'name': 'Olivia Wang',
          'role': 'UX Researcher',
          'avatar': 'https://randomuser.me/api/portraits/women/15.jpg',
        },
      ],
      'expenseSummary': [
        {'category': 'Cloud Services', 'amount': 4350.75},
        {'category': 'Equipment', 'amount': 3200.00},
        {'category': 'Software Licenses', 'amount': 2750.50},
        {'category': 'Training', 'amount': 1650.00},
        {'category': 'Travel', 'amount': 500.00},
      ],
    },
    {
      'id': 'proj-005',
      'name': 'Smart City Initiative',
      'description': 'IoT and data analytics solution for urban infrastructure management',
      'startDate': DateTime.now().subtract(const Duration(days: 60)),
      'endDate': DateTime.now().add(const Duration(days: 305)),
      'budget': 85000.00,
      'spent': 23450.60,
      'status': 'active',
      'client': 'Metropolis City Council',
      'teamMembers': [
        {
          'id': 'user-016',
          'name': 'Karen Johnson',
          'role': 'Project Director',
          'avatar': 'https://randomuser.me/api/portraits/women/16.jpg',
        },
        {
          'id': 'user-017',
          'name': 'Marcus Thompson',
          'role': 'IoT Specialist',
          'avatar': 'https://randomuser.me/api/portraits/men/17.jpg',
        },
        {
          'id': 'user-018',
          'name': 'Laura Martinez',
          'role': 'Data Scientist',
          'avatar': 'https://randomuser.me/api/portraits/women/18.jpg',
        },
        {
          'id': 'user-019',
          'name': 'Chris Wilson',
          'role': 'Backend Developer',
          'avatar': 'https://randomuser.me/api/portraits/men/19.jpg',
        },
        {
          'id': 'user-020',
          'name': 'Aisha Khan',
          'role': 'UI/UX Designer',
          'avatar': 'https://randomuser.me/api/portraits/women/20.jpg',
        },
      ],
      'expenseSummary': [
        {'category': 'Hardware', 'amount': 8750.75},
        {'category': 'Travel', 'amount': 5200.00},
        {'category': 'Consultancy', 'amount': 4830.50},
        {'category': 'Software', 'amount': 3250.00},
        {'category': 'Testing Equipment', 'amount': 1420.35},
      ],
    },
    {
      'id': 'proj-006',
      'name': 'Financial App Redesign',
      'description': 'Complete UI/UX overhaul and feature enhancement for banking application',
      'startDate': DateTime.now().subtract(const Duration(days: 15)),
      'endDate': DateTime.now().add(const Duration(days: 75)),
      'budget': 28000.00,
      'spent': 6830.25,
      'status': 'active',
      'client': 'GlobalBank Financial',
      'teamMembers': [
        {
          'id': 'user-021',
          'name': 'Helen Park',
          'role': 'Lead Designer',
          'avatar': 'https://randomuser.me/api/portraits/women/21.jpg',
        },
        {
          'id': 'user-022',
          'name': 'Jason Rodriguez',
          'role': 'Frontend Developer',
          'avatar': 'https://randomuser.me/api/portraits/men/22.jpg',
        },
        {
          'id': 'user-023',
          'name': 'Zoe Williams',
          'role': 'Interaction Designer',
          'avatar': 'https://randomuser.me/api/portraits/women/23.jpg',
        },
      ],
      'expenseSummary': [
        {'category': 'Design Tools', 'amount': 2350.75},
        {'category': 'Usability Testing', 'amount': 3100.00},
        {'category': 'Team Workshops', 'amount': 1380.50},
      ],
    },
    {
      'id': 'proj-007',
      'name': 'Supply Chain Optimization',
      'description': 'Implementing blockchain and AI solutions for logistics management',
      'startDate': DateTime.now().subtract(const Duration(days: 120)),
      'endDate': DateTime.now().add(const Duration(days: 150)),
      'budget': 65000.00,
      'spent': 38750.80,
      'status': 'active',
      'client': 'Global Logistics Corp',
      'teamMembers': [
        {
          'id': 'user-024',
          'name': 'Daniel Kim',
          'role': 'Blockchain Specialist',
          'avatar': 'https://randomuser.me/api/portraits/men/24.jpg',
        },
        {
          'id': 'user-025',
          'name': 'Priya Sharma',
          'role': 'Supply Chain Analyst',
          'avatar': 'https://randomuser.me/api/portraits/women/25.jpg',
        },
        {
          'id': 'user-026',
          'name': 'Alex Turner',
          'role': 'Backend Developer',
          'avatar': 'https://randomuser.me/api/portraits/men/26.jpg',
        },
        {
          'id': 'user-027',
          'name': 'Natalie Green',
          'role': 'Product Manager',
          'avatar': 'https://randomuser.me/api/portraits/women/27.jpg',
        },
      ],
      'expenseSummary': [
        {'category': 'Travel', 'amount': 9750.75},
        {'category': 'Software Development', 'amount': 12200.00},
        {'category': 'Hardware', 'amount': 7830.50},
        {'category': 'Consultancy', 'amount': 8970.55},
      ],
    },
  ];

  Map<String, bool> _expandedProjects = {};

  @override
  void initState() {
    super.initState();
    // Initialize all projects as collapsed
    for (var project in _projects) {
      _expandedProjects[project['id']] = false;
    }
  }

  void _toggleProjectExpanded(String projectId) {
    setState(() {
      _expandedProjects[projectId] = !(_expandedProjects[projectId] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search coming soon')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _projects.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _projects.length,
                  itemBuilder: (context, index) {
                    final project = _projects[index];
                    final isExpanded = _expandedProjects[project['id']] ?? false;
                    return _buildProjectCard(project);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.work_outline,
            size: 72,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No projects assigned yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Projects will appear here once assigned to you',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String status = project['status'] ?? 'Active';
    final double budget = (project['budget'] as num).toDouble();
    final double spent = (project['spent'] as num).toDouble();
    final double percentage = budget > 0 ? (spent / budget * 100).clamp(0, 100) : 0;
    final bool isOverBudget = spent > budget;
    
    // Determine colors based on percentage
    List<Color> gradientColors;
    if (percentage < 50) {
      gradientColors = [Color(0xFF42CD85), Color(0xFF00C6B3)]; // Green
    } else if (percentage < 80) {
      gradientColors = [Color(0xFFFF9D54), Color(0xFFFF7D54)]; // Orange
    } else {
      gradientColors = [Color(0xFFFF5454), Color(0xFFFF3D7F)]; // Red
    }
    
    return GradientCard(
      useGradientBorder: true,
      borderColors: gradientColors,
      isPrimary: false,
      borderWidth: 1.5,
      borderRadius: 16,
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
          // Project header with title and status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
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
                      Icons.folder_special_rounded,
                      size: 20,
                      color: gradientColors[0],
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                          project['name'],
                    style: TextStyle(
                      fontSize: 20,
                            fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                ],
                      ),
                      Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                  color: status.toLowerCase() == 'active' 
                      ? Colors.green.withOpacity(0.1) 
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: status.toLowerCase() == 'active' 
                        ? Colors.green.withOpacity(0.5) 
                        : Colors.grey.withOpacity(0.5),
                    width: 1,
                  ),
                        ),
                        child: Text(
                  status,
                          style: TextStyle(
                    color: status.toLowerCase() == 'active' 
                        ? Colors.green 
                        : Colors.grey,
                            fontWeight: FontWeight.bold,
                    fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
          
          SizedBox(height: 12),
          
          // Project description
                  Text(
                    project['description'],
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white70 : Colors.black87.withOpacity(0.7),
            ),
          ),
          
          SizedBox(height: 12),
          
          // Client and timeline info
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                Row(
                  children: [
                    Icon(
                      Icons.business_rounded,
                      size: 16,
                      color: isDark ? Colors.white60 : Colors.grey[700],
                    ),
                    SizedBox(width: 8),
                            Text(
                              'Client: ${project['client']}',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey[800],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.date_range_rounded,
                      size: 16,
                      color: isDark ? Colors.white60 : Colors.grey[700],
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Timeline: ${DateFormat('MMM d, yyyy').format(project['startDate'])} - ${DateFormat('MMM d, yyyy').format(project['endDate'])}',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.grey[800],
                          fontSize: 14,
                        ),
                      ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          
          SizedBox(height: 20),
          
          // Budget information
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                'Budget: \$${budget.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                Text(
                'Spent: \$${spent.toStringAsFixed(2)}',
                                  style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isOverBudget 
                      ? Colors.red 
                      : (isDark ? Colors.white : Colors.black87),
                                  ),
                                ),
                              ],
                            ),
          
          SizedBox(height: 8),
          
          // Progress bar with percentage
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                            ClipRRect(
                borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                    percentage < 50
                        ? Colors.green
                        : (percentage < 80 ? Colors.orange : Colors.red),
                                ),
                                minHeight: 8,
                              ),
                            ),
              SizedBox(height: 4),
                            Text(
                '${percentage.toStringAsFixed(1)}% of budget used',
                              style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                                fontSize: 12,
                  fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
          
          SizedBox(height: 12),
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionButton(
                icon: Icons.analytics_rounded,
                label: 'Details',
                onTap: () {
                  _showProjectDetails(project);
                },
                gradientColors: [Color(0xFF4A6FFF), Color(0xFF7A54FF)],
              ),
              SizedBox(width: 12),
              _buildActionButton(
                icon: Icons.edit_rounded,
                label: 'Edit',
                onTap: () {
                  // Edit project
                },
                gradientColors: [Color(0xFF00C6B3), Color(0xFF00E5A3)],
                      ),
                    ],
                  ),
                ],
              ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required List<Color> gradientColors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.3),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.white,
            ),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showProjectDetails(Map<String, dynamic> project) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String status = project['status'] ?? 'Active';
    final double budget = (project['budget'] as num).toDouble();
    final double spent = (project['spent'] as num).toDouble();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF1A1A2E) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar for bottom sheet
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 12),
                  height: 5,
                  width: 40,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              
              // Project header
            Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF4A6FFF), Color(0xFF7A54FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.folder_special_rounded,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                          Text(
                            project['name'],
                    style: TextStyle(
                              fontSize: 22,
                      fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            project['client'],
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Project details section
                      _buildDetailSection(
                        title: "Project Overview",
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project['description'],
                    style: TextStyle(
                                fontSize: 15,
                                color: isDark ? Colors.white70 : Colors.black87.withOpacity(0.7),
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 16),
                            _buildInfoRow(
                              icon: Icons.date_range_rounded,
                              title: "Timeline",
                              value: "${DateFormat('MMM d, yyyy').format(project['startDate'])} - ${DateFormat('MMM d, yyyy').format(project['endDate'])}",
                            ),
                            SizedBox(height: 10),
                            _buildInfoRow(
                              icon: Icons.account_balance_wallet_rounded,
                              title: "Budget",
                              value: "\$${budget.toStringAsFixed(2)}",
                            ),
                            SizedBox(height: 10),
                            _buildInfoRow(
                              icon: Icons.payments_rounded,
                              title: "Spent",
                              value: "\$${spent.toStringAsFixed(2)}",
                              valueColor: spent > budget ? Colors.red : null,
                            ),
                            SizedBox(height: 10),
                            _buildInfoRow(
                              icon: Icons.pie_chart_rounded,
                              title: "Utilization",
                              value: "${((spent/budget) * 100).toStringAsFixed(1)}%",
                            ),
                          ],
                        ),
                      ),
                      
                      // Team members section
                      _buildDetailSection(
                        title: "Team Members",
                        child: Column(
                          children: [
                            for (var member in project['teamMembers'])
                              _buildTeamMemberItem(member),
                          ],
                        ),
                      ),
                      
                      // Expense breakdown section
                      _buildDetailSection(
                        title: "Expense Breakdown",
                        child: Column(
                          children: [
                            // Expense summary in pie chart or bar
                            Container(
                              height: 200,
                              margin: EdgeInsets.only(bottom: 20),
                              child: _buildExpenseChart(project['expenseSummary']),
                            ),
                            
                            // Detailed expense list with fixed height and scrolling
                            Container(
                              height: 200, // Fixed height to prevent overflow
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    for (var expense in project['expenseSummary'])
                                      _buildExpenseItem(
                                        category: expense['category'],
                                        amount: (expense['amount'] as num).toDouble(),
                                        percentage: (expense['amount'] as num).toDouble() / spent * 100,
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
                ),
              ),
              
              // Bottom actions
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Color(0xFF1A1A2E).withOpacity(0.9) : Colors.white.withOpacity(0.9),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBottomAction(
                      icon: Icons.assignment_rounded,
                      label: "Generate Report",
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Generate project report
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Report generation coming soon")),
                        );
                      },
                    ),
                    _buildBottomAction(
                      icon: Icons.show_chart_rounded,
                      label: "View Analytics",
                      onTap: () {
                        Navigator.pop(context);
                        // Show analytics dialog
                        _showProjectAnalytics(project);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildDetailSection({required String title, required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Divider(
            color: isDark ? Colors.white24 : Colors.black12,
            height: 24,
          ),
          child,
        ],
      ),
    );
  }
  
  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        SizedBox(width: 12),
        Text(
          title + ":",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: valueColor ?? (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTeamMemberItem(Map<String, dynamic> member) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(member['avatar']),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    member['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                    member['role'],
                    style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.message_outlined,
              color: isDark ? Colors.white70 : Colors.black54,
              size: 20,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Messaging coming soon")),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseChart(List<dynamic> expenses) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Create data for bar chart
    List<Map<String, dynamic>> chartData = [];
    for (var expense in expenses) {
      chartData.add({
        'category': expense['category'],
        'amount': expense['amount'],
      });
    }
    
    // Sort by amount (highest first)
    chartData.sort((a, b) => (b['amount'] as num).compareTo(a['amount'] as num));
    
    // Simplified bar chart representation
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var data in chartData)
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data['category'],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    Text(
                      '\$${(data['amount'] as num).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                // Create a bar representing the value
                LinearProgressIndicator(
                  value: 1.0, // Full width always
                  backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(_getCategoryColor(data['category'])),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
      ],
    );
  }
  
  Color _getCategoryColor(String category) {
    // Return different colors based on category
    switch (category.toLowerCase()) {
      case 'travel':
        return Color(0xFF4A6FFF);
      case 'accommodation':
        return Color(0xFF00C6B3); 
      case 'meals':
        return Color(0xFFFF9D54);
      case 'equipment':
        return Color(0xFF7A54FF);
      case 'office':
        return Color(0xFF54C7FC);
      case 'transportation':
        return Color(0xFFFF5454);
      case 'hardware':
        return Color(0xFF00E5A3);
      case 'software':
        return Color(0xFFFF3D7F);
      case 'cloud services':
        return Color(0xFF54FBFC);
      case 'consultancy':
        return Color(0xFFE554FF);
      case 'training':
        return Color(0xFFFFD954);
      default:
        return Color(0xFF888888);
    }
  }
  
  Widget _buildExpenseItem({
    required String category,
    required double amount,
    required double percentage,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getCategoryColor(category),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              category,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A6FFF), Color(0xFF7A54FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF4A6FFF).withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
      child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showProjectAnalytics(Map<String, dynamic> project) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double budget = (project['budget'] as num).toDouble();
    final double spent = (project['spent'] as num).toDouble();
    final double percentage = budget > 0 ? (spent / budget * 100).clamp(0, 100) : 0;
    
    // Calculate project duration in days
    final startDate = project['startDate'] as DateTime;
    final endDate = project['endDate'] as DateTime;
    final projectDuration = endDate.difference(startDate).inDays;
    final daysElapsed = DateTime.now().difference(startDate).inDays;
    final daysRemaining = endDate.difference(DateTime.now()).inDays;
    final completionPercentage = (daysElapsed / projectDuration * 100).clamp(0, 100);
    
    // Get expense data for charts
    final expenseSummary = project['expenseSummary'] as List<dynamic>;
    
    // Calculate monthly spending (mock data for demonstration)
    final monthlySpending = [
      {'month': 'Jan', 'amount': spent * 0.15},
      {'month': 'Feb', 'amount': spent * 0.20},
      {'month': 'Mar', 'amount': spent * 0.25},
      {'month': 'Apr', 'amount': spent * 0.18},
      {'month': 'May', 'amount': spent * 0.22},
    ];
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF1A1A2E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4A6FFF), Color(0xFF7A54FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.analytics_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Project Analytics",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            project['name'],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              // Analytics content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Key metrics
                      Row(
                        children: [
                          _buildMetricCard(
                            icon: Icons.calendar_today_rounded,
                            title: "Time Elapsed",
                            value: "${completionPercentage.toStringAsFixed(1)}%",
                            subtitle: "$daysElapsed of $projectDuration days",
                            gradient: [Color(0xFF4A6FFF), Color(0xFF7A54FF)],
                            flex: 1,
                          ),
                          SizedBox(width: 12),
                          _buildMetricCard(
                            icon: Icons.account_balance_wallet_rounded,
                            title: "Budget Used",
                            value: "${percentage.toStringAsFixed(1)}%",
                            subtitle: "\$${spent.toStringAsFixed(0)} of \$${budget.toStringAsFixed(0)}",
                            gradient: [Color(0xFF00C6B3), Color(0xFF00E5A3)],
                            flex: 1,
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Budget Burndown Chart
                      _buildAnalyticsSection(
                        title: "Budget Burndown",
                        child: Container(
                          height: 200,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _buildBudgetBurndownChart(budget, spent, completionPercentage.toDouble()),
                        ),
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Expense Categories
                      _buildAnalyticsSection(
                        title: "Expense Categories",
                        child: Container(
                          height: 250,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _buildExpensePieChart(expenseSummary),
                        ),
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Monthly Spending Trend
                      _buildAnalyticsSection(
                        title: "Monthly Spending Trend",
                        child: Container(
                          height: 200,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _buildMonthlySpendingChart(monthlySpending),
                        ),
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Remaining Budget Forecast
                      _buildAnalyticsSection(
                        title: "Budget Forecast",
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Based on current spending rate:",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                              ),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildForecastItem(
                                    title: "Current daily rate",
                                    value: "\$${(spent / daysElapsed).toStringAsFixed(2)}/day",
                                    icon: Icons.show_chart_rounded,
                                    color: Color(0xFF4A6FFF),
                                  ),
                                  _buildForecastItem(
                                    title: "Projected final cost",
                                    value: "\$${(spent / daysElapsed * projectDuration).toStringAsFixed(2)}",
                                    icon: Icons.assessment_rounded,
                                    color: Color(0xFFFF9D54),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Divider(
                                color: isDark ? Colors.white24 : Colors.black12,
                              ),
                              SizedBox(height: 12),
                              Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
                                    "Project status:",
            style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.white70 : Colors.black54,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: (spent / daysElapsed * projectDuration) > budget 
                                          ? Colors.red.withOpacity(0.1) 
                                          : Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: (spent / daysElapsed * projectDuration) > budget 
                                            ? Colors.red.withOpacity(0.5) 
                                            : Colors.green.withOpacity(0.5),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      (spent / daysElapsed * projectDuration) > budget
                                          ? "Over Budget"
                                          : "Within Budget",
                                      style: TextStyle(
                                        color: (spent / daysElapsed * projectDuration) > budget
                                            ? Colors.red
                                            : Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Bottom actions
              Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: isDark ? Color(0xFF1A1A2E).withOpacity(0.9) : Colors.white.withOpacity(0.9),
                  border: Border(
                    top: BorderSide(
                      color: isDark ? Colors.white24 : Colors.black12,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Exporting analytics data...")),
                        );
                      },
                      icon: Icon(Icons.download_rounded, size: 18),
                      label: Text("Export"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? Colors.white70 : Colors.black54,
                        side: BorderSide(
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Sharing analytics dashboard...")),
                        );
                      },
                      icon: Icon(Icons.share_rounded, size: 18),
                      label: Text("Share"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color(0xFF4A6FFF),
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
  
  Widget _buildAnalyticsSection({required String title, required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Text(
          title,
            style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 10),
        child,
      ],
    );
  }
  
  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required List<Color> gradient,
    required int flex,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      flex: flex,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              gradient[0].withOpacity(0.15),
              gradient[1].withOpacity(0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: gradient[0].withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: gradient[0],
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white60 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: color,
            ),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white60 : Colors.black45,
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
  
  Widget _buildBudgetBurndownChart(double budget, double spent, double completionPercentage) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Ideal burn line points (simplified for demonstration)
    List<Map<String, dynamic>> idealBurnData = [
      {'x': 0, 'y': budget},
      {'x': 100, 'y': 0},
    ];
    
    // Actual burn line points (simplified for demonstration)
    List<Map<String, dynamic>> actualBurnData = [
      {'x': 0, 'y': budget},
      {'x': completionPercentage, 'y': budget - spent},
    ];
    
    // Simplified chart representation
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomPaint(
            size: Size.infinite,
            painter: BurndownChartPainter(
              idealBurnData: idealBurnData,
              actualBurnData: actualBurnData,
              maxBudget: budget,
              isDark: isDark,
            ),
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildChartLegendItem(
              color: Color(0xFF00C6B3),
              label: "Ideal Burn",
            ),
            SizedBox(width: 20),
            _buildChartLegendItem(
              color: Color(0xFF4A6FFF),
              label: "Actual Burn",
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildChartLegendItem({required Color color, required String label}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 12,
          height: 3,
          color: color,
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white60 : Colors.black45,
          ),
        ),
      ],
    );
  }
  
  Widget _buildExpensePieChart(List<dynamic> expenses) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Sort expenses by amount (largest first)
    expenses.sort((a, b) => (b['amount'] as num).compareTo(a['amount'] as num));
    
    // Take top 5 expenses for the chart
    List<dynamic> topExpenses = expenses.length > 5 
        ? expenses.sublist(0, 5) 
        : expenses;
    
    // Calculate total for percentage
    double totalAmount = 0;
    for (var expense in expenses) {
      totalAmount += (expense['amount'] as num).toDouble();
    }
    
    // Calculate percentages
    List<double> percentages = [];
    for (var expense in topExpenses) {
      percentages.add((expense['amount'] as num).toDouble() / totalAmount * 100);
    }
    
    return Row(
      children: [
        // Pie chart
        Container(
          width: 150,
          height: 150,
          child: CustomPaint(
            painter: PieChartPainter(
              percentages: percentages,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "\$${totalAmount.toStringAsFixed(0)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    "Total Spent",
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white60 : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 20),
        
        // Legend
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < topExpenses.length; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getCategoryColor(topExpenses[i]['category']),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          topExpenses[i]['category'],
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        "${percentages[i].toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildMonthlySpendingChart(List<Map<String, dynamic>> data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Find max value
    double maxAmount = 0;
    for (var item in data) {
      if ((item['amount'] as double) > maxAmount) {
        maxAmount = item['amount'] as double;
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Y-axis labels
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "\$${maxAmount.toStringAsFixed(0)}",
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                  Text(
                    "\$${(maxAmount / 2).toStringAsFixed(0)}",
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                  Text(
                    "\$0",
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 8),
              
              // Bar chart
        Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var item in data)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 30,
                            height: (item['amount'] as double) / maxAmount * 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFF4A6FFF), Color(0xFF7A54FF)],
                              ),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            item['month'],
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.white60 : Colors.black54,
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
        SizedBox(height: 10),
      ],
    );
  }
}

class BurndownChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> idealBurnData;
  final List<Map<String, dynamic>> actualBurnData;
  final double maxBudget;
  final bool isDark;

  BurndownChartPainter({
    required this.idealBurnData,
    required this.actualBurnData,
    required this.maxBudget,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = isDark ? Colors.white24 : Colors.black12
      ..strokeWidth = 1;
    
    // Draw axes
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), axisPaint); // X-axis
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), axisPaint); // Y-axis
    
    // Draw ideal burn line
    final idealPaint = Paint()
      ..color = Color(0xFF00C6B3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final idealPath = Path();
    idealPath.moveTo(
      0,
      0,
    );
    idealPath.lineTo(
      size.width,
      size.height,
    );
    canvas.drawPath(idealPath, idealPaint);
    
    // Draw actual burn line
    final actualPaint = Paint()
      ..color = Color(0xFF4A6FFF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final actualPath = Path();
    actualPath.moveTo(
      0,
      0,
    );
    actualPath.lineTo(
      actualBurnData[1]['x'] / 100 * size.width,
      (maxBudget - actualBurnData[1]['y']) / maxBudget * size.height,
    );
    canvas.drawPath(actualPath, actualPaint);
    
    // Draw point at the end of actual line
    canvas.drawCircle(
      Offset(
        actualBurnData[1]['x'] / 100 * size.width,
        (maxBudget - actualBurnData[1]['y']) / maxBudget * size.height,
      ),
      5,
      Paint()..color = Color(0xFF4A6FFF),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class PieChartPainter extends CustomPainter {
  final List<double> percentages;
  
  PieChartPainter({required this.percentages});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.8; // 80% of half width
    
    double startAngle = -90 * (3.14159 / 180); // Start from top (in radians)
    
    // Colors for pie slices
    final colors = [
      Color(0xFF4A6FFF),
      Color(0xFF00C6B3),
      Color(0xFFFF9D54),
      Color(0xFF7A54FF),
      Color(0xFFFF5454),
    ];
    
    // Draw each slice
    for (int i = 0; i < percentages.length; i++) {
      final sweepAngle = percentages[i] / 100 * 2 * 3.14159; // Convert to radians
      
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = colors[i % colors.length];
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      
      startAngle += sweepAngle;
    }
    
    // Draw white center for donut effect
    final centerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    
    canvas.drawCircle(
      center,
      radius * 0.6, // 60% of radius for inner circle
      centerPaint,
    );
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
} 