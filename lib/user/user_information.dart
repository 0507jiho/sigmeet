import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meeting_app/user/participated_meeting.dart';
import 'package:meeting_app/user/written_meeting.dart';

class UserInformation extends StatefulWidget {
  const UserInformation(this.userID, {Key? key}) : super(key: key);

  final String userID;

  @override
  State<UserInformation> createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userID)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(
            child: Text('Document does not exist'),
          );
        }

        final List writtenMeeting = snapshot.data!['writtenMeeting'];
        final List participatedMeeting = snapshot.data!['participatedMeeting'];

        return SingleChildScrollView(
          child: Column(
            children: [
              WrittenMeeting(writtenMeeting),
              ParticipatedMeeting(participatedMeeting),
            ],
          ),
        );
      },
    );
    ;
  }
}
