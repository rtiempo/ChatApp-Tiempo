import 'dart:core';
import 'dart:ui';
import 'package:chat_app/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/constants.dart';

class ConversationScreen extends StatefulWidget {
  static String id = 'conversation_screen';
  late final String conversationId;
  late final String username;
  late final String currentUserEmail;

  ConversationScreen({Key? key, required this.conversationId, required this.username, required this.currentUserEmail}) : super(key: key);

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  TextEditingController messageTextEditingController = new TextEditingController();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  Stream<QuerySnapshot<Map<String, dynamic>>>? messagesSnapshot;

  Widget conversationMessages() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: messagesSnapshot,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        return snapshot.hasData ? ListView.builder(
            itemCount: snapshot.data!.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return MessageTile(
                  message: snapshot.data!.docs[index].data()['message'],
                  sentByMe: (widget.currentUserEmail.compareTo(snapshot.data!.docs[index].data()['sender']) == 0) ? true : false,
              );
            },
        ) : Column(
          children: [
            const SizedBox(
              height: 160.0,
            ),
            Text(
              'You can now start a conversation with this person.',
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

  sendMessage() {
    databaseMethods.sendMessage(messageTextEditingController.text, widget.conversationId, widget.currentUserEmail);

    setState(() {
      messageTextEditingController.text = "";
    });
  }

  @override
  void initState() {
    databaseMethods.getConversation(widget.conversationId).then((val) {
      setState(() {
        messagesSnapshot = val;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username),
        backgroundColor: Color(0xff243B53),
      ),
      body: Container(
        child: Stack(
          children: [
            Padding(
                padding: EdgeInsets.only(bottom: 112.0),
                child: conversationMessages()
            ),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextFormField(
                  controller: messageTextEditingController,
                  onChanged: (value) {
                  },
                  style: const TextStyle(color: Color(0xff243B53)),
                  maxLength: 240,
                  decoration: kTextFieldDecoration.copyWith(
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Color(0xff243B53), width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    hintText: 'Type your message...',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.send),
                      color: Color(0xff829AB1),
                      onPressed: () {
                        sendMessage();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  late final String message;
  late final bool sentByMe;

  MessageTile({required this.message, required this.sentByMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 3,
          bottom: 3,
          left: sentByMe ? 0 : 24,
          right: sentByMe ? 24 : 0),
      alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
            margin: sentByMe ? EdgeInsets.only(left: 30) : EdgeInsets.only(right: 30),
            padding: EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
            decoration: BoxDecoration(
                borderRadius: sentByMe ? BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomLeft: Radius.circular(23)
                ) :
                BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomRight: Radius.circular(23)),
              gradient: LinearGradient(
                  colors: sentByMe ? [
                    const Color(0xff243B53),
                    const Color(0xff243B53)
                  ]
                  : [
                    const Color(0xff9FB3C8),
                    const Color(0xff9FB3C8)
                  ],
              )
            ),
        child: Text(message,
            textAlign: TextAlign.start,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'OverpassRegular',
                fontWeight: FontWeight.w300)),
      ),
    );
  }
}
