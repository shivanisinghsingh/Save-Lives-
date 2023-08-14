
import 'dart:io';
import 'dart:async';

import 'package:savelives/model/donor.dart';
import 'package:savelives/screens/campaign_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:savelives/screens/blood_requests.dart';
import 'package:savelives/screens/drawer.dart';
import 'package:savelives/screens/edit_profile.dart';
import 'package:savelives/screens/loading.dart';
import 'package:savelives/screens/login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class selection extends StatefulWidget {


   @override
   State<selection> createState() => _selectionState();

 }

 class _selectionState extends State<selection> {

   final GoogleSignIn googleSignIn = GoogleSignIn();
//  final StorageReference storageRef = FirebaseStorage.instance.ref();
   final donorRef = Firestore.instance.collection('donor');
//
   Donor currentUser;
   Campaign camp_currentUser;
   bool wannaSearch = false;

   TextEditingController userBloodQuery = TextEditingController();
   TextEditingController userLocationQuery = TextEditingController();

   List<dynamic> donors = [];
//
//
   @override
   void initState() {
     // Detects when user signed in
     googleSignIn.onCurrentUserChanged.listen((account){
       handleSignIn(account);
     }, onError: (err) {
       print('Error signing in: $err');
     });

     // Re-authenticate user when app is opened
     googleSignIn.signInSilently(suppressErrors: false).then((account){
       handleSignIn(account);
     }).catchError((err) {
       print('Error signing in: $err');
     });

     showDonors(context);
     // showCampaigns(context);

     super.initState();


   }

   bool isAuth=false;
   loginWithGoogle(){
     googleSignIn.signIn();
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



   StreamBuilder showSearchResults() {
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
           height: MediaQuery
               .of(context)
               .size
               .height,
           child: Column(
             children: <Widget>[
               allDonors.length == 0 ? Text("No Donors Found") : Column(
                 children: allDonors,
               ),
             ],
           ),
         );
       },
     );
   }
   
   @override
   Widget build(BuildContext context) {
     return  Scaffold(

       body: Stack(
         children: [
           Image.asset("assets/img/1.png",height:200 ,fit: BoxFit.fill,),
           Center(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Image.asset("assets/img/drop2.png",height:120,),
                 Text("Save Lives", style: TextStyle(color: Colors.red, fontSize: 35.0,fontWeight: FontWeight.bold)),
               SizedBox(height: 100,),
                 Column(
                   children: [
                     Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Container(
                           height: 60,
                           width: 140,
                           decoration:BoxDecoration(
                               // color: Colors.white,
                               border: Border.all(color: Colors.red),
                               borderRadius: BorderRadius.circular(40),
                               // boxShadow: [
                               //   BoxShadow(
                               //       color: Colors.red.shade100,
                               //       spreadRadius: 0.4,
                               //       blurRadius: 5)]
                           ) ,
                           child:InkWell(
                               splashColor: Colors.red,borderRadius: BorderRadius.circular(40),
                               onTap: (){

                                 Navigator.push(context, MaterialPageRoute(builder: (context)=>isAuth?RequestBlood(currentUser):LoginScreen()));
                               },child: Container(color: Colors.transparent,
                               child: Center(child: Text("Request For Blood",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.red,),)))) ,
                         ),
                         SizedBox(width:25),
                         Container(
                           height: 60,
                           width: 140,
                           decoration:BoxDecoration(
                             // color: Colors.white,
                             border: Border.all(color: Colors.red),
                             borderRadius: BorderRadius.circular(40),
                             // boxShadow: [
                             //   BoxShadow(
                             //       color: Colors.red.shade100,
                             //       spreadRadius: 0.4,
                             //       blurRadius: 5)]
                           ) ,
                           child:InkWell(
                               splashColor: Colors.red,borderRadius: BorderRadius.circular(40),
                               onTap: (){
                                   Navigator.push(context, MaterialPageRoute(builder: (context)=>isAuth?EditProfile(currentUser, authScreen()):LoginScreen()));
                               },child: Container(color: Colors.transparent,
                               child: Center(child: Text("Donate Blood",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.red,),)))) ,
                         ),

                       ],
                     ),
                     SizedBox(height: 20,),
                     Container(
                       height: 60,
                       width: 140,
                       decoration:BoxDecoration(
                         // color: Colors.white,
                         border: Border.all(color: Colors.red),
                         borderRadius: BorderRadius.circular(40),
                         // boxShadow: [
                         //   BoxShadow(
                         //       color: Colors.red.shade100,
                         //       spreadRadius: 0.4,
                         //       blurRadius: 5)]
                       ) ,
                       child:InkWell(
                           splashColor: Colors.red,borderRadius: BorderRadius.circular(40),
                           onTap: (){
                             Navigator.push(context, MaterialPageRoute(builder: (context)=>isAuth?sc():LoginScreen()));
                           },child: Container(color: Colors.transparent,
                           child: Center(child: Text("Find Donors",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.red,),)))) ,
                     ),
                   ],

                 )

               ],
             ),
           ),
           Align(alignment: Alignment.bottomCenter ,
               child: Image.asset("assets/img/2.png",height:150 ,fit: BoxFit.fill,)),
         ],
       ),
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
     );}
   Scaffold authScreen() {
     return Scaffold(
         drawer: MainDrawer(googleSignIn,currentUser),
         backgroundColor: Colors.red,
         body: NestedScrollView(

           // scrollDirection: Axis.vertical,
           headerSliverBuilder: (context, innerBoxIsScrolled) =>
           [
             SliverAppBar(

               forceElevated: innerBoxIsScrolled,
               pinned: true,
               // floating: false,
               // pinned: true,
               excludeHeaderSemantics: true,
               centerTitle: true,
               flexibleSpace: FlexibleSpaceBar(
                 title: Text("Save Lives", style: TextStyle(color: Colors.white,
                     fontWeight: FontWeight.bold,
                     fontSize: 20),),
               ),

               // leading: InkWell(onTap: (),
               //     child: Icon(Icons.menu,size: 30,color: Colors.white,)),
               // // actions: [Ico],
               expandedHeight: 100.0,

             ),
           ],
           body: Container(height: 1500,
             decoration: BoxDecoration(color: Colors.white,
                 borderRadius: BorderRadius.only(topLeft: Radius.circular(40),
                     topRight: Radius.circular(40))),
             child: ListView(physics: NeverScrollableScrollPhysics(),
               children: <Widget>[
                 Stack(
                     children: <Widget>[
                       Padding(
                         padding: const EdgeInsets.all(15.0),
                         child: Card(
                           elevation: 10,
                           shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(50)),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: <Widget>[
                               Padding(
                                 padding: const EdgeInsets.all(15.0),
                                 child: Center(child: Text("Find a Donor",
                                   style: TextStyle(fontSize: 30.0,
                                       color: Colors.red,
                                       fontWeight: FontWeight.w400),)),
                               ),
                               Container(
                                   padding: EdgeInsets.only(left: 30.0,
                                       right: 30.0,
                                       top: 10.0,
                                       bottom: 10.0),
                                   child: TextField(
                                     textInputAction: TextInputAction.next,
                                     onSubmitted: (_) =>
                                         FocusScope.of(context).nextFocus(),
                                     controller: userLocationQuery,
                                     decoration: InputDecoration(
                                       suffixIcon: IconButton(
                                           icon: Icon(Icons.my_location),
                                           onPressed: getUserLocation),
                                       border: OutlineInputBorder(
                                         borderRadius: BorderRadius.circular(
                                             10.0),
                                       ),
                                       hintText: "Location",
                                     ),
                                   )
                               ),
                               SizedBox(height: 10.0,),
                               Padding(
                                 padding: EdgeInsets.only(left: 30.0,
                                     right: 30.0,
                                     top: 10.0,
                                     bottom: 10.0),
                                 child: DropdownButtonFormField(
                                   decoration: InputDecoration(
                                       suffixIcon: IconButton(
                                           icon: Icon(Icons.clear),
                                           onPressed: () {
                                             setState(() {
                                               wannaSearch = false;
                                               userLocationQuery.clear();
                                               userBloodQuery.clear();
                                               FocusScope.of(context).unfocus();
                                             });
                                           }),
                                       border: OutlineInputBorder(
                                         borderRadius: BorderRadius.circular(
                                             10.0),
                                       )
                                   ),
                                   hint: Text("Select Blood Group"),
                                   items: [
                                     DropdownMenuItem(child: Text("A+"),
                                       value: "A+",),
                                     DropdownMenuItem(child: Text("A-"),
                                       value: "A-",),
                                     DropdownMenuItem(child: Text("B+"),
                                       value: "B+",),
                                     DropdownMenuItem(child: Text("B-"),
                                       value: "B-",),
                                     DropdownMenuItem(child: Text("AB+"),
                                       value: "AB+",),
                                     DropdownMenuItem(child: Text("AB-"),
                                       value: "AB-",),
                                     DropdownMenuItem(child: Text("O+"),
                                       value: "O+",),
                                     DropdownMenuItem(child: Text("O-"),
                                       value: "O-",),
                                   ],
                                   onChanged: (val) {
                                     setState(() {
                                       userBloodQuery.text = val;
                                     });
                                   },
                                 ),
                               ),
                               SizedBox(height: 10.0,),
                               Center(
                                 child: Padding(
                                   padding: const EdgeInsets.only(
                                       left: 20.0, bottom: 10.0),
                                   child: MaterialButton(
                                     onPressed: () {
                                       setState(() {
                                         wannaSearch = true;
                                         FocusScope.of(context).unfocus();
                                       });
                                     },
                                     color: Colors.red,
                                     child: Text("Search", style: TextStyle(
                                         fontFamily: "Gotham",
                                         fontSize: 20.0,
                                         color: Colors.white),),
                                     shape: RoundedRectangleBorder(
                                         borderRadius: BorderRadius.circular(
                                             10.0),
                                         side: BorderSide(color: Colors.red)),
                                   ),
                                 ),
                               ),
                             ],
                           ),
                         ),
                       )
                     ]
                 ),
                 SizedBox(height: 20.0,),
                 Text("  Recent Donors", style: TextStyle(
                     fontFamily: "Gotham", fontSize: 22.0, color: Colors.red),),
                 SizedBox(height: 10.0,),
                 wannaSearch ? showSearchResults() : StreamBuilder(
                   stream: donorRef.where("bloodGroup", isGreaterThan: "")
                       .snapshots(),
                   builder: (context, snapshot) {
                     if (!snapshot.hasData) {
                       return circularLoading();
                     }
                     List<ShowDonors> allDonors = [];
                     snapshot.data.documents.forEach((doc) {
                       allDonors.add(ShowDonors.fromDocument(doc));
                     });

                     return Container(
                       // height: MediaQuery.of(context).size.height,
                       child: Column(
                         children: allDonors,

                       ),
                     );
                   },
                 ),
               ],
             ),
           ),
         )


     );
   }
 }

 class sc extends StatefulWidget {

   @override
   State<sc> createState() => _scState();
 }

 class _scState extends State<sc> {






  GlobalKey<FormFieldState> _key = GlobalKey<FormFieldState>();

   final GoogleSignIn googleSignIn = GoogleSignIn();
//  final StorageReference storageRef = FirebaseStorage.instance.ref();
   final donorRef = Firestore.instance.collection('donor');
   final campRef = Firestore.instance.collection('campaign').snapshots();
   showCampaigns(context) async {

     final QuerySnapshot snapshot = await donorRef.getDocuments();

     setState(() {
       campaigns = snapshot.documents;
     });
   }
//
   Donor currentUser;
   bool wannaSearch = false;

   TextEditingController userBloodQuery = TextEditingController();
   TextEditingController userLocationQuery = TextEditingController();

   List<dynamic> donors = [];

   List<dynamic> campaigns = [];

   @override
  void dispose() {
     userBloodQuery.dispose();
    // TODO: implement dispose
    super.dispose();
  }
//
//
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

     showCampaigns(context);
     showDonors(context);
     super.initState();
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

   StreamBuilder showSearchResult(){

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
   final databaseReference = FirebaseDatabase.instance.reference();

   StreamBuilder showSearchResults(){

     return StreamBuilder(
       stream: donorRef.orderBy('location')
           .where('locationSearch', arrayContains: userLocationQuery.text)
           .where('bloodGroup', isEqualTo: userBloodQuery.text)
           .snapshots(),
       builder: (context, snapshot) {
         if (!snapshot.hasData) {
           return Center(child: Text("Try some Other requirement"));
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

   Scaffold authScreen(){
     return Scaffold(
       // appBar: AppBar(
       //   elevation: 0,
       backgroundColor: Colors.red,
       // ),
       drawer: MainDrawer(googleSignIn,currentUser),
       body: NestedScrollView(
         headerSliverBuilder: (context, innerBoxIsScrolled) =>
         [
           SliverAppBar(
             // actions: [
             //   Padding(
             //     padding: const EdgeInsets.only(right: 10),
             //     child: Icon(Icons.add_circle,size: 25,),
             //   )
             // ],
             forceElevated: innerBoxIsScrolled,
             pinned: true,
             // floating: false,
             // pinned: true,
             excludeHeaderSemantics: true,
             centerTitle: true,
             flexibleSpace: FlexibleSpaceBar(
               title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Text("Save Lives", style: TextStyle(color: Colors.white,
                       fontWeight: FontWeight.bold,
                       fontSize: 20),),
                   Padding(
                     padding: const EdgeInsets.only(right: 10),
                     child: InkWell(splashColor: Colors.white,
                       onTap: (){
                         Navigator.push(context, MaterialPageRoute(builder: (context)=>EditProfile(currentUser, authScreen())));
                       },
                         child: Row(
                           children: [
                             Text("Be a donor",style: TextStyle(fontSize: 7),),
                             Icon(Icons.add_circle,size: 25,color: Colors.white,),
                           ],
                         )),
                   )
                 ],
               ),
             ),
             expandedHeight: 130.0,
           )
         ],
         body:Container(height: 1500,
           decoration: BoxDecoration(color: Colors.white,
               borderRadius: BorderRadius.only(topLeft: Radius.circular(40),
                   topRight: Radius.circular(40))),
           child: ListView(
             children: <Widget>[
               Center(child: Text("Campaigns", style: TextStyle(fontFamily: "Gotham", fontSize: 22.0, color: Colors.black),)),
               SizedBox(height: 10.0,),
               StreamBuilder<QuerySnapshot>(
                   stream: campRef,
                   builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot){
                     if(snapshot.connectionState==ConnectionState.waiting)
                       return Center(
                         child: Container(height: 50,width: 50,
                             child: CircularProgressIndicator()),
                       );
                     if(snapshot.hasError)
                       return Text("Some error");
                     return CarouselSlider.builder(
                       
                         itemCount: snapshot.data.documents.length,
                         itemBuilder: (context,index,ini){
                           return Padding(
                             padding: const EdgeInsets.all(8.0),
                             child: Card(elevation: 4,shadowColor: Colors.black,
                               shape: RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(20)),
                               child: ClipRRect(
                                 borderRadius: BorderRadius.circular(20),
                                 child: GestureDetector(
                                   onTap: (){
                                     Navigator.push(context, MaterialPageRoute(builder: (context)=>campaign_details(
                                          name:snapshot.data.documents[index]['name'],
                                          bloodGroup:snapshot.data.documents[index]['bloodGroup'],
                                          phoneNumber:snapshot.data.documents[index]['phoneNumber'],
                                          image:snapshot.data.documents[index]['image'],
                                          location:snapshot.data.documents[index]['location'],
                                          bloodNeededDate:snapshot.data.documents[index]['bloodNeededDate']
                                     )));
                                   },
                                   child: snapshot.data.documents==null?Text("Campaign Not Available"): Image.network(
                                     snapshot.data.documents[index]['image'],fit: BoxFit.fill,width: double.infinity,height: 200,
                                     loadingBuilder: (BuildContext context, Widget child,
                                         ImageChunkEvent loadingProgress) {
                                       if (loadingProgress == null) return child;
                                       return Center(
                                         child: CircularProgressIndicator(
                                           value: loadingProgress.expectedTotalBytes != null
                                               ? loadingProgress.cumulativeBytesLoaded /
                                               loadingProgress.expectedTotalBytes
                                               : null,
                                         ),
                                       );
                                     },
                                   ),
                                 ),
                               ),
                             ),
                           );
                         },
                             options: CarouselOptions(
                               height: 200.0,
                               enlargeCenterPage: true,
                               autoPlay: true,
                               aspectRatio: 16 / 3,
                               autoPlayCurve: Curves.fastOutSlowIn,

                               enableInfiniteScroll: true,
                               autoPlayAnimationDuration: Duration(milliseconds: 800),
                               viewportFraction: 1.0,
                             )
                           );

                   }),

               Stack(
                   children: <Widget>[

                     Padding(
                       padding: const EdgeInsets.all(15.0),
                       child: Card(
                         elevation: 10,
                         shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(50)),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: <Widget>[

                             Padding(
                               padding: const EdgeInsets.all(15.0),
                               child: Center(child: Text("Find a Donor",
                                 style: TextStyle(fontSize: 30.0,
                                     color: Colors.red,
                                     fontWeight: FontWeight.w400),)),
                             ),
                             Container(
                                 padding: EdgeInsets.only(left: 30.0,
                                     right: 30.0,
                                     top: 10.0,
                                     bottom: 10.0),
                                 child: TextField(
                                   textInputAction: TextInputAction.next,
                                   onSubmitted: (_) =>
                                       FocusScope.of(context).nextFocus(),
                                   controller: userLocationQuery,
                                   decoration: InputDecoration(
                                     suffixIcon: IconButton(
                                         icon: Icon(Icons.my_location),
                                         onPressed: getUserLocation),
                                     border: OutlineInputBorder(
                                       borderRadius: BorderRadius.circular(
                                           10.0),
                                     ),
                                     hintText: "Location",
                                   ),
                                 )
                             ),
                             SizedBox(height: 10.0,),
                             Padding(
                               padding: EdgeInsets.only(left: 30.0,
                                   right: 30.0,
                                   top: 10.0,
                                   bottom: 10.0),
                               child: DropdownButtonFormField(
                                 key: _key,
                                 decoration: InputDecoration(
                                     suffixIcon: IconButton(
                                         icon: Icon(Icons.clear),
                                         onPressed: () {
                                           setState(() {
                                             wannaSearch = false;
                                             userBloodQuery.clear();
                                             _key.currentState.reset();
                                             userLocationQuery.clear();
                                             FocusScope.of(context).unfocus();
                                           });
                                         }),
                                     border: OutlineInputBorder(
                                       borderRadius: BorderRadius.circular(
                                           10.0),
                                     )
                                 ),
                                 hint: Text("Select Blood Group"),
                                 items: [
                                   DropdownMenuItem(child: Text("A+"),
                                     value: "A+",),
                                   DropdownMenuItem(child: Text("A-"),
                                     value: "A-",),
                                   DropdownMenuItem(child: Text("B+"),
                                     value: "B+",),
                                   DropdownMenuItem(child: Text("B-"),
                                     value: "B-",),
                                   DropdownMenuItem(child: Text("AB+"),
                                     value: "AB+",),
                                   DropdownMenuItem(child: Text("AB-"),
                                     value: "AB-",),
                                   DropdownMenuItem(child: Text("O+"),
                                     value: "O+",),
                                   DropdownMenuItem(child: Text("O-"),
                                     value: "O-",),
                                 ],

                                 onChanged: (val) {
                                   setState(() {
                                     userBloodQuery.text = val;
                                   });
                                 },
                               ),
                             ),
                             SizedBox(height: 10.0,),
                             Center(
                               child: MaterialButton(
                                 onPressed: () {
                                   setState(() {
                                     wannaSearch = true;
                                     FocusScope.of(context).unfocus();
                                   });
                                 },
                                 color: Colors.red,
                                 child: Text("Search", style: TextStyle(
                                     fontFamily: "Gotham",
                                     fontSize: 20.0,
                                     color: Colors.white),),
                                 shape: RoundedRectangleBorder(
                                     borderRadius: BorderRadius.circular(
                                         10.0),
                                     side: BorderSide(color: Colors.red)),
                               ),

                             ),
                             Center(
                               child: Padding(
                                 padding: const EdgeInsets.only(bottom: 10),
                                 child: Align(
                                     alignment: Alignment.bottomCenter,
                                     child: ElevatedButton(
                                       onPressed: (){
                                         setState(() {
                                           showDialog(context: context, builder: (context)=>AlertDialog(
                                             title: Text("Add Campaign"),
                                             content: Padding(
                                               padding: const EdgeInsets.all(10.0),
                                               child: Form(
                                                 key: _formKey,
                                                 child: ListView(
                                                   children: <Widget>[
                                                     Padding(
                                                       padding: const EdgeInsets.only(top:8.0),
                                                       child: TextFormField(
                                                         validator: (value) {
                                                           if (value.isEmpty) {
                                                             return 'Specify Your Campaign name';
                                                           }
                                                           return null;
                                                         },
                                                         decoration: InputDecoration(
                                                             fillColor: Colors.grey,
                                                             suffixIcon: IconButton(icon: Icon(Icons.drive_file_rename_outline, color: Colors.red,), onPressed: getUserLocation),
                                                             hintText: "Campaign name",
                                                             border: OutlineInputBorder(
                                                               borderRadius: BorderRadius.circular(10.0),
                                                             )
                                                         ),
                                                         controller: namecontroller,
                                                       ),
                                                     ),
                                                     Padding(
                                                       padding: const EdgeInsets.only(top:8.0),
                                                       child:  _imageFile == null
                                                           ? Center(
                                                         child: Row(
                                                           children: [
                                                             Text("Upload image: "),
                                                             ElevatedButton(
                                                               child: Icon(Icons.add_a_photo_outlined),
                                                               onPressed: () => uploadImage(),
                                                             ),
                                                           ],
                                                         ),
                                                       )
                                                           : Center(child: Image.file(_imageFile)),
                                             ),
                                                     // ),
                                             Padding(
                                                       padding: const EdgeInsets.only(top:8.0),
                                                       child: TextFormField(
                                                         validator: (value) {
                                                           if (value.isEmpty) {
                                                             return 'Specify Your Campaign Location';
                                                           }
                                                           return null;
                                                         },
                                                         decoration: InputDecoration(
                                                             fillColor: Colors.grey,
                                                             suffixIcon: IconButton(icon: Icon(Icons.location_on, color: Colors.red,),),
                                                             hintText: "Campaign Location",
                                                             border: OutlineInputBorder(
                                                               borderRadius: BorderRadius.circular(10.0),
                                                             )
                                                         ),
                                                         controller: addressController,
                                                       ),
                                                     ),
                                                     // Padding(
                                                     //   padding: const EdgeInsets.only(top:8.0),
                                                     //   child: TextFormField(
                                                     //     keyboardType: TextInputType.numberWithOptions(),
                                                     //     validator: (value) {
                                                     //       if (value.isEmpty) {
                                                     //         return 'Blood Amount is Required';
                                                     //       }
                                                     //       return null;
                                                     //     },
                                                     //     decoration: InputDecoration(
                                                     //         fillColor: Colors.grey,
                                                     //         hintText: "Blood Amount (in Unit)",
                                                     //         border: OutlineInputBorder(
                                                     //           borderRadius: BorderRadius.circular(10.0),
                                                     //         )
                                                     //     ),
                                                     //     controller: amountController,
                                                     //   ),
                                                     // ),
                                                     Padding(
                                                       padding: const EdgeInsets.only(top:8.0),
                                                       child: TextFormField(
                                                         keyboardType: TextInputType.numberWithOptions(),
                                                         validator: (value) {
                                                           if (value.isEmpty || value.length!=10) {
                                                             return 'Provide 10 Digit Number';
                                                           }
                                                           return null;
                                                         },
                                                         decoration: InputDecoration(
                                                             hintText: "Phone Number",
                                                             border: OutlineInputBorder(
                                                               borderRadius: BorderRadius.circular(10.0),
                                                             )
                                                         ),
                                                         controller: phoneNumberController,
                                                       ),
                                                     ),
                                                     Padding(
                                                       padding: const EdgeInsets.only(top:8.0),
                                                       child: TextFormField(
                                                         validator: (value) {
                                                           if (value.isEmpty) {
                                                             return 'Please Specify providing blood groups with comma';
                                                           }
                                                           return null;
                                                         },
                                                         decoration: InputDecoration(
                                                             fillColor: Colors.grey,
                                                             suffixIcon: IconButton(icon: Icon(Icons.drive_file_rename_outline, color: Colors.red,), onPressed: getUserLocation),
                                                             hintText: "Blood Groups",
                                                             border: OutlineInputBorder(
                                                               borderRadius: BorderRadius.circular(10.0),
                                                             )
                                                         ),
                                                         controller: bloodGroupController,
                                                       ),
                                                     ),
                                                     Padding(
                                                       padding: const EdgeInsets.only(top:8.0),
                                                       child: TextFormField(
                                                         onTap: (){
                                                           pickDate();
                                                         },
                                                         validator: (value) {
                                                           if (value.isEmpty) {
                                                             return 'Please Provide Campaign Date';
                                                           }
                                                           return null;
                                                         },
                                                         decoration: InputDecoration(
                                                             hintText: "Campaign Date",
                                                             border: OutlineInputBorder(
                                                               borderRadius: BorderRadius.circular(10.0),
                                                             ),
                                                             fillColor: Colors.pinkAccent
                                                         ),
                                                         controller: bloodNeedDateController,
                                                       ),
                                                     ),
                                                     Padding(
                                                       padding: const EdgeInsets.all(8.0),
                                                       child: MaterialButton(
                                                           child: Text("Add Campaign", style: TextStyle(color: Colors.white, fontSize: 20.0),),
                                                           color: Theme.of(context).primaryColor,
                                                           onPressed: () {
                                                             if (_formKey.currentState.validate()) {
                                                               //   Scaffold.of(context).showSnackBar(SnackBar(content: Text('Processing Data')));
                                                               handleBloodRequest();
                                                             }
                                                           }
                                                       ),
                                                     ),

                                                   ],
                                                 ),
                                               ),
                                             ),
                                             // actions: [
                                             // ],
                                           ));
                                         });
                                       },
                                       style: ButtonStyle(
                                         backgroundColor: MaterialStatePropertyAll(Colors.red)
                                     ),
                                       child: Text("Create a Campaign",style: TextStyle(color: Colors.white),

                                       ),
                                       // color: Colors.red,
                                     )),
                               ),
                             ),
                           ],
                         ),
                       ),
                     )
                   ]
               ),
               SizedBox(height: 20.0,),
               Text("Donors", style: TextStyle(fontFamily: "Gotham", fontSize: 22.0, color: Colors.black),),
               SizedBox(height: 10.0,),

               wannaSearch?showSearchResults():StreamBuilder(
                 stream: donorRef.where("bloodGroup", isGreaterThan: "").snapshots(),
                 builder: (context, snapshot) {
                   if (!snapshot.hasData) {
                     return circularLoading();
                   }
                   List<ShowDonors> allDonors = [];
                   snapshot.data.documents.forEach((doc) {
                     allDonors.add(ShowDonors.fromDocument(doc));
                   });

                   return Container(
                     height: MediaQuery.of(context).size.height,
                     child: Column(
                       children: allDonors,
                     ),
                   );
                 },
               ),



             ],
           ),
         ),

       ),


     );
   }


   pickDate() async {
     DateTime date = await showDatePicker(
       context: context,
       initialDate: DateTime.now(),
       firstDate: DateTime.now(),
       lastDate: DateTime(DateTime.now().year+1),
     );

     if(date !=null){
       setState(() {
         bloodNeedDateController.text = date.day.toString() +"-"+ date.month.toString() +"-"+date.year.toString();
       });
     }
   }
   requestBlood() async {

     DocumentSnapshot doc = await bloodRequestRef.document(Uuid().v4()).get();

     // var text;
     bloodRequestRef.document(Uuid().v4()).setData({
       // "id":id.toString(),
       "name":namecontroller.text,
       "image":nameofpic.toString(),
       "location":addressController.text,
       "bloodGroup":bloodGroupController.text,
       "phoneNumber":phoneNumberController.text,
       // "bloodAmount":amountController.text,
       "bloodNeededDate": bloodNeedDateController.text,
     });

   }
   File _imageFile;

   ///NOTE: Only supported on Android & iOS
   ///Needs image_picker plugin {https://pub.dev/packages/image_picker}
   final picker = ImagePicker();
   String nameofpic="";

   FirebaseStorage _storage = FirebaseStorage.instance;

   uploadImage() async {
     final _firebaseStorage = FirebaseStorage.instance;
     final _imagePicker = ImagePicker();
     PickedFile image;
     //Check Permissions
     await Permission.photos.request();
     var permissionStatus = await Permission.photos.status;
     if (permissionStatus.isGranted){
       //Select Image
       image = await _imagePicker.getImage(source: ImageSource.gallery);
       var file = File(image.path);
       String uniqueFileName =
       DateTime.now().millisecondsSinceEpoch.toString();

       if (image != null){
         //Upload to Firebase
         var snapshot = await _firebaseStorage.ref()
             .child('images/$uniqueFileName')
             .putFile(file).onComplete;
         var downloadUrl = await snapshot.ref.getDownloadURL();
         setState(() {
           nameofpic = downloadUrl;
           // imagecontroller=downloadUrl;
           print(nameofpic);

         });
       } else {
         print('No Image Path Received');
       }
     } else {
       print('Permission not granted. Try Again with permission access');
     }
   }
   final bloodRequestRef = Firestore.instance.collection('campaign');

   bool isRequesting = false;

   handleBloodRequest() async {

     setState(() {
       isRequesting = true;
     });

     await requestBlood();


     setState(() {
       isRequesting = false;
       Navigator.pop(context);
       showDialog(context: context, builder: (context)=>AlertDialog(
         title: Text("successful create"),
         content: MaterialButton(child: Text("ok"),onPressed: (){
           namecontroller.clear();
           // imagecontroller.clear();
           addressController.clear();
           // amountController.clear();
           bloodNeedDateController.clear();
           bloodGroupController.clear();
           phoneNumberController.clear();
           Navigator.pop(context);},),
       ));
     });



   }
   // TextEditingController displayNameController = TextEditingController();
   TextEditingController addressController = TextEditingController();
   TextEditingController namecontroller = TextEditingController();
   TextEditingController bloodGroupController = TextEditingController();
   TextEditingController phoneNumberController = TextEditingController();
   // TextEditingController amountController = TextEditingController();
   TextEditingController bloodNeedDateController = TextEditingController();
   TextEditingController imagecontroller = TextEditingController();

   GlobalKey<FormState> _formKey = GlobalKey<FormState>();

   @override
   Widget build(BuildContext context) {
     // if(isAuth){
     return authScreen();
     // }else{
     //   return unAuthScreen();
     // }
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
              Container(height: 70,width: 70,color: Colors.white,
                child: Stack(
                  children: [
                    Center(
                      child: Container(height: 70,width: 70,decoration: BoxDecoration(
                        image: DecorationImage(image:AssetImage("assets/img/drop2.png"),fit: BoxFit.contain),),
                      ),
                    ),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 11),
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





class ShowCamp extends StatelessWidget {

  final String displayName;
  final String photoUrl;
  final String location;
  final String bloodGroup;
  final String date;
  final String phoneNumber;

  ShowCamp({
    this.displayName,
    this.location,
    this.photoUrl,
    this.phoneNumber,
    this.bloodGroup,
    this.date,
  });

  factory ShowCamp.fromDocument(DocumentSnapshot doc) {
    return ShowCamp(
      displayName: doc['name'],
      location: doc['location'],
      bloodGroup: doc['bloodGroup'],
      photoUrl: doc['image'],
      phoneNumber: doc['phoneNumber'],
      date: doc['bloodNeededDate'],
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
                    Container(height: 24,width: double.infinity,child: Text("$date"),),
                    Container(height: 24,width: double.infinity,child: Text("$location"),),
                    Expanded(child: MaterialButton(elevation: 2,minWidth: 50,color: Colors.red,onPressed: (){_launchURL("tel:$phoneNumber");},
                        child: Text("Call Now",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),))),
                  ],
                ),
              )),
              Container(height: 70,width: 70,color: Colors.white,
                child: Stack(
                  children: [
                    Center(
                      child: Container(height: 70,width: 70,decoration: BoxDecoration(
                        image: DecorationImage(image:AssetImage("assets/img/drop2.png"),fit: BoxFit.contain),),
                      ),
                    ),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 11),
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




