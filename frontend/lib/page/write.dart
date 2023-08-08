import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
// import 'package:test_project/page/control.dart';
// import 'package:test_project/repository/contents_repository.dart';

class Write extends StatefulWidget {
  const Write({super.key});

  @override
  State<Write> createState() => _WriteState();
}

class _WriteState extends State<Write> {
  // textfield에서 입력받은 정보를 저장할 변수
  late String userId;

  late String title;
  final TextEditingController _titleController = TextEditingController();

  late String contents;
  final TextEditingController _contentsController = TextEditingController();

  late String category; //

  late int rate;
  final TextEditingController _rateController = TextEditingController();

  // 사용자의 이미지 저장하는 리스트

  // ignore: unused_field
  late String _uploadedImageUrl;

  String categoryCurrentLocation = "default";

  // 카테고리 선택
  final Map<String, dynamic> categoryOptionsTypeToString = {
    "default": "카테고리",
    "electronics": "디지털/전자",
    "tools": "공구",
    "clothes": "의류",
    "others": "기타"
  };

  final List<XFile> _selectedFiles = [];
  // 사용자의 다수의 image를 받기위한 생성자
  final ImagePicker _picker = ImagePicker();
  Future<void> _selectImages() async {
    try {
      final List<XFile> selectedImages = await _picker.pickMultiImage(
        imageQuality: 100,
      );
      setState(() {
        if (selectedImages.isNotEmpty) {
          _selectedFiles.addAll(selectedImages);
        } else {
          //print('no image select');
        }
      });
    } catch (e) {
      //print(e);
      throw Exception(e);
    }
    print("Image List length: ${_selectedFiles.length.toString()}");
    print(_selectedFiles);
  }

  Future<void> _uploadImagesToServer({
    required List<XFile> selectedFiles,
  }) async {
    final uri = Uri.parse(
        'https://hu7ixbp145.execute-api.ap-northeast-2.amazonaws.com/SendImage-test/images');
    final request = http.MultipartRequest('POST', uri);

    // API 키 추가
    request.headers['x-api-key'] = 'EgHMxqZNlk2C89mFBqv4d6OgrECiOmuD3wSPiMSl';

    // JSON 데이터 추가
    Map<String, dynamic> jsonData = {
      // 추가할 JSON 데이터 내용
      "Method": "sendImagesToS3",
      "userId": "rkskek12",
    };
    request.fields['data'] = jsonEncode(jsonData); // JSON 데이터를 'data' 키로 전송

    print("Sent JSON Data:");
    print(jsonData); // 보내는 JSON 데이터 출력

    for (var selectedFile in selectedFiles) {
      request.files.add(
        await http.MultipartFile.fromPath('filename', selectedFile.path),
      );
    }

    print("Sent Multipart Files:");
    for (var file in request.files) {
      print(file.filename);
    }

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        print("Success");
        print(response.statusCode);

        final responseBody = await response.stream.bytesToString();
        print("Response Data:");
        print(responseBody); // Lambda 함수의 응답 데이터 출력
      } else {
        print("Fail");
        final responseBody = await response.stream.bytesToString();
        print("Response Data:");
        print(responseBody); // Lambda 함수의 응답 데이터 출력
        print(response.statusCode);
        // throw Exception('Failed to send images');
      }
    } catch (e) {
      print(e);
      // throw Exception('Failed to send images');
    }
  }

//   Future<void> uploadImagesToServer({
//   required List<XFile> selectedFiles,
//   required String userId,
//   required String imageDescription,
// }) async {
//   final uri = Uri.parse('https://651n535yzg.execute-api.ap-northeast-2.amazonaws.com/post');

//   final request = http.MultipartRequest('POST', uri);

//   // JSON 데이터 추가
//   final jsonBody = jsonEncode({
//     "Method": "sendImagesToS3",
//     "userId": userId,
//     "imageDescription": imageDescription,
//   });
//   request.fields['jsonData'] = jsonBody;

//   // 이미지 파일 추가
//   for (var selectedFile in selectedFiles) {
//     final file = await http.MultipartFile.fromPath('imageFiles', selectedFile.path);
//     request.files.add(file);
//   }

