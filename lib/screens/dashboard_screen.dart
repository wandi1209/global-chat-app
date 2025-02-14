import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:globalchat/providers/user_provider.dart';
import 'package:globalchat/screens/chatroom_screen.dart';
import 'package:globalchat/screens/profile_screen.dart';
import 'package:globalchat/screens/splash_screen.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  var user = FirebaseAuth.instance.currentUser;
  var db = FirebaseFirestore.instance;
  var scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> chatroomsList = [];
  List<String> chatroomsIds = [];

  void getChatrooms() {
    db.collection("chatrooms").get().then((dataSnapshot) {
      for (var singleChatroomData in dataSnapshot.docs) {
        chatroomsList.add(singleChatroomData.data());
        chatroomsIds.add(singleChatroomData.id.toString());
      }
      setState(() {});
    });
  }

  @override
  void initState() {
    getChatrooms();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text("Global Chat"),
          leading: InkWell(
            onTap: () {
              scaffoldKey.currentState!.openDrawer();
            },
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: CircleAvatar(
                child: Text(
                  (userProvider.userName.isNotEmpty)
                      ? userProvider.userName[0]
                      : "?",
                ),
              ),
            ),
          ),
        ),
        drawer: Drawer(
          child: Container(
            child: Column(
              children: [
                SizedBox(height: 50),
                ListTile(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ProfileScreen();
                    }));
                  },
                  leading: CircleAvatar(
                    child: Text(
                      (userProvider.userName.isNotEmpty)
                          ? userProvider.userName[0]
                          : "?",
                    ),
                  ),
                  title: Text(
                    userProvider.userName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(userProvider.userEmail),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ProfileScreen();
                    }));
                  },
                  leading: Icon(Icons.people),
                  title: Text("Profile"),
                ),
                ListTile(
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(builder: (context) {
                      return SplashScreen();
                    }), (route) {
                      return false;
                    });
                  },
                  leading: Icon(Icons.logout),
                  title: Text("Logout"),
                ),
              ],
            ),
          ),
        ),
        body: ListView.builder(
          itemCount: chatroomsList.length,
          itemBuilder: (BuildContext context, int index) {
            String chatroomName = chatroomsList[index]["chatroom_name"] ?? "";
            return ListTile(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ChatroomScreen(
                    chatroomId: chatroomsIds[index],
                    chatroomName: chatroomName,
                  );
                }));
              },
              leading: CircleAvatar(
                backgroundColor: Colors.blueGrey[900],
                child: Text(
                  chatroomName[0],
                  style: TextStyle(color: Colors.white),
                ),
              ),
              title: Text(chatroomName),
              subtitle: Text(chatroomsList[index]["desc"]),
            );
          },
        ));
  }
}
