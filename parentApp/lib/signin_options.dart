import 'package:flutter/material.dart';
import 'package:parent_control/parent_signin.dart';

class SigninOptions extends StatefulWidget {
  static String routename='signinoptions';
  const SigninOptions({super.key});

  @override
  State<SigninOptions> createState() => _SigninOptionsState();
}

class _SigninOptionsState extends State<SigninOptions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child:Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width*0.4,
                decoration: const BoxDecoration(),
                child: TextButton(style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  )
                ),onPressed:(){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return const ParentSigninPage(title:'Parent',isParent:true);
                  }));
                } ,child:const Text('Login as Parent',style: TextStyle(color: Colors.white),))
              )
              
            ],
          ),
        )
      )
    );
  }
}