//   final response = await request.send();
//   if (response.statusCode == 200) {
//     // Lambda 함수에서 올바른 응답을 받은 경우
//     final responseData = await response.stream.bytesToString();
//     print('Response Data: $responseData');
//   } else {
//     // Lambda 함수에서 오류 응답을 받은 경우
//     print('Error: ${response.statusCode}, ${await response.stream.bytesToString()}');
//   }
// }

  // Future<void> _updateImageData() async {
  //   imageJsonData = await _getImageIdData();
  //   imageData = _convertImageJsonData(imageJsonData);
  // }

  // Future<List<dynamic>> _getImageIdData() async {
  //   var url = Uri.parse(
  //       'https://ubuntu.i4624.tk/image/sql/recent/${_selectedFiles.length}');
  //   var response = await http.get(url);
  //   if (response.statusCode == 200) {
  //     final List<dynamic> responseData =
  //         jsonDecode(utf8.decode(response.bodyBytes));
  //     imageJsonData = responseData;
  //     return imageJsonData;
  //   } else {
  //     throw Exception('Failed to get image data');
  //   }
  // }

  // List<Map<String, dynamic>> _convertImageJsonData(
  //     List<dynamic> imageJsonData) {
  //   return imageJsonData
  //       .map<Map<String, int>>((data) => {
  //             'imageUid': data[0],
  //           })
  //       .toList();
  // }

  // Send Data To Server
  Future _sendDataToServer({
    // required String userId,
    required String title,
    required String contents, // 카테고리
    required String productCategory,
    required String category, //거래방식
    required int rate,
  }) async {
    await _uploadImagesToServer(selectedFiles: _selectedFiles);
    final uri = Uri.parse('https://ubuntu.i4624.tk/api/v1/post');
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'title': title,
      'content': contents,
      'rate': rate,
      // 'writer': json.encode(user.toJson()),
      'category': category,
      // 'imageIds':
      //     imageData.map<int>((item) => item['imageUid'] as int).toList(),
      'boardCategory': category,
      'itemCategory': productCategory,
    });
    final response = await http
        .post(
          uri,
          headers: headers,
          body: body,
        )
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      //print(response.statusCode);
    } else {
      // print(response.statusCode);
      // print(response.reasonPhrase);
      throw Exception('Failed to send total data');
    }
  }

  // Appbar Widget
  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        color: Colors.black,
        padding: EdgeInsets.zero,
        onPressed: () {
          Navigator.pop(context);
        },
        constraints: const BoxConstraints(),
        splashRadius: 24,
        iconSize: 24,
        // 아래의 ButtonStyle 추가
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(Size.zero),
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 192, 234, 255),
      elevation: 1,
      title: Row(
        children: const [
          Expanded(
            child: Center(
              child: Text(
                "게시글 작성",
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
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: SizedBox(
            child: TextButton(
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(Size.zero),
                padding: MaterialStateProperty.all(EdgeInsets.zero),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                overlayColor: MaterialStateColor.resolveWith(
                    (states) => Colors.transparent),
                backgroundColor: MaterialStateColor.resolveWith(
                    (states) => Colors.transparent),
                foregroundColor: MaterialStateColor.resolveWith((states) =>
                    states.contains(MaterialState.pressed)
                        ? const Color.fromARGB(255, 132, 206, 243)
                        : Colors.black),
              ),
              onPressed: () async {
                _uploadImagesToServer(selectedFiles: _selectedFiles);
                //거래방식 정보가 비어있을 때
                // if (categoryCurrentLocation == "default") {
                //   showDialog(
                //     context: context,
                //     barrierDismissible: false,
                //     builder: (BuildContext context) {
                //       return AlertDialog(
                //         contentPadding: const EdgeInsets.fromLTRB(0, 20, 0, 5),
                //         shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(10.0)),
                //         content: Column(
                //           mainAxisSize: MainAxisSize.min,
                //           crossAxisAlignment: CrossAxisAlignment.center,
                //           children: const [
                //             Text(
                //               "거래방식을 입력해주세요",
                //             ),
                //           ],
                //         ),
                //         actions: <Widget>[
                //           Center(
                //             child: SizedBox(
                //               width: 250,
                //               child: ElevatedButton(
                //                 style: ButtonStyle(
                //                   backgroundColor:
                //                       MaterialStateColor.resolveWith(
                //                     (states) {
                //                       if (states
                //                           .contains(MaterialState.disabled)) {
                //                         return Colors.grey;
                //                       } else {
                //                         return const Color.fromARGB(
                //                             255, 132, 206, 243);
                //                       }
                //                     },
                //                   ),
                //                 ),
                //                 child: const Text("확인"),
                //                 onPressed: () {
                //                   Navigator.pop(context);
                //                 },
                //               ),
                //             ),
                //           ),
                //         ],
                //       );
                //     },
                //   );
                // }
                // // 카테고리 정보가 비어있을 때
                // else if (categoryCurrentLocation == "default") {
                //   showDialog(
                //     context: context,
                //     barrierDismissible: false,
                //     builder: (BuildContext context) {
                //       return AlertDialog(
                //         contentPadding: const EdgeInsets.fromLTRB(0, 20, 0, 5),
                //         shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(10.0)),
                //         content: Column(
                //           mainAxisSize: MainAxisSize.min,
                //           crossAxisAlignment: CrossAxisAlignment.center,
                //           children: const [
                //             Text(
                //               "카테고리를 입력해주세요",
                //             ),
                //           ],
                //         ),
                //         actions: <Widget>[
                //           Center(
                //             child: SizedBox(
                //               width: 250,
                //               child: ElevatedButton(
                //                 style: ButtonStyle(
                //                   backgroundColor:
                //                       MaterialStateColor.resolveWith(
                //                     (states) {
                //                       if (states
                //                           .contains(MaterialState.disabled)) {
                //                         return Colors.grey;
                //                       } else {
                //                         return const Color.fromARGB(
                //                             255, 132, 206, 243);
                //                       }
                //                     },
                //                   ),
                //                 ),
                //                 child: const Text(
                //                   "확인",
                //                   style: TextStyle(
                //                     color: Colors.black,
                //                   ),
                //                 ),
                //                 onPressed: () {
                //                   Navigator.pop(context);
                //                 },
                //               ),
                //             ),
                //           ),
                //         ],
                //       );
                //     },
                //   );
                // }
                // // 제목 정보가 비어있을 때
                // else if (_titleController.text.isEmpty) {
                //   showDialog(
                //     context: context,
                //     barrierDismissible: false,
                //     builder: (BuildContext context) {
                //       return AlertDialog(
                //         contentPadding: const EdgeInsets.fromLTRB(0, 20, 0, 5),
                //         shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(10.0)),
                //         content: Column(
                //           mainAxisSize: MainAxisSize.min,
                //           crossAxisAlignment: CrossAxisAlignment.center,
                //           children: const [
                //             Text(
                //               "제목을 입력해주세요",
                //             ),
                //           ],
                //         ),
                //         actions: <Widget>[
                //           SizedBox(
                //             width: 250,
                //             child: ElevatedButton(
                //               style: ButtonStyle(
                //                 backgroundColor: MaterialStateColor.resolveWith(
                //                   (states) {
                //                     if (states
                //                         .contains(MaterialState.disabled)) {
                //                       return Colors.grey;
                //                     } else {
                //                       return Colors.blue;
                //                     }
                //                   },
                //                 ),
                //               ),
                //               child: const Text("확인"),
                //               onPressed: () {
                //                 Navigator.pop(context);
                //               },
                //             ),
                //           ),
                //         ],
                //       );
                //     },
                //   );
                // }
                // // 가격 정보가 비어있을 때
                // else if (_rateController.text.isEmpty) {
                //   showDialog(
                //     context: context,
                //     barrierDismissible: false,
                //     builder: (BuildContext context) {
                //       return AlertDialog(
                //         contentPadding: const EdgeInsets.fromLTRB(0, 20, 0, 5),
                //         shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(10.0)),
                //         content: Column(
                //           mainAxisSize: MainAxisSize.min,
                //           crossAxisAlignment: CrossAxisAlignment.center,
                //           children: const [
                //             Text(
                //               "평점을 입력해주세요",
                //             ),
                //           ],
                //         ),
                //         actions: <Widget>[
                //           Center(
                //             child: SizedBox(
                //               width: 250,
                //               child: ElevatedButton(
                //                 child: const Text("확인"),
                //                 onPressed: () {
                //                   Navigator.pop(context);
                //                 },
                //               ),
                //             ),
                //           ),
                //         ],
                //       );
                //     },
                //   );
                // }
                // // 내용 정보가 비어있을 때
                // else if (_contentsController.text.isEmpty) {
                //   showDialog(
                //     context: context,
                //     barrierDismissible: false,
                //     builder: (BuildContext context) {
                //       return AlertDialog(
                //         contentPadding: const EdgeInsets.fromLTRB(0, 20, 0, 5),
                //         shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(10.0)),
                //         content: Column(
                //           mainAxisSize: MainAxisSize.min,
                //           crossAxisAlignment: CrossAxisAlignment.center,
                //           children: const [
                //             Text(
                //               "내용을 입력해주세요",
                //             ),
                //           ],
                //         ),
                //         actions: <Widget>[
                //           Center(
                //             child: SizedBox(
                //               width: 250,
                //               child: ElevatedButton(
                //                 child: const Text("확인"),
                //                 onPressed: () {
                //                   Navigator.pop(context);
                //                 },
                //               ),
                //             ),
                //           ),
                //         ],
                //       );
                //     },
                //   );
                // } else if (_selectedFiles.isEmpty) {
                //   showDialog(
                //     context: context,
                //     barrierDismissible: false,
                //     builder: (BuildContext context) {
                //       return AlertDialog(
                //         contentPadding: const EdgeInsets.fromLTRB(0, 20, 0, 5),
                //         shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(10.0)),
                //         content: Column(
                //           mainAxisSize: MainAxisSize.min,
                //           crossAxisAlignment: CrossAxisAlignment.center,
                //           children: const [
                //             Text(
                //               "사진을 첨부해주세요",
                //             ),
                //           ],
                //         ),
                //         actions: <Widget>[
                //           Center(
                //             child: SizedBox(
                //               width: 250,
                //               child: ElevatedButton(
                //                 child: const Text("확인"),
                //                 onPressed: () {
                //                   Navigator.pop(context);
                //                 },
                //               ),
                //             ),
                //           ),
                //         ],
                //       );
                //     },
                //   );
                // }
                // // 모든 정보가 입력되었을 때
                // else {
                //   _sendDataToServer(
                //       // user: UserInfo(),
                //       // userId: UserInfo.userId,
                //       title: _titleController.text,
                //       contents: _contentsController.text,
                //       productCategory: categoryCurrentLocation,
                //       category: categoryCurrentLocation,
                //       rate:
                //           int.parse(_rateController.text.replaceAll(',', '')));
                //   //print("데이터 전송");
                //   Navigator.pop(context);
                //   // Navigator.push(
                //   //   context,
                //   //   MaterialPageRoute(builder: (context) => const Control()),
                //   // );
                // }
              },
              child: const Text(
                "완료",
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _makeTextArea() {
    return ListView.separated(
      itemBuilder: (BuildContext context, index) {
        return Column(
          children: [
            // Category textfield
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 20, 10),
                  child: GestureDetector(
                    child: PopupMenuButton<String>(
                      offset: const Offset(0, 30),
                      shape: ShapeBorder.lerp(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          1),
                      onSelected: (String value) {
                        setState(() {
                          categoryCurrentLocation = value;
                        });
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          const PopupMenuItem(
                            value: "electronics",
                            child: Text("디지털/전자"),
                          ),
                          const PopupMenuItem(
                            value: "tools",
                            child: Text("공구"),
                          ),
                          const PopupMenuItem(
                            value: "clothes",
                            child: Text("의류"),
                          ),
                          const PopupMenuItem(
                            value: "others",
                            child: Text("기타"),
                          ),
                        ];
                      },
                      //좌측 상단 판매, 구매, 대여 선택바
                      child: SizedBox(
                        width: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            //앱 내에서 좌측 상단바 출력을 위한 데이터
                            Text(
                              categoryOptionsTypeToString[
                                  categoryCurrentLocation]!,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Title textfield
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Center(
                child: TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.fromLTRB(0, 10, 20, 20),
                    hintText: "제목을 입력해주세요",
                  ),
                  textInputAction: TextInputAction.next,
                  onSubmitted: (value) => _titleController,
                ),
              ),
            ),
            // rate textfield
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: TextFormField(
                controller: _rateController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  enabledBorder: UnderlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.fromLTRB(0, 10, 20, 20),
                  hintText: "평점을 입력해주세요",
                ),
                textInputAction: TextInputAction.next,
                onChanged: (value) {
                  // 입력 값에서 ',' 제거
                  String rate = value.replaceAll(',', '');
                  // 빈 문자열인 경우 그대로 입력
                  if (rate.isEmpty) {
                    _rateController.value = TextEditingValue(
                      text: '',
                      selection: TextSelection.fromPosition(
                        const TextPosition(offset: 0),
                      ),
                    );
                    return;
                  }
                  // 1000단위로 ',' 추가
                  rate = NumberFormat('#,###').format(int.parse(rate));
                  // 변경된 값을 다시 입력
                  _rateController.value = TextEditingValue(
                    text: rate,
                    selection: TextSelection.fromPosition(
                      TextPosition(offset: rate.length),
                    ),
                  );
                },
              ),
            ),
            // Contents textfield
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TextField(
                controller: _contentsController,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  enabledBorder: UnderlineInputBorder(),
                  hintText: "내용을 입력해주세요",
                ),
                maxLength: 1000,
                maxLines: 10,
                textInputAction: TextInputAction.done,
              ),
            ),
            // image viewer
            SizedBox(
              child: Wrap(
                spacing: 8.0,
                children: _selectedFiles
                    .map((file) => Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color.fromARGB(255, 167, 167, 167),
                              ),
                            ),
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: Image.file(
                                File(file.path),
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        );
      },
      itemCount: 1,
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          height: 1,
          color: Colors.black.withOpacity(0.4),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbarWidget(),
      body: _makeTextArea(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _selectImages();
        },
        tooltip: 'Increment',
        backgroundColor: const Color.fromARGB(255, 172, 227, 255),
        label: const Text(
          "이미지 추가",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
