import 'package:flutter/material.dart';

class blockedPage extends StatefulWidget {
  final String title;
  const blockedPage({super.key, required this.title});

  @override
  State<blockedPage> createState() => _blockedPageState();
}

class _blockedPageState extends State<blockedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title),),
      body: Container(
        child:Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
              margin: EdgeInsets.only(top: 20),
              child: const Text(
                "App will not be able to open due to excessive usage!",
                style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
              
            ],
          ),
        )
      )
    );
  }
}