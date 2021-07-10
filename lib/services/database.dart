import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods{
  CollectionReference<Map<String, dynamic>> users = FirebaseFirestore.instance.collection('users');

  getUserByEmail(String email) async {
    return await users
        .where('email', isEqualTo: email)
        .get();
  }

  uploadUserInfo(userMap){
    users
        .add(userMap).catchError((e){
          print("Failed to add user: $e");
    });
  }
}