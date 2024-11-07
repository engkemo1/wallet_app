import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n.dart';
import '../../provider/provider_language.dart';
import '../../util/constant.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).settings, style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white)),
        backgroundColor: COLOR_PRIMARY,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).language,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: COLOR_PRIMARY,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              title: Text(S.of(context).switch_language, style: Theme.of(context).textTheme.bodyLarge),
              trailing: Consumer<LanguageProvider>(
                builder: (context, languageProvider, child) {
                  return Switch(
                    thumbColor: const MaterialStatePropertyAll(Colors.grey),
                    activeColor: COLOR_PRIMARY,
                    value: languageProvider.locale.languageCode == 'ar',
                    onChanged: (bool value) {
                      languageProvider.toggleLanguage();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
