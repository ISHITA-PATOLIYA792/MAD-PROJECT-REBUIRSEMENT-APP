import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:async';

// Add imports for gradient elements
import 'package:reimbursement_box/widgets/gradient_card.dart';
import 'package:reimbursement_box/main.dart';

// Add these at the top of the class to define gradients
final List<Color> primaryGradient = [Color(0xFF9067C6), Color(0xFF8557D0)];
final List<Color> secondaryGradient = [Color(0xFF4A6FFF), Color(0xFF7A54FF)];
final List<Color> tertiaryGradient = [Color(0xFF00C6B3), Color(0xFF00E5A3)];

class MyCompensationScreen extends StatefulWidget {
  const MyCompensationScreen({Key? key}) : super(key: key);

  @override
  State<MyCompensationScreen> createState() => _MyCompensationScreenState();
}

class _MyCompensationScreenState extends State<MyCompensationScreen> {
  final supabase = Supabase.instance.client;
  bool _isLoading = false;

  // Mock data (would be fetched from Supabase in a real app)
  final Map<String, dynamic> _compensationData = {
    'salary': {
      'basic': 5500.00,
      'hra': 2200.00,
      'conveyance': 800.00,
      'medical': 1250.00,
      'special': 1800.00,
      'performance': 2500.00,
      'total': 14050.00,
    },
    'benefits': {
      'stockOptions': {
        'granted': 1000,
        'vested': 250,
        'unvested': 750,
        'grantPrice': 25.50,
        'currentPrice': 42.75,
        'nextVestingDate': DateTime.now().add(const Duration(days: 90)),
      },
      'leaveEncashment': {
        'available': 12,
        'rate': 500.00,
        'eligible': true,
      },
      'otherBenefits': [
        {
          'name': 'Health Insurance',
          'description': 'Comprehensive coverage for you and family',
          'value': '₹500,000 coverage',
        },
        {
          'name': 'Retirement Plan',
          'description': '401k with 5% company match',
          'value': '5% matching',
        },
        {
          'name': 'Learning & Development',
          'description': 'Annual budget for courses and certifications',
          'value': '₹50,000/year',
        },
      ],
    },
    'documents': {
      'paySlips': [
        {
          'month': 'September 2023',
          'date': '30-09-2023',
          'amount': 14050.00,
          'url': 'https://example.com/payslips/sep2023.pdf',
        },
        {
          'month': 'August 2023',
          'date': '31-08-2023',
          'amount': 14050.00,
          'url': 'https://example.com/payslips/aug2023.pdf',
        },
        {
          'month': 'July 2023',
          'date': '31-07-2023',
          'amount': 13500.00,
          'url': 'https://example.com/payslips/jul2023.pdf',
        },
        {
          'month': 'June 2023',
          'date': '30-06-2023',
          'amount': 13500.00,
          'url': 'https://example.com/payslips/jun2023.pdf',
        },
      ],
      'taxDocuments': [
        {
          'name': 'Form 16 (2022-23)',
          'description': 'Annual Tax Statement',
          'date': '31-05-2023',
          'url': 'https://example.com/tax/form16_2022_23.pdf',
        },
        {
          'name': 'Form 12BA (2022-23)',
          'description': 'Perquisites Statement',
          'date': '31-05-2023',
          'url': 'https://example.com/tax/form12ba_2022_23.pdf',
        },
        {
          'name': 'Investment Proof Submission',
          'description': 'Tax saving investments',
          'date': '15-01-2023',
          'url': 'https://example.com/tax/investment_proofs_2022_23.pdf',
        },
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Compensation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Monthly compensation summary
                  _buildHeaderCard(),
                  const SizedBox(height: 24),
                  
                  // Direct Compensation Section
                  _buildSectionTitle('Direct Compensation'),
                  _buildDirectCompensationTab(),
                  const SizedBox(height: 24),
                  
                  // Indirect Compensation Section
                  _buildSectionTitle('Indirect Compensation'),
                  _buildIndirectCompensationTabs(),
                  const SizedBox(height: 24),
                  
                  // Salary breakdown section
                  _buildSectionTitle('Salary Breakdown'),
                  _buildSalaryBreakdownCard(),
                  const SizedBox(height: 24),
                  
                  // Benefits section
                  _buildSectionTitle('Benefits'),
                  _buildStockOptionsCard(),
                  const SizedBox(height: 16),
                  _buildLeaveEncashmentCard(),
                  const SizedBox(height: 16),
                  _buildOtherBenefitsCard(),
                  const SizedBox(height: 24),
                  
                  // Documents section
                  _buildSectionTitle('Documents'),
                  _buildDocumentsCard(),
                  const SizedBox(height: 24),

                  // Compensation history section
                  _buildCompensationHistoryCard(),
                  // Add bottom padding to avoid any overflow
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            height: 24,
            width: 6,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: primaryGradient,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Text(
        title,
            style: TextStyle(
              fontSize: 20,
          fontWeight: FontWeight.bold,
              foreground: Paint()
                ..shader = LinearGradient(
                  colors: [Colors.deepPurple, Colors.purple.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(Rect.fromLTWH(0, 0, 200, 24)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isDark ? Colors.purple.withOpacity(0.6) : Colors.deepPurple.withOpacity(0.6),
                    isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Replace the header card with this gradient version
  Widget _buildHeaderCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GradientCard(
      gradientColors: primaryGradient,
      useGradientBorder: true,
      borderColors: [Colors.white.withOpacity(0.4), Colors.white.withOpacity(0.2)],
      borderWidth: 2.0,
      borderRadius: 20,
      boxShadow: [
        BoxShadow(
          color: primaryGradient[0].withOpacity(0.5),
          blurRadius: 15,
          offset: Offset(0, 8),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
              'Monthly Compensation',
              style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                fontWeight: FontWeight.w500,
                        ),
              ),
            ),
            const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
            Text(
                          '₹${NumberFormat('#,##,###').format(_compensationData['salary']['total'])}',
              style: const TextStyle(
                            color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.arrow_upward,
                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '4.1%',
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
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.update,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                            'Last Updated',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '22 Apr 2025',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                ),
                const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
            ),
          ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildHeaderStatItem(
                  title: 'CTC',
                  value: '₹${NumberFormat('#,##,###').format(_compensationData['salary']['total'] * 12)}',
                  icon: Icons.account_balance_wallet,
                ),
                Container(
                  height: 30,
                  width: 1,
                  color: Colors.white.withOpacity(0.2),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                _buildHeaderStatItem(
                  title: 'In-Hand',
                  value: '₹${NumberFormat('#,##,###').format((_compensationData['salary']['total'] * 0.85).round())}',
                  icon: Icons.payments,
                ),
                Container(
                  height: 30,
                  width: 1,
                  color: Colors.white.withOpacity(0.2),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                _buildHeaderStatItem(
                  title: 'Deductions',
                  value: '₹${NumberFormat('#,##,###').format((_compensationData['salary']['total'] * 0.15).round())}',
                  icon: Icons.savings,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for header card stats
  Widget _buildHeaderStatItem({required String title, required String value, required IconData icon}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryBreakdownCard() {
    final salaryComponents = [
      {
        'title': 'Base Salary',
        'amount': '\$75,000',
        'percentage': 68,
        'color': Colors.blue,
      },
      {
        'title': 'Bonus',
        'amount': '\$12,500',
        'percentage': 11,
        'color': Colors.green,
      },
      {
        'title': 'Allowances',
        'amount': '\$8,000',
        'percentage': 7,
        'color': Colors.purple,
      },
      {
        'title': 'Benefits',
        'amount': '\$15,500',
        'percentage': 14,
        'color': Colors.orange,
      },
    ];
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Salary Breakdown',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Total Annual Compensation: \$111,000',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            ...salaryComponents.map((component) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (component['color'] as Color).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: (component['color'] as Color).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: component['color'] as Color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
          Text(
                                  component['title'] as String,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
          ),
          Text(
                              component['amount'] as String,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
            ),
          ),
        ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: (component['percentage'] as int) / 100,
                          backgroundColor:
                              Theme.of(context).colorScheme.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              component['color'] as Color),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${component['percentage']}%',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                // Add functionality to view detailed breakdown
              },
              icon: const Icon(Icons.analytics),
              label: const Text('View Detailed Breakdown'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockOptionsCard() {
    final stockOptions = _compensationData['benefits']['stockOptions'];
    final currentValue = stockOptions['vested'] * stockOptions['currentPrice'];
    final unvestedValue = stockOptions['unvested'] * stockOptions['currentPrice'];
    final potentialGain = (stockOptions['currentPrice'] - stockOptions['grantPrice']) * stockOptions['granted'];
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Stock Options',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Your equity compensation',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            
            // Stock summary
            Row(
              children: [
                Expanded(
                  child: _buildStockInfoItem(
                    'Total Granted',
                    stockOptions['granted'].toString(),
                    'options',
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStockInfoItem(
                    'Vested',
                    stockOptions['vested'].toString(),
                    'options',
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStockInfoItem(
                    'Unvested',
                    stockOptions['unvested'].toString(),
                    'options',
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Value summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Price:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '\$${stockOptions['currentPrice'].toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
            const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Grant Price:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '\$${stockOptions['grantPrice'].toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Vested Value:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '\$${currentValue.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                      ),
                    ],
                  ),
            const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Unvested Value:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '\$${unvestedValue.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
            const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Potential Gain:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '\$${potentialGain.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Next vesting date
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Vesting Date',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        DateFormat('MMMM d, yyyy').format(stockOptions['nextVestingDate']),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // View details button
            OutlinedButton.icon(
              onPressed: () {
                // Add functionality to view stock details
              },
              icon: const Icon(Icons.show_chart),
              label: const Text('View Vesting Schedule'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockInfoItem(
    String title,
    String value,
    String subtitle,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value,
          style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
          ),
        ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildCompensationDistribution() {
    final pieChartData = [0.40, 0.25, 0.15, 0.20]; // Salary, Bonus, Benefits, Stock
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pie_chart,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Total Compensation',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Breakdown of your total compensation package',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            
            // Pie chart
            SizedBox(
              height: 200,
              child: Row(
              children: [
                Expanded(
                    flex: 2,
                    child: CustomPaint(
                      size: const Size(200, 200),
                      painter: PieChartPainter(
                        percentages: pieChartData,
                        colors: [
                          Colors.blue,
                          Colors.green,
                          Colors.orange,
                          Colors.purple,
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        _buildLegendItem('Base Salary', '40%', Colors.blue),
                        const SizedBox(height: 12),
                        _buildLegendItem('Bonuses', '25%', Colors.green),
                        const SizedBox(height: 12),
                        _buildLegendItem('Benefits', '15%', Colors.orange),
                        const SizedBox(height: 12),
                        _buildLegendItem('Stock Options', '20%', Colors.purple),
                    ],
                  ),
                ),
              ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Total value
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Total Annual Value',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$111,000',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String title, String percentage, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
      decoration: BoxDecoration(
            color: color,
        shape: BoxShape.circle,
      ),
        ),
        const SizedBox(width: 8),
        Expanded(
        child: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          percentage,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildDirectCompensationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Salary breakdown section
          _buildSalaryBreakdownCard(),
          const SizedBox(height: 24),

          // Total compensation section
          _buildCompensationDistribution(),
          const SizedBox(height: 24),

          // Bonus and incentives section
          _buildBonusSection(),
          const SizedBox(height: 24),

          // Retirement benefits section
          _buildRetirementBenefitsCard(),
          const SizedBox(height: 24),

          // Leave encashment section
          _buildLeaveEncashmentCard(),
          const SizedBox(height: 24),

          // Other benefits section
          _buildOtherBenefitsCard(),
          const SizedBox(height: 24),

          // Documents section
          _buildDocumentsCard(),
          const SizedBox(height: 24),

          // Compensation history section
          _buildCompensationHistoryCard(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCompensationHistoryCard() {
    final historyItems = [
      {
        'event': 'Annual Salary Increase',
        'date': 'January 1, 2023',
        'change': '+5.2%',
        'isPositive': true,
      },
      {
        'event': 'Performance Bonus',
        'date': 'December 15, 2022',
        'change': '\$3,500',
        'isPositive': true,
      },
      {
        'event': 'Promotion',
        'date': 'July 1, 2022',
        'change': '+8.5%',
        'isPositive': true,
      },
      {
        'event': 'Benefit Plan Change',
        'date': 'January 1, 2022',
        'change': 'Updated',
        'isPositive': null,
      },
    ];
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Compensation History',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Your compensation changes over time',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ...historyItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.only(top: 4, right: 12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: item['isPositive'] == null
                              ? Colors.grey
                              : (item['isPositive'] as bool)
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                  item['event'] as String,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                                  item['change'] as String,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: item['isPositive'] == null
                                            ? Colors.grey
                                            : (item['isPositive'] as bool)
                                                ? Colors.green
                                                : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['date'] as String,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // Add functionality to view full history
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                padding: EdgeInsets.zero,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View full history',
                              style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  // Help dialog showing compensation information
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.help_outline,
              color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
            const Text('Compensation Help'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpSection(
                'Base Salary',
                'Your annual base pay before taxes and other deductions.',
              ),
              const Divider(),
              _buildHelpSection(
                'Bonuses',
                'Additional compensation including performance bonuses, sign-on bonuses, and other incentives.',
              ),
              const Divider(),
              _buildHelpSection(
                'Stock Options',
                'Equity compensation that gives you the right to purchase company stock at a predetermined price.',
              ),
              const Divider(),
              _buildHelpSection(
                'Benefits',
                'Non-cash compensation including health insurance, retirement plans, and other perks.',
              ),
              const Divider(),
              _buildHelpSection(
                'Total Compensation',
                'The combined value of all compensation elements including salary, bonuses, equity, and benefits.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Open detailed compensation guide
            },
            child: const Text('View Detailed Guide'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(String title, String description) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  // Build the tabs for indirect compensation
  Widget _buildIndirectCompensationTabs() {
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(text: 'Protection'),
              Tab(text: 'Time Off'),
              Tab(text: 'Perks'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 500, // Increased height to make content visible
            child: TabBarView(
              children: [
                // Protection tab
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        _buildProtectionItem(
                          'Health Insurance',
                          'Comprehensive medical coverage for you and your family',
                          Icons.health_and_safety,
                          Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        _buildProtectionItem(
                          'Life Insurance',
                          'Coverage of 3x your annual salary',
                          Icons.shield,
                          Colors.purple,
                        ),
                        const SizedBox(height: 16),
                        _buildProtectionItem(
                          'Disability Insurance',
                          'Short and long-term disability coverage',
                          Icons.accessibility_new,
                          Colors.green,
                        ),
                        const SizedBox(height: 16),
                        _buildProtectionItem(
                          'Dental & Vision',
                          'Complete dental and vision care benefits',
                          Icons.visibility,
                          Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Time Off tab
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        _buildTimeOffItem(
                          'Paid Time Off',
                          '20 days per year, accrued monthly',
                          Icons.beach_access,
                          Colors.blue,
                          '15 days remaining',
                        ),
                        const SizedBox(height: 16),
                        _buildTimeOffItem(
                          'Sick Leave',
                          '10 days per year for illness and medical appointments',
                          Icons.medical_services,
                          Colors.red,
                          '8 days remaining',
                        ),
                        const SizedBox(height: 16),
                        _buildTimeOffItem(
                          'Parental Leave',
                          '12 weeks of paid leave for new parents',
                          Icons.family_restroom,
                          Colors.green,
                          'Eligible when needed',
                        ),
                        const SizedBox(height: 16),
                        _buildTimeOffItem(
                          'Holidays',
                          '11 paid company holidays per year',
                          Icons.celebration,
                          Colors.purple,
                          '8 holidays remaining this year',
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Perks tab
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        _buildPerkItem(
                          'Flexible Work',
                          'Work from home options and flexible hours',
                          Icons.home_work,
                          Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        _buildPerkItem(
                          'Learning Budget',
                          '\$1,000 annual allowance for professional development',
                          Icons.school,
                          Colors.purple,
                        ),
                        const SizedBox(height: 16),
                        _buildPerkItem(
                          'Wellness Program',
                          'Gym memberships and wellness activities',
                          Icons.fitness_center,
                          Colors.green,
                        ),
                        const SizedBox(height: 16),
                        _buildPerkItem(
                          'Employee Discounts',
                          'Special offers from partner companies',
                          Icons.loyalty,
                          Colors.orange,
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

  Widget _buildProtectionItem(String title, String description, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      // View details
                    },
                    child: const Text('View Details'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeOffItem(String title, String description, IconData icon, Color color, String status) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                        status,
                              style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // View history
                    },
                    child: const Text('View History'),
                        ),
                      ),
                      const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Request time off
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                    ),
                    child: const Text('Request'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerkItem(String title, String description, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                      Container(
              padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      // Learn more
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Learn more',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: color,
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
    );
  }

  Widget _buildLeaveEncashmentCard() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Leave Encashment',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Convert your unused leaves to cash',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
                      Container(
              padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available for encashment:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '12 days',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Estimated value:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '\$2,400',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Add functionality for Leave Encashment
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Encash Leaves'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherBenefitsCard() {
    final benefits = [
      {
        'icon': Icons.home,
        'title': 'Housing Allowance',
        'description': '\$500/month housing subsidy',
      },
      {
        'icon': Icons.directions_bus,
        'title': 'Transport Allowance',
        'description': '\$200/month for commuting',
      },
      {
        'icon': Icons.school,
        'title': 'Education Benefit',
        'description': 'Up to \$2,000/year for courses',
      },
      {
        'icon': Icons.sports_tennis,
        'title': 'Wellness Program',
        'description': 'Gym membership & wellness activities',
      },
    ];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.card_giftcard,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Other Benefits',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Additional perks and allowances',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ...benefits.map((benefit) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          benefit['icon'] as IconData,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              benefit['title'] as String,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                            const SizedBox(height: 2),
                            Text(
                              benefit['description'] as String,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // Add functionality to view all benefits
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                padding: EdgeInsets.zero,
              ),
              child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        Text(
                    'View all benefits',
                    style: TextStyle(
                            fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsCard() {
    final documents = [
      {
        'title': 'Salary Statement',
        'date': 'Aug 2023',
        'icon': Icons.description,
      },
      {
        'title': 'Bonus Letter',
        'date': 'Jul 2023',
        'icon': Icons.emoji_events,
      },
      {
        'title': 'Tax Documents',
        'date': 'Apr 2023',
        'icon': Icons.account_balance,
      },
      {
        'title': 'Benefits Guide',
        'date': 'Jan 2023',
        'icon': Icons.health_and_safety,
      },
    ];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.folder,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Documents',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      ),
                    ],
                  ),
            const SizedBox(height: 12),
            Text(
              'Access your compensation related documents',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ...documents.map((document) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        document['icon'] as IconData,
                        size: 24,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      document['title'] as String,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    subtitle: Text(
                      document['date'] as String,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.download,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        // Add download functionality
                      },
                    ),
                    onTap: () {
                      // Add view document functionality
                    },
                  ),
                )),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // Add functionality to view all documents
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                padding: EdgeInsets.zero,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View all documents',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBonusSection() {
    final bonusData = [
      {
        'title': 'Performance Bonus',
        'status': 'Achieved',
        'amount': '\$7,500',
        'date': 'Dec 2023',
        'progress': 1.0,
      },
      {
        'title': 'Quarterly Incentive',
        'status': 'On Track',
        'amount': '\$2,500',
        'date': 'Sep 2023',
        'progress': 0.75,
      },
      {
        'title': 'Referral Bonus',
        'status': 'Pending',
        'amount': '\$1,000',
        'date': 'TBD',
        'progress': 0.5,
      },
      {
        'title': 'Project Completion',
        'status': 'Not Started',
        'amount': '\$1,500',
        'date': 'TBD',
        'progress': 0.0,
      },
    ];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Bonus & Incentives',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Your additional earning opportunities',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ...bonusData.map((bonus) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
                            bonus['title'] as String,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
            ),
          ),
          Text(
                            bonus['amount'] as String,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Expected: ${bonus['date']}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getStatusColor(bonus['status'] as String)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              bonus['status'] as String,
            style: TextStyle(
                                fontSize: 11,
                                color: _getStatusColor(bonus['status'] as String),
                                fontWeight: FontWeight.bold,
                              ),
            ),
          ),
        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: bonus['progress'] as double,
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            _getStatusColor(bonus['status'] as String)),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                // Add functionality to view bonus details
              },
              icon: const Icon(Icons.visibility),
              label: const Text('View Bonus Plan Details'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Achieved':
        return Colors.green;
      case 'On Track':
        return Colors.blue;
      case 'Pending':
        return Colors.orange;
      case 'Not Started':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildRetirementBenefitsCard() {
    final retirementData = {
      'companyContribution': 4500.0,
      'employeeContribution': 6000.0,
      'totalBalance': 52500.0,
      'projectedRetirement': 825000.0,
      'contributionPercentage': 6.0,
      'matchPercentage': 4.5,
    };

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.savings,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Retirement Benefits',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                ),
                ),
              ],
            ),
            const SizedBox(height: 12),
                Text(
              'Your 401(k) and retirement savings',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            
            // Total balance section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                Text(
                    'Current Balance',
                    style: Theme.of(context).textTheme.bodyMedium,
                ),
                  const SizedBox(height: 8),
                Text(
                    '\$${retirementData['totalBalance']!.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Projected at Retirement: \$${NumberFormat('#,###').format(retirementData['projectedRetirement'])}',
                    style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
            const SizedBox(height: 24),
            
            // Contributions section
            Row(
              children: [
                Expanded(
                  child: _buildRetirementInfoItem(
                    'Your Contribution',
                    '\$${retirementData['employeeContribution']!.toStringAsFixed(2)}',
                    '${retirementData['contributionPercentage']!.toStringAsFixed(1)}% of salary',
                    Icons.person,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildRetirementInfoItem(
                    'Company Match',
                    '\$${retirementData['companyContribution']!.toStringAsFixed(2)}',
                    '${retirementData['matchPercentage']!.toStringAsFixed(1)}% of salary',
                    Icons.business,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Current allocation chart
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Allocation',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildAllocationItem('Stocks', 65, Colors.blue),
                    _buildAllocationItem('Bonds', 25, Colors.green),
                    _buildAllocationItem('Cash', 10, Colors.amber),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
              onPressed: () {
                      // Add functionality to view retirement plan details
                    },
                    icon: const Icon(Icons.description),
                    label: const Text('Plan Details'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Add functionality to adjust contributions
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Adjust'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRetirementInfoItem(
    String title,
    String amount,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildAllocationItem(String title, int percentage, Color color) {
    return Expanded(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 60,
                width: 60,
                child: CircularProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeWidth: 8,
                ),
              ),
              Text(
                '$percentage%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<double> percentages;
  final List<Color> colors;

  PieChartPainter({
    required this.percentages,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    // Start at the top (negative y-axis)
    double startAngle = -math.pi / 2;
    
    for (int i = 0; i < percentages.length; i++) {
      final sweepAngle = 2 * math.pi * percentages[i];
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = colors[i];
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      
      startAngle += sweepAngle;
    }
    
    // Draw a white circle in the middle for a donut chart effect
    final centerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    
    canvas.drawCircle(
      center,
      radius * 0.5, // Inner circle radius (adjust as needed)
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
} 