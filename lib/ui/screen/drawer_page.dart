import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wallet_app/ui/screen/auth_page.dart';
import 'package:wallet_app/ui/screen/profile_screen.dart';
import 'package:wallet_app/ui/screen/service/about_us.dart';
import 'package:wallet_app/ui/screen/settings_screen.dart';

import '../../generated/l10n.dart';
import '../../util/file_path.dart';
import 'home_page.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({Key? key}) : super(key: key);

  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> with TickerProviderStateMixin {
  bool sideBarActive = false;
  late AnimationController rotationController;

  @override
  void initState() {
    rotationController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).cardColor,
          body: Stack(
            children: [
              Column(
                children: [
                  StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }

                        var userData = snapshot.data!.data() as Map<String, dynamic>;
                        String username = userData['name'] ?? 'User';
                        String id = userData['id'] ?? 'ID';

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 100,
                              width: MediaQuery.of(context).size.width * 0.6,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                    bottomRight: Radius.circular(60)),
                                color: Theme.of(context).colorScheme.background,
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          border: Border.all(color: const Color(0xffD8D9E4))),
                                      child: CircleAvatar(
                                        radius: 22.0,
                                        backgroundColor: Theme.of(context).colorScheme.background,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(50.0),
                                          child: userData["profileImageUrl"] == "" || userData["profileImageUrl"] == null
                                              ? SvgPicture.asset(avatorOne)
                                              : Image.network(userData["profileImageUrl"], fit: BoxFit.fill),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(username, style: Theme.of(context).textTheme.titleLarge),
                                        Text("ID: $id", style: Theme.of(context).textTheme.bodyLarge),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        );
                      }
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        navigatorTitle(S.of(context).home, true, onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const HomePage()),
                          );
                        }),
                        navigatorTitle(S.of(context).profile, false, onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ProfileScreen()),
                          );
                        }),
                        navigatorTitle(S.of(context).settings, false, onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SettingsScreen()),
                          );
                        }),
                        navigatorTitle(S.of(context).about, false, onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AboutUsPage()),
                          );
                        }),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () async{
                      try {
                        // Sign out the user
                        await FirebaseAuth.instance.signOut();

                        // Navigate to the AuthPage or Login Page
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => AuthPage(register: false)),
                        );
                      } catch (e) {
                        // Handle any errors during sign out
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error during logout: $e')),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(
                            Icons.power_settings_new,
                            size: 24,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          const SizedBox(width: 10),
                          Text(S.of(context).logout, style: Theme.of(context).textTheme.titleLarge),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: (sideBarActive) ? MediaQuery.of(context).size.width * 0.6 : 0,
                top: (sideBarActive) ? MediaQuery.of(context).size.height * 0.2 : 0,
                child: RotationTransition(
                  turns: (sideBarActive)
                      ? Tween(begin: -0.05, end: 0.0).animate(rotationController)
                      : Tween(begin: 0.0, end: -0.05).animate(rotationController),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: (sideBarActive) ? MediaQuery.of(context).size.height * 0.7 : MediaQuery.of(context).size.height,
                    width: (sideBarActive) ? MediaQuery.of(context).size.width * 0.8 : MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: sideBarActive ? const BorderRadius.all(Radius.circular(40)) : const BorderRadius.all(Radius.circular(0)),
                      color: Colors.white,
                    ),
                    child: ClipRRect(
                      borderRadius: sideBarActive ? const BorderRadius.all(Radius.circular(40)) : const BorderRadius.all(Radius.circular(0)),
                      child: const HomePage(),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 20,
                child: (sideBarActive)
                    ? IconButton(
                  padding: const EdgeInsets.all(30),
                  onPressed: closeSideBar,
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).iconTheme.color,
                    size: 30,
                  ),
                )
                    : InkWell(
                  onTap: openSideBar,
                  child: Container(
                    margin: const EdgeInsets.all(17),
                    height: 30,
                    width: 30,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector navigatorTitle(String name, bool isSelected, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          (isSelected)
              ? Container(
            width: 5,
            height: 40,
            color: const Color(0xffffac30),
          )
              : const SizedBox(width: 5, height: 40),
          const SizedBox(width: 10, height: 45),
          Text(
            name,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontSize: 16,
              fontWeight: (isSelected) ? FontWeight.w700 : FontWeight.w400,
            ),
            textAlign: TextAlign.end, // Align text to the end for RTL
          ),
        ],
      ),
    );
  }

  void closeSideBar() {
    sideBarActive = false;
    setState(() {});
  }

  void openSideBar() {
    sideBarActive = true;
    setState(() {});
  }
}
