import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
import 'package:path/path.dart' as path;

import '../../../generated/l10n.dart'; // Import the generated localization file
import '../../../util/constant.dart';

class BankAccounts extends StatefulWidget {
  final String name;
  final int id;
  final String collectionName;

  BankAccounts({super.key, required this.name, required this.id, required this.collectionName});

  @override
  State<BankAccounts> createState() => _BankAccountsState();
}

class _BankAccountsState extends State<BankAccounts> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Form key for validation
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController bloodController = TextEditingController();
  final TextEditingController insuranceController = TextEditingController();
  final TextEditingController ipanNumberController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  File? _selectedImage;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance; // Firebase Storage instance

  bool _isLoading = false; // Loading state

  // Function to pick an image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
        imageController.text = pickedImage.path;
      });
    }
  }

  // Function to upload image to Firebase Storage and get download URL
  Future<String?> _uploadImage(File image) async {
    try {
      // Create a reference for the image file in Firebase Storage
      String fileName = path.basename(image.path); // Get the file name
      Reference storageRef = _storage.ref().child('images/$fileName');

      // Upload the file to Firebase Storage
      UploadTask uploadTask = storageRef.putFile(image);
      await uploadTask;

      // Get the download URL
      String downloadURL = await storageRef.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading image: $e")),
      );
      return null;
    }
  }

  // Show a loading dialog
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(COLOR_PRIMARY),
            ),
          ),
        );
      },
    );
  }

  // Dismiss the loading dialog
  void _dismissLoadingDialog() {
    Navigator.of(context).pop();
  }

  // Save data to Firestore with validation
  Future<void> _saveToFirestore() async {
    if (!_formKey.currentState!.validate()) {
      // If the form is not valid, return without saving
      return;
    }

    setState(() {
      _isLoading = true;
    });
    _showLoadingDialog(); // Show loading dialog

    String? imageUrl;

    // Upload image if selected
    if (_selectedImage != null) {
      imageUrl = await _uploadImage(_selectedImage!);
    }

    var userId = FirebaseAuth.instance.currentUser!.uid;
    Map<String, dynamic> data;

    // Conditional data map based on widget.id
    if (widget.id == 1) {
      data = {
        "bankName": bankNameController.text,
        "accountNumber": accountNumberController.text,
        "ipanNumber": ipanNumberController.text,
        "imageURL": imageUrl, // Save the image URL instead of the file path
        "createdAt": FieldValue.serverTimestamp(),
        "userId": userId
      };
    } else if (widget.id == 2) {
      data = {
        "name": nameController.text,
        "age": ageController.text,
        "weight": weightController.text,
        "height": lengthController.text,
        "insurance": insuranceController.text,
        "imageURL": imageUrl, // Save the image URL
        "createdAt": FieldValue.serverTimestamp(),
        "userId": userId
      };
    } else if (widget.id == 4) {
      data = {
        "name": nameController.text,
        "email": emailController.text,
        "password": passwordController.text,
        "imageURL": imageUrl, // Save the image URL
        "createdAt": FieldValue.serverTimestamp(),
        "userId": userId
      };
    } else if (widget.id == 5) {
      data = {
        "bankName": bankNameController.text,
        "discountCode": discountController.text,
        "imageURL": imageUrl, // Save the image URL
        "createdAt": FieldValue.serverTimestamp(),
        "userId": userId
      };
    } else {
      // Default data structure if widget.id doesn't match any case
      data = {
        "imageURL": imageUrl, // Save the image URL
        "createdAt": FieldValue.serverTimestamp(),
        "userId": userId
      };
    }

    try {
      // Add the data as a new document in the Firestore collection named after widget.name
      await _firestore.collection(widget.collectionName.replaceAll(" ", "")).add(data);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).addToFirestore)),
      );
    } catch (e) {
      print("Error adding document to Firestore: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add data: $e")),
      );
    } finally {
      _dismissLoadingDialog(); // Dismiss the loading dialog
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: _formKey, // Assign form key
          child: ListView(
            children: [
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
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: Text("${S.of(context).add} ${widget.name}", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
              ),
              const SizedBox(height: 20),

              if (widget.id == 2) ...[
                // Health Form Fields with validation
                _buildValidatedTextField(S.of(context).name, S.of(context).enterName, nameController, TextInputType.name, "Name is required"),
                _buildValidatedTextField(S.of(context).age, S.of(context).enterAge, ageController, TextInputType.number, "Age is required"),
                _buildValidatedTextField(S.of(context).weight, S.of(context).enterWeight, weightController, TextInputType.number, "Weight is required"),
                _buildValidatedTextField(S.of(context).height, S.of(context).enterHeight, lengthController, TextInputType.number, "Height is required"),
                _buildValidatedTextField(S.of(context).insurance, S.of(context).enterInsurance, insuranceController, TextInputType.text, "Insurance is required"),
              ],
              if (widget.id == 4) ...[
                // User Account Form Fields with validation
                _buildValidatedTextField(S.of(context).name, S.of(context).enterName, nameController, TextInputType.name, "Name is required"),
                _buildValidatedTextField(S.of(context).email, S.of(context).enterEmail, emailController, TextInputType.emailAddress, "Valid email is required", emailValidation: true),
                _buildValidatedTextField(S.of(context).password, S.of(context).enterPassword, passwordController, TextInputType.visiblePassword, "Password is required"),
              ],
              if (widget.id == 5) ...[
                // Bank Information Form Fields with validation
                _buildValidatedTextField(S.of(context).bankName, S.of(context).enterBankName, bankNameController, TextInputType.name, "Bank name is required"),
                _buildValidatedTextField(S.of(context).discountCode, S.of(context).enterDiscountCode, discountController, TextInputType.text, "Discount code is required"),
              ],
              if (widget.id == 1) ...[
                // Another Bank Information Form Fields with validation
                _buildValidatedTextField(S.of(context).bankName, S.of(context).enterBankName, bankNameController, TextInputType.name, "Bank name is required"),
                _buildValidatedTextField(S.of(context).accountNumber, S.of(context).enterAccountNumber, accountNumberController, TextInputType.number, "Account number is required"),
                _buildValidatedTextField(S.of(context).ipanNumber, S.of(context).enterIPANNumber, ipanNumberController, TextInputType.number, "IPAN number is required"),
              ],

              // Image Picker Field (optional, without validation)
              if (widget.id != 4)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        backgroundColor: Colors.black,
                        context: context,
                        builder: (context) => SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.camera_alt, color: Colors.white),
                                  title: Text(S.of(context).addImage, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15)),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    _pickImage(ImageSource.camera);
                                  },
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(Icons.photo, color: Colors.white),
                                  title: Text(S.of(context).imagePicker, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15)),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    _pickImage(ImageSource.gallery);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    child: TextFormField(
                      controller: imageController,
                      decoration: InputDecoration(
                        labelText: S.of(context).addImage,
                        hintText: S.of(context).imagePicker,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                      ),
                      enabled: false,
                    ),
                  ),
                ),

              // Submit Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 10),
                child: ElevatedButton(
                  onPressed: _saveToFirestore,
                  style: ElevatedButton.styleFrom(backgroundColor: COLOR_PRIMARY),
                  child: Text(S.of(context).submit, style: const TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build a text field with validation
  Widget _buildValidatedTextField(String title, String hintText, TextEditingController controller, TextInputType keyboardType, String validationMessage, {bool emailValidation = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: title,
          hintStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(20)),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(20)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return validationMessage;
          }
          if (emailValidation && !RegExp(r"^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$").hasMatch(value)) {
            return S.of(context).enterEmail;
          }
          return null;
        },
      ),
    );
  }
}
