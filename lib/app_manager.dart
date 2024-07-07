import 'package:cloud_gallery/gallery.dart';
import 'package:cloud_gallery/login_page.dart';
import 'package:cloud_gallery/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppManager extends StatefulWidget{
  const AppManager({super.key});

  @override
  State<AppManager> createState() => _AppManagerState();
}

class _AppManagerState extends State<AppManager> {
  bool hasAccount = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot){
        if (snapshot.hasData){
          return Gallery();
        }else{
          return pageToReturn();
        }
      },
      )
    );
  }

  Future togglePages() async{
    setState(() {
      hasAccount=!hasAccount;      
    });
  }

  Widget pageToReturn(){
    if(hasAccount){
      return LoginPage(signUpPage: togglePages,);
    }else{
      return SignupPage(logInPage: togglePages,);
    }
  }
}