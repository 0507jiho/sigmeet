import 'package:flutter/material.dart';
import 'package:meeting_app/config/palette.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meeting_app/popup/link_copy_popup.dart';

class MeetingWidget extends StatefulWidget {
  const MeetingWidget(this.meetingID, this.title, this.time, this.memberID,
      this.applicantID, this.maxMember, this.userID, this.chatURL,
      {Key? key})
      : super(key: key);

  final String meetingID;
  final String title;
  final Timestamp time;
  final List memberID;
  final List applicantID;
  final int maxMember;
  final String userID;
  final String chatURL;

  @override
  State<MeetingWidget> createState() => _MeetingWidgetState();
}

class _MeetingWidgetState extends State<MeetingWidget> {
  String userName = '';
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
    DateTime now = DateTime.now();
    String title = widget.title;
    DateTime time = widget.time.toDate();
    List memberID = widget.memberID;
    List applicantID = widget.applicantID;
    int nowMember = memberID.length;

    return FutureBuilder<DocumentSnapshot>(
      future: fetchDataFromFirebase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 데이터를 아직 가져오지 못한 경우
          return Center(child: CircularProgressIndicator()); // 로딩 표시 등을 보여줄 수 있습니다.
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
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_month),
                          Text.rich(
                            TextSpan(children: [
                              (now.year == time.year &&
                                      now.month == time.month &&
                                      now.day == time.day)
                                  ? TextSpan(text: ' 오늘 ')
                                  : TextSpan(
                                      text: ' ${time.month}/${time.day} '),
                              (time.hour < 12)
                                  ? TextSpan(
                                      text: '오전 ${time.hour}시 ${time.minute}분')
                                  : TextSpan(
                                      text:
                                          '오후 ${time.hour - 12}시 ${time.minute}분'),
                            ]),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Row(
                        children: [
                          Icon(Icons.group),
                          Text(' $nowMember / ${widget.maxMember}명'),
                        ],
                      ),
                      SizedBox(),
                    ],
                  ),
                  Divider(
                    color: Colors.grey[800],
                  ),
                  Row(
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
                                // Text('$userRate점'),
                              ],
                            ),
                            Text(
                                '$userGender, $userMajor, $userClass학번, ${userBirth.toString().padLeft(2, '0')}년생'),
                          ],
                        ),
                      ),
                      if (!memberID.contains(user!.uid) &&
                          !applicantID.contains(user!.uid) && !(nowMember == widget.maxMember))
                        GestureDetector(
                          onTap: () async {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user!.uid)
                                .update({
                              'requestedMeeting':
                                  FieldValue.arrayUnion([widget.meetingID]),
                            });
                            await FirebaseFirestore.instance
                                .collection('meetings')
                                .doc(widget.meetingID)
                                .update({
                              'applicantID': FieldValue.arrayUnion([user!.uid]),
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            height: 30,
                            width: 70,
                            decoration: BoxDecoration(
                              color: Palette.activeButtonColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Text(
                                '신청하기',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (applicantID.contains(user!.uid))
                        GestureDetector(
                          onTap: () async {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user!.uid)
                                .update({
                              'requestedMeeting':
                                  FieldValue.arrayRemove([widget.meetingID]),
                            });
                            await FirebaseFirestore.instance
                                .collection('meetings')
                                .doc(widget.meetingID)
                                .update({
                              'applicantID':
                                  FieldValue.arrayRemove([user!.uid]),
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            height: 30,
                            width: 70,
                            decoration: BoxDecoration(
                              color: Palette.cancelButtonColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Text(
                                '신청취소',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (memberID.contains(user!.uid))
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  LinkCopyPopup(widget.chatURL),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            height: 30,
                            width: 70,
                            decoration: BoxDecoration(
                              color: Palette.checkButtonColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Text(
                                '링크확인',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (nowMember == widget.maxMember)
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          height: 30,
                          width: 70,
                          decoration: BoxDecoration(
                            color: Palette.inactiveButtonColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Text(
                              '신청마감',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
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
