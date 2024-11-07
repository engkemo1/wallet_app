import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:wallet_app/ui/screen/auth_page.dart';

import '../../util/file_path.dart';
import 'drawer_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  static DateTime now = DateTime.now();
  String formattedTime = DateFormat.jm().format(now); // Correct time format
  String formattedDate = DateFormat('MMM d, yyyy | EEE').format(now); // Use 'EEE' for short weekday

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _topContent(),
              _centerContent(),
              _bottomContent()
            ],
          ),
        ),
      ),
    );
  }

  Widget _topContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(
          height: 18,
        ),
        Row(
          children: <Widget>[
            Text(
              formattedTime,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(
              width: 30,
            ),

          ],
        ),
        const SizedBox(
          height: 2,
        ),
        Text(
          formattedDate,
          style: Theme.of(context).textTheme.bodyMedium,
        )
      ],
    );
  }

  Widget _centerContent() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Image.asset(logo),


          const SizedBox(
            height: 18,
          ),
          Text(
            'Open An Account For Digital Smart Wallet Solutions.\nInstant Payouts. \n\nJoin For Free.',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 15),
          )
        ],
      ),
    );
  }

  Widget _bottomContent() {
    return Column(
      children: <Widget>[
        MaterialButton(
          elevation: 0,
          color: Colors.blue,
          height: 50,
          minWidth: 200,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AuthPage(),
              ),
            );
          },
          child: Text(
            'Sign in',
            style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.white),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        InkWell(
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AuthPage(),
              ),
            );
          },
          child: Text(
            'Create an Account',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(
          height: 16,
        ),
      ],
    );
  }
}
