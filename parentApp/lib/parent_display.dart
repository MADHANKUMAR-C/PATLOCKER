import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parent_control/children_display.dart';
import 'package:parent_control/myhome_page.dart';
import 'package:parent_control/signin_options.dart';

class ParentDisplay extends StatefulWidget {
  final bool isParent;
  const ParentDisplay({super.key, required this.isParent});

  @override
  State<ParentDisplay> createState() => _ParentDisplayState();
}

class _ParentDisplayState extends State<ParentDisplay> {
  String? docId;
  String? parentId;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  getCurrentUser() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        docId = user.uid;
      });
      getParentId(docId);
    }
  }

  getParentId(String? docId) async {
    if (docId != null) {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('parents')
          .where('userId', isEqualTo: docId)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          parentId = querySnapshot.docs[0]['parentId'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details...'),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamed(SigninOptions.routename);
            },
            icon: const Icon(Icons.login_rounded, color: Colors.black),
          ),
        ],
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              margin: EdgeInsets.only(right: 16, top: 16),
              child: Text(
                parentId != null ? 'PARENT ID: $parentId' : 'Loading...',
                style: TextStyle(color: Color.fromARGB(255, 255, 0, 0), fontSize: 18),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) {
                          return MyHomePage(title: 'PATLOCKER', isParent: true);
                        },
                      ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.2,
                        width: MediaQuery.of(context).size.width * 0.7,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 138, 97, 214),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Center(
                          child: Text(
                            'My usage details',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) {
                          return const ChildrenDisplay();
                        },
                      ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.2,
                        width: MediaQuery.of(context).size.width * 0.7,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 138, 97, 214),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Center(
                          child: Text(
                            'Child usage details',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
