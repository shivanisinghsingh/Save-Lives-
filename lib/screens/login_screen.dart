
import 'package:savelives/screens/loading.dart';
import 'package:savelives/screens/selection.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/donor.dart';
import 'edit_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:geolocator/geolocator.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final GoogleSignIn googleSignIn = GoogleSignIn();
//  final StorageReference storageRef = FirebaseStorage.instance.ref();
  final donorRef = Firestore.instance.collection('donor');
//
  Donor currentUser;
  bool wannaSearch = false;

  TextEditingController  userBloodQuery = TextEditingController();
  TextEditingController userLocationQuery = TextEditingController();

  List<dynamic> donors = [];
//
//
  @override
  void initState() {
    super.initState();
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

    showDonors(context);

  }

  bool isAuth=false;

  loginWithGoogle()async{
    await googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  getUserLocation() async {
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.lowest);
    List<Placemark> placemarks= await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String completeAddress = '${placemark.locality}';
    userLocationQuery.text = completeAddress;
  }

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

  showDonors(context) async {

    final QuerySnapshot snapshot = await donorRef.getDocuments();

    setState(() {
      donors = snapshot.documents;
    });
  }
//


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



  StreamBuilder showSearchResults(){

    return StreamBuilder(
      stream: donorRef.orderBy('location')
          .where('locationSearch', arrayContains: userLocationQuery.text)
          .where('bloodGroup', isEqualTo: userBloodQuery.text)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularLoading();
        }
        print(userBloodQuery.text);
        List<ShowDonors> allDonors = [];
        snapshot.data.documents.forEach((doc) {
          allDonors.add(ShowDonors.fromDocument(doc));
        });

        return Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              allDonors.length==0?Text("No Donors Found"):Column(
                children: allDonors,
              ),
            ],
          ),
        );

      },
    );

  }

  Scaffold unAuthScreen(){
    return Scaffold(
        body: !isAuth?Container(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.only(left: 35.0, right: 20.0,),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(padding: EdgeInsets.only(top: 10.0, bottom: 60.0),child: Text("Sign In", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 50.0 ),)),
                Container(padding: EdgeInsets.only(top: 20.0, bottom: 40.0),child: Image.asset('assets/img/logo.png', height: MediaQuery.of(context).size.height*0.2,)),
                Container(
                    padding: const EdgeInsets.only(top:20.0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          color: Colors.white,
                          height:30.0,
                          child: Image.asset('assets/img/g_logo.png',),
                        ),
                        Container(
                          height: 50.0,
                          width: MediaQuery.of(context).size.width*.7,
                          child: MaterialButton(
                            onPressed:loginWithGoogle,
                            child: Text("Continue with Google", style: TextStyle(color: Colors.red, fontFamily: "Gotham", fontSize: 20.0 ),),
                            color:Colors.white ,
                          ),
                        ),
                      ],
                    )
                ),
              ],
            ),
          ),
        ):Center(child: CircularProgressIndicator(backgroundColor: Colors.red,),)
    );
  }


  @override
  Widget build(BuildContext context) {
    return !isAuth?unAuthScreen():sc();


  }
}

class ShowDonors extends StatelessWidget {

  final String displayName;
  final String photoUrl;
  final String location;
  final String bloodGroup;
  final String gender;
  final String phoneNumber;

  ShowDonors({
    this.displayName,
    this.location,
    this.photoUrl,
    this.phoneNumber,
    this.bloodGroup,
    this.gender,
  });

  factory ShowDonors.fromDocument(DocumentSnapshot doc) {
    return ShowDonors(
      displayName: doc['displayName'],
      location: doc['location'],
      bloodGroup: doc['bloodGroup'],
      photoUrl: doc['photoUrl'],
      phoneNumber: doc['phoneNumber'],
      gender: doc['gender'],
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(shadowColor: Colors.black,elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(elevation: 4,shadowColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  child: CircleAvatar(radius: 35,
                    backgroundImage: NetworkImage("$photoUrl"),),
                ),
              ),
              Expanded(child: Container(decoration: BoxDecoration(),
                child: Column(mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(height: 24,width: double.infinity,child: Text("$displayName",style: TextStyle(fontSize:20,color: Colors.black),),),
                    Container(height: 24,width: double.infinity,child: Text("$gender"),),
                    Container(height: 24,width: double.infinity,child: Text("$location"),),
                    Expanded(child: MaterialButton(elevation: 2,minWidth: 50,color: Colors.red,onPressed: (){_launchURL("tel:$phoneNumber");},
                        child: Text("Call Now",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),))),
                  ],
                ),
              )),
              Container(height: 70,width: 70,
                child: Stack(
                  children: [
                    Center(
                      child: Container(height: 70,width: 70,decoration: BoxDecoration(
                        image: DecorationImage(image:AssetImage("assets/img/drop2.png"),fit: BoxFit.fill),),
                      ),
                    ),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 25),
                          child: Text("$bloodGroup",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),),
                        ))
                  ],
                ),
              )
            ],
          ),

        ),
      ),
    );

  }
}



