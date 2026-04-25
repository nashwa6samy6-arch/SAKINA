import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  // go to supabase database
  final supabase = Supabase.instance.client;

  //send info if not correct error
  Future<void> login({
    required String email,
    required String password,
    required String role,
  }) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
    // Save role in user metadata
    await supabase.auth.updateUser(UserAttributes(data: {'role': role}));
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String university,
  }) async {
    await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'university': university,
        //add gender
      },
    );
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  Future<void> signInWithGoogle() async {
    await supabase.auth.signInWithOAuth(OAuthProvider.google);
  }
}
