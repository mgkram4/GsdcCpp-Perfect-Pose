import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:perfect_pose/services/auth_service.dart';
import 'package:perfect_pose/widgets/bottom_bar.dart';
import 'package:perfect_pose/widgets/settings_modal.dart';
import 'package:perfect_pose/widgets/top_app_bar.dart';
import 'package:intl/intl.dart';

final user = AuthService();

class ProfilePage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: top_app_bar(
        centerText: 'User Profile',
        onSettingsTap: () => showSettingsModal(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.01,
            ),
            child: Column(
              children: [
                // StreamBuilder to display username from firebase
                StreamBuilder<DocumentSnapshot>(
                    stream: _firestore
                        .collection('users')
                        .doc(_auth.currentUser!.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const Center(child: Text('No user data available'));
                      }

                      final userData = snapshot.data!.data() as Map<String, dynamic>;
                      final username = userData['email'] ?? 'Unknown';
                      
                      // Profile Settings Container
                      return Container(
                        height: screenHeight * 0.14,
                        margin: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.01,
                          vertical: screenHeight * 0.01,
                        ),
                        padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              offset: const Offset(0, 3),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Username Text
                                Text(
                                  username,
                                  style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // Logout Button
                                GestureDetector(
                                  onTap: () async {
                                    try {
                                      await user.signOut();
                                      // Navigate to login page or home page after logout
                                      Navigator.of(context)
                                          .pushReplacementNamed('/login');
                                    } catch (e) {
                                      // Show error message
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text('Failed to log out: $e')),
                                      );
                                    }
                                  },
                                  child: Text(
                                    'Logout',
                                    style: TextStyle(
                                      color: Colors.red[300],
                                      fontSize: 25,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.red[300],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Change Profile Picture Button
                                GestureDetector(
                                  onTap: () {
                                    // Add change profile picture functionality here
                                  },
                                  child: const Text(
                                    'Change PFP',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                      decorationColor: Colors.grey,
                                    ),
                                  ),
                                ),
                                // Reset Password Button
                                GestureDetector(
                                  onTap: () {
                                    // Add reset password functionality here
                                  },
                                  child: const Text(
                                    'Reset Password',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                      decorationColor: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),

                // Recent Activities Header
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.01,
                    vertical: screenHeight * 0.01,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        offset: const Offset(0, 3),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Recent Activities',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // StreamBuilder to display recent activities from firebase
                StreamBuilder<DocumentSnapshot>(
                  stream: _firestore
                      .collection('users')
                      .doc(_auth.currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Center(child: Text('No user data available'));
                    }

                    // Extract the 'pose' array from the document
                    var poseData = snapshot.data!.get('pose') as List<dynamic>? ?? [];

                    if (poseData.isEmpty) {
                      return const Center(child: Text('No history found'));
                    }
                    
                    // Get recent exercises from the past recentActivitiyDays days
                    const recentActivitiyDays = 30;
                    var recentActivities = poseData.where((pose) {
                      return pose['timestamp'].toDate().isAfter(
                        DateTime.now().subtract(const Duration(days: recentActivitiyDays)));
                    }).toList();

                    return SizedBox(
                      height: screenHeight * 0.4,
                      child: ListView.builder(
                        itemCount: recentActivities.length,
                        itemBuilder: (context, index) {
                          var exercise = recentActivities[index];
                          String pose = exercise['pose'] ?? 'Unknown';
                          double score = (exercise['similarity_score'] ?? 0) * 100;
                          Timestamp timestamp = exercise['timestamp'] ?? Timestamp.now();

                          return _buildHistoryContainer(
                            context,
                            pose,
                            score,
                            timestamp,
                          );
                        },
                      ),
                    );
                  },
                ),

                // Delete Account Button
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.01,
                    vertical: screenHeight * 0.01,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // Add delete account functionality here
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red[300],
                      elevation: 5,
                    ),
                    child: Text(
                      'Delete Account',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.red[300],
                        color: Colors.red[300],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const bottom_bar(),
    );
  }

// Helper method to create exercise containers with dynamic font sizing
  Widget _buildHistoryContainer(
      BuildContext context, String pose, double score, Timestamp timestamp) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double fontSizeExercise = screenWidth * 0.0675;
    double fontSizeDate = screenWidth * 0.05;
    double fontSizeScore = screenWidth * 0.0515;
    double fontSizeViewDetails = screenWidth * 0.045;
    String yesterday = DateFormat('MM/dd/yyyy').format(DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day - 1));
    String date = DateFormat('MM/dd/yyyy').format(timestamp.toDate());

    return Container(
      height: screenHeight * 0.18,
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.01,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 1),
            blurRadius: 5,
            color: const Color.fromARGB(255, 98, 97, 97).withOpacity(0.3),
          ),
        ],
      ),
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  pose[0].toUpperCase() + pose.substring(1, pose.length),
                  style: TextStyle(
                      fontSize: fontSizeExercise, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.clip,
                  maxLines: 1,
                ),
              ),
              Text(
                (date != yesterday) ? date : "Yesterday",
                style: TextStyle(
                    fontSize: fontSizeDate,
                    color: const Color.fromARGB(255, 141, 141, 141)),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Form score: ${score.toStringAsFixed(0)}/100",
                style: TextStyle(fontSize: fontSizeScore),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "View Details",
                style: TextStyle(
                    fontSize: fontSizeViewDetails,
                    color: const Color.fromARGB(255, 3, 123, 244)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
