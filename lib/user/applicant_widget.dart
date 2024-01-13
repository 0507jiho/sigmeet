import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meeting_app/config/palette.dart';

class ApplicantWidget extends StatefulWidget {
  const ApplicantWidget(this.userID, this.documentID, this.onDelete, {Key? key})
      : super(key: key);

  final String userID;
  final String documentID;
  final VoidCallback onDelete;

  @override
  State<ApplicantWidget> createState() => _ApplicantWidgetState();
}

class _ApplicantWidgetState extends State<ApplicantWidget> {
  final user = FirebaseAuth.instance.currentUser;

  Future<DocumentSnapshot> fetchDataFromFirebase() async {
    String userID = widget.userID;

    // Firebase Firestore에서 한 개의 문서 조회
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userID).get();

    return snapshot;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: fetchDataFromFirebase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 데이터를 아직 가져오지 못한 경우
          return CircularProgressIndicator(); // 로딩 표시 등을 보여줄 수 있습니다.
        } else if (snapshot.hasError) {
          // 에러가 발생한 경우
          return Text('Error: ${snapshot.error}');
        } else {
          // 데이터를 성공적으로 가져온 경우
          if (snapshot.hasData) {
            String userName = snapshot.data!['userName'];
            int userRate = snapshot.data!['userRate'];
            String userGender = snapshot.data!['userGender'];
            String userMajor = snapshot.data!['userMajor'];
            int userClass = snapshot.data!['userClass'];
            int userBirth = snapshot.data!['userBirth'].toDate().year % 100;
            String userImage = snapshot.data!['userImage'];

            return Container(
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(5),
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      backgroundImage: NetworkImage(userImage),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(userName),
                            SizedBox(
                              width: 20,
                            ),
                            Text('$userRate점'),
                          ],
                        ),
                        Text(
                            '$userGender, $userMajor, $userClass학번, ${userBirth.toString().padLeft(2, '0')}년생'),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.userID)
                              .update({
                            'requestedMeeting':
                                FieldValue.arrayRemove([widget.documentID]),
                          });
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.userID)
                              .update({
                            'participatedMeeting':
                                FieldValue.arrayUnion([widget.documentID]),
                          });
                          await FirebaseFirestore.instance
                              .collection('meetings')
                              .doc(widget.documentID)
                              .update({
                            'applicantID':
                                FieldValue.arrayRemove([widget.userID]),
                          });
                          await FirebaseFirestore.instance
                              .collection('meetings')
                              .doc(widget.documentID)
                              .update({
                            'memberID': FieldValue.arrayUnion([widget.userID]),
                          });
                          widget.onDelete();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(5),
                          backgroundColor: Palette.buttonColor1,
                          minimumSize: Size(30, 30),
                        ),
                        child: Icon(Icons.check, size: 15,),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.userID)
                              .update({
                            'requestedMeeting':
                                FieldValue.arrayRemove([widget.documentID]),
                          });
                          await FirebaseFirestore.instance
                              .collection('meetings')
                              .doc(widget.documentID)
                              .update({
                            'applicantID':
                                FieldValue.arrayRemove([widget.userID]),
                          });
                          widget.onDelete();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(5),
                          backgroundColor: Palette.cancelButtonColor,
                          minimumSize: Size(30, 30),
                        ),
                        child: Icon(Icons.close, size: 15,),
                      ),
                    ],
                  )
                ],
              ),
            );
          } else {
            return Text('Document does not exist');
          }
        }
      },
    );
  }
}
