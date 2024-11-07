import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:wallet_app/util/constant.dart';

import '../../generated/l10n.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _profileImageUrl;
  File? _imageFile;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get();
    _nameController.text = userDoc['username'] ?? '';
    _emailController.text = userDoc['email'] ?? '';
    _profileImageUrl = userDoc['profileImageUrl'];
    setState(() {});
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile != null) {
      final ref = FirebaseStorage.instance.ref().child('profile_images/${DateTime.now().toString()}.jpg');
      await ref.putFile(_imageFile!);
      _profileImageUrl = await ref.getDownloadURL();
    }
  }

  Future<void> _saveProfile() async {
    if (_imageFile != null) {
      await _uploadImage();
    }
    await _firestore.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
      'name': _nameController.text,
      'email': _emailController.text,
      'profileImageUrl': _profileImageUrl,
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(S.of(context).editProfile,style: TextStyle(color: Colors.white),),
        backgroundColor: COLOR_PRIMARY,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: COLOR_PRIMARY,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!):

                       ( _profileImageUrl!=null?_profileImageUrl!="" ? NetworkImage(_profileImageUrl!) : null:null),
                  child: _imageFile == null && _profileImageUrl == null || _profileImageUrl==""
                      ? const Icon(Icons.camera_alt, size: 50, color: Colors.white70)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration:  InputDecoration(
                hintText: 'Name',
                enabledBorder:OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey)
                ),
                focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey)
            ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey)
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration:  InputDecoration(
                hintText: 'Email',
                enabledBorder:OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey)
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey)
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey)
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: COLOR_PRIMARY,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16,color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
