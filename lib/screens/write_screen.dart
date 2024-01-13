import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meeting_app/config/palette.dart';

class WriteScreen extends StatefulWidget {
  const WriteScreen({Key? key}) : super(key: key);

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  final _authentication = FirebaseAuth.instance;
  final _formkey = GlobalKey<FormState>();
  double sliderValue = 2;

  String title = '';
  DateTime? time;
  int? maxMember;
  String url = '';

  void _tryValidation() {
    final isValid = _formkey.currentState!.validate();
    if (isValid) {
      _formkey.currentState!.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          '글 작성',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.close,
              color: Colors.white,
            ),
          ),
        ],
        backgroundColor: Palette.backgroundColor,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formkey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '제목',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  TextFormField(
                    key: ValueKey(1),
                    validator: (value) {
                      if (value!.isEmpty || value.length < 4) {
                        return 'Please enter at least 4 characters';
                      }
                      if (value.length > 20) {
                        return 'Please enter less than 20 characters';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      title = value!;
                    },
                    onChanged: (value) {
                      title = value;
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    '시간',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        time != null
                            ? '${time!.month}월 ${time!.day}일 ${time!.hour}시 ${time!.minute}분'
                            : '시간을 선택하세요',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          ).then((selectedDate) {
                            showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            ).then((newTime) {
                              setState(() {
                                time = DateTime(
                                  selectedDate!.year,
                                  selectedDate!.month,
                                  selectedDate!.day,
                                  newTime!.hour,
                                  newTime!.minute,
                                );
                              });
                            });
                          });
                        },
                        child: Icon(Icons.calendar_month),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    '최대 인원',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            valueIndicatorShape:
                                PaddleSliderValueIndicatorShape(),
                          ),
                          child: Slider(
                            value: sliderValue,
                            min: 2,
                            max: 15,
                            divisions: 13,
                            label: sliderValue != 15
                                ? sliderValue.toInt().toString()
                                : '제한 없음',
                            onChanged: (newValue) {
                              setState(() {
                                sliderValue = newValue;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: sliderValue != 15
                            ? Text('${sliderValue.toInt()}명')
                            : Text('제한 없음'),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    '오픈채팅방 URL',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  TextFormField(
                    key: ValueKey(2),
                    validator: (value) {
                      if (url == '') {
                        return 'Please enter the URL';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      url = value!;
                    },
                    onChanged: (value) {
                      url = value;
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                    ),
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        _tryValidation();
                        try {
                          final meetingDoc = await FirebaseFirestore.instance
                              .collection('meetings')
                              .doc();
                          meetingDoc.set({
                            'title': title,
                            'writtenTime': DateTime.now(),
                            'time': time,
                            'maxMember':
                                sliderValue != 15 ? sliderValue.toInt() : 0,
                            'userID': _authentication.currentUser!.uid,
                            'memberID': [_authentication.currentUser!.uid],
                            'applicantID': [],
                            'chatURL': url,
                          });
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(_authentication.currentUser!.uid)
                              .update({
                            'writtenMeeting':
                                FieldValue.arrayUnion([meetingDoc.id]),
                            'participatedMeeting':
                                FieldValue.arrayUnion([meetingDoc.id]),
                          });
                          if (!mounted) return;
                          Navigator.pop(context);
                        } catch (e) {
                          print(e);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please check your inputs'),
                                backgroundColor: Colors.blue,
                              ),
                            );
                            return;
                          }
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 30),
                        height: 45,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Palette.buttonColor1,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
