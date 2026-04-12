// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

import '../util/colors.dart';

class RegexConstants {
  // Generic
  static const ANY_CHARACTER = r'[\s\S]';
  static const ALPHA_NUMERIC = r'[a-zA-Z0-9 ]';

  // Alphabets & Name-related
  static const ONLY_ALPHABETS = r'^[a-zA-Z]+$';
  static const NAME_VALIDATOR = r'^[a-zA-Z .-]+$';
  static const NAME_PATTERN = r'[a-zA-Z .-]';
  static const CITY_PATTERN = r'[a-zA-Z ]';

  // Numbers
  static const DIGIT = r'\d';
  static const ONLY_NUMBERS = r'^[0-9]+$';
  static const NON_NUMERIC = r'[^0-9]';
  static const DECIMAL_NUMBER = r'^-?\d+(\.\d+)?$';
  static const PHONE_NUMBER = r'^[0-9]{10}$';
  static const PHONE_NUMBER_PATTERN = r'^[0-9+\s]+$';

  // Password / Validation
  static const ATLEAST_ONE_NUMBER = r'(.*[0-9].*)';
  static const ATLEAST_ONE_LOWERCASE = r'(.*[a-z].*)';
  static const ATLEAST_ONE_UPPERCASE = r'(.*[A-Z].*)';
  static const ATLEAST_ONE_SPECIAL_CHARACTER = r"(.*[~`!@#\$%^&*()\-+={}" r'"' r"|\\/:;<>,.?\[\]'_].*)";
  static const PASSWORD_PATTERN = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';

  // Email
  static const EMAIL_ADDRESS_PATTERN = r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";

  // Special
  static const REGEX_NO_SPECIAL_CHARACTERS = r'[0-9a-zA-Z]';
  static const FORWARD_BACKWARD_SLASH = r'[/\\]';
}

class AppConstants {
  static const appName = 'Kharcha Sutra';
  static const supportEmail ='support@kharchasutra.com';

  static const Password_reset_link_header = 'We will send a password reset link to your registered email.';
  
  static const Password_reset_link_warning = 'Use the email link to reset your password and ensure the following requirements are met:';

  static const Password_rule = 'Your password must be 8–20 characters long and include at least one uppercase letter, one lowercase letter, one number, and one special character.';

  static const Password_note = 'If your password does not meet these requirements, you may still be able to reset it, but you will not be able to log in using that password.';

  static const Email_rule = 'Enter a valid email address. We’ll send you a verification link to confirm your account.';

  static const SecurityQuestionRule = 'Choose a security question and answer. This will help us verify your identity if you forget your password.';

  static const Color commonTextColor = Colors.white;

  // In app_constants.dart
  static const purposeUpdatePassword = 'updatePassword';
  static const purposeUpdateSecurityQA = 'updateSecurityQA';
  
  // FontFamily
  static const Montserrat = 'Montserrat';
  static const OpenSans = 'OpenSans';
  static const PlayfairDisplay = 'PlayfairDisplay';


  static const listOfSecurityQuestions = [
    'What nickname do your friends call you?',
    'What is the name of your childhood friend?',
    'Who is your favourite sportsperson?',
    'What was the first mobile app you installed?',
    'What is the best movie you watched in a theatre?',
  ];

  static const listOfSecurityHints = [
    'Your question is related to a name people used for you.',
    'Your question is related to someone you knew growing up.',
    'Your question is related to a public figure you admire.',
    'Your question is related to your early mobile experience.',
    'Your question is related to an entertainment experience.',
  ];

}

class ImagePathConstants {
  static const String asset = 'lib/asset';
  static const String icons = '$asset/icon';

  static const String googleIcon = '$icons/google_icon.jpeg';
}


class TransactionConstants {

  // ── Categories ────────────────────────────────────────────
  static const List<Map<String, String>> expenseCategories = [
    {'label': 'Food',          'icon': '🍔'},
    {'label': 'Transport',     'icon': '🚗'},
    {'label': 'Shopping',      'icon': '🛍'},
    {'label': 'Entertainment', 'icon': '🎬'},
    {'label': 'Bills',         'icon': '💡'},
    {'label': 'Health',        'icon': '❤️'},
    {'label': 'Other',         'icon': '📦'},
  ];

  static const List<Map<String, String>> incomeCategories = [
    {'label': 'Salary',     'icon': '💼'},
    {'label': 'Freelance',  'icon': '💻'},
    {'label': 'Business',   'icon': '🏢'},
    {'label': 'Investment', 'icon': '📈'},
    {'label': 'Gift',       'icon': '🎁'},
    {'label': 'Bonus',      'icon': '🏆'},
    {'label': 'Other',      'icon': '📦'},
  ];

  // ── Plain label lists (for dropdowns, reports, etc.) ──────
  static List<String> get expenseCategoryLabels =>
      expenseCategories.map((c) => c['label']!).toList();

  static List<String> get incomeCategoryLabels =>
      incomeCategories.map((c) => c['label']!).toList();

  // ── Category emoji map ────────────────────────────────────
  static const Map<String, String> categoryEmoji = {
    'Food':          '🍔',
    'Transport':     '🚗',
    'Shopping':      '🛍',
    'Entertainment': '🎬',
    'Bills':         '💡',
    'Health':        '🩺',
    'Salary':        '💼',
    'Freelance':     '💻',
    'Business':      '🏢',
    'Investment':    '📈',
    'Gift':          '🎁',
    'Bonus':         '🏆',
    'Other':         '📦',
  };

  // ── Category icon background colors ──────────────────────
  static const Map<String, Color> categoryIconBg = {
    'Food':          WidgetColors.catBgFood,
    'Transport':     WidgetColors.catBgTransport,
    'Shopping':      WidgetColors.catBgShopping,
    'Entertainment': WidgetColors.catBgEntertainment,
    'Bills':         WidgetColors.catBgBills,
    'Health':        WidgetColors.catBgHealth,
    'Salary':        WidgetColors.catBgSalary,
    'Freelance':     WidgetColors.catBgFreelance,
    'Business':      WidgetColors.catBgBusiness,
    'Investment':    WidgetColors.catBgInvestment,
    'Gift':          WidgetColors.catBgGift,
    'Bonus':         WidgetColors.catBgBonus,
    'Other':         WidgetColors.catBgOther,
  };

  // ── Convenience helpers ───────────────────────────────────
  static String emojiFor(String category) =>
      categoryEmoji[category] ?? '📦';

  static Color iconBgFor(String category) =>
      categoryIconBg[category] ?? WidgetColors.catBgOther;

  // ── Month names ───────────────────────────────────────────
  static const List<String> monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  static String monthName(int month) => monthNames[month - 1];
}