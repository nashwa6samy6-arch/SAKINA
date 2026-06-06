import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final supabase = Supabase.instance.client;

  String get _redirectUrl {
    if (kIsWeb) {
      final port = Uri.base.port;
      return 'http://localhost:$port';
    }
    return 'io.supabase.sakina://login-callback/';
  }

  Future<void> login({
    required String email,
    required String password,
    required String role,
  }) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
    await supabase.auth.updateUser(UserAttributes(data: {'role': role}));
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String university,
    required String role,
    required String gender,
  }) async {
    await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'university': university,
        'role': role,
        'gender': gender,
      },
    );
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  Future<void> signInWithGoogle({required String role}) async {
    final redirectUrl = kIsWeb
        ? 'http://localhost:${Uri.base.port}?role=$role'
        : 'io.supabase.sakina://login-callback/';
    await supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirectUrl,
      authScreenLaunchMode: kIsWeb
          ? LaunchMode.platformDefault
          : LaunchMode.externalApplication,
    );
  }

  Future<void> signInWithMicrosoft({required String role}) async {
    final redirectUrl = kIsWeb
        ? 'http://localhost:${Uri.base.port}?role=$role'
        : 'io.supabase.sakina://login-callback/';
    await supabase.auth.signInWithOAuth(
      OAuthProvider.azure,
      redirectTo: redirectUrl,
      authScreenLaunchMode: kIsWeb
          ? LaunchMode.platformDefault
          : LaunchMode.externalApplication,
    );
  }
}
