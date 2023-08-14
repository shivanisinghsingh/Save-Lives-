import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About Us"),
      ),
      body: Padding(
        padding: EdgeInsets.all(40.0),
        child: Column(
          children: <Widget>[
            Text("Save Life A unique societal platform, which facilitates real-time connect between th requester and the willing blood donor in a defined geography. The workflow is to connect the willing donor to save a life at time of need across the country. Save Life- a mobile application to find blood donor online. The application enables geo-searching, real- time connection and updates in times of emergency like never before. We are searching out to the community witha simple request - to help us signing up donors to Save Life. This will be another small step in continuation with your contribution to building a better society.",
              style: TextStyle(fontFamily: "Gotham", fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black),
            )
          ],
        ),
      ),
    );
  }
}
