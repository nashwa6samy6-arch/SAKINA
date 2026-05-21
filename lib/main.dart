import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sakina/sakina_app.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await EasyLocalization.ensureInitialized();

  String? pendingRole;
  if (kIsWeb) {
    final uri = Uri.base;
    pendingRole = uri.queryParameters['role'];
  }

  await Supabase.initialize(
    url: 'https://gmrfwpntjvcrsbqpvzur.supabase.co',
    anonKey: 'sb_publishable__vpgk7qNq798y_h3_Zs9sQ_zCqC-65D',
  );

  Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
    final event = data.event;
    final session = data.session;

    if (event == AuthChangeEvent.signedIn && session != null) {
      String? role = session.user.userMetadata?['role'];

      if (role == null && pendingRole != null) {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(data: {'role': pendingRole}),
        );
        role = pendingRole;
        pendingRole = null;
      }

      if (role == 'landlord') {
        navigatorKey.currentState?.pushReplacementNamed('/landlord-home');
      } else if (role == 'tenant') {
        navigatorKey.currentState?.pushReplacementNamed('/home');
      } else {
        navigatorKey.currentState?.pushReplacementNamed('/role');
      }
    } else if (event == AuthChangeEvent.signedOut) {
      navigatorKey.currentState?.pushReplacementNamed('/');
    }
  });

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      startLocale: Locale('en'),
      child: SakinaApp(),
    ),
  );
  await Future.delayed(Duration(seconds: 3));

  FlutterNativeSplash.remove();
}
