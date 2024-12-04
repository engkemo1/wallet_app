import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet_app/ui/screen/bank_accounts/bank_accounts.dart';
import '../../../generated/l10n.dart';
import '../../../util/constant.dart';
import '../j.dart'; // Assuming this is where WalletDetailsScreen is defined

class Service extends StatelessWidget {
  final int id;
  final String name;
  final String collectionName;
  final String logo;

  const Service({
    Key? key,
    required this.name,
    required this.logo,
    required this.id,
    required this.collectionName,
  }) : super(key: key);

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri,mode: LaunchMode.inAppWebView)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Back button
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                ),

              ],
            ),
            // Logo
            Image.asset(
              logo,
              height: 100,
            ),
            const SizedBox(height: 10),

            // Service name
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            ),
            const SizedBox(height: 60),

            // Add Button
            SizedBox(
              width: 300,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BankAccounts(
                        collectionName: collectionName,
                        name: name,
                        id: id,
                      ),
                    ),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(COLOR_PRIMARY),
                ),
                child: Text(
                  S.of(context).add,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Show All Button
            SizedBox(
              width: 300,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddWallet(
                        collectionName: collectionName,
                        title: name,
                        id: id.toString(),
                      ),
                    ),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(COLOR_PRIMARY),
                ),
                child: Text(
                  S.of(context).showALL,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            if (id == 4) _buildEmailCards(),
          ],
        ),
      ),
    );
  }

  // Build Yahoo and Gmail cards
  Widget _buildEmailCards() {
    return Column(
      children: [
        Card(
          child: ListTile(
            leading: Icon(Icons.email, color: Colors.redAccent),
            title: const Text("Gmail"),
            onTap: () => _launchURL('https://mail.google.com/'),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.email, color: Colors.purpleAccent),
            title: const Text("Yahoo Mail"),
            onTap: () => _launchURL('https://mail.yahoo.com/'),
          ),
        ),
      ],
    );
  }
}
