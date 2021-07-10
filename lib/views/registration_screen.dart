import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/constants.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import 'login_screen.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:chat_app/models/user_model.dart';



// ignore: use_key_in_widget_constructors
class RegistrationScreen extends StatefulWidget {
  static String id = 'registration_screen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  DatabaseMethods databaseMethods = new DatabaseMethods();

  final _formKey = GlobalKey<FormState>();
  bool showSpinner = false;

  TextEditingController usernameTextEditingController = new TextEditingController();
  TextEditingController emailTextEditingController = new TextEditingController();
  TextEditingController passwordTextEditingController = new TextEditingController();
  TextEditingController confirmPasswordTextEditingController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ListView(
            children: <Widget>[
              const SizedBox(
                height: 32.0,
              ),
              Hero(
                tag: 'logo',
                // ignore: sized_box_for_whitespace
                child: Container(
                  height: 180.0,
                  child: Image.asset('images/logo.png'),
                ),
              ),
              const SizedBox(
                height: 48.0,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      validator: (value){
                        return value!.isEmpty || value.length < 2 ? "Username is too short" : null;
                      },
                      controller: usernameTextEditingController,
                      onChanged: (value) {
                      },
                      style: const TextStyle(color: Color(0xff243B53)),
                      decoration: kTextFieldDecoration.copyWith(hintText: 'Username'),
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),TextFormField(
                      validator: (value){
                        return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value!) ? null : "A valid email address is required";
                      },
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                      },
                      style: const TextStyle(color: Color(0xff243B53)),
                      decoration: kTextFieldDecoration.copyWith(hintText: 'Email'),
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    TextFormField(
                      validator: (value){
                        return value!.length < 6 ? "Password must have at least 6 characters" : null;
                      },
                      controller: passwordTextEditingController,
                      obscureText: true,
                      onChanged: (value) {;
                      },
                      style: const TextStyle(color: Color(0xff243B53)),
                      decoration: kTextFieldDecoration.copyWith(hintText: 'Password'),
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    TextFormField(
                      validator: (value){
                        return value == passwordTextEditingController.text ? null : "Password and confirm password do not match";
                      },
                      controller: confirmPasswordTextEditingController,
                      obscureText: true,
                      onChanged: (value) {
                      },
                      style: const TextStyle(color: Color(0xff243B53)),
                      decoration: kTextFieldDecoration.copyWith(hintText: 'Confirm Password'),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 24.0,
              ),
              ConstrainedBox(
                constraints: const BoxConstraints.tightFor(width: 200, height: 48),
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
                  onPressed: () async {
                    if(_formKey.currentState!.validate()){
                      setState(() {
                        showSpinner = true;
                      });

                      try {
                        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
                            email: emailTextEditingController.text,
                            password: passwordTextEditingController.text
                        );

                        if (userCredential != null) {
                          Map<String, String> userInfoMap = {
                            'username': usernameTextEditingController.text,
                            'email': emailTextEditingController.text,
                          };
                          userInfoMap['userType'] = '0';

                          databaseMethods.uploadUserInfo(userInfoMap);

                          Navigator.pushNamed(context, LoginScreen.id);
                        }

                        setState(() {
                          showSpinner = false;
                        });
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'weak-password') {
                          // ignore: avoid_print
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Error', style: TextStyle(color: Color(0xff243B53))),
                              content: const Text('The password provided is too weak.', style: TextStyle(color: Color(0xff243B53))),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.pop(context, 'OK'),
                                  child: const Text('OK', style: TextStyle(color: Color(0xff3EBD93))),
                                ),
                              ],
                            ),
                          );
                          print('The password provided is too weak.');
                          setState(() {
                            showSpinner = false;
                          });
                        } else if (e.code == 'email-already-in-use') {
                          // ignore: avoid_print
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Error', style: TextStyle(color: Color(0xff243B53))),
                              content: const Text('The account already exists for that email.', style: TextStyle(color: Color(0xff243B53))),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.pop(context, 'OK'),
                                  child: const Text('OK', style: TextStyle(color: Color(0xff3EBD93))),
                                ),
                              ],
                            ),
                          );
                          print('The account already exists for that email.');
                          setState(() {
                            showSpinner = false;
                          });
                        }
                      } catch (e) {
                        // ignore: avoid_print
                        print(e);
                      }
                    }
                  },
                  child: const Text('Sign up'),
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
              ConstrainedBox(
                constraints: const BoxConstraints.tightFor(width: 200, height: 48),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    primary: const Color(0xff243B53),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    side: const BorderSide(color: Color(0xff243B53), width: 1),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, LoginScreen.id);
                  },
                  child: const Text('Sign in'),
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
              Row(
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  const Expanded(
                    child: Divider(
                      color: Color(0xFF9FB3C8),
                      height: 36,
                    ),
                  ),
                  const Text(
                    '  or Sign up with  ',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Color(0xFF627D98),
                    ),
                  ),
                  const Expanded(
                    child: Divider(
                      color: Color(0xFF9FB3C8),
                      height: 36,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 16.0,
              ),
              Row(
                children: [
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints.tightFor(width: 50, height: 40),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          primary: const Color(0xff243B53),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          side: const BorderSide(color: Color(0xff243B53), width: 1),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                        ),
                        onPressed: () {
                          //Navigator.pushNamed(context, RegistrationScreen.id);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              // ignore: sized_box_for_whitespace
                              child: Container(
                                height: 24,
                                child: Image.asset('images/google_logo.png'),
                              ),
                            ),
                            const Text('Google'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 12.0,
                  ),
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints.tightFor(width: 50, height: 40),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          primary: const Color(0xff243B53),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          side: const BorderSide(color: Color(0xff243B53), width: 1),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                        ),
                        onPressed: () {
                          //Navigator.pushNamed(context, RegistrationScreen.id);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              // ignore: sized_box_for_whitespace
                              child: Container(
                                height: 24,
                                child: Image.asset('images/fb_logo.png'),
                              ),
                            ),
                            const Text('Facebook'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 24.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
