# Reimburse Desk

A comprehensive, modern expense reimbursement management system built with Flutter and Supabase.

## Table of Contents

1. [Project Definition](#project-definition)
2. [Problem Statement](#problem-statement)
3. [Solution Overview](#solution-overview)
   - [Brief Explanation](#brief-explanation)
   - [Key Features](#key-features)
   - [Approach](#approach)
   - [Uniqueness](#uniqueness)
   - [Frameworks/Technologies](#frameworkstechnologies)
   - [Tech Stack](#tech-stack)
4. [Authentication Features](#authentication-features)
5. [Setup Instructions](#setup-instructions)
6. [UI/UX Design](#uiux-design)
   - [Dashboard UI Mockup](#dashboard-ui-mockup)
   - [Screens Overview](#screens-overview)
   - [User Flow](#user-flow)
   - [Design Highlights](#design-highlights)
7. [Use Case](#use-case)
8. [System Architecture](#system-architecture)
9. [Coding Approach](#coding-approach)
   - [Component System](#component-system)
   - [Border System](#border-system)
   - [Theme System](#theme-system)
10. [Dependencies](#dependencies)
11. [Troubleshooting](#troubleshooting)
12. [Additional Resources](#additional-resources)

## Project Definition

Reimburse Desk is a comprehensive enterprise expense management system designed to streamline the process of submitting, tracking, and approving business expenses. The application provides an intuitive interface for employees to submit expense claims with receipt documentation, while offering managers and finance teams powerful tools for review, analysis, and processing of reimbursements.

## Problem Statement

Traditional expense reimbursement processes face several challenges:

1. **Time-consuming manual workflows**: Paper-based or basic digital solutions require significant manual data entry.
2. **Lack of transparency**: Employees often have no visibility into the status of their reimbursement requests.
3. **Complex approval chains**: Multi-level approvals can delay reimbursements and frustrate employees.
4. **Receipt management**: Physical receipts can be lost, while digital receipts are often scattered across email and various platforms.
5. **Limited data analytics**: Finance teams lack tools to analyze spending patterns and enforce policy compliance.
6. **Integration challenges**: Many solutions don't integrate well with existing enterprise systems (accounting, HR, etc.).

## Solution Overview

### Brief Explanation

Reimburse Desk addresses these challenges with a mobile-first, cloud-based solution that offers a seamless experience for employees, managers, and finance teams. The application streamlines the entire expense management lifecycle from submission to payment, leveraging modern technologies for enhanced efficiency, transparency, and user experience.

### Key Features

- **Intuitive expense submission**: Simple interface for submitting expenses with receipt capture
- **Real-time status tracking**: Employees can monitor their reimbursement status at every stage
- **Smart categorization**: Automatic categorization of expenses based on receipt data
- **Multi-level approval workflow**: Configurable approval chains with notifications
- **Comprehensive dashboard**: Detailed analytics and reports for finance teams
- **Receipt management**: Digital storage and organization of all receipts
- **Multiple project support**: Track expenses across different projects or departments
- **Compensation management**: View salary, benefits, and total compensation information
- **Dark/Light theme**: Fully customizable UI with theme support

### Approach

Our approach focuses on user experience while maintaining enterprise-grade security and compliance:

1. **User-centered design**: Built with the needs of all stakeholders in mind
2. **Mobile-first**: Designed for on-the-go expense management
3. **Offline capabilities**: Core functions work without constant internet connection
4. **Scalable architecture**: Cloud-based backend that can scale with organization size
5. **Security-focused**: Encrypted data transmission and storage
6. **Integration-ready**: APIs for connecting with accounting and HR systems

### Uniqueness

Reimburse Desk differentiates itself through:

- **Comprehensive compensation view**: Unlike most expense tools, our app includes total compensation tracking
- **Advanced analytics**: Powerful reporting for both users and finance teams
- **Modern UI/UX**: Beautiful, intuitive interface with customizable themes
- **Component-based architecture**: Highly maintainable and extensible codebase
- **Receipt intelligence**: ML-powered receipt parsing and categorization
- **Cross-platform support**: Consistent experience across devices

### Frameworks/Technologies

- **Flutter**: Cross-platform UI toolkit for building natively compiled applications
- **Supabase**: Open source Firebase alternative with PostgreSQL database
- **Flutter Dotenv**: Environment configuration management
- **Gradient Borders**: Custom UI elements for modern visual design

### Tech Stack

**Frontend:**
- Flutter/Dart
- Material Design 3
- Custom UI component system

**Backend:**
- Supabase (PostgreSQL)
- Authentication services
- Storage for receipts and documents

**Infrastructure:**
- Cloud-based hosting
- RESTful API architecture
- WebSocket for real-time updates

## Authentication Features

- Email/Password authentication
- Google Sign-In integration
- GitHub Sign-In integration
- Password reset functionality
- Persistent login sessions
- User profile management
- Role-based authorization (Admin, Manager, Employee)

## Setup Instructions

### Prerequisites

- Flutter SDK (stable channel)
- A Supabase account
- Google Developer account (for Google Sign-In)
- GitHub Developer account (for GitHub Sign-In)

### Step 1: Clone the repository

```bash
git clone <repository-url>
cd reimbursement_box
```

### Step 2: Set up Supabase

1. Create a new project on [Supabase](https://supabase.com/).
2. Once your project is created, go to the SQL Editor in the Supabase dashboard.
3. Execute the following SQL to set up the database schema:

```sql
-- Create users table (handled by Supabase Auth)

-- Create profiles table
CREATE TABLE profiles (
  id UUID REFERENCES auth.users NOT NULL PRIMARY KEY,
  email TEXT NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  employee_id TEXT,
  department TEXT,
  role TEXT DEFAULT 'employee',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create expenses table
CREATE TABLE expenses (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  amount DECIMAL(10, 2) NOT NULL,
  receipt_url TEXT,
  category TEXT NOT NULL,
  expense_date DATE NOT NULL,
  status TEXT DEFAULT 'pending',
  project_id INTEGER REFERENCES projects(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create projects table
CREATE TABLE projects (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  start_date DATE,
  end_date DATE,
  budget DECIMAL(12, 2),
  current_spend DECIMAL(12, 2) DEFAULT 0,
  client TEXT,
  status TEXT DEFAULT 'active',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create project_members table for team members
CREATE TABLE project_members (
  id SERIAL PRIMARY KEY,
  project_id INTEGER REFERENCES projects(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users,
  role TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Set up RLS (Row Level Security)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_members ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own profile" 
ON profiles FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" 
ON profiles FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can view their own expenses" 
ON expenses FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own expenses" 
ON expenses FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own expenses" 
ON expenses FOR UPDATE USING (auth.uid() = user_id AND status = 'pending');

-- Managers can see all expenses
CREATE POLICY "Managers can view all expenses"
ON expenses FOR SELECT USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('manager', 'admin'))
);

-- Set up triggers
CREATE OR REPLACE FUNCTION handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, email, full_name, avatar_url)
  VALUES (new.id, new.email, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'avatar_url');
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE handle_new_user();
```

### Step 3: Configure Authentication Providers

#### Email Provider
1. In your Supabase dashboard, navigate to Authentication > Providers > Email.
2. Ensure the Email provider is enabled.
3. Configure settings for email confirmation if desired.

#### Google Provider
1. Navigate to Authentication > Providers > Google.
2. Enable the Google provider.
3. Follow the instructions to set up Google OAuth credentials.
4. Add your app's redirect URL (typically: io.supabase.reimbursementbox://login-callback/).
5. Copy your Google client ID and client secret to Supabase.

#### GitHub Provider
1. Navigate to Authentication > Providers > GitHub.
2. Enable the GitHub provider.
3. Register a new OAuth application on [GitHub](https://github.com/settings/developers).
4. Set the Authorization callback URL to your Supabase redirect URL.
5. Copy your GitHub client ID and client secret to Supabase.

### Step 4: Environment Setup

1. Create a .env file in the root of your project.
2. Add the following variables with your Supabase details:

```
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_REDIRECT_URL=io.supabase.reimbursementbox://login-callback/
```

### Step 5: Update Android Configuration

For Android, update the android/app/src/main/AndroidManifest.xml file to include:

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="io.supabase.reimbursementbox"
        android:host="login-callback" />
</intent-filter>
```

### Step 6: Update iOS Configuration

For iOS, update the ios/Runner/Info.plist file to include:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>io.supabase.reimbursementbox</string>
        </array>
    </dict>
</array>
```

### Step 7: Run the app

```bash
flutter pub get
flutter run
```

## UI/UX Design

### Dashboard UI Mockup

```
+--------------------------------------------------+
|                                                  |
| Reimburse Desk                        🌙  👤    |
|                                                  |
| +----------------------------------------------+ |
| |                                              | |
| | Welcome back,                                | |
| | John Smith                                   | |
| |                                              | |
| | Your expense summary for July 2023           | |
| |                                              | |
| +----------------------------------------------+ |
|                                                  |
| +----------------------------------------------+ |
| |                                              | |
| | 📊 Expense Status                            | |
| |                                              | |
| | $3,420.75                $1,250.00  $850.50  | |
| | +----------+  +----------+  +----------+     | |
| | |Pending   |  |Approved  |  |Rejected  |     | |
| | |    3     |  |    5     |  |    1     |     | |
| | +----------+  +----------+  +----------+     | |
| |                                              | |
| | [View all expenses]                          | |
| |                                              | |
| +----------------------------------------------+ |
|                                                  |
| My Projects                                      |
|                                                  |
| +----------------+  +----------------+           |
| |                |  |                |           |
| | 🏢             |  | 🌐             |           |
| | CRM Upgrade    |  | Website Redesign           |
| |                |  |                |           |
| | Budget: $25K   |  | Budget: $15K   |           |
| | Spent: $18.5K  |  | Spent: $12.7K  |           |
| | Members: 6     |  | Members: 4     |           |
| |                |  |                |           |
| +----------------+  +----------------+           |
|                                                  |
| Quick Actions                                    |
|                                                  |
| +----------------+  +----------------+           |
| |                |  |                |           |
| | 📸             |  | 📊             |           |
| | Add Expense    |  | Reports        |           |
| |                |  |                |           |
| | Submit a new   |  | View expense   |           |
| | expense with   |  | reports and    |           |
| | receipt        |  | analytics      |           |
| |                |  |                |           |
| +----------------+  +----------------+           |
|                                                  |
| +----------------+  +----------------+           |
| |                |  |                |           |
| | 💼             |  | 💰             |           |
| | My Projects    |  | Compensation   |           |
| |                |  |                |           |
| | Manage your    |  | View your      |           |
| | active         |  | salary and     |           |
| | projects       |  | benefits       |           |
| |                |  |                |           |
| +----------------+  +----------------+           |
|                                                  |
+--------------------------------------------------+
```

### Screens Overview

1. **Splash/Onboarding Screens**
   - App introduction and user onboarding flow
   - Authentication (Login/Register)

2. **Dashboard Screen**
   - Overview of expenses, statistics, and activities
   - Quick access to common actions
   - Profile summary and navigation

3. **Expense Management**
   - Add Expense screen with receipt capture
   - My Expenses list with filtering options
   - Expense Detail view with approval status
   - Edit Expense functionality

4. **Project Management**
   - My Projects screen showing assigned projects
   - Project details with expense allocation
   - Project statistics and team information

5. **Compensation Screen**
   - Salary information and compensation breakdown
   - Benefits visualization including leave encashment
   - Perks and indirect compensation details

### User Flow

1. **Authentication Flow**
   - User opens app → Splash screen → Login/Register → Dashboard

2. **Expense Submission Flow**
   - Dashboard → Add Expense → Fill details → Capture receipt → Submit → View in My Expenses

3. **Expense Approval Flow**
   - Manager receives notification → Reviews expense → Approves/Rejects → Employee notified

4. **Compensation Review Flow**
   - Dashboard → My Compensation → View breakdown → Access benefits details

### Design Highlights

1. **Clean Interface**: Minimalist design with proper spacing and visual hierarchy
2. **Card-Based Layout**: Organized content in cards with consistent styling
3. **Visual Progress Tracking**: Clear progress indicators and statistics
4. **Modern Color Scheme**: Pleasant color palette with light/dark mode support
5. **Descriptive Cards**: Feature cards with icons and descriptions
6. **Gradient Borders**: Custom border system for a distinctive visual identity
7. **Responsive Design**: Adapts to different screen sizes and orientations

## Use Case

**Employee Use Case:**

1. Sarah, a sales representative, incurs expenses during a client meeting.
2. She opens the Reimburse Desk app and taps "Add Expense".
3. She takes a photo of the receipt, which automatically fills most expense details.
4. She selects the appropriate project and expense category, then submits.
5. The app notifies her manager of the pending approval.
6. Sarah can track the status of her reimbursement in real-time.
7. Once approved, she receives a notification and can see the expected payment date.

**Manager Use Case:**

1. Alex, a team manager, receives notifications about pending expense approvals.
2. He opens the app and views detailed information about each expense.
3. He can review receipt images, check policy compliance, and expense history.
4. Alex approves valid expenses or rejects with comments if necessary.
5. He can view department spending analytics and budget utilization.

**Finance Team Use Case:**

1. The finance department uses the web dashboard to process approved expenses.
2. They can export data for accounting systems integration.
3. They generate reports on spending patterns and policy compliance.
4. They manage reimbursement schedules and payment processing.

## System Architecture

Reimburse Desk follows a client-server architecture with the following components:

1. **Client Application (Flutter)**
   - UI Layer: Material Design components and custom widgets
   - State Management: Provider pattern for app state
   - Service Layer: API clients and local data management
   - Utility Layer: Helper functions and shared code

2. **Backend Services (Supabase)**
   - Authentication Service: User management and access control
   - Database: PostgreSQL for structured data storage
   - Storage Service: File storage for receipts and documents
   - Realtime Service: WebSocket connections for live updates

3. **External Integrations**
   - Accounting Systems: Data export/import capabilities
   - Payment Processing: Integration with payment providers
   - HR Systems: Employee data synchronization

4. **Security Infrastructure**
   - Encrypted data transmission (HTTPS/SSL)
   - Secure authentication with token management
   - Role-based access control
   - Data backup and recovery mechanisms

## Coding Approach

Reimburse Desk is built using a component-based architecture that emphasizes:

1. **Separation of Concerns**: Clear distinction between UI, business logic, and data access
2. **Reusable Components**: Custom widget library for consistent UI
3. **Consistent Styling**: Centralized theme and style management
4. **Testability**: Structured for effective unit and integration testing
5. **Maintainability**: Clean code practices and comprehensive documentation

### Component System

Our application uses a comprehensive component system with reusable widgets:

- **GradientCard**: Flexible card component with gradient border options
- **GradientButton**: Customizable button with gradient backgrounds
- **BorderedContainer**: Container with configurable borders and shadows
- **BorderedInput**: Text input fields with consistent styling
- **ShimmerLoading**: Loading state indicators with animation
- **AnimatedThemeToggle**: Interactive theme switching component

### Border System

A unified border system provides consistent visual boundaries throughout the app:

- **BorderStyles**: Utility class with standardized border styles
- **Border Parameters**: Configurable width, color, and radius
- **Theme Awareness**: Automatically adapts to light/dark themes
- **Gradient Borders**: Support for gradient-colored borders

### Theme System

The application features a comprehensive theming system:

- **Light/Dark Mode**: Full support for both theme modes
- **Dynamic Theme Switching**: Runtime theme changes without app restart
- **Consistent Color Palette**: Predefined color schemes for both modes
- **Gradient Library**: Standard gradients for primary and secondary elements
- **Material 3 Support**: Leverages latest Material Design guidelines

## Dependencies

- **flutter**: ^3.10.0
- **cupertino_icons**: ^1.0.5
- **supabase_flutter**: ^1.10.4
- **flutter_dotenv**: ^5.0.2
- **provider**: ^6.0.5
- **shared_preferences**: ^2.1.1
- **http**: ^1.1.0
- **path**: ^1.8.3
- **path_provider**: ^2.0.15
- **image_picker**: ^0.8.7+5
- **url_launcher**: ^6.1.11
- **intl**: ^0.18.1
- **lottie**: ^2.3.2
- **fl_chart**: ^0.62.0
- **pdf**: ^3.10.1
- **sqflite**: ^2.2.8+4

## Troubleshooting

- **Authentication Issues**: 
  - Verify redirect URLs match exactly in Supabase and app configurations
  - Check Supabase logs for authentication errors
  - Ensure proper permissions in database RLS policies

- **Database Connection Issues**:
  - Confirm API keys are correctly set in .env file
  - Check internet connectivity
  - Verify Supabase service status

- **Image Upload Issues**:
  - Check storage permissions in Supabase
  - Verify file size limits
  - Ensure proper error handling for upload failures

- **Build Issues**:
  - Run `flutter clean` followed by `flutter pub get`
  - Check for dependency conflicts in pubspec.yaml
  - Update Flutter SDK if necessary

## Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Flutter Documentation](https://flutter.dev/docs)
- [Supabase Flutter SDK](https://supabase.com/docs/reference/dart/introduction)
- [Material Design Guidelines](https://material.io/design)
- [Flutter Provider Pattern](https://pub.dev/packages/provider)
- [FL Chart Documentation](https://pub.dev/packages/fl_chart)
