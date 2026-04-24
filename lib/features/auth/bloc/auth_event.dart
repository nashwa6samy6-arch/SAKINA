abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final String role; 
  LoginRequested({required this.email, required this.password, required this.role,});
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String university;
  SignUpRequested({
    required this.email,
    required this.password,
    required this.fullName,
    required this.university, String? gender,
  });
}

class LogoutRequested extends AuthEvent {}
class GoogleSignInRequested extends AuthEvent {}
