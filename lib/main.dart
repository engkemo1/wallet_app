import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wallet_app/generated/l10n.dart'; // Import the generated localization file
import 'package:wallet_app/provider/provider_language.dart';
import 'package:wallet_app/ui/screen/home_page.dart';
import 'package:wallet_app/ui/screen/welcome.dart';
import 'package:wallet_app/util/constant.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var user =FirebaseAuth.instance.currentUser?.uid;
    return  Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          title: 'Flutter Wallet App',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          locale: languageProvider.locale,
          supportedLocales: const [
            Locale('en', ''), // English
            Locale('ar', ''), // Arabic
          ],
          localizationsDelegates: const [
            S.delegate, // Your generated localization delegate
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate, // Add this for Cupertino support
          ],
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,
          home: user ==null ? const SignInPage() : const HomePage(),
        );
      },
    );
  }
}
