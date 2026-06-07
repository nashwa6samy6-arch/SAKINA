import 'package:flutter/material.dart';

String _cleanMessage(String message) {
  if (message.contains('invalid_credentials') ||
      message.contains('Invalid login credentials')) {
    return 'Invalid email or password. Please try again.';
  }
  if (message.contains('email_taken') || message.contains('already registered')) {
    return 'This email is already registered.';
  }
  if (message.contains('weak_password')) {
    return 'Password is too weak. Please use at least 6 characters.';
  }
  if (message.contains('invalid_email') || message.contains('Invalid email')) {
    return 'Please enter a valid email address.';
  }
  if (message.contains('network') || message.contains('SocketException')) {
    return 'No internet connection. Please check your network.';
  }
  if (message.contains('AuthApiException') || message.contains('statusCode')) {
    final match = RegExp(r'message:\s*([^,}]+)').firstMatch(message);
    if (match != null) return match.group(1)?.trim() ?? message;
  }
  return message;
}

void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red),
          SizedBox(width: 8),
          Text('Error', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: Text(_cleanMessage(message)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK', style: TextStyle(color: Colors.black)),
        ),
      ],
    ),
  );
}

void showSuccessDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green),
          SizedBox(width: 8),
          Text('Success', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK', style: TextStyle(color: Colors.black)),
        ),
      ],
    ),
  );
}