import 'dart:async';

import 'package:savelives/model/donor.dart';
import 'package:savelives/screens/login_screen.dart';
import 'package:savelives/screens/selection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {



  handleSignIn(GoogleSignInAccount account) {
    if (account != null) {
      createUserInFireStore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFireStore() async {
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await donorRef.document(user.id).get();

    if (!doc.exists) {

      // 3) get username from create account, use it to make new user document in users collection
      donorRef.document(user.id).setData({
        "id": user.id,
        "displayName": user.displayName,
        "photoUrl": user.photoUrl,
        "location": "",
        "locationSearch":"",
        "phoneNumber":"",
        "bloodGroup":"",
        'gender':"",
        'dateOfBirth':"",
      });

      doc = await donorRef.document(user.id).get();
    }

    currentUser = Donor.fromDocument(doc);

  }
//  final StorageReference storageRef = FirebaseStorage.instance.ref();
  final donorRef = Firestore.instance.collection('donor');
//
  Donor currentUser;
  bool wannaSearch = false;

  final GoogleSignIn googleSignIn = GoogleSignIn();
  @override
  void initState() {

    // Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account)async {
      await handleSignIn(account);
    }, onError: (err) {
      print('Error signing in: $err');
    });

    // Re-authenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) async{
      await handleSignIn(account);
    }).catchError((err) {
      print('Error signing in: $err');
    });
    Timer(
        Duration(seconds: 3), () => Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => isAuth?sc():LoginScreen())));


    super.initState();

  }

  bool isAuth=false;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment:MainAxisAlignment.center,
          children: [
            Image.asset('assets/img/logo.png', width: 200.0,),
            SizedBox(height: 20,),
            CircularProgressIndicator(backgroundColor: Colors.red,)
          ],
        ),

      ),
    );
  }
}
