import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wallet_app/ui/screen/service/service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wallet_app/generated/l10n.dart'; // Import localization file

import '../../util/file_path.dart';
import 'drawer_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    var userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      var document = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      setState(() {
        userData = document.data();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.only(left: 18, right: 18, top: 34),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _contentHeader(),
                const SizedBox(height: 30),
                Text(
                  S.of(context).accountOverview, // Localized string
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildCardWidget(S.of(context).healthCard, userData?['healthCardUrl']),
                      _buildCardWidget(S.of(context).carCard, userData?['carFormUrl']),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      S.of(context).services, // Localized string
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _contentServices(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _contentHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            Image.asset(logo, width: 80),
            const SizedBox(width: 10),
            Text('WATHEEQ', style: Theme.of(context).textTheme.displaySmall),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DrawerPage()),
            );
          },
          child: SvgPicture.asset(
            menu,
            width: 16,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
      ],
    );
  }

  Widget _buildCardWidget(String title, String? imageUrl) {
    return SizedBox(
      width: 300,
      height: 200,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Colors.blueAccent, Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl != null)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImage(imageUrl: imageUrl),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  userData?["username"] ?? 'Username',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.perm_identity, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'ID: ${userData?['id'] ?? 'N/A'}',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Created: ${_formatTimestamp(userData?['createdAt'])}',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    DateTime date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _contentServices(BuildContext context) {
    List<ModelServices> listServices = [
      ModelServices(collectionName:"Bank Accounts",title: S.of(context).bankAccounts, img: "assets/bank (1).png", id: 1), // Localized
      ModelServices(collectionName : "Health Information", title: S.of(context).healthInformation, img: "assets/consent (1).png", id: 2), // Localized
      ModelServices(collectionName: "Cheapness",title: S.of(context).cheapness, img: "assets/loss.png", id: 3), // Localized
      ModelServices(collectionName:"Emails",title: S.of(context).emails, img: "assets/email.png", id: 4), // Localized
      ModelServices(collectionName:"Coupons", title: S.of(context).coupons, img: "assets/coupon.png", id: 5), // Localized
    ];

    return SizedBox(
      width: double.infinity,
      height: 400,
      child: GridView.count(
        crossAxisCount: 4,
        childAspectRatio: MediaQuery.of(context).size.width /
            (MediaQuery.of(context).size.height / 1.5),
        children: listServices.map((value) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Service(collectionName:value.collectionName ,name: value.title, logo: value.img, id: value.id),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).cardColor,
                  ),
                  child: Image.asset(
                    value.img,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 14),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ModelServices {
  String title, img;
  int id;
  String collectionName;
  ModelServices({required this.title, required this.collectionName,required this.img, required this.id});
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
