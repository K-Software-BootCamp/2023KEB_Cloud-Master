import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:comment_box/comment/comment.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_project/page/modifyBoard.dart';
import '../repository/contents_repository.dart';
import 'control.dart';

class DetailContentView extends StatefulWidget {
  Map<String, dynamic> data;
  DetailContentView({Key? key, required this.data}) : super(key: key);

  @override
  State<DetailContentView> createState() => _DetailContentViewState();
}

class _DetailContentViewState extends State<DetailContentView>
    with TickerProviderStateMixin {
  ScrollController controller = ScrollController();
  double locationAlpha = 0;
  final ContentsRepository contentsRepository = ContentsRepository();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation _colorTween;
  late List<dynamic> imgList;
  late Size size;
  late String username;
  int _currentPage = 0;

  late String currentLocation;

  final formKey = GlobalKey<FormState>();
  final TextEditingController commentController = TextEditingController();

  //앱 내에서 좌측 상단바 출력을 위한 데이터
  final Map<String, String> optionsTypeToString = {
    "setting": "PIN 설정",
    "auth": "PIN 해제",
  };
  final Map<String, dynamic> cabinetNumberToString = {
    "default": "캐비넷 번호",
    "1": "1번 캐비넷",
    "2": "2번 캐비넷",
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
    _colorTween = ColorTween(begin: Colors.white, end: Colors.black)
        .animate(_animationController);
    imgList = widget.data["imageList"];
    _currentPage = 0;
  }

  Future<String?> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString('userId')!;
    return prefs.getString('userId');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    size = MediaQuery.of(context).size;
  }

  Widget _makeIcon(IconData icon) {
    return AnimatedBuilder(
      animation: _colorTween,
      builder: (context, child) => Icon(icon, color: Colors.black),
    );
  }

  late int statusCode;
  Future _sendDataToServer({
    required int boardId,
    required String userId,
  }) async {
    final uri = Uri.parse(
        'https://hu7ixbp145.execute-api.ap-northeast-2.amazonaws.com/SendImage-test/boards/crud');

    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'Method': 'delete',
      'boardId': boardId,
      'userId': userId,
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

  // appBar Widget 구현
  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: _makeIcon(Icons.arrow_back),
      ),
      backgroundColor: Colors.white.withAlpha(locationAlpha.toInt()),
      elevation: 0,
      actions: [
        GestureDetector(
          child: PopupMenuButton<String>(
            icon: const Icon(
              Icons.menu,
              color: Colors.black,
            ),
            offset: const Offset(0, 50),
            shape: ShapeBorder.lerp(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                1),
            onSelected: (String value) {
              setState(() {
                currentLocation = value;
                if (currentLocation == "modify" &&
                    UserInfo.userId == widget.data['userId']) {
                  showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                            title: const Text(''),
                            content: const Text('게시글을 수정하시겠습니까?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) {
                                        return ModifyBoard(data: widget.data);
                                      },
                                    ),
                                  );
                                },
                                child: const Text('예'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, 'Cancel'),
                                child: const Text('아니오'),
                              ),
                            ],
                          ));
                } else if (currentLocation == "modify" &&
                    UserInfo.userId != widget.data['userId']) {
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
                              "게시글 작성자가 아닙니다.",
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
                } else if (currentLocation == "delete" &&
                    UserInfo.userId == widget.data['userId']) {
                  showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                            title: const Text(''),
                            content: const Text('게시글을 삭제하시겠습니까?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () async {
                                  try {
                                    _fetchData(context);
                                    await _sendDataToServer(
                                        boardId: widget.data['boardId'],
                                        userId: UserInfo.userId);
                                    // ignore: use_build_context_synchronously
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const Control()),
                                        (route) => false);
                                  } catch (e) {
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
                                                "게시글 삭제가 실패했습니다.",
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
                                    throw Exception(e);
                                  }
                                },
                                child: const Text('예'),
                              ),
                              TextButton(
                                onPressed: () {
                                  print(widget.data['boardId']);
                                  Navigator.pop(context, 'Cancel');
                                },
                                child: const Text('아니오'),
                              ),
                            ],
                          ));
                } else if (currentLocation != "delete" &&
                    UserInfo.userId != widget.data['userId']) {
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
                              "게시글 작성자가 아닙니다.",
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
                                  print(widget.data['boardId']);
                                  Navigator.pop(context, 'Cancel');
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                } else {
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
                              "게시글 작성자가 아닙니다.",
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
              });
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: "modify",
                  child: Text("게시글 수정"),
                ),
                const PopupMenuItem(
                  value: "delete",
                  child: Text("게시글 삭제"),
                ),
              ];
            },
          ),
        ),
      ],
    );
  }

  Widget _imageSlider() {
    return SizedBox(
      height: size.width * 0.8,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          PageView.builder(
            itemCount: widget.data["imageList"].length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Image.network(
                  widget.data["imageList"][index],
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return Image.asset(
                      "assets/images/No_image.jpg",
                      width: 100,
                      height: 100,
                    );
                  },
                ),
              );
            },
            //enableInfiniteScroll: true,
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(500)),
            child: Text(
              '${_currentPage + 1}/${widget.data["imageList"].length}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.data['imageList'].length, (index) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 5.0,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Colors.black //Colors.white
                        : Colors.grey
                            .withOpacity(0.4), //Colors.white.withOpacity(0.4),
                  ),
                );
              }),
            ),
          )
        ],
      ),
    );
  }

  Widget _sellerInfo() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: Image.asset("assets/svg/user.png"),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.data["userId"],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(widget.data["boardCategory"]),
                ],
              ),
              // Expanded(
              //   child: ManorTemperature(manorTemp: 37.3),
              // )
            ],
          ),
        ),
      ],
    );
  }

  Widget _line() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      color: Colors.grey.withOpacity(0.3),
    );
  }

  Widget _contentDetail() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text(
            widget.data["boardTitle"],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "${widget.data["boardCategory"]}", // ∙ ${widget.data["boardCreatedTime"]}", //category 추가 건의
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            widget.data["boardContent"],
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget commentChild(data) {
    return ListView(
      children: [
        for (var i = 0; i < data.length; i++)
          Padding(
            padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 0.0),
            child: ListTile(
              leading: GestureDetector(
                onTap: () async {
                  // Display the image in large form.
                  print("Comment Clicked");
                },
                child: Container(
                  height: 50.0,
                  width: 50.0,
                  decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(50))),
                  child: CircleAvatar(
                      radius: 50,
                      backgroundImage: CommentBox.commentImageParser(
                        imageURLorPath: ("assets/svg/user.png"),
                      )),
                ),
              ),
              title: Text(
                data[i]['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(data[i]['message']),
            ),
          )
      ],
    );
  }

  Widget _bodyWidget() {
    return CustomScrollView(
      controller: controller,
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate(
            [
              _imageSlider(),
              _sellerInfo(),
              _line(),
              _contentDetail(),
              _line(),
              //_otherCellContents(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bottomBarWidget() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      height: 60,
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10),
            height: 40,
            width: 1,
            color: Colors.grey.withOpacity(0.3),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: '댓글을 작성해주세요.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10.0), // Adjust this value
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              print(widget.data['boardId']);
            },
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const SizedBox(
      height: 20,
    );
    return Scaffold(
      key: scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: _appbarWidget(),
      body: _bodyWidget(),
      bottomNavigationBar: _bottomBarWidget(),
      resizeToAvoidBottomInset: false,
    );
  }
}
