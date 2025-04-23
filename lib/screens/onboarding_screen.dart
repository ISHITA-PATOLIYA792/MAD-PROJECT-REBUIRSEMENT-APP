import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _pages = [
    OnboardingItem(
      image: 'assets/images/track_receipts.jpg',
      title: 'Track Receipts',
      description: 'Easily scan and store all your receipts in one place',
    ),
    OnboardingItem(
      image: 'assets/images/manage_expenses.jpg',
      title: 'Manage Expenses',
      description: 'Organize and categorize your expenses effortlessly',
    ),
    OnboardingItem(
      image: 'assets/images/corporate_cards.png',
      title: 'Corporate Cards',
      description: 'Manage and track corporate card expenses seamlessly',
    ),
    OnboardingItem(
      image: 'assets/images/reimburse_employees.jpg',
      title: 'Reimburse Employees',
      description: 'Quick and easy employee reimbursement process',
    ),
    OnboardingItem(
      image: 'assets/images/send_invoices.jpg',
      title: 'Send Invoices',
      description: 'Create and send professional invoices instantly',
    ),
    OnboardingItem(
      image: 'assets/images/pay_bills.jpg',
      title: 'Pay Bills',
      description: 'Handle bill payments directly through the app',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _pages[index];
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentPage > 0)
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        )
                      else
                        const SizedBox(width: 48),
                      if (_currentPage == _pages.length - 1)
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, '/auth');
                              },
                              child: const Text('Sign Up'),
                            ),
                            const SizedBox(width: 16),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, '/auth');
                              },
                              child: const Text('Sign In'),
                            ),
                          ],
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingItem extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const OnboardingItem({
    Key? key,
    required this.image,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            image,
            height: 240,
          ),
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
} 