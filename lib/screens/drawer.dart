
import 'package:savelives/screens/about.dart';
import 'package:savelives/screens/blood_request_page.dart';
import 'package:savelives/screens/blood_requests.dart';
import 'package:savelives/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../model/donor.dart';

class MainDrawer extends StatefulWidget {

  final GoogleSignIn googleSignIn;
//
  Donor currentUser;
  MainDrawer(this.googleSignIn, this.currentUser);

  @override
  _MainDrawerState createState() => _MainDrawerState();
}
//
// Donor currentUser;
class _MainDrawerState extends State<MainDrawer> {

  Donor currentUser;
  @override
  Widget build(BuildContext context) {

    return Drawer(
      elevation: 0,
      child:Column(mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40)),
                color: Colors.red),
            child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Image.asset("assets/img/logo.png",height: 130,width: 150,),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text("Save Lives",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 25),),
                )
              ],
            )),
          ),


          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
            children: [
              // SizedBox(height: 20,), SizedBox(height: 20,),

              // SizedBox(height: 20,), SizedBox(height: 20,),
              Row(children: [

              ],),
            ListTile(
                      title: Text('Home', style: TextStyle(color: Colors.black, fontFamily: "Gotham", fontSize: 18.0 ),),
                      leading: Icon(Icons.home, color: Colors.red,),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),ListTile(
                      title: Text('Request for Blood', style: TextStyle(color: Colors.black, fontFamily: "Gotham", fontSize: 18.0 ),),
                      leading: Icon(Icons.select_all, color: Colors.red,),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>RequestBlood(currentUser)));
                      },
                    ),
                    ListTile(
                      title: Text('Blood Requests', style: TextStyle(color: Colors.black, fontFamily: "Gotham", fontSize: 16.0 ),),
                      leading: Icon(Icons.remove_from_queue, color: Colors.red,),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>ShowRequest()));
                      },
                    ),
                    ListTile(
                      title: Text('Sign out', style: TextStyle(color: Colors.black, fontFamily: "Gotham", fontSize: 16.0 ),),
                      leading: Icon(Icons.lock_open_sharp, color: Colors.red,),
                      onTap: () async{
                        Navigator.pop(context);
                        await widget.googleSignIn.signOut();

                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
                      },
                    ),
                    ListTile(
                      title: Text('About Us', style: TextStyle(color: Colors.black, fontFamily: "Gotham", fontSize: 16.0 ),),
                      leading: Icon(Icons.info, color: Colors.red,),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>AboutUs()));
                      },
                    ),
            ],),
          )

        ],
      )
    );
  }
}
