import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:perfect_pose/widgets/bottom_bar.dart';
import 'package:perfect_pose/widgets/settings_modal.dart';
import 'package:perfect_pose/widgets/top_app_bar.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _selectedItem = "All Exercises";

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: top_app_bar(
          centerText: "History",
          onSettingsTap: () => showSettingsModal(context)),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Filter By Text Container
                Container(
                  height: 45,
                  margin: EdgeInsets.only(
                    top: screenWidth * 0.0775,
                    right: screenWidth * 0.1,
                  ),
                  child: Text(
                    'Filter by:',
                    style: TextStyle(
                        fontSize: screenWidth * 0.0675,
                        fontWeight: FontWeight.bold),
                  ),
                ),

                // DropdownMenu
                Container(
                  alignment: Alignment.center,
                  width: 150,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 223, 224, 224),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButton<String>(
                    iconSize: 30,
                    iconEnabledColor: Colors.black,
                    icon: const Icon(Icons.keyboard_arrow_down_sharp),
                    underline: Container(),
                    isExpanded: true,
                    value: _selectedItem,
                    items: [
                      _buildDropdownMenuItem(context, "All Exercises"),
                      _buildDropdownMenuItem(context, "Bodyweight"),
                      _buildDropdownMenuItem(context, "Functional"),
                      _buildDropdownMenuItem(context, "Lifting"),
                      _buildDropdownMenuItem(context, "Yoga"),
                    ],
                    onChanged: (String? value) {
                      setState(() {
                        _selectedItem = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.only(top: 20)),

            // StreamBuilder to display exercises from Firebase
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(_auth.currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading history'));
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: Text('No history found'));
                  }

                  // Extract the 'pose' array from the document
                  var poseData =
                      snapshot.data!.get('pose') as List<dynamic>? ?? [];

                  if (poseData.isEmpty) {
                    return const Center(child: Text('No history found'));
                  }

                  // Filter exercises based on _selectedItem
                  var filteredExercises = poseData.where((pose) {
                    return _selectedItem == "All Exercises" ||
                        pose['category'] == _selectedItem.toLowerCase();
                  }).toList();

                  if (filteredExercises.isEmpty) {
                    return const Center(child: Text('No history found'));
                  }

                  return ListView.builder(
                    itemCount: filteredExercises.length,
                    itemBuilder: (context, index) {
                      var exercise = filteredExercises[index];
                      String category = exercise['category'] ?? 'Unknown';
                      String pose = exercise['pose'] ?? 'Unknown';
                      double score = (exercise['similarity_score'] ?? 0) *100; 
                      Timestamp timestamp = exercise['timestamp'] ?? Timestamp.now();

                      _buildHistoryContainer(context, "Bodyweight", "john Pork", 21, Timestamp.now());
                      return _buildHistoryContainer(
                        context,
                        category,
                        pose,
                        score,
                        timestamp,
                      );
                      
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const bottom_bar(),
    );
  }

  // Helper method to create exercise containers with dynamic font sizing
  Widget _buildHistoryContainer(BuildContext context, String category,
      String pose, double score, Timestamp timestamp) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double fontSizeExercise = screenWidth * 0.0675;
    double fontSizeDate = screenWidth * 0.05;
    double fontSizeScore = screenWidth * 0.0515;
    double fontSizeViewDetails = screenWidth * 0.045;
    String yesterday = DateFormat('MM/dd/yyyy').format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - 1));
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

  // Helper method to create dropdown menu items with dynamic font sizing
  DropdownMenuItem<String> _buildDropdownMenuItem(
      BuildContext context, String text) {
    double screenWidth = MediaQuery.of(context).size.width;
    return DropdownMenuItem(
      value: text,
      child: Align(
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(fontSize: screenWidth * 0.04),
          )),
    );
  }
}
