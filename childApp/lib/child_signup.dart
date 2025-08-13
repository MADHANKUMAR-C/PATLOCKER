import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parent_control/children.dart';

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
  TextEditingController _parentCodeController = TextEditingController();
  bool isSignup = true;
  bool signUp=false;

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _parentCodeController.dispose();
    super.dispose();
  }
    Future<String> checkParentId(String parentId) async {
    return await FirebaseFirestore.instance
        .collection('parents')
        .where('parentId', isEqualTo: parentId)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        return value.docs[0]['userId'];
      }
      return value.docs[0]['userId'];
    });
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
                    hintText: 'Name of Child',
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
                  controller: _parentCodeController,
                  decoration: const InputDecoration(
                    hintText: 'Enter Parent Code',
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
                    String parentId=await checkParentId(_parentCodeController.text);
                    if(parentId.isNotEmpty){
                          UserCredential credential =
                        await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: _emailController.text,
                      password: _passController.text,);
                        Children children = Children(
                          credential.user!.uid,
                          _nameController.text,
                          _ageController.text,
                          'Android',
                          [],
                          _parentCodeController.text,parentId,
                        );
                        await FirebaseFirestore.instance
                            .collection('childrens')
                            .doc(credential.user!.uid.isNotEmpty ? credential.user!.uid : null)
                            .set(children.toJSON());
                            setState(() {
                        _emailController.text = '';
                        _passController.text = '';
                        _parentCodeController.text='';
                        _nameController.text='';
                        _ageController.text='';
                      });
                            setState(() {
                              signUp=true;
                            });
                            if(!isSignup){
                              setState(() {
                              isSignup=true;
                            });
                            }}
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