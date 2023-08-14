import 'package:flutter/material.dart';
import 'package:share/share.dart';
class campaign_details extends StatefulWidget {
  String name;
  String phoneNumber;
  String image;
  String bloodNeededDate;
  String bloodGroup;
  String location;

   campaign_details({Key key, this.name, this.bloodGroup, this.phoneNumber, this.image, this.location, this.bloodNeededDate}) : super(key: key);

  @override
  State<campaign_details> createState() => _campaign_detailsState();
}

class _campaign_detailsState extends State<campaign_details> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      appBar:AppBar(
        shadowColor: Colors.transparent,
        title: Text(widget.name),
        backwardsCompatibility: false,
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20)),
              child: Image.network(widget.image,fit: BoxFit.cover,height: 220,width: double.infinity,)
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20,left: 20),
                child: Text(widget.name.toUpperCase(),style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20,right: 20),
                child: MaterialButton(child: Text("Share this Campaign",style: TextStyle(color: Colors.white),),color: Colors.red,onPressed: (){Share.share("I'm sharing you a blood Campaign ${widget.name} in ${widget.location} on ${widget.bloodNeededDate}. \nThe availabe blood groups are ${widget.bloodGroup} \nThe mobile number of Campaign manager is ${widget.phoneNumber}.\n*Make sure you do not have any type of disease", subject:  'Nice Service');
                },)
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20,top: 20),
            child: Row(
              children: [
                Text("Date: ",style: TextStyle(fontSize: 15),),
                Text(widget.bloodNeededDate,style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),)
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Text("Location of Campaign: ",style: TextStyle(fontSize: 15),),
                Text(widget.location,style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),)
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              children: [
                Text("Phone No: ",style: TextStyle(fontSize: 15),),
                Text(widget.phoneNumber,style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),)
              ],
            ),
          ), Padding(
            padding: const EdgeInsets.only(left: 20,top: 20),
            child: Row(
              children: [
                Text("Blood Groups: ",style: TextStyle(fontSize: 15),),
                Text(widget.bloodGroup,style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),)
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text("*make sure you do not have any type of disease: ",style: TextStyle(fontSize: 15,color: Colors.red,fontWeight: FontWeight.bold),),
          ),

        ],
      ),
    );
  }
}
