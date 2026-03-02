class ApiEndpoints {
  // Use 10.0.2.2 for Android Emulator, or your local IP (e.g. 192.168.1.x) for physical device testing
  // For production/real phone usage:
  static const String baseUrl = "https://mycashbook.codelab-by-tnv.top/api/v1";
  
  // Auth
  static const String login = "/auth/login/";
  static const String register = "/auth/register/";
  static const String verifyOtp = "/auth/verify-otp/";
  static const String resendOtp = "/auth/resend-otp/";
  static const String profile = "/auth/profile/";
  static const String refresh = "/auth/refresh/";
  static const String changePassword = "/auth/change-password/";
  static const String forgotPassword = "/auth/forgot-password/";
  static const String resetPassword = "/auth/reset-password/";

  // Books
  static const String books = "/books/";
  static String transactions(int bookId) => "/books/$bookId/transactions/";
  static const String validateBid = "/validate-bid/";
  static const String transfer = "/transfer/";
  static String deleteTransaction(int id) => "/transactions/$id/";
}
