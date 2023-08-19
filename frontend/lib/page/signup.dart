import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:test_project/page/login.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  //String userID = '';
  final TextEditingController _userIDController = TextEditingController();
  //String userPW = '';
  final TextEditingController _userPWController = TextEditingController();
  //String confirmPW = '';
  final TextEditingController _confirmPWController = TextEditingController();

  //final _formKey = GrobalKey<FormState>();

  Widget makeStringInput({
    //required String text,
    required TextEditingController controller,
    label,
    obsureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
        const SizedBox(
          height: 5,
        ),
        TextField(
          obscureText: obsureText,
          controller: controller,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
              ),
            ),
            border: OutlineInputBorder(
                borderSide: BorderSide(
              color: Colors.grey,
            )),
          ),
        ),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }

  Widget makeIntInput({
    required TextEditingController controller,
    label,
    obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          maxLength: 13,
          obscureText: obscureText,
          controller: controller,
          onChanged: (value) {
            // 입력 값에서 '-' 제거
            String phoneNum = value.replaceAll('-', '');
            // 빈 문자열인 경우 그대로 입력
            if (phoneNum.isEmpty) {
              controller.value = TextEditingValue(
                text: '',
                selection: TextSelection.fromPosition(
                  const TextPosition(offset: 0),
                ),
              );
              return;
            }
            // 전화번호에 '-' 추가
            String formattedPhoneNum = '';
            for (int i = 0; i < phoneNum.length; i++) {
              if (i == 3 || i == 7) {
                formattedPhoneNum += '-';
              }
              formattedPhoneNum += phoneNum[i];
            }

            // 변경된 값을 다시 입력
            controller.value = TextEditingValue(
              text: formattedPhoneNum,
              selection: TextSelection.fromPosition(
                TextPosition(offset: formattedPhoneNum.length),
              ),
            );
          },
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
              ),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
              ),
            ),
            counterText: '', // 최대 입력 길이 표시 제거
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Future _sendSignUpDataToServer({
    required String userId,
    required String userPw,
  }) async {
    final uri = Uri.parse(
        'https://hu7ixbp145.execute-api.ap-northeast-2.amazonaws.com/SendImage-test/users');

    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'Method': 'Signup',
      'userId': userId,
      'userPw': userPw,
    });

    try {
      final response = await http
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        print(response.statusCode);
        print(response.body);
        return responseBody["statusCode"];
      } else {
        print(response.statusCode);
        print(response.reasonPhrase);
        return false;
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to send total data');
    }
  }

  PreferredSizeWidget _signupAppbarWidget() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_sharp),
        color: Colors.black,
        padding: EdgeInsets.zero,
        onPressed: () {
          Navigator.pop(context);
        },
        constraints: const BoxConstraints(),
        splashRadius: 24,
        iconSize: 24,
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(Size.zero),
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 1,
      title: Row(
        children: const [
          Expanded(
            child: Center(
              child: Text(
                "회원가입",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          style: ButtonStyle(
            minimumSize: MaterialStateProperty.all(Size.zero),
            padding: const MaterialStatePropertyAll(
                EdgeInsets.fromLTRB(0, 0, 20, 0)),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            overlayColor:
                MaterialStateColor.resolveWith((states) => Colors.transparent),
            backgroundColor:
                MaterialStateColor.resolveWith((states) => Colors.transparent),
            foregroundColor: MaterialStateColor.resolveWith((states) =>
                states.contains(MaterialState.pressed)
                    ? Colors.blue
                    : Colors.black),
          ),
          onPressed: () async {},
          child: const Text(
            "완료",
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ],
    );
  }

  final FocusNode _passwordFocus = FocusNode();
  Widget _bodyWiget() {
    return SafeArea(
      child: SingleChildScrollView(
        child: SizedBox(
          //height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        Flex(
                          direction: Axis.vertical,
                          children: [
                            const SizedBox(
                              height: 30,
                            ),
                            makeStringInput(
                              label: "ID",
                              //text: userID,
                              controller: _userIDController,
                            ),
                            makeStringInput(
                              label: "Password",
                              obsureText: true,
                              //text: userPW,
                              controller: _userPWController,
                            ),
                            makeStringInput(
                              label: "Confirm Pasword",
                              obsureText: true,
                              //text: confirmPW,
                              controller: _confirmPWController,
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Container(
                      padding: const EdgeInsets.only(top: 3, left: 3),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          border: const Border(
                              bottom: BorderSide(color: Colors.black),
                              top: BorderSide(color: Colors.black),
                              right: BorderSide(color: Colors.black),
                              left: BorderSide(color: Colors.black))),
                      child: MaterialButton(
                        minWidth: double.infinity,
                        height: 60,
                        onPressed: () async {
                          if (_userIDController.text.isEmpty) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(0, 20, 0, 5),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: const [
                                      Text(
                                        "ID를 입력해주세요",
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
                                                MaterialStateColor.resolveWith(
                                              (states) {
                                                if (states.contains(
                                                    MaterialState.disabled)) {
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
                          } else if (_userPWController.text.isEmpty) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(0, 20, 0, 5),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: const [
                                      Text(
                                        "비밀번호를 입력해주세요",
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
                                                MaterialStateColor.resolveWith(
                                              (states) {
                                                if (states.contains(
                                                    MaterialState.disabled)) {
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
                          } else if (_confirmPWController.text.isEmpty) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(0, 20, 0, 5),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: const [
                                      Text(
                                        "재확인 비밀번호를 입력해주세요",
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
                                                MaterialStateColor.resolveWith(
                                              (states) {
                                                if (states.contains(
                                                    MaterialState.disabled)) {
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
                          } else if (_confirmPWController.text !=
                              _userPWController.text) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(0, 20, 0, 5),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: const [
                                      Text(
                                        "비밀번호가 일치하지않습니다.",
                                      ),
                                      Text(
                                        "다시 입력해주세요",
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
                                                MaterialStateColor.resolveWith(
                                              (states) {
                                                if (states.contains(
                                                    MaterialState.disabled)) {
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
                          } else {
                            // 모든 필드가 입력되었고 비밀번호가 일치하는 경우
                            late var success;
                            success = await _sendSignUpDataToServer(
                              userId: _userIDController.text,
                              userPw: _confirmPWController.text,
                            );
                            if (success == 200) {
                              // // ignore: use_build_context_synchronously
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) => const LogIn()),
                              // );
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                            } else if (success == 400) {
                              // ignore: use_build_context_synchronously
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    contentPadding:
                                        const EdgeInsets.fromLTRB(0, 20, 0, 5),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: const [
                                        Text(
                                          "이미 등록된 아이디입니다.",
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
                                                      MaterialState.disabled)) {
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
                            } else {
                              // ignore: use_build_context_synchronously
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    contentPadding:
                                        const EdgeInsets.fromLTRB(0, 20, 0, 5),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: const [
                                        Text(
                                          "서버와의 통신이 원활하지않습니다.",
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
                                                      MaterialState.disabled)) {
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
                          }
                        },
                        //color: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40)),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("계정이 이미 존재하시나요? "),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LogIn()),
                            );
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ))
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _signupAppbarWidget(),
      body: _bodyWiget(),
    );
  }
}
