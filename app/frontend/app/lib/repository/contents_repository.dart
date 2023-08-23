import 'dart:convert';
import 'package:http/http.dart' as http;

// 유저 데이터를 저장하는 클래스
class UserInfo {
  static String userId = '';
  late String password;
  static late String jwt;

  Map<String, dynamic> toJson() {
    return {
      'username': userId,
      //'name': name,
    };
  }
}

// 서버로 부터 받은 게시글 데이터를 다루는 클래스
class ContentsRepository {
  //서버를 통해 받는 게시글 데이터의 원본을 저장하는 변수
  List<Map<String, dynamic>> originBoardDatas = [];
  //게시글 구현을 위한 변환 데이터를 저장할 변수
  Map<String, List<Map<String, dynamic>>> mainBoardDatas = {};
  Map<String, List<Map<String, dynamic>>> recentmainBoardDatas = {};
  // 서버를 통해 받은 개별 게시글 리스트
  Map<String, dynamic> indiviBoardData = {};

  // 서버에서 게시글 데이터를 불러오는 함수
  Future<List<Map<String, dynamic>>> loadboardListData() async {
    final uri = Uri.parse(
        'https://hu7ixbp145.execute-api.ap-northeast-2.amazonaws.com/SendImage-test/boards');

    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'Method': 'GetBoardList',
    });

    try {
      final response = await http
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 5));

      final responseBody = response.body;

      if (response.statusCode == 200) {
        final parsedBody = jsonDecode(responseBody);

        if (parsedBody is Map<String, dynamic> &&
            parsedBody.containsKey('body')) {
          final boardDataList = jsonDecode(parsedBody['body']) as List<dynamic>;

          originBoardDatas = List<Map<String, dynamic>>.from(
              boardDataList.map((item) => item as Map<String, dynamic>));

          print(
              "=============================================================");
          print(originBoardDatas);
          print(
              "=============================================================");

          return originBoardDatas;
        } else {
          print('Response body does not contain "body" field.');
          throw Exception('Failed to load data');
        }
      } else {
        print(response.statusCode);
        print(responseBody);
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to send total data');
    }
  }

  Future<List<Map<String, dynamic>>> loadBoradData() async {
    try {
      originBoardDatas = await loadboardListData();
      // Sort the originBoardDatas based on the 'boardId' in descending order
      originBoardDatas.sort((a, b) => b['boardId'].compareTo(a['boardId']));
    } catch (e) {
      print('Failed to load data: $e');
    }
    return originBoardDatas;
  }

  void sortingCategotyData() {
    mainBoardDatas.clear();
    mainBoardDatas["all"] = List<Map<String, dynamic>>.from(originBoardDatas);

    for (var boardData in originBoardDatas) {
      final category = boardData["boardCategory"];
      if (category != null) {
        if (mainBoardDatas.containsKey(category)) {
          mainBoardDatas[category]?.add(boardData);
        } else {
          mainBoardDatas[category] = [boardData];
        }
      }

      final imageList = boardData["imageList"];
      if (imageList is String) {
        boardData["imageList"] = [imageList]; // 이미지 URL을 리스트로 감싸서 저장
      } else if (imageList is Set) {
        boardData["imageList"] = imageList.toList(); // Set 형태인 경우 List로 변환하여 저장
      }
    }
  }

  Future<List<Map<String, dynamic>>> loadContentsFromLocation(
      String location) async {
    await loadBoradData();
    sortingCategotyData();
    return mainBoardDatas[location]!;
  }
}
