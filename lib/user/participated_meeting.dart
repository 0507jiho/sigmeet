import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meeting_app/meeting/meeting_widget.dart';

class ParticipatedMeeting extends StatefulWidget {
  const ParticipatedMeeting(this.participatedMeeting, {Key? key}) : super(key: key);

  final List participatedMeeting;

  @override
  State<ParticipatedMeeting> createState() => _ParticipatedMeetingState();
}

class _ParticipatedMeetingState extends State<ParticipatedMeeting> {
  bool isExpanded = false;
  late Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> futureDocs;

  @override
  void initState() {
    super.initState();
    futureDocs = fetchDocuments();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  fetchDocuments() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('meetings')
        .where(FieldPath.documentId, whereIn: widget.participatedMeeting)
        .get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 20),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        width: MediaQuery.of(context).size.width - 20,
        height: isExpanded ? 500 : null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 1,
            color: Colors.grey,
          ),
        ),
        child: Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '참가한 모임',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    !isExpanded ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                  ),
                ],
              ),
            ),
            if (isExpanded)
              Expanded(
                child: FutureBuilder<
                    List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                  future: futureDocs,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final docs = snapshot.data ?? [];

                    return ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
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
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
