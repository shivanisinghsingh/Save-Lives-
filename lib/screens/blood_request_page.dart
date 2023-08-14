import 'package:savelives/model/donor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'loading.dart';


class ShowRequest extends StatefulWidget {
  @override
  _ShowRequestState createState() => _ShowRequestState();
}

class _ShowRequestState extends State<ShowRequest> {
  Donor currentuser;

  final bloodRequestRef = Firestore.instance.collection('request');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 80,shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(30),bottomLeft: Radius.circular(30))),
        title: Text("Blood Requests"),
      ),
      body: StreamBuilder(
        stream: bloodRequestRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularLoading();
          }
          List<ShowRequests> allRequests = [];
          snapshot.data.documents.forEach((doc) {
            allRequests.add(ShowRequests.fromDocument(doc));
          });

          return Container(
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(         //scroll view
              scrollDirection: Axis.vertical,
              child: Column(
                children: allRequests,
              ),
            ),
          );
        },
      ),
    );
  }
}

class ShowRequests extends StatelessWidget {

  final String location;
  final String bloodGroup;
  final String bloodAmount;
  final String phoneNumber;
  final String requiredDate;
  final String name;
  final String id;

  ShowRequests({
    this.name,
    this.id,
    this.location,
    this.phoneNumber,
    this.bloodGroup,
    this.requiredDate,
    this.bloodAmount,
  });

  factory ShowRequests.fromDocument(DocumentSnapshot doc) {
    return ShowRequests(
      name:doc['name'],
      id:doc['id'],
      location: doc['location'],
      bloodGroup: doc['bloodGroup'],
      phoneNumber: doc['phoneNumber'],
      requiredDate: doc['bloodNeededDate'],
      bloodAmount: doc['bloodAmount'],
    );
  }

  Donor currentUser;
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
      child: Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 2.0,shadowColor: Colors.black,
        child: Container(height: 100,width: double.infinity,
          decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(20.0)),
          child: Row(
            children: [
              Container(height: 100,width: 130,
                child: Column(
                  children: [
                    Container(
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Text("$location",overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.white),),
                        ),
                        height: 40,decoration: BoxDecoration(color: Colors.red,borderRadius: BorderRadius.only(topLeft: Radius.circular(20)))),
                    Expanded(child: Container(child: Center(child: Padding(
                      padding: const EdgeInsets.only(bottom: 7,right: 3),
                      child: Text("$bloodGroup",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                    ),),
                      decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/img/drop.png"),fit: BoxFit.fitHeight),
                          color: Colors.white,borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20)))
                      ,))
                  ],
                ),
                decoration: BoxDecoration(color: Colors.red,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20),bottomLeft: Radius.circular(20))),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        child: Text("$name",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold,color: Colors.red),overflow: TextOverflow.ellipsis,),height: 24,),
                      Container(child: Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("unit: "),
                          Text("$bloodAmount"),
                        ],
                      ),height: 24,),
                      Container(child: Text("$phoneNumber"),height: 24,),
                      Expanded(child: Container(child: Text("$requiredDate"))),
                    ],),
                ),
              ),
              InkWell(
splashColor: Colors.white,
onTap: (){ Share.share("Hey this is $name.\ni'm sharing you a $bloodGroup blood request with $bloodAmount unit blood in $location.\nThe mobile number of needy person is $phoneNumber.\nMake sure you do not have any type of disease", subject:  'Nice Service');
},
                child: Container(width: 60,color: Colors.red,
                  child: Center(
                    child: IconButton(
                      // onPressed: (){                       },
                      icon: Icon(Icons.share_sharp,color: Colors.white,),
                    ),
                  ),

                ),
              )
            ],
          ),

        ),
      ),
    );

  }


}
