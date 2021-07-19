import 'package:flutter/material.dart';
import 'package:chat_app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

class forgot extends StatefulWidget {
  static String id = 'forgot_screen';

  @override
  _forgotState createState() => _forgotState();
}

class _forgotState extends State<forgot> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailTextEditingController = new TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
        backgroundColor: Color(0xff243B53),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: TextFormField(
                      validator: (value){
                        return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value!) ? null : "A valid email address is required";
                      },
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                      },
                      style: const TextStyle(color: Color(0xff243B53)),
                      decoration: kTextFieldDecoration.copyWith(
                        hintText: 'Email',
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints.tightFor(width: 312, height: 48),
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
                          await _firebaseAuth.sendPasswordResetEmail(email: emailTextEditingController.text);
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              content: const Text('A link has been sent to your email to change your password.', style: TextStyle(color: Color(0xff243B53))),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.pop(context, 'OK'),
                                  child: const Text('OK', style: TextStyle(color: Color(0xff3EBD93))),
                                ),
                              ],
                            ),);
                        }
                      },
                      child: const Text('Send Reset Password Email'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
