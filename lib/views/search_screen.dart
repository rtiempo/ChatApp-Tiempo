import 'dart:core';
import 'dart:ui';
import 'package:chat_app/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/helpers/helperFuntions.dart';

class SearchScreen extends StatefulWidget {
  static String id = 'search_screen';
  late final String email;

  SearchScreen({Key? key, required this.email}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class  _SearchScreenState extends State<SearchScreen> {
  final _auth = FirebaseAuth.instance;
  DatabaseMethods databaseMethods = new DatabaseMethods();
  QuerySnapshot<Map<String, dynamic>>? searchSnapshot;
  late User loggedInUser;
  var local;
  Future<int>? _query;

  void getUser() async {
    databaseMethods.getUserByEmail(widget.email).then((val){
      setState(() {
        searchSnapshot = val;
        local = searchSnapshot!.size;
      });
      _query = Future<int>.delayed(
        const Duration(seconds: 3),
          () => searchSnapshot!.size,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getUser();
  }

  void getCurrentUser() {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }

  }

  Widget searchList(){
    return (local >= 1) ? ListView.builder(
      itemCount: searchSnapshot!.docs.length,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemBuilder: (context, index){
        return GestureDetector(
          onTap: () async {
            String currentUserEmail = await HelperFunctions.getUserEmailSharedPreference() as String;
            String currentUsername = await HelperFunctions.getUsernameSharedPreference() as String;

            Map<String, String> contactMap = {
              'username': searchSnapshot!.docs[index].data()['username'],
              'email': searchSnapshot!.docs[index].data()['email'],
            };

            Map<String, String> contactMap2 = {
              'username': currentUsername,
              'email': currentUserEmail,
            };

            DocumentSnapshot snapshot = await databaseMethods.searchContacts(currentUserEmail, searchSnapshot!.docs[index].data()['email']);

            if(currentUserEmail != searchSnapshot!.docs[index].data()['email']){
              if(snapshot.exists){
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Error', style: TextStyle(color: Color(0xff243B53))),
                    content: const Text('You both already have a connection.', style: TextStyle(color: Color(0xff243B53))),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'OK'),
                        child: const Text('OK', style: TextStyle(color: Color(0xff3EBD93))),
                      ),
                    ],
                  ),
                );
              }else{
                databaseMethods.addToContacts(currentUserEmail, searchSnapshot!.docs[index].data()['email'], contactMap, contactMap2);
              }
            }else{
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Error', style: TextStyle(color: Color(0xff243B53))),
                  content: const Text('You are not allowed to add your own self.', style: TextStyle(color: Color(0xff243B53))),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'OK'),
                      child: const Text('OK', style: TextStyle(color: Color(0xff3EBD93))),
                    ),
                  ],
                ),
              );
            }
          },
          child: SearchTile(
              username: searchSnapshot!.docs[index].data()['username'],
              email: searchSnapshot!.docs[index].data()['email']
          ),
        );
      }
    ) : BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: AlertDialog(

        content: const Text('User not found.', style: TextStyle(color: Color(0xff243B53))),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK', style: TextStyle(color: Color(0xff3EBD93))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff243B53),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          child: Column(
            children: [
              const SizedBox(
                height: 24.0,
              ),
              FutureBuilder<int>(
                future: _query,
                  builder: (BuildContext context, AsyncSnapshot<int> snapshot){
                    List<Widget> children;
                    if (snapshot.hasData) {
                      children = <Widget>[
                        searchList(),
                      ];
                    } else {
                      children = <Widget>[
                        Center(child: CircularProgressIndicator()),
                      ];
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: children,
                    );
                  },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchTile extends StatelessWidget {
  late final String username;
  late final String email;
  SearchTile({required this.username, required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Icon(
            Icons.account_circle,
            color: Color(0xff243B53),
            size: 56.0,
          ),
          const SizedBox(
            width: 8.0,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                //searchSnapshot.docs[0].data()!.username,
                username,
                style: TextStyle(
                  fontSize: 20.0,
                  color: Color(0xff243B53),
                ),
              ),
              Text(
                email,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Color(0xff243B53),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
