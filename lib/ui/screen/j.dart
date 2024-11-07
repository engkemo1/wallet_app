import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wallet_app/util/constant.dart';

class WalletDetailsScreen extends StatefulWidget {
  final String collectionName;
  final String title;
  final String id;

  WalletDetailsScreen({required this.collectionName, required this.id, required this.title});

  @override
  _WalletDetailsScreenState createState() => _WalletDetailsScreenState();
}

class _WalletDetailsScreenState extends State<WalletDetailsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _walletDataList = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Function to fetch all documents from Firestore collection
  Future<void> _fetchData() async {
    var userId=FirebaseAuth.instance.currentUser!.uid;

    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection(widget.collectionName.replaceAll(" ", ""))
          .where('userId', isEqualTo:userId ) // Filter by user ID
          .get();

      setState(() {
        _walletDataList = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching data: $e')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(widget.title,style: TextStyle(color: Colors.white),),
        backgroundColor: COLOR_PRIMARY,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _walletDataList.isEmpty
          ? const Center(child: Text("No data found"))
          : Padding(
        padding: const EdgeInsets.all(12.0),
        child:SizedBox(
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
             children: List.generate(_walletDataList.length, (index)=>
                 _buildWalletCard(_walletDataList[index])


                  ),
                ),
          ),
        )));
  }

  // Function to build a compact card for each wallet document
// Function to build a compact card for each wallet document
  Widget _buildWalletCard(Map<String, dynamic> walletData) {
    String? imageUrl = walletData['imageURL'];
    DateTime? createdAt;

    // Handle 'createdAt' field if it exists
    if (walletData.containsKey('createdAt') && walletData['createdAt'] != null) {
      createdAt = (walletData['createdAt'] as Timestamp).toDate(); // Assuming it's a Firestore Timestamp
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shadowColor: Colors.black12,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 10),
            if (createdAt != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.grey[600],
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Created: ${_formatDate(createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            Wrap(
              children: _buildDynamicFields(walletData),
            ),
          ],
        ),
      ),
    );
  }

// Helper function to format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Function to build dynamic fields in a compact and modern style
  List<Widget> _buildDynamicFields(Map<String, dynamic> walletData) {
    List<Widget> fields = [];
    walletData.forEach((key, value) {
      if (key != 'imageURL' && key != 'createdAt') {
        fields.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 10),
            child: Wrap(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    _getIconForField(key),
                    color: Colors.blueAccent,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                FittedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatKey(key),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });
    return fields;
  }

  // Helper function to format keys for better display
  String _formatKey(String key) {
    return key[0].toUpperCase() +
        key.substring(1).replaceAll(RegExp(r'([A-Z])'), ' \$1');
  }

  // Helper function to get icons for specific fields
  IconData _getIconForField(String key) {
    switch (key) {
      case 'balance':
        return Icons.account_balance_wallet;
      case 'transaction':
        return Icons.swap_horiz;
      case 'name':
        return Icons.person_outline;
      case 'date':
        return Icons.calendar_today;
      default:
        return Icons.info_outline;
    }
  }
}
