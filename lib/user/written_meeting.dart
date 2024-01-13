import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meeting_app/config/palette.dart';
import 'package:meeting_app/user/applicant_widget.dart';

class WrittenMeeting extends StatefulWidget {
  const WrittenMeeting(this.writtenMeeting, {Key? key}) : super(key: key);

  final List writtenMeeting;

  @override
  State<WrittenMeeting> createState() => _WrittenMeetingState();
}

class _WrittenMeetingState extends State<WrittenMeeting> {
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
        .where(FieldPath.documentId, whereIn: widget.writtenMeeting)
        .get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    Future deleteDocument(String docID, List applicantID, List memberID) async {
      for (String id in applicantID) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(id)
            .update({
          'requestedMeeting':
          FieldValue.arrayRemove([docID]),
        });
      }

      for (String id in memberID) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(id)
            .update({
          'participatedMeeting':
          FieldValue.arrayRemove([docID]),
        });
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'writtenMeeting':
        FieldValue.arrayRemove([docID]),
      });

      await FirebaseFirestore.instance
          .collection('meetings')
          .doc(docID)
          .delete();
    }

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
                    '내가 만든 모임',
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
                        List<Widget> widgetList = [];
                        if (docs[index]['applicantID'].length == 0) {
                          widgetList.add(
                            Text('신청자가 없습니다'),
                          );
                        }
                        docs[index]['applicantID'].forEach((item) {
                          widgetList
                              .add(ApplicantWidget(item, docs[index].id, () {
                            setState(() {
                              widgetList.removeWhere((widget) =>
                                  widget is ApplicantWidget &&
                                  widget.userID == item);
                            });
                          }));
                        });
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      docs[index]['title'],
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    deleteDocument(docs[index].id, docs[index]['applicantID'], docs[index]['memberID']);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.all(5),
                                    backgroundColor: Palette.inactiveButtonColor,
                                    minimumSize: Size(30, 20),
                                  ),
                                  child: Text(
                                    '삭제',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: widgetList,
                            ),
                          ],
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
