import 'package:flutter/material.dart';
import 'package:wallet_app/util/constant.dart';
import 'package:wallet_app/generated/l10n.dart'; // Import the generated localization file

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).about_us_title, // Localized title
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: COLOR_PRIMARY,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              const SizedBox(height: 20),
              Text(
                S.of(context).team, // Localized description
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _iconButton(Icons.phone, S.of(context).call_us), // Localized button label
                  const SizedBox(width: 20),
                  _iconButton(Icons.email, S.of(context).email_us), // Localized button label
                  const SizedBox(width: 20),
                  _iconButton(Icons.web, S.of(context).visit_website), // Localized button label
                ],
              ),
              const SizedBox(height: 40),
              Image.asset(
                'assets/svg/logo.jpg',
                height: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 10),
              Text(
                S.of(context).abouUs,
                // S.of(context).abouUs, // Localized description
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: COLOR_PRIMARY, size: 40),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: COLOR_PRIMARY)),
      ],
    );
  }
}
