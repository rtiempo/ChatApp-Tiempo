import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods{
  CollectionReference<Map<String, dynamic>> users = FirebaseFirestore.instance.collection('users');
  CollectionReference<Map<String, dynamic>> conversation = FirebaseFirestore.instance.collection('conversation');

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

  getUserContacts(String userEmail) async {
    return await users
        .doc(userEmail)
        .collection('contacts')
        .snapshots();
  }

  searchContacts(String userEmail, String contactEmail) async {
    return await users
        .doc(userEmail)
        .collection('contacts')
        .doc(contactEmail)
        .get();
  }

  addToContacts(String userEmail, String contactEmail, contactMap, contactMap2){
    users
        .doc(userEmail)
        .collection('contacts')
        .doc(contactEmail)
        .set(contactMap)
        .then((value) => print("Contact added"))
        .catchError((e) => print("Failed to add contact: $e"));

    users
        .doc(contactEmail)
        .collection('contacts')
        .doc(userEmail)
        .set(contactMap2)
        .then((value) => print("Contact added"))
        .catchError((e) => print("Failed to add contact: $e"));

  }

  getConversation(String conversationId) async {
    return await conversation
        .doc(conversationId)
        .collection('messages')
        .orderBy('timeDate')
        .snapshots();
  }

  createConversation(String email, String email2, contactMap, contactMap2){
    String conversationId = (email.compareTo(email2) > 0) ? email+email2 : email2+email;

    conversation
      .doc(conversationId)
      .set({
          'usernames': [contactMap['username'], contactMap2['username']],
          'usersEmail': [contactMap['email'], contactMap2['email']],
        })
      .then((value) => print("Conversation Created"))
      .catchError((e) => print("Failed to create new conversation: $e"));
  }

  sendMessage(String message, String conversationId, String sender){
    conversation
      .doc(conversationId)
      .collection('messages')
      .add({
        'message': message,
        'sender': sender,
        'timeDate': DateTime.now(),
      });
  }
}