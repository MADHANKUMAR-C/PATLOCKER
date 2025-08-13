
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parent_control/app_information.dart';

class AppUsageDetails extends StatefulWidget {
  final String childId;
  final AppInformation appInformation;
  final int appIndex;

  AppUsageDetails({Key? key, required this.childId, required this.appInformation, required this.appIndex}) : super(key: key);

  @override
  _AppUsageDetailsState createState() => _AppUsageDetailsState();
}

class _AppUsageDetailsState extends State<AppUsageDetails> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController _limitTimeController;
  bool _isBlocked = false;

  @override
  void initState() {
    super.initState();
    _limitTimeController = TextEditingController(text: widget.appInformation.limitTime.toString());
    _isBlocked = widget.appInformation.isBlocked ;
  }

  @override
  void dispose() {
    _limitTimeController.dispose();
    super.dispose();
  }

  void _updateAppSettings() async {
    DocumentReference docRef = _firestore.collection('childrens').doc(widget.childId);

    // Fetch the document
    DocumentSnapshot docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      List<dynamic> appInformation = docSnapshot['appInformation'];

      // Update the specific app information
      appInformation[widget.appIndex]['limitTime'] = int.parse(_limitTimeController.text);
      appInformation[widget.appIndex]['isBlocked'] = _isBlocked;

      // Update the document with the modified appInformation array
      await docRef.update({'appInformation': appInformation}).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Settings updated successfully')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appInformation.appName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App Usage Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Screen Time: ${(int.parse(widget.appInformation.screenTime) / 1000 / 60).toStringAsFixed(1)} mins'),
            SizedBox(height: 8),
            Text('Last Used: ${DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(int.parse(widget.appInformation.lastUsed)))}'),
            SizedBox(height: 8),
            TextField(
              controller: _limitTimeController,
              decoration: InputDecoration(
                labelText: 'Set Time Limit (ms)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Block App:'),
                Switch(
                  value: _isBlocked,
                  onChanged: (value) {
                    setState(() {
                      _isBlocked = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _updateAppSettings,
              child: Text('Update Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
