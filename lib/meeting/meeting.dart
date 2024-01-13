import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meeting_app/meeting/meeting_widget.dart';

class Meetings extends StatefulWidget {
  const Meetings({Key? key}) : super(key: key);

  @override
  State<Meetings> createState() => _MeetingsState();
}

class _MeetingsState extends State<Meetings> {
  Future closeApplication(String docID, List applicantID) async {
    for (String id in applicantID) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .update({
        'requestedMeeting':
        FieldValue.arrayRemove([docID]),
      });
      await FirebaseFirestore.instance
          .collection('meetings')
          .doc(docID)
          .update({
        'applicantID':
        FieldValue.arrayRemove([id]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('meetings')
          .orderBy('writtenTime', descending: true)
          .snapshots(),
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final docs = snapshot.data!.docs;

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.separated(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              if (docs[index]['memberID'].length == docs[index]['maxMember']) {
                closeApplication(docs[index].id, docs[index]['applicantID']);
              }
              return MeetingWidget(
                docs[index].id,
                docs[index]['title'],
                docs[index]['time'],
                docs[index]['memberID'],
                docs[index]['applicantID'],
                docs[index]['maxMember'],
                docs[index]['userID'],
                docs[index]['chatURL'],
              );
            },
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(
              thickness: 1,
              color: Colors.black,
            ),
          ),
        );
      },
    );
  }
}
