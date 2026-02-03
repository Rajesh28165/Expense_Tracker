// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

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
  static const appName = 'Hisabkitab';

  static const otpTimer = 30;
  static const users = 'users';
  static const expenses = 'expenses';

  static const Password_rule = 'Your password must be 8 - 20 characters long, and must contain at least 1 number, 1 lower case letter, 1 upper case letter and 1 special character';
  static const SecurityQuestionRule = 'Choose a security question and answer. This will help us verify your identity if you forget your password.';

  static const Color commonTextColor = Colors.white;
  
  // FontFamily
  static const Roboto = 'Roboto';
  static const Montserrat = 'Montserrat';
  static const DancingScript = 'DancingScript';
  static const OpenSans = 'OpenSans';
  static const Pacifico = 'Pacifico';
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

  static const slogans = [
    'Track Every Rupee, Every Day',
    'Your Money, Your Control',
    'Know Where Your Money Goes',
    'Smart Spending Starts Here',
    'Track. Analyze. Save.',
    'HISABKITAB – Expenses Made Easy'
  ];


}

class ImagePathConstants {
  static const String asset = 'lib/asset';
  static const String icons = '$asset/icon';
  static const String imagePath = '$asset/images';
  static const String landingPath = '$imagePath/landing';
  static const String bg = '$imagePath/bg';

  static const String space = '$imagePath/space.jpg';
  static const String star = '$imagePath/star.jpg';
  static const String earth = '$imagePath/earth.jpg';
  static const String lock = '$imagePath/lock.jpg';
  static const String techWall = '$imagePath/techWall.jpg';
  static const String shultter = '$imagePath/shultter.jpg';

  static const String barGraph = '$landingPath/bar_graph.png';
  static const String calculator = '$landingPath/calculator.png';
  static const String cash = '$landingPath/cash.png';
  static const String coins = '$landingPath/coins.png';
  static const String money = '$landingPath/money.png';
  static const String moneyManagement = '$landingPath/money_management.png';
  static const String progressGraph = '$landingPath/progress_graph.png';

  static const String solidBlack = '$bg/solid-black.jpg';
  static const String blackSolid = '$bg/black-solid.jpg';
  static const String skyBlue = '$bg/sky-blue.jpg';
  static const String gradient = '$bg/gradient.jpg';

  static const String googleIcon = '$icons/google_icon.jpeg';
}


class ErrorMsg {
  static const String pswdError = "Please enter valid password";  
}

class SuccessMsg {
  
}