import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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
  final ImagePicker _picker = ImagePicker(); // Image picker instance

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    var userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      var document = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
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

  // Function to pick an image from the device
  Future<void> _pickImageAndUpload() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      TextEditingController nameController = TextEditingController();

      // Show dialog for user input
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Enter Your Name'),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Name'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  String userName = nameController.text.trim();
                  Navigator.of(context).pop(); // Close dialog

                  if (userName.isEmpty) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(content: Text('Name cannot be empty!')),
                    );
                    return;
                  }

                  try {
                    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

                    // Upload to Firebase Storage
                    UploadTask uploadTask = FirebaseStorage.instance
                        .ref('userHealthCards/$fileName')
                        .putFile(imageFile);
                    TaskSnapshot snapshot = await uploadTask;
                    String imageUrl = await snapshot.ref.getDownloadURL();

                    // Save the image URL, userId, and name to Firestore
                    await FirebaseFirestore.instance.collection("overview").add({
                      "image": imageUrl,
                      "name": userName,
                      "userId": FirebaseAuth.instance.currentUser?.uid ?? 'unknown',
                    });

                    // Use global ScaffoldMessenger to avoid invalid context issues
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(content: Text('Image uploaded successfully!')),
                    );
                  } catch (e) {
                    // Use global ScaffoldMessenger for error display
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(content: Text('Error uploading image: $e')),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          );
        },
      );
    }
  }

  // Function to delete the image from Firebase Storage and Firestore
  Future<void> _deleteImage(String docId, String imageUrl) async {
    try {
      // Delete from Firebase Storage
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      // Delete from Firestore
      await FirebaseFirestore.instance.collection("overview").doc(docId).delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting image: $e')),
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
            : StreamBuilder<Object>(
            stream: FirebaseFirestore.instance.collection("overview").where("userId",isEqualTo:FirebaseAuth.instance.currentUser?.uid ).snapshots(),
            builder: (context,AsyncSnapshot snapShot) {
              if (!snapShot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              var data = snapShot.data!.docs;

              return Padding(
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
                            height:snapShot==null? 100:220,
                            child:ListView(
                              scrollDirection: Axis.horizontal,
                              children: [

                                ...data.map((doc) => _buildCardWidget(
                                  doc['name'],
                                  doc['image'],
                                  doc.id, // Pass document ID
                                )),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap:_pickImageAndUpload,
                                    child: Container(
                                      decoration: const BoxDecoration(shape: BoxShape.circle),
                                    child: const Center(child: Icon(Icons.add_circle_outline,size: 50,),),),
                                  ),
                                ),
                              ]
                            )  ),

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
                  );
              }
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


    Widget _buildCardWidget(String title, String? imageUrl, String docId) {
      return SizedBox(
        width: 300,
        height: 200,
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Container(
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
                       title,
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
              Positioned(
                right: 8,
                top: 8,
                child: IconButton(
                  icon: Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () {
                    _deleteImage(docId, imageUrl!);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    DateTime date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
 showAddNoteDialog() {
    TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a Note'),
          content: TextField(
            style:  const TextStyle(fontSize: 16,fontWeight: FontWeight.w400),
            controller: noteController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintStyle: TextStyle(fontSize: 14,fontWeight: FontWeight.w400),
              hintText: 'Enter your note here...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String noteText = noteController.text.trim();
                Navigator.of(context).pop();

                if (noteText.isEmpty) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Note cannot be empty!')),
                  );
                  return;
                }

                try {
                  await FirebaseFirestore.instance.collection('notes').add({
                    'userId': FirebaseAuth.instance.currentUser?.uid ?? 'unknown',
                    'note': noteText,
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Note added successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(content: Text('Error adding note: $e')),
                  );
                }
              },
              child: const Text('Add Note'),
            ),
          ],
        );
      },
    );
  }

  Widget _contentServices(BuildContext context) {
    List<ModelServices> listServices = [
      ModelServices(
          collectionName: "Bank Accounts",
          title: S.of(context).bankAccounts,
          img: "assets/bank (1).png",
          id: 1),
      ModelServices(
          collectionName: "Health Information",
          title: S.of(context).healthInformation,
          img: "assets/consent (1).png",
          id: 2),
      ModelServices(
          collectionName: "Cheapness",
          title: S.of(context).cheapness,
          img: "assets/svg/drivers-license.png",
          id: 3),
      ModelServices(
          collectionName: "Emails",
          title: S.of(context).emails,
          img: "assets/email.png",
          id: 4),
      ModelServices(
          collectionName: "Coupons",
          title: S.of(context).coupons,
          img: "assets/coupon.png",
          id: 5),
    ];

    return SizedBox(
      width: double.infinity,
      height: 400,
      child: GridView.count(
        crossAxisCount: 4,
        childAspectRatio: MediaQuery.of(context).size.width /
            (MediaQuery.of(context).size.height / 1.5),
        children: [
          ...listServices.map((value) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Service(
                        collectionName: value.collectionName,
                        name: value.title,
                        logo: value.img,
                        id: value.id),
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
          // Add Note Button
          GestureDetector(
            onTap: () => showAddNoteDialog(),
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
                  child: const Icon(Icons.note_add, size: 32),
                ),
                const SizedBox(height: 8),
                Text(
                  S.of(context).addNote,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
          // Show Notes Button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShowNotesPage()),
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
                  child: const Icon(Icons.notes, size: 32),
                ),
                const SizedBox(height: 8),
                Text(
                  'Show Notes', // Replace with localized string if needed
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ModelServices {
  String title, img;
  int id;
  String collectionName;

  ModelServices(
      {required this.title,
      required this.collectionName,
      required this.img,
      required this.id});
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
class ShowNotesPage extends StatelessWidget {
  const ShowNotesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notes')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No notes found.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            );
          }

          var notes = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              var note = notes[index];
              String noteText = note['note'] ?? 'No content';
              DateTime? timestamp = note['timestamp'] != null
                  ? (note['timestamp'] as Timestamp).toDate()
                  : null;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        noteText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            timestamp != null
                                ? DateFormat('MMMM dd, yyyy • hh:mm a')
                                .format(timestamp)
                                : 'No timestamp',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const Icon(
                            Icons.event_note,
                            color: Colors.blueAccent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}