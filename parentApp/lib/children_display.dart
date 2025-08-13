import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parent_control/children.dart';
import 'package:parent_control/children_details.dart';

class ChildrenDisplay extends StatefulWidget {
  const ChildrenDisplay({super.key});

  @override
  State<ChildrenDisplay> createState() => _ChildrenDisplayState();
}

class _ChildrenDisplayState extends State<ChildrenDisplay> {
  String? parentUserId;

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  getCurrentUser() async {
    var user = await FirebaseAuth.instance.currentUser;
    setState(() {
      parentUserId = user!.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Child Informations'),
      ),
      body: Container(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('childrens')
              .where('parentUserId', isEqualTo: parentUserId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data!.docs;
              return snapshot.data!.docs.isNotEmpty ? ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Children child = Children.fromMap(data[index].data());
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return ChildrenDetails(data: child, childId: child.userId,);
                          },
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.1,
                        width: MediaQuery.of(context).size.width * 0.65,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Color.fromARGB(255, 223, 131, 226),
                        ),
                        child: Center(
                          child: Text(
                            '${data[index]['name']}',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ): const Center(child: Text('There is no children associated with this parent till now', style: TextStyle(color: Colors.black),));
            }
            return Container(
              child: Center(child: Text('There is no children associated with this parent till now', style: TextStyle(color: Colors.black),)),
            );
          },
        ),
      ),
    );
  }
}
