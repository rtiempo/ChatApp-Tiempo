import 'dart:core';
import 'dart:ui';
import 'package:chat_app/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  static String id = 'search_screen';
  late final String email;

  SearchScreen({Key? key, required this.email}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class  _SearchScreenState extends State<SearchScreen> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  QuerySnapshot<Map<String, dynamic>>? searchSnapshot;

  void getUser() {
    print(widget.email);
    databaseMethods.getUserByEmail(widget.email).then((val){

        searchSnapshot = val;

    });
  }

  Widget searchList(){
    return (searchSnapshot != null) ? ListView.builder(
      itemCount: searchSnapshot!.docs.length,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemBuilder: (context, index){
        return SearchTile(
            username: searchSnapshot!.docs[index].data()['username'],
            email: searchSnapshot!.docs[index].data()['email']
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
  void initState() {
    super.initState();
    getUser();
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
              searchList(),
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
