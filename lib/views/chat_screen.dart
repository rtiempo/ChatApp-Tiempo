import 'package:chat_app/services/database.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/constants.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/models/user_model.dart';
import 'search_screen.dart';

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

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() {
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
                        return value!.isEmpty || value.length < 2 ? "A valid email address is required" : null;
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
                            /*databaseMethods.getUserByEmail(emailTextEditingController.text).then((QuerySnapshot querySnapshot){
                              querySnapshot.docs.forEach((doc){
                                print(doc["email"]);
                              });
                            });*/
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => SearchScreen(email: emailTextEditingController.text)
                            ));
                          },
                        ),
                      ),
                    ),
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
                ),
              ),
            ),
            Column(
              children: [
                const SizedBox(
                  height: 128.0,
                ),
                Container(
                  height: 200,
                  child: Image.asset('images/logo.png'),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                Text(
                  'Default Username',
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
          ],
        ),
      ),
    );
  }
}
