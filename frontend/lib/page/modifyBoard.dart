import 'dart:convert';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:test_project/repository/contents_repository.dart';

import 'control.dart';
// import 'package:test_project/page/control.dart';
// import 'package:test_project/repository/contents_repository.dart';

class ModifyBoard extends StatefulWidget {
  Map<String, dynamic> data;
  ModifyBoard({Key? key, required this.data}) : super(key: key);

  @override
  State<ModifyBoard> createState() => _ModifyBoardState();
}

class _ModifyBoardState extends State<ModifyBoard> {
  // textfield에서 입력받은 정보를 저장할 변수
  late String userId;

  late String title;
  late final TextEditingController _titleController = TextEditingController();

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
    "entertainment": "게임/오락",
    "electronic": "전자기기",
    "clothes": "의류",
    "health": "운동/건강",
    "food": "음식",
  };

  @override
  void initState() {
    super.initState();
    userId = widget.data['userId'];
    _titleController.text = widget.data['boardTitle'];
    _contentsController.text = widget.data['boardContent'];
    rate = widget.data['rate'];
    categoryCurrentLocation = widget.data['boardCategory'];
  }

  final List<XFile> _selectedFiles = [];
  // 사용자의 다수의 image를 받기위한 생성자
  final ImagePicker _picker = ImagePicker();

  void _selectImages() async {
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

  Future _uploadImagesToServer({
    required List<XFile> selectedFiles,
  }) async {
    final uri = Uri.parse(
        'https://hu7ixbp145.execute-api.ap-northeast-2.amazonaws.com/SendImage-test/images');
    final request = http.MultipartRequest('POST', uri);

    // Content-Type 헤더 설정
    request.headers['Content-Type'] = 'multipart/form-data';

    // JSON 데이터를 Map으로 구성하여 추가
    Map<String, String> jsonMap = {
      'boardId': UserInfo.userId,
      'userId': 'rkskek12',
    };
    String jsonData = jsonEncode(jsonMap);
    request.fields['jsonData'] = jsonData;

    print("Sent JSON Data: $jsonData");

    for (var selectedFile in selectedFiles) {
      // 확장자 추출
      String extension = selectedFile.path.split('.').last;

      // 이미지 데이터를 Base64로 인코딩
      List<int> imageBytes = await selectedFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      request.files.add(
        http.MultipartFile(
          'filename', // form field 이름
          http.ByteStream.fromBytes(
              utf8.encode(base64Image)), // 이미지 데이터를 바이트 스트림으로 전환
          utf8.encode(base64Image).length, // Base64로 인코딩된 데이터의 바이트 길이
          filename:
              'image_${selectedFiles.indexOf(selectedFile) + 1}.$extension', // 확장자 포함한 파일명
          contentType: MediaType('image', extension), // 컨텐츠 타입 설정
        ),
      );
    }

    print("Sent Multipart Files:");
    for (var file in request.files) {
      print(file.filename);
    }

    try {
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final responseJson = jsonDecode(responseBody);
        print(responseJson);
        List<String> imageUrls =
            List<String>.from(jsonDecode(responseJson['body']));
        print(imageUrls);
        return imageUrls; // 이미지 URL 목록
      } else {
        print(request.headers);
        print(response.reasonPhrase);
      }
    } catch (e) {
      print(e);
      // throw Exception('Failed to send images');
    }
  }

  // Send Data To Server
  Future _sendDataToServer({
    required String title,
    required String contents,
    required String category,
    required int rate,
  }) async {
    // List imageList = await _uploadImagesToServer(selectedFiles: _selectedFiles);
    final uri = Uri.parse(
        'https://hu7ixbp145.execute-api.ap-northeast-2.amazonaws.com/SendImage-test/boards/crud');
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'Method': 'modify',
      'boardId': widget.data['boardId'],
      'boardTitle': title,
      'boardContent': contents,
      'rate': rate,
      'userId': UserInfo.userId,
      'boardCategory': category,
      // 'imageList': imageList,
    });
    final response = await http
        .post(
          uri,
          headers: headers,
          body: body,
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      print(response.statusCode);
      print(response.body);
      return true;
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      return false;
      // throw Exception('Failed to send total data');
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
                //카테고리 정보가 비어있을 때
                if (categoryCurrentLocation == "default") {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        contentPadding: const EdgeInsets.fromLTRB(5, 20, 5, 5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Text(
                              "카테고리를 입력해주세요",
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
                                      if (states
                                          .contains(MaterialState.disabled)) {
                                        return Colors.grey;
                                      } else {
                                        return const Color.fromARGB(
                                            255, 132, 206, 243);
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
                // 제목 정보가 비어있을 때
                else if (_titleController.text.isEmpty) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        contentPadding: const EdgeInsets.fromLTRB(0, 20, 0, 5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Text(
                              "제목을 입력해주세요",
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          SizedBox(
                            width: 250,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateColor.resolveWith(
                                  (states) {
                                    if (states
                                        .contains(MaterialState.disabled)) {
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
                        ],
                      );
                    },
                  );
                }
                // 평점 정보가 비어있을 때
                else if (rate == null) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        contentPadding: const EdgeInsets.fromLTRB(0, 20, 0, 5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Text(
                              "평점을 입력해주세요",
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          Center(
                            child: SizedBox(
                              width: 250,
                              child: ElevatedButton(
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
                // 내용 정보가 비어있을 때
                else if (_contentsController.text.isEmpty) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        contentPadding: const EdgeInsets.fromLTRB(0, 20, 0, 5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Text(
                              "내용을 입력해주세요",
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          Center(
                            child: SizedBox(
                              width: 250,
                              child: ElevatedButton(
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
                // 사진 정보가 비어있을 때
                // else if (_selectedFiles.isEmpty) {
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
                // 모든 정보가 입력되었을 때
                else {
                  // Display the loading dialog
                  _fetchData(context);
                  bool checkResult = await _sendDataToServer(
                    title: _titleController.text,
                    category: categoryCurrentLocation,
                    contents: _contentsController.text,
                    rate: rate,
                  );
                  if (checkResult == true) {
                    try {
                      // ignore: use_build_context_synchronously
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Control()),
                          (route) => false);
                    } catch (e) {
                      throw Exception(e);
                    }
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
                              borderRadius: BorderRadius.circular(10.0)),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: const [
                              Text(
                                "업로드를 실패했습니다.",
                              ),
                            ],
                          ),
                          actions: <Widget>[
                            Center(
                              child: SizedBox(
                                width: 250,
                                child: ElevatedButton(
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
        List<Widget> boxContents = [
          IconButton(
            onPressed: () {
              _selectImages();
            },
            icon: Container(
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: Icon(
                Icons.camera_alt_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Container(),
          _selectedFiles.length <= 3
              ? Container()
              : FittedBox(
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: Text(
                      '+${(_selectedFiles.length - 3).toString()}',
                    ),
                  ),
                ),
        ];
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
                            value: "entertainment",
                            child: Text("게임/오락"),
                          ),
                          const PopupMenuItem(
                            value: "electronic",
                            child: Text("전자기기"),
                          ),
                          const PopupMenuItem(
                            value: "clothes",
                            child: Text("의류"),
                          ),
                          const PopupMenuItem(
                            value: "health",
                            child: Text("운동/건강"),
                          ),
                          const PopupMenuItem(
                            value: "food",
                            child: Text("음식"),
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
            // rate textfield
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: RatingBar.builder(
                    initialRating: widget.data['rate'].toDouble(),
                    minRating: 0,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemSize: 40,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        rate = rating.toInt();
                      });
                    },
                  ),
                ),
              ],
            ),
            // image viewer
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: 300,
                child: GridView.count(
                  padding: const EdgeInsets.all(2),
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  childAspectRatio: 0.9,
                  shrinkWrap: true,
                  children: List.generate(
                    3,
                    (index) => DottedBorder(
                      color: Colors.blue,
                      dashPattern: const [5, 3],
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(10),
                      child: Container(
                        decoration: index <= _selectedFiles.length - 1
                            ? BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: FileImage(
                                    File(_selectedFiles[index].path),
                                  ),
                                ),
                              )
                            : null,
                        child: Center(child: boxContents[index]),
                      ),
                    ),
                  ).toList(),
                ),
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
    );
  }
}
