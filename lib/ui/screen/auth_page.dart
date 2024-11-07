import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../util/button_widget.dart';
import 'drawer_page.dart';

class AuthPage extends StatefulWidget {
  bool register = true;

  AuthPage({Key? key, required this.register}) : super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool checkedValue = false;

  final _usernamekey = GlobalKey<FormState>();
  final _IDNamekey = GlobalKey<FormState>();
  final _emailKey = GlobalKey<FormState>();
  final _passwordKey = GlobalKey<FormState>();
  final _confirmPasswordKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _iDNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _carController = TextEditingController();
  final _healthController = TextEditingController();
  File? _selectedImageHealth;
  File? _selectedImageCar;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isLoading = false;

  Future<void> registerUser() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      // Register user in Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());

      // Store additional user info in Firestore
      String? carImageUrl;
      String? healthImageUrl;

      // Upload health card image if available
      if (_selectedImageHealth != null) {
        healthImageUrl = await uploadHealthImage(_selectedImageHealth!);
      }

      // Upload car image if available
      if (_selectedImageCar != null) {
        carImageUrl = await uploadCarImage(_selectedImageCar!);
      }

      // Save user data along with image URLs to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'username': _usernameController.text.trim(),
        'id': _iDNameController.text.trim(),
        'email': _emailController.text.trim(),
        'carFormUrl': carImageUrl,
        'healthCardUrl': healthImageUrl,
        'healthCardUrl': healthImageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Navigate to DrawerPage after successful registration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DrawerPage()),
      );

    } on FirebaseAuthException catch (e) {
      buildSnackError(e.message!, context, 50);
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }





  Future<String?> uploadHealthImage(File file) async {
    try {
      final String filePath = 'uploads/health_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage.ref().child(filePath);

      await storageRef.putFile(file);
      String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading health image: $e");
      return null;
    }
  }

  Future<String?> uploadCarImage(File? file) async {
    if (file == null) return null;

    try {
      final storageRef = _storage.ref().child('uploads/car_image.jpg');
      await storageRef.putFile(file);
      String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading car image: $e");
      return null;
    }
  }
  /// Uploads the car image to Firebase Storage and returns the download URL.


  Future<void> _pickImage(ImageSource source, bool isCar) async {
    final ImagePicker picker = ImagePicker();

    // Pick an image from the source (camera or
    //  gallery)
    final XFile? pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        // Update the selected image based on whether it's a car or health image
        if (isCar) {
          _selectedImageCar = File(pickedImage.path); // Set the selected car image
          _carController.text = pickedImage.path;     // Update the car form path in the controller
        } else {
          _selectedImageHealth = File(pickedImage.path); // Set the selected health image
          _healthController.text = pickedImage.path;     // Update the health card path in the controller
        }
      });
    }
  }
  Future<void> loginUser() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DrawerPage()),
      );
    } on FirebaseAuthException catch (e) {
      buildSnackError(e.message!, context, 50);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      body: Center(
        child: Container(
          height: size.height,
          width: size.height,
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xff151f2c) : Colors.white,
          ),
          child: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: size.height * 0.02),
                        child: Align(
                          child: Text(
                            'Hey there,',
                            style: GoogleFonts.poppins(
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xff1D1617),
                              fontSize: size.height * 0.02,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: size.height * 0.015),
                        child: Align(
                          child: widget.register
                              ? Text(
                                  'Create an Account',
                                  style: GoogleFonts.poppins(
                                    color: isDarkMode
                                        ? Colors.white
                                        : const Color(0xff1D1617),
                                    fontSize: size.height * 0.025,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : Text(
                                  'Welcome Back',
                                  style: GoogleFonts.poppins(
                                    color: isDarkMode
                                        ? Colors.white
                                        : const Color(0xff1D1617),
                                    fontSize: size.height * 0.025,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: size.height * 0.01),
                      ),
                      widget.register
                          ? buildTextField(_usernameController, "User Name",
                              Icons.person_outlined, false, size, (valuename) {
                              if (valuename.length <= 2) {
                                buildSnackError(
                                  'Invalid name',
                                  context,
                                  size,
                                );
                                return '';
                              }
                              return null;
                            }, _usernamekey, isDarkMode, TextInputType.text,
                              true, null)
                          : Container(),
                      widget.register
                          ? buildTextField(_iDNameController, "ID",
                              Icons.perm_identity, false, size, (valuename) {
                              if (valuename.length <= 2) {
                                buildSnackError(
                                  'Invalid name',
                                  context,
                                  size,
                                );
                                return '';
                              }
                              return null;
                            }, _IDNamekey, isDarkMode, TextInputType.number,
                              true, null)
                          : Container(),
                      widget.register
                          ? Column(
                            children: [
                              InkWell(
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
                                                leading: const Icon(
                                                    Icons.camera_alt,
                                                    color: Colors.white),
                                                title: const Text(
                                                  'Take a photo',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 15),
                                                ),
                                                onTap: () {
                                                  Navigator.of(context).pop();
                                                  _pickImage(ImageSource.camera,
                                                      true); // Pass `true` for car form
                                                },
                                              ),
                                              const Divider(),
                                              ListTile(
                                                leading: const Icon(Icons.photo,
                                                    color: Colors.white),
                                                title: const Text(
                                                  'Choose from gallery',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 15),
                                                ),
                                                onTap: () {
                                                  Navigator.of(context).pop();
                                                  _pickImage(ImageSource.gallery,
                                                      true); // Pass `true` for car form
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: buildTextField(
                                      _carController,
                                      "Car form",
                                      Icons.camera_alt_outlined,
                                      false,
                                      size,
                                      null,
                                      null,
                                      isDarkMode,
                                      TextInputType.number,
                                      false,
                                      _selectedImageCar != null
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.green,
                                            )
                                          : null)),

                            ],
                          )
                          : Container(),
                      widget.register
                          ? InkWell(
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
                                            leading: const Icon(
                                                Icons.camera_alt,
                                                color: Colors.white),
                                            title: const Text(
                                              'Take a photo',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 15),
                                            ),
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              _pickImage(ImageSource.camera,
                                                  false); // Pass `false` for health form
                                            },
                                          ),
                                          const Divider(),
                                          ListTile(
                                            leading: const Icon(Icons.photo,
                                                color: Colors.white),
                                            title: const Text(
                                              'Choose from gallery',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 15),
                                            ),
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              _pickImage(ImageSource.gallery,
                                                  false); // Pass `false` for health form
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: buildTextField(
                                  _healthController,
                                  "Health card",
                                  Icons.camera_alt_outlined,
                                  false,
                                  size,
                                  null,
                                  null,
                                  isDarkMode,
                                  TextInputType.number,
                                  false,
                                  _selectedImageHealth != null
                                      ? Icon(
                                          Icons.check,
                                          color: Colors.green,
                                        )
                                      : null),
                            )
                          : Container(),
                      Form(
                        child: buildTextField(_emailController, "Email",
                            Icons.email_outlined, false, size, (valuemail) {
                          if (valuemail.length < 5) {
                            buildSnackError(
                              'Invalid email',
                              context,
                              size,
                            );
                            return '';
                          }
                          if (!RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+.[a-zA-Z]+")
                              .hasMatch(valuemail)) {
                            buildSnackError(
                              'Invalid email',
                              context,
                              size,
                            );
                            return '';
                          }
                          return null;
                        }, _emailKey, isDarkMode, TextInputType.emailAddress,
                            true, null),
                      ),
                      Form(
                        child: buildTextField(_passwordController, "Passsword",
                            Icons.lock_outline, true, size, (valuepassword) {
                          if (valuepassword.length < 6) {
                            buildSnackError(
                              'Invalid password',
                              context,
                              size,
                            );
                            return '';
                          }
                          return null;
                        }, _passwordKey, isDarkMode,
                            TextInputType.visiblePassword, true, null),
                      ),
                      Form(
                        child: widget.register
                            ? buildTextField(
                                _confirmController,
                                "Confirm Passsword",
                                Icons.lock_outline,
                                true,
                                size, (valuepassword) {
                                if (valuepassword != _passwordController.text) {
                                  buildSnackError(
                                    'Passwords must match',
                                    context,
                                    size,
                                  );
                                  return '';
                                }
                                return null;
                              }, _confirmPasswordKey, isDarkMode,
                                TextInputType.visiblePassword, true, null)
                            : Container(),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.015,
                          vertical: size.height * 0.025,
                        ),
                        child: widget.register
                            ? CheckboxListTile(
                                title: RichText(
                                  textAlign: TextAlign.left,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            "By creating an account, you agree to our ",
                                        style: TextStyle(
                                          color: const Color(0xffADA4A5),
                                          fontSize: size.height * 0.015,
                                        ),
                                      ),
                                      WidgetSpan(
                                        child: InkWell(
                                          onTap: () {
                                            // ignore: avoid_print
                                            print('Conditions of Use');
                                          },
                                          child: Text(
                                            "Conditions of Use",
                                            style: TextStyle(
                                              color: const Color(0xffADA4A5),
                                              decoration:
                                                  TextDecoration.underline,
                                              fontSize: size.height * 0.015,
                                            ),
                                          ),
                                        ),
                                      ),
                                      TextSpan(
                                        text: " and ",
                                        style: TextStyle(
                                          color: const Color(0xffADA4A5),
                                          fontSize: size.height * 0.015,
                                        ),
                                      ),
                                      WidgetSpan(
                                        child: InkWell(
                                          onTap: () {
                                            // ignore: avoid_print
                                            print('Privacy Notice');
                                          },
                                          child: Text(
                                            "Privacy Notice",
                                            style: TextStyle(
                                              color: const Color(0xffADA4A5),
                                              decoration:
                                                  TextDecoration.underline,
                                              fontSize: size.height * 0.015,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                activeColor: const Color(0xff7B6F72),
                                value: checkedValue,
                                onChanged: (newValue) {
                                  setState(() {
                                    checkedValue = newValue!;
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              )
                            : SizedBox(),
                      ),
                      AnimatedPadding(
                        duration: const Duration(milliseconds: 500),
                        padding: widget.register
                            ? EdgeInsets.only(top: size.height * 0.025)
                            : EdgeInsets.only(top: size.height * 0.085),
                        child: ButtonWidget(
                          text: widget.register ? "Register" : "Login",
                          backColor: isDarkMode
                              ? [
                                  Colors.black,
                                  Colors.black,
                                ]
                              : const [Color(0xff92A3FD), Color(0xff9DCEFF)],
                          textColor: const [
                            Colors.white,
                            Colors.white,
                          ],
                          onPressed: () async {
                            if (widget.register) {
                              // Validation for registration
                              if (_usernamekey.currentState!.validate() &&
                                  _IDNamekey.currentState!.validate() &&
                                  _emailKey.currentState!.validate() &&
                                  _passwordKey.currentState!.validate() &&
                                  _confirmPasswordKey.currentState!.validate()) {
                                if (checkedValue == false) {
                                  buildSnackError('Accept our Privacy Policy and Terms of Use', context, size);
                                } else {
                                  // Register the user
                                  await registerUser();
                                }
                              }
                            } else {
                              // Validation for login
                              if (_emailKey.currentState!.validate() && _passwordKey.currentState!.validate()) {
                                await loginUser();
                              }
                            }
                          },
                        ),
                      ),
                      AnimatedPadding(
                        duration: const Duration(milliseconds: 500),
                        padding: EdgeInsets.only(
                          top: widget.register
                              ? size.height * 0.025
                              : size.height * 0.15,
                        ),
                        child: Row(
                          //TODO: replace text logo with your logo
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Login',
                              style: GoogleFonts.poppins(
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontSize: size.height * 0.045,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '+',
                              style: GoogleFonts.poppins(
                                color: const Color(0xff3b22a1),
                                fontSize: size.height * 0.06,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: widget.register
                                  ? "Already have an account? "
                                  : "Don’t have an account yet? ",
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white
                                    : const Color(0xff1D1617),
                                fontSize: size.height * 0.018,
                              ),
                            ),
                            WidgetSpan(
                              child: InkWell(
                                onTap: () => setState(() {
                                  if (widget.register) {
                                    widget.register = false;
                                  } else {
                                    widget.register = true;
                                  }
                                }),
                                child: widget.register
                                    ? Text(
                                        "Login",
                                        style: TextStyle(
                                          foreground: Paint()
                                            ..shader = const LinearGradient(
                                              colors: <Color>[
                                                Color(0xffEEA4CE),
                                                Color(0xffC58BF2),
                                              ],
                                            ).createShader(
                                              const Rect.fromLTWH(
                                                0.0,
                                                0.0,
                                                200.0,
                                                70.0,
                                              ),
                                            ),
                                          fontSize: size.height * 0.018,
                                        ),
                                      )
                                    : Text(
                                        "Register",
                                        style: TextStyle(
                                          foreground: Paint()
                                            ..shader = const LinearGradient(
                                              colors: <Color>[
                                                Color(0xffEEA4CE),
                                                Color(0xffC58BF2),
                                              ],
                                            ).createShader(
                                              const Rect.fromLTWH(
                                                  0.0, 0.0, 200.0, 70.0),
                                            ),
                                          // color: const Color(0xffC58BF2),
                                          fontSize: size.height * 0.018,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool pwVisible = false;

   buildTextField(
      TextEditingController controller,
      String hintText,
      IconData icon,
      bool password,
      size,
      FormFieldValidator? validator,
      Key? key,
      bool isDarkMode,
      TextInputType textInputType,
      bool enable,
      Widget? suffix) {
    return Padding(
      padding: EdgeInsets.only(top: size.height * 0.025),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        width: size.width * 0.9,
        height: size.height * 0.06,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black : const Color(0xffF7F8F8),
          borderRadius: const BorderRadius.all(Radius.circular(15)),
        ),
        child: Form(
          key: key,
          child: Center(
            child: TextFormField(
              controller: controller,
              enabled: enable,
              style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? const Color(0xffADA4A5) : Colors.black),
              validator: validator,
              keyboardType: textInputType,
              textInputAction: TextInputAction.next,
              obscureText: password ? !pwVisible : false,
              decoration: InputDecoration(
                errorStyle: const TextStyle(height: 0),
                hintStyle: const TextStyle(
                  fontSize: 16,
                  color: Color(0xffADA4A5),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: hintText,
                prefixIcon: Icon(
                  icon,
                  color: const Color(0xff7B6F72),
                ),
                suffixIcon: password
                    ? InkWell(
                        onTap: () {
                          setState(() {
                            pwVisible = !pwVisible;
                          });
                        },
                        child: pwVisible
                            ? const Icon(
                                Icons.visibility_off_outlined,
                                color: Color(0xff7B6F72),
                              )
                            : const Icon(
                                Icons.visibility_outlined,
                                color: Color(0xff7B6F72),
                              ),
                      )
                    : suffix,
              ),
            ),
          ),
        ),
      ),
    );
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> buildSnackError(
      String error, context, size) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.black,
        content: SizedBox(
          height:50,
          child: Center(
            child: Text(error),
          ),
        ),
      ),
    );
  }
}
