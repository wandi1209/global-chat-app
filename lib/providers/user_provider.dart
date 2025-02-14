import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String userName = "";
  String userEmail = "";
  String userId = "";

  Map<String, dynamic>? userData = {};
  var db = FirebaseFirestore.instance;

  Future<void> getUserDetails() async {
    var authUser = FirebaseAuth.instance.currentUser;
    await db.collection("users").doc(authUser!.uid).get().then((dataSnapshot) {
      userName = dataSnapshot.data()?["name"] ?? "";
      userEmail = dataSnapshot.data()?["email"] ?? "";
      userId = dataSnapshot.data()?["id"] ?? "";
      notifyListeners();
    });
  }
}
