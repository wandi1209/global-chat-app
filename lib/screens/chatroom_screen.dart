import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:globalchat/providers/user_provider.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ChatroomScreen extends StatefulWidget {
  String chatroomName;
  String chatroomId;
  ChatroomScreen(
      {super.key, required this.chatroomName, required this.chatroomId});

  @override
  State<ChatroomScreen> createState() => _ChatroomScreenState();
}

class _ChatroomScreenState extends State<ChatroomScreen> {
  var db = FirebaseFirestore.instance;
  TextEditingController messageText = TextEditingController();

  Future<void> sendMessage() async {
    if (messageText.text.isEmpty) {
      return;
    }
    Map<String, dynamic> messageToSend = {
      "text": messageText.text,
      "sender_name": Provider.of<UserProvider>(context, listen: false).userName,
      "sender_id": Provider.of<UserProvider>(context, listen: false).userId,
      "chatroom_id": widget.chatroomId,
      "timestamp": FieldValue.serverTimestamp(),
    };
    try {
      await db.collection("messages").add(messageToSend);
      messageText.text = "";
    } catch (e) {}
  }

  Widget singleChatItem({
    required String senderName,
    required String text,
    required String senderId,
  }) {
    return Column(
      crossAxisAlignment:
          senderId == Provider.of<UserProvider>(context, listen: false).userId
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, right: 6),
          child: Text(
            senderName,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Container(
            decoration: BoxDecoration(
              color: senderId ==
                      Provider.of<UserProvider>(context, listen: false).userId
                  ? Colors.blueGrey[900]
                  : Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                text,
                style: TextStyle(
                    color: senderId ==
                            Provider.of<UserProvider>(context, listen: false)
                                .userId
                        ? Colors.white
                        : Colors.black),
              ),
            )),
        SizedBox(
          height: 8,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatroomName),
      ),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder(
                  stream: db
                      .collection("messages")
                      .where("chatroom_id", isEqualTo: widget.chatroomId)
                      .orderBy("timestamp", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print(snapshot.error);
                      return Text("Some error has occured!");
                    }
                    var allMessages = snapshot.data?.docs ?? [];
                    if (allMessages.length < 1) {
                      return Center(
                        child: Text("No message here"),
                      );
                    }

                    return ListView.builder(
                        reverse: true,
                        itemCount: allMessages.length,
                        itemBuilder: (
                          BuildContext context,
                          int index,
                        ) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: singleChatItem(
                              senderName: allMessages[index]["sender_name"],
                              text: allMessages[index]["text"],
                              senderId: allMessages[index]["sender_id"],
                            ),
                          );
                        });
                  })),
          Container(
            color: Colors.grey[200],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: messageText,
                    decoration: InputDecoration(
                      hintText: "Write message here...",
                      border: InputBorder.none,
                    ),
                  )),
                  InkWell(
                    onTap: sendMessage,
                    child: Icon(Icons.send),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
