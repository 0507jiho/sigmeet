import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meeting_app/config/palette.dart';
import 'package:meeting_app/shared/menu_bottom.dart';
import 'package:meeting_app/user/user_information.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _authentication.currentUser;
      if (user != null) {
        loggedUser = user;
        print(loggedUser!.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          '내 정보',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _authentication.signOut();
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.exit_to_app_sharp,
              color: Colors.white,
            ),
          ),
        ],
        backgroundColor: Palette.backgroundColor,
      ),
      bottomNavigationBar: MenuBottom(1),
      body: UserInformation(loggedUser!.uid),
    );
  }
}
