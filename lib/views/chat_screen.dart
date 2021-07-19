import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/conversation_screen.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/constants.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_auth/firebase_auth.dart';
import 'search_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/helpers/helperFuntions.dart';

// ignore: use_key_in_widget_constructors
class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  late User loggedInUser;
  TextEditingController emailTextEditingController = new TextEditingController();
  var email;
  DatabaseMethods databaseMethods = new DatabaseMethods();
  Future<int>? _query;
  Stream<QuerySnapshot<Map<String, dynamic>>>? contactSnapshot;
  late String currentUsername;
  late Stream contacts;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        email = user.email;
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }

    databaseMethods.getUserByEmail(email).then((val) async {
      setState(() {
        HelperFunctions.saveUsernameSharedPreference(val.docs[0].data()['username']);
        currentUsername = val.docs[0].data()['username'];
      });
      _query = Future<int>.delayed(
        const Duration(seconds: 3),
            () => val!.size,
      );
    });

    databaseMethods.getUserContacts(email).then((val) async {
      setState(() {
        contactSnapshot = val;
        print(val.toString() +'y a h a l l o');
      });
    });
  }

  Widget contactList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: contactSnapshot,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        return snapshot.hasData ? ListView.builder(
            itemCount: snapshot.data!.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  const SizedBox(
                    height: 16.0,
                  ),
                  GestureDetector(
                    onTap: () {
                      String conversationId = (currentUsername.compareTo(snapshot.data!.docs[index].data()['username']) > 0) ?
                        currentUsername : snapshot.data!.docs[index].data()['username'];

                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => ConversationScreen(conversationId: conversationId, username: snapshot.data!.docs[index].data()['username'], currentUserEmail: email,)
                      ));
                    },
                    child: contactTile(
                      username: snapshot.data!.docs[index].data()['username'],
                      email: snapshot.data!.docs[index].data()['email'],
                    ),
                  ),
                ],
              );
            },
        ) : Column(
          children: [
            const SizedBox(
              height: 160.0,
            ),
            Text(
              'You have no contacts as of the moment.',
              style: TextStyle(
                fontSize: 18.0,
                color: Color(0xff243B53),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        bottomNavigationBar: Container(
          color: Color(0xff243B53),
          child: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Color(0xff829AB1),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: EdgeInsets.all(5.0),
            indicatorColor: Color(0xff3EBD93),
            tabs: [
              Tab(
                text: "Chat",
                icon: Icon(Icons.messenger_outline),
              ),
              Tab(
                text: "Profile",
                icon: Icon(Icons.person),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
              Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView(
                  children: [
                    const SizedBox(
                      height: 16.0,
                    ),
                    TextFormField(
                      validator: (value){
                        return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value!) ? null : "A valid email address is required";
                      },
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                      },
                      style: const TextStyle(color: Color(0xff243B53)),
                      decoration: kTextFieldDecoration.copyWith(
                        hintText: 'Search user email',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search),
                          color: Color(0xff829AB1),
                          onPressed: () {
                            if(_formKey.currentState!.validate()){
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => SearchScreen(email: emailTextEditingController.text)
                              ));
                            }
                          },
                        ),
                      ),
                    ),
                    contactList(),
                  ],
                ),
              ),
            ),
            FutureBuilder<int>(
              future: _query,
              builder: (BuildContext context, AsyncSnapshot<int> snapshot){
                List<Widget> children;
                if (snapshot.hasData) {
                  children = <Widget>[
                    Column(
                      children: [
                        Container(
                          height: 200,
                          child: Image.asset('images/logo.png'),
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        Text(
                          currentUsername,
                          style: TextStyle(
                            fontSize: 24.0,
                            color: Color(0xff243B53),
                          ),
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Color(0xff243B53),
                          ),
                        ),
                        const SizedBox(
                          height: 24.0,
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints.tightFor(width: 300, height: 48),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              onPrimary: Colors.white,
                              primary: const Color(0xff243B53),
                              elevation: 5.0,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(30)),
                              ),
                            ),
                            onPressed: () {
                              _auth.signOut();
                              Navigator.pop(context);
                            },
                            child: const Text('Sign out'),
                          ),
                        ),
                      ],
                    ),
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
    );
  }
}

class contactTile extends StatelessWidget {
  final String username;
  final String email;

  contactTile({required this.username, required this.email});

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

