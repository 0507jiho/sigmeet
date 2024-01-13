import 'dart:io';
import 'package:flutter/material.dart';
import 'package:meeting_app/config/palette.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({Key? key}) : super(key: key);

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  final _classList = List<int>.generate(10, (int index) => 23 - index);
  final _majorList = ['소프트웨어', '인공지능', '컴퓨터공학'];

  final _authentication = FirebaseAuth.instance;
  bool isLoginScreen = true;
  bool showSpinner = false;
  final _formkey = GlobalKey<FormState>();
  String userName = '';
  String userEmail = '';
  String userPassword = '';
  String userGender = '남자';
  int userClass = 23;
  DateTime? userBirth;
  String userMajor = '소프트웨어';

  void _tryValidation() {
    final isValid = _formkey.currentState!.validate();
    if (isValid) {
      _formkey.currentState!.save();
    }
  }

  File? pickedImage;

  void _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImageFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxHeight: 300,
    );
    setState(() {
      if (pickedImageFile != null) {
        pickedImage = File(pickedImageFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: 'Σ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'Sigmeet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]),
                ),
                //Title
                Container(
                  margin: EdgeInsets.all(15),
                  padding: EdgeInsets.all(20),
                  height: isLoginScreen ? 400 : 500,
                  width: MediaQuery.of(context).size.width - 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isLoginScreen = true;
                              });
                            },
                            child: Text(
                              '로그인',
                              style: TextStyle(
                                color: isLoginScreen
                                    ? Palette.activeColor
                                    : Palette.textColor1,
                                fontSize: isLoginScreen ? 20 : 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isLoginScreen = false;
                              });
                            },
                            child: Text(
                              '회원가입',
                              style: TextStyle(
                                color: !isLoginScreen
                                    ? Palette.activeColor
                                    : Palette.textColor1,
                                fontSize: !isLoginScreen ? 20 : 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (isLoginScreen)
                        Container(
                          margin: EdgeInsets.only(top: 45),
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Form(
                            key: _formkey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '이메일',
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
                                    return null;
                                  },
                                  onSaved: (value) {
                                    userEmail = value!;
                                  },
                                  onChanged: (value) {
                                    userEmail = value;
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(10),
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  '비밀번호',
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                TextFormField(
                                  key: ValueKey(2),
                                  validator: (value) {
                                    if (value!.isEmpty || value.length < 6) {
                                      return 'Password must be at least 6 characters long';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    userPassword = value!;
                                  },
                                  onChanged: (value) {
                                    userPassword = value;
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(10),
                                  ),
                                  obscureText: true,
                                ),
                                Center(
                                  child: GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        showSpinner = true;
                                      });
                                      _tryValidation();
                                      try {
                                        final newUser = await _authentication
                                            .signInWithEmailAndPassword(
                                          email: userEmail,
                                          password: userPassword,
                                        );
                                        if (newUser.user != null) {
                                          if (!mounted) return;
                                          setState(() {
                                            showSpinner = false;
                                          });
                                        }
                                      } catch (e) {
                                        print(e);
                                      }
                                    },
                                    child: Container(
                                      margin:
                                          EdgeInsets.symmetric(vertical: 30),
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
                                )
                              ],
                            ),
                          ),
                        ),
                      if (!isLoginScreen)
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(top: 45),
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Form(
                              key: _formkey,
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Column(
                                        children: [
                                          CircleAvatar(
                                            radius: 80,
                                            backgroundColor: Colors.grey[300],
                                            backgroundImage: pickedImage != null
                                                ? FileImage(pickedImage!)
                                                : null,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              _pickImage();
                                            },
                                            child: Container(
                                              margin: EdgeInsets.all(10),
                                              width: 100,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Palette.buttonColor1,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.image,
                                                    color: Colors.white,
                                                  ),
                                                  Text(
                                                    '사진 선택',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '이메일',
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    TextFormField(
                                      key: ValueKey(3),
                                      validator: (value) {
                                        if (value!.isEmpty ||
                                            value.length < 4) {
                                          return 'Please enter at least 4 characters';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) {
                                        userEmail = value!;
                                      },
                                      onChanged: (value) {
                                        userEmail = value;
                                      },
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(10),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      '비밀번호',
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    TextFormField(
                                      key: ValueKey(4),
                                      validator: (value) {
                                        if (value!.isEmpty ||
                                            value.length < 6) {
                                          return 'Password must be at least 6 characters long';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) {
                                        userPassword = value!;
                                      },
                                      onChanged: (value) {
                                        userPassword = value;
                                      },
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(10),
                                      ),
                                      obscureText: true,
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      '닉네임',
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    TextFormField(
                                      key: ValueKey(5),
                                      validator: (value) {
                                        if (value!.isEmpty ||
                                            value.length < 2) {
                                          return 'Nickname must be at least 2 characters long';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) {
                                        userName = value!;
                                      },
                                      onChanged: (value) {
                                        userName = value;
                                      },
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(10),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      '성별',
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: RadioListTile(
                                            title: Text('남자'),
                                            value: '남자',
                                            groupValue: userGender,
                                            onChanged: (value) {
                                              setState(() {
                                                userGender = value!;
                                              });
                                            },
                                          ),
                                        ),
                                        Expanded(
                                          child: RadioListTile(
                                            title: Text('여자'),
                                            value: '여자',
                                            groupValue: userGender,
                                            onChanged: (value) {
                                              setState(() {
                                                userGender = value!;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '학번',
                                              style: TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                            DropdownButton(
                                              value: userClass,
                                              items: _classList.map(
                                                (value) {
                                                  return DropdownMenuItem(
                                                    value: value,
                                                    child: Text('$value학번'),
                                                  );
                                                },
                                              ).toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  userClass = value!;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '생년월일',
                                              style: TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  userBirth != null
                                                      ? userBirth
                                                          .toString()
                                                          .split(" ")[0]
                                                      : "0000-00-00",
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
                                                      initialDate:
                                                          DateTime.now(),
                                                      firstDate: DateTime(1900),
                                                      lastDate: DateTime.now(),
                                                    ).then((selectedDate) {
                                                      setState(() {
                                                        userBirth =
                                                            selectedDate;
                                                      });
                                                    });
                                                  },
                                                  child: Icon(
                                                      Icons.calendar_month),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      '학과',
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    DropdownButton(
                                      value: userMajor,
                                      items: _majorList.map(
                                        (value) {
                                          return DropdownMenuItem(
                                            value: value,
                                            child: Text(value),
                                          );
                                        },
                                      ).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          userMajor = value!;
                                        });
                                      },
                                    ),
                                    Center(
                                      child: GestureDetector(
                                        onTap: () async {
                                          setState(() {
                                            showSpinner = true;
                                          });
                                          if (pickedImage == null) {
                                            setState(() {
                                              showSpinner = false;
                                            });
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Please pick your image'),
                                                backgroundColor: Colors.blue,
                                              ),
                                            );
                                            return;
                                          }
                                          _tryValidation();
                                          try {
                                            final newUser = await _authentication
                                                .createUserWithEmailAndPassword(
                                              email: userEmail,
                                              password: userPassword,
                                            );

                                            final Reference refImage =
                                                FirebaseStorage.instance
                                                    .ref()
                                                    .child('user_image')
                                                    .child(
                                                        '${newUser.user!.uid}.png');
                                            await refImage
                                                .putFile(pickedImage!);
                                            final url =
                                                await refImage.getDownloadURL();

                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(newUser.user!.uid)
                                                .set({
                                              'userName': userName,
                                              'email': userEmail,
                                              'userGender': userGender,
                                              'userClass': userClass,
                                              'userBirth': userBirth,
                                              'userMajor': userMajor,
                                              'userRate': 50,
                                              'userImage': url,
                                              'participatedMeeting': [],
                                              'requestedMeeting': [],
                                              'writtenMeeting': [],
                                            });
                                            if (newUser.user != null) {
                                              if (!mounted) return;
                                              setState(() {
                                                showSpinner = false;
                                              });
                                            }
                                          } catch (e) {
                                            print(e);
                                            if (mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Please check your email and password'),
                                                  backgroundColor: Colors.blue,
                                                ),
                                              );
                                              setState(() {
                                                showSpinner = false;
                                              });
                                              return;
                                            }
                                          }
                                        },
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: 30),
                                          height: 45,
                                          width: 100,
                                          decoration: BoxDecoration(
                                            color: Palette.buttonColor1,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Icon(
                                            Icons.arrow_forward,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                //Login & Signup
              ],
            ),
          ),
        ),
      ),
    );
  }
}
