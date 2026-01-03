// ignore_for_file: constant_identifier_names

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
  static const users = 'users';
  static const expenses = 'expenses';
}

class ImagePathConstants {
  static const String basePath = 'lib/asset/images';
  static const String space = '$basePath/space.jpg';
  static const String star = '$basePath/star.jpg';
  static const String earth = '$basePath/earth.jpg';
  static const String lock = '$basePath/lock.jpg';
  static const String techWall = '$basePath/techWall.jpg';
  static const String shultter = '$basePath/shultter.jpg';
}


class ErrorMsg {
  static const String pswdError = "Password must be 8+ characters\nwith uppercase, lowercase,\nnumber, and special character.";  
}

class SuccessMsg {
  
}