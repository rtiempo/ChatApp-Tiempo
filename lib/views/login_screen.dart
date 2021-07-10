import 'package:chat_app/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'registration_screen.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:chat_app/models/user_model.dart';


// ignore: use_key_in_widget_constructors
class LoginScreen extends StatefulWidget {
  static String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin{
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  bool showSpinner = false;
  late AnimationController controller;
  late Animation animation;

  TextEditingController emailTextEditingController = new TextEditingController();
  TextEditingController passwordTextEditingController = new TextEditingController();

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this
    );

    animation = ColorTween(begin: const Color(0xFF102A43), end: Colors.white).animate(controller);

    controller.forward();

    controller.addListener(() {
      setState(() {});
      // ignore: avoid_print
      print(animation.value);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
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
                  height: 200,
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
                        return value!.isEmpty || value.length < 2 ? "A valid email address is required" : null;
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
                        return value!.length < 6 ? "Invalid Password" : null;
                      },
                      controller: passwordTextEditingController,
                      obscureText: true,
                      onChanged: (value) {
                      },
                      style: const TextStyle(color: Color(0xff243B53)),
                      decoration: kTextFieldDecoration.copyWith(hintText: 'Password'),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: const SizedBox(
                      height: 16.0,
                    ),
                  ),
                  ConstrainedBox(
                      constraints: const BoxConstraints.tightFor(),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                        ),
                        onPressed: () {
                          print('kawaii');
                        },
                        child: Text('Forgot Password', style: TextStyle(color: Color(0xff3EBD93))),
                      ),
                  ),
                ],
              ),
              const SizedBox(
                height: 8.0,
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
                        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
                            email: emailTextEditingController.text,
                            password: passwordTextEditingController.text
                        );
                        if (userCredential != null) {
                          User? user = _auth.currentUser;

                          if (user != null && !user.emailVerified){
                            await user.sendEmailVerification();

                            showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text('Email not yet verified', style: TextStyle(color: Color(0xff243B53))),
                                content: const Text('Please verify your email using the verification link sent to your email account.', style: TextStyle(color: Color(0xff243B53))),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, 'OK'),
                                    child: const Text('OK', style: TextStyle(color: Color(0xff3EBD93))),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            Navigator.pushNamed(context, ChatScreen.id);
                          }
                        }
                        setState(() {
                          showSpinner = false;
                        });
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'user-not-found') {
                          // ignore: avoid_print
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Error', style: TextStyle(color: Color(0xff243B53))),
                              content: const Text('No user found for that email.', style: TextStyle(color: Color(0xff243B53))),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.pop(context, 'OK'),
                                  child: const Text('OK', style: TextStyle(color: Color(0xff3EBD93))),
                                ),
                              ],
                            ),
                          );
                          print('No user found for that email.');
                          setState(() {
                            showSpinner = false;
                          });
                        } else if (e.code == 'wrong-password') {
                          // ignore: avoid_print
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Error', style: TextStyle(color: Color(0xff243B53))),
                              content: const Text('Wrong password provided for that user.', style: TextStyle(color: Color(0xff243B53))),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.pop(context, 'OK'),
                                  child: const Text('OK', style: TextStyle(color: Color(0xff3EBD93))),
                                ),
                              ],
                            ),
                          );
                          print('Wrong password provided for that user.');
                          setState(() {
                            showSpinner = false;
                          });
                        }
                      }
                    }
                  },
                  child: const Text('Sign in'),
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
                    Navigator.pushNamed(context, RegistrationScreen.id);
                  },
                  child: const Text('Sign up'),
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
                    '  or Sign in with  ',
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
                height: 16.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
