import 'package:flutter/material.dart';
import 'package:parent_control/child_signin.dart';

class SigninOptions extends StatefulWidget {
  static String routename='signinoptions';
  const SigninOptions({super.key});

  @override
  State<SigninOptions> createState() => _SigninOptionsState();
}
class _SigninOptionsState extends State<SigninOptions> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.4,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: isHover
                      ? Color.fromARGB(255, 224, 27, 201)
                      : Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    return const ChildSigninPage(title: 'Child', isParent: false);
                  }));
                },
                child: const Text(
                  'Login as Child',
                  style: TextStyle(color: Colors.white),
                ),
                onHover: (isHovered) {
                  setState(() {
                    isHover = isHovered;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}