import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String title; // Title text
  final bool enable;
  final String hintText; // Hint text for the TextField
  final TextEditingController controller; // Controller for input
  final double borderRadius; // Border radius for rounded corners
  final bool obscureText; // To hide text input (for password fields)
  final TextInputType keyboardType; // Input type (text, number, email, etc.)

  const CustomTextField({
    Key? key,
    required this.title,
    required this.hintText,
    required this.controller,
    this.borderRadius = 12.0, // Default radius
    this.obscureText = false, // Default not obscure
    this.keyboardType = TextInputType.text, required this.enable, // Default text input
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title above the TextField
          Text(
            title,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8.0),
          // Custom TextField with rounded border
          TextField(
            enabled: enable,
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey,fontWeight: FontWeight.w500,fontSize: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(color: Colors.blue, width: 2.0),
// Rounded corners
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(color: Colors.blue, width: 2.0),
              ),
disabledBorder:   OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
          ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            ),
          ),
        ],
      ),
    );
  }
}
