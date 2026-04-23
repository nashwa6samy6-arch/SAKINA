import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sakina/sakina_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gmrfwpntjvcrsbqpvzur.supabase.co',
    anonKey: 'sb_publishable__vpgk7qNq798y_h3_Zs9sQ_zCqC-65D',
  );

  runApp(EasyLocalization(
    supportedLocales: [Locale('en'), Locale('ar')],
    path: 'assets/translations',
    fallbackLocale: Locale('en'),
    startLocale: Locale('en'),
    child: SakinaApp(),
  ));
}
