import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'authentication.dart';
import 'image_processor.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CardList extends StatelessWidget {
  final Auth auth = new Auth();
  String currUid;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('history').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        if(snapshot.hasError)
          return Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          default:
            auth.getCurrentUserID().then((id)=>{this.currUid = id});
            return ListView(
              children: snapshot.data.documents.where((doc)=>doc.data['userID'] == this.currUid).map((doc){
                print("test ");
                print(doc.data['userID']);
                print(this.currUid);
                print(doc.data['userID'] == this.currUid);
                String res = doc.data['detectionResult'];
                String path = doc.data['imagePath'];
                Timestamp timestamp = doc.data['date'];
                String date = DateFormat("dd-MM-yyyy hh:mm:ss").format(timestamp.toDate()).toString();
                return CustomCard(res,date,path);
              }).toList(),
            );
        }
      },
    );
  }
}

class CustomCard extends StatelessWidget {
  final String _detectionResult;
  final String _timestamp;
  final String _imagepath;

  CustomCard(this._detectionResult, this._timestamp, this._imagepath);

  Widget _getContent() {
    return Container(
      child: Row(
        children: <Widget>[
          Image.network(
            _imagepath,
            width: 100,
            height: 100,
          ),
          Container(
            padding: EdgeInsets.fromLTRB(60.0, 40.0, 0.0, 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(_detectionResult),
                Text(_timestamp),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      padding: new EdgeInsets.only(
          top: MediaQuery.of(context).size.height * .04,
          right: 20.0,
          left: 20.0),
      child: Container(
        height: 150.0,
        width: MediaQuery.of(context).size.width,
        child: GestureDetector(
          child: Card(
            color: Colors.white,
            elevation: 4.0,
            child: _getContent(),
          ),
          onTap: () {
            print("Card Pressed");
          },
        ),
      ),
    );
  }
}

class DetectPage extends StatefulWidget {
  final Auth auth;
  final VoidCallback onLogout;

  DetectPage({this.auth, this.onLogout});

  @override
  _DetectPageState createState() => _DetectPageState();
}

class _DetectPageState extends State<DetectPage> {
  CardList _cardList;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  void initState() {
    _populate();
  }

  Widget _getBackground() {
    return Container(
      height: MediaQuery.of(context).size.height * 1,
      color: Color(0xfffff6f6),
    );
  }

  Future<void> _populate() async{
    setState(() {
     _cardList = CardList(); 
    });
  }
 
  Widget _getCards() {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _populate,
      child: _cardList,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Plant Health"),
        actions: <Widget>[
          FlatButton(
            child: Text("Logout"),
            textColor: Colors.white,
            onPressed: () async {
              widget.auth.logout();
              widget.onLogout();
            },
          )
        ],
      ),
      body: Stack(
        children: <Widget>[_getBackground(), _getCards()],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.camera_alt,
          color: Colors.white,
        ),
        backgroundColor: Color(0xffa1c45a),
        onPressed: () async {
          File selected =
              await ImagePicker.pickImage(source: ImageSource.camera);
          if (selected != null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ImageProcessor(selected, widget.auth)));
          }
        },
      ),
    );
  }
}
