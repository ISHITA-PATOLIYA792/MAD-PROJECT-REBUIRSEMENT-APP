import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reimbursement_box/screens/splash_screen.dart';
import 'package:reimbursement_box/screens/onboarding_screen.dart';
import 'package:reimbursement_box/screens/auth_screen.dart';
import 'package:reimbursement_box/screens/home_screen.dart';
import 'package:reimbursement_box/screens/dashboard_screen.dart';
import 'package:reimbursement_box/screens/add_expense_screen.dart';
import 'package:reimbursement_box/screens/my_expenses_screen.dart';
import 'package:reimbursement_box/screens/expense_details_screen.dart';
import 'package:reimbursement_box/screens/edit_expense_screen.dart';
import 'package:reimbursement_box/screens/my_projects_screen.dart';
import 'package:reimbursement_box/screens/my_compensation_screen.dart';
import 'package:reimbursement_box/pages/expense_action_page.dart';
import 'package:reimbursement_box/models/expense.dart';

// add theme toggle notifier
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

// light theme primary gradient
final LinearGradient lightPrimaryGradient = LinearGradient(
  colors: [Color(0xFF4A6FFF), Color(0xFF7A54FF)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// dark theme primary gradient
final LinearGradient darkPrimaryGradient = LinearGradient(
  colors: [Color(0xFF2A3F8A), Color(0xFF6649B8)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// light theme secondary gradient
final LinearGradient lightSecondaryGradient = LinearGradient(
  colors: [Color(0xFF00C6B3), Color(0xFF00E5A3)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// dark theme secondary gradient
final LinearGradient darkSecondaryGradient = LinearGradient(
  colors: [Color(0xFF009B8A), Color(0xFF00BF87)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
    
    if (dotenv.env['SUPABASE_URL'] == null || 
        dotenv.env['SUPABASE_ANON_KEY'] == null) {
      throw Exception('SUPABASE_URL and SUPABASE_ANON_KEY must be defined in .env file');
    }
    
    // Fix for web authentication redirect
    final String redirectUrl = kIsWeb 
        ? 'http://localhost:3000/'  // For web debugging
        : 'io.supabase.reimbursementbox://login-callback/'; // For mobile
    
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
      debug: kDebugMode,
    );
    
    if (kDebugMode) {
      print('Supabase initialized successfully');
      
      // Check if we can query the expenses table
      try {
        final client = Supabase.instance.client;
        await client.from('expenses').select('id').limit(1);
        print('Database tables exist and are accessible');
      } catch (e) {
        print('WARNING: Database tables might not be properly set up: $e');
        print('You may need to create the required tables in your Supabase project.');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Failed to initialize app: $e');
    }
    // Continue to run the app, but services will fail
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // listen to theme changes
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'Reimburse Desk',
          themeMode: currentMode,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4A6FFF),
              primary: const Color(0xFF4A6FFF),
              secondary: const Color(0xFF00C6B3),
              tertiary: const Color(0xFFFF7D54),
              brightness: Brightness.light,
            ),
            cardTheme: CardTheme(
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              surfaceTintColor: Colors.white,
              color: Colors.white,
              shadowColor: Colors.black.withOpacity(0.05),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4A6FFF), width: 2.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A6FFF),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                shadowColor: const Color(0xFF4A6FFF).withOpacity(0.4),
              ),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF4A6FFF),
              elevation: 0,
              centerTitle: true,
              iconTheme: const IconThemeData(color: Color(0xFF4A6FFF)),
              titleTextStyle: const TextStyle(
                color: Color(0xFF2C2C2C),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: const Color(0xFF00C6B3),
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              extendedPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            textTheme: TextTheme(
              titleLarge: TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.bold, letterSpacing: 0.3),
              titleMedium: TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.w600),
              bodyLarge: TextStyle(color: Color(0xFF1A1A2E)),
              bodyMedium: TextStyle(color: Color(0xFF1A1A2E)),
            ),
            iconTheme: const IconThemeData(
              color: Color(0xFF4A6FFF),
            ),
            dividerTheme: const DividerThemeData(
              color: Color(0xFFEEEEEE),
              thickness: 1,
            ),
            tabBarTheme: TabBarTheme(
              labelColor: Color(0xFF4A6FFF),
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: Color(0xFF4A6FFF),
              indicatorSize: TabBarIndicatorSize.label,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF7A54FF),
              primary: const Color(0xFF7A54FF),
              secondary: const Color(0xFF00E5A3),
              tertiary: const Color(0xFFFF7D54),
              brightness: Brightness.dark,
              surface: const Color(0xFF1A1A2E),
              background: const Color(0xFF0F0F1A),
            ),
            cardTheme: CardTheme(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: const Color(0xFF252542),
              shadowColor: Colors.black.withOpacity(0.5),
            ),
            scaffoldBackgroundColor: const Color(0xFF0F0F1A),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade800),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF7A54FF), width: 2.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade800),
              ),
              filled: true,
              fillColor: const Color(0xFF252542),
              hintStyle: TextStyle(color: Colors.grey.shade500),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A54FF),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                shadowColor: const Color(0xFF7A54FF).withOpacity(0.4),
              ),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: const Color(0xFF1A1A2E),
              foregroundColor: const Color(0xFF7A54FF),
              elevation: 0,
              centerTitle: true,
              iconTheme: const IconThemeData(color: Color(0xFF7A54FF)),
              titleTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: const Color(0xFF00E5A3),
              foregroundColor: Colors.black87,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              extendedPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            textTheme: const TextTheme(
              titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.3),
              titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              bodyLarge: TextStyle(color: Color(0xFFE2E2E8)),
              bodyMedium: TextStyle(color: Color(0xFFE2E2E8)),
            ),
            iconTheme: const IconThemeData(
              color: Color(0xFF7A54FF),
            ),
            dividerTheme: const DividerThemeData(
              color: Color(0xFF35354A),
              thickness: 1,
            ),
            tabBarTheme: TabBarTheme(
              labelColor: Color(0xFF7A54FF),
              unselectedLabelColor: Colors.grey.shade400,
              indicatorColor: Color(0xFF7A54FF),
              indicatorSize: TabBarIndicatorSize.label,
            ),
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/onboarding': (context) => const OnboardingScreen(),
            '/auth': (context) => const AuthScreen(),
            '/home': (context) => const HomeScreen(),
            '/dashboard': (context) => const DashboardScreen(),
            '/add_expense': (context) => const AddExpenseScreen(),
            '/my_expenses': (context) => const MyExpensesScreen(),
            '/expense_details': (context) {
              final expense = ModalRoute.of(context)!.settings.arguments as Expense;
              return ExpenseDetailsScreen(expense: expense);
            },
            '/edit_expense': (context) {
              final expense = ModalRoute.of(context)!.settings.arguments as Expense;
              return EditExpenseScreen(expense: expense);
            },
            '/my_projects': (context) => const MyProjectsScreen(),
            '/my_compensation': (context) => const MyCompensationScreen(),
            '/expense_action': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
              return ExpenseActionPage(
                action: args['action']!,
                expenseId: args['expense_id']!,
                trackingId: args['tracking_id']!,
                token: args['token']!,
              );
            },
          },
        );
      },
    );
  }
}
