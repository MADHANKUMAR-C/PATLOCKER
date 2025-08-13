import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parent_control/parent.dart';

class newSignIn extends StatefulWidget {
  final String title;
  const newSignIn({super.key, required this.title});

  @override
  State<newSignIn> createState() => _newSignInState();
}

class _newSignInState extends State<newSignIn> {
  TextEditingController _ageController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passController = TextEditingController();
  bool isSignup = true;
  bool signUp=false;

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }
  String generateRandomCode() {
    const String alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    const int codeLength = 6;
    final Random random = Random();
    String code = '';

    for (int i = 0; i < codeLength; i++) {
      final int randomIndex = random.nextInt(alphabet.length);
      code += alphabet[randomIndex];
    }
    return code;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.title} '),),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: 
            Container(
              width: MediaQuery.of(context).size.width * 0.75,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(width: 2, color: Colors.grey),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Name of Parent',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Container(
              width: MediaQuery.of(context).size.width * 0.75,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(width: 2, color: Colors.grey),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: TextField(
                  controller: _ageController,
                  decoration: const InputDecoration(
                    hintText: 'Age',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Container(
              width: MediaQuery.of(context).size.width * 0.75,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(width: 2, color: Colors.grey),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Email ID',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          Container(
            width: MediaQuery.of(context).size.width * 0.75,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(width: 2, color: Colors.grey),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: TextField(
                controller: _passController,
                decoration: const InputDecoration(
                  hintText: 'Password',
                  border: InputBorder.none,
                ),
                obscureText: true,
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          if(signUp)
          Container(
              margin: EdgeInsets.only(top: 20),
              child: const Text(
                'Account Created. Please login',
                style: TextStyle(color: Color.fromARGB(255, 24, 170, 203)),
              ),
            ),
          if (!isSignup)
            Container(
              margin: EdgeInsets.only(top: 20),
              child: const Text(
                'Error occured. Please try after some time',
                style: TextStyle(color: Colors.red),
              ),
            ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            decoration: const BoxDecoration(),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 99, 208, 132),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () async {
                try {
                  if (_emailController.text.isNotEmpty &&
                      _passController.text.isNotEmpty) {
                    UserCredential credential =
                        await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: _emailController.text,
                      password: _passController.text,
                    );
                      String parentId = generateRandomCode(); // Generate Parent ID
                      Parent parent = Parent(
                          credential.user!.uid,
                          _nameController.text,
                          _ageController.text,
                          'Android',
                          [],
                          parentId,
                        );
                        await FirebaseFirestore.instance
                            .collection('parents')
                            .doc(credential.user!.uid.isNotEmpty ? credential.user!.uid : null)
                            .set(parent.toJSON());
                            setState(() {
                              signUp=true;
                            });
                            
                      setState(() {
                        _emailController.text = '';
                        _passController.text = '';
                        _ageController.text='';
                        _nameController.text='';
                      });
                    }
                    else{
                      setState(() {
                    isSignup = !isSignup;
                  });
                    }}
                 catch (e) {
                  setState(() {
                    isSignup = !isSignup;
                  });
                }
              },
              child: const Text(
                'Click here to Signup!',
                style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}