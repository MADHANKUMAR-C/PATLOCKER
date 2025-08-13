import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parent_control/child_signup.dart';
import 'package:parent_control/myhome_page.dart';

class ChildSigninPage extends StatefulWidget {
  final String title;
  final bool isParent;

  const ChildSigninPage({Key? key, required this.title, required this.isParent}) : super(key: key);
  @override
  State<ChildSigninPage> createState() => _ChildSigninPageState();
}

class _ChildSigninPageState extends State<ChildSigninPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passController = TextEditingController();
  bool isSignup = true;
  bool child=false;
  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} Signin'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
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
                    hintText: 'Mail ID',
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
          if (!isSignup)
            Container(
              margin: EdgeInsets.only(top: 20),
              child: const Text(
                "User credentials doesn't not match.",
                style: TextStyle(color: Colors.red),
              ),
            ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            decoration: const BoxDecoration(),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () async {
                try {
                  if (_emailController.text.isNotEmpty &&
                      _passController.text.isNotEmpty) {
                    UserCredential credential =
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: _emailController.text,
                      password: _passController.text,
                    );
                    if (credential.user != null) {
                        Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) {
                          return MyHomePage(title: 'KIDLOCKER', isParent: false);
                        },
                      ));
                      }
                    } else {
                      setState(() {
                        isSignup = !isSignup;
                      });
                    }
                  }
                 catch (e) {
                  print(e);
                  setState(() {
                    isSignup = !isSignup;
                  });
                }
              },
              child: const Text(
                'Signin',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            decoration: const BoxDecoration(),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () async {
                Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) {
                          return newSignIn(title: 'Child SignUp');
                        },
                      ));
              },
              child: const Text(
                'New User?',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
