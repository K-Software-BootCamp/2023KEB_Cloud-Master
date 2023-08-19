import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:test_project/page/signup.dart';

import '../repository/contents_repository.dart';
import 'control.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  // =======================================================
  TextEditingController userId = TextEditingController();
  TextEditingController userPw = TextEditingController();
  String? jwt;
  late dynamic statusCode;
  // =======================================================
  Future _sendDataToServer({
    required String userId,
    required String userPw,
  }) async {
    final uri = Uri.parse(
        'https://hu7ixbp145.execute-api.ap-northeast-2.amazonaws.com/SendImage-test/users');

    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'Method': 'Login',
      'userId': userId,
      'userPw': userPw,
    });

    final response = await http
        .post(uri, headers: headers, body: body)
        .timeout(const Duration(seconds: 5));

    final responseBody = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (responseBody["statusCode"] == 200) {
        setState(() {
          UserInfo.userId = userId;
        });
      }
      print(response.statusCode);
      print(responseBody);
      return int.parse(responseBody["statusCode"].toString());
    } else {
      setState(() {
        statusCode = response.statusCode;
      });
      return int.parse(responseBody["statusCode"].toString());
    }
  }

  void _fetchData(BuildContext context) async {
    // Show the loading dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 15),
                Text('Loading...'),
              ],
            ),
          ),
        );
      },
    );

    // Simulate asynchronous delay
    await Future.delayed(const Duration(seconds: 3));

    // Close the loading dialog
    Navigator.of(context).pop();
  }

  // =======================================================
  Widget _bodyWidget() {
    // Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: Colors.white,
        child: Column(
          //scrollDirection: Axis.vertical,
          children: [
            Flexible(
              flex: 2,
              child: Container(),
            ),
            Flexible(
              flex: 5,
              child: Container(
                // ignore: sort_child_properties_last
                child: const Center(
                  child: Text("앱 이미지 스페이스"),
                ),
                decoration: const BoxDecoration(
                  color: Colors.blueAccent,
                ),
              ),
              // Image.asset(
              //   "assets/images/appIcon.png",
              // ),
            ),
            Flexible(
              flex: 10,
              child: Form(
                child: Theme(
                  data: ThemeData(
                    primaryColor: Colors.grey,
                    inputDecorationTheme: const InputDecorationTheme(
                      labelStyle: TextStyle(
                        color: Colors.teal,
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(40.0),
                    child: Builder(
                      builder: (context) {
                        return Column(
                          children: [
                            TextField(
                              controller: userId,
                              decoration:
                                  const InputDecoration(labelText: 'ID 입력'),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            TextField(
                              controller: userPw,
                              decoration:
                                  const InputDecoration(labelText: '비밀번호 입력'),
                              keyboardType: TextInputType.text,
                              obscureText: true, // 비밀번호 안보이도록 하는 것
                            ),
                            const Padding(padding: EdgeInsets.all(10)),
                            ButtonTheme(
                              // minWidth: 100.0,
                              // height: 50.0,
                              child: ElevatedButton(
                                onPressed: () async {
                                  _fetchData(context);
                                  statusCode = await _sendDataToServer(
                                    userId: userId.text,
                                    userPw: userPw.text,
                                  );

                                  if (statusCode == 200) {
                                    try {
                                      setState(() {
                                        UserInfo.userId = userId.text;
                                      });
                                      // ignore: use_build_context_synchronously
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const Control()),
                                          (route) => false);
                                    } catch (e) {
                                      // ignore: use_build_context_synchronously
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            contentPadding:
                                                const EdgeInsets.fromLTRB(
                                                    0, 20, 0, 5),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0)),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: const [
                                                Text(
                                                  "인터넷 연결이 불안정합니다.",
                                                ),
                                              ],
                                            ),
                                            actions: <Widget>[
                                              Center(
                                                child: SizedBox(
                                                  width: 250,
                                                  child: ElevatedButton(
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateColor
                                                              .resolveWith(
                                                        (states) {
                                                          if (states.contains(
                                                              MaterialState
                                                                  .disabled)) {
                                                            return Colors.grey;
                                                          } else {
                                                            return Colors.blue;
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                    child: const Text("확인"),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  } else {
                                    // ignore: use_build_context_synchronously
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  0, 20, 0, 5),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0)),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: const [
                                              Text(
                                                "ID 또는 패스워드를 확인해주세요.",
                                              ),
                                            ],
                                          ),
                                          actions: <Widget>[
                                            Center(
                                              child: SizedBox(
                                                width: 250,
                                                child: ElevatedButton(
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateColor
                                                            .resolveWith(
                                                      (states) {
                                                        if (states.contains(
                                                            MaterialState
                                                                .disabled)) {
                                                          return Colors.grey;
                                                        } else {
                                                          return Colors.blue;
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                  child: const Text("확인"),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(312.7, 45),
                                  backgroundColor: Colors.blueAccent,
                                ),
                                child: const Text(
                                  "로그인",
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const SignUp()),
                                      );
                                    },
                                    child: const Text(
                                      '회원가입',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _bodyWidget(),
    );
  }
}
