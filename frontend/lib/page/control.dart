import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
//import 'package:test_project/page/image.dart';
import 'package:test_project/page/home.dart';
import 'package:test_project/page/write.dart';

class Control extends StatefulWidget {
  const Control({super.key});

  @override
  State<Control> createState() => _ControlState();
}

class _ControlState extends State<Control> {
  List<Map<String, String>> datas = [];
  int _currentPageIndex = 0;

  // 각 페이지로 이동
  Widget _bodyWidget() {
    switch (_currentPageIndex) {
      case 0:
        return Home();
      case 1:
        return const Write();
      default:
        return Home();
    }
  }

  // 바텀 네이게이션의 아이콘
  BottomNavigationBarItem _bottomNavigationBarItem(
      String iconName, String label) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: SvgPicture.asset(
          "assets/svg/${iconName}_off.svg",
          width: 22,
        ),
      ),
      activeIcon: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: SvgPicture.asset(
          "assets/svg/${iconName}_on.svg",
          width: 22,
          color: const Color.fromARGB(255, 132, 206, 243),
        ),
      ),
      label: label,
    );
  }

  // 바텀 네비게이션
  Widget _bottomNavigationBarWidget() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white, //const Color.fromARGB(255, 184, 210, 255),
      elevation: 10.0,
      onTap: (int index) {
        setState(() {
          _currentPageIndex = index;
        });
      },
      currentIndex: _currentPageIndex,
      selectedItemColor: const Color.fromARGB(255, 132, 206, 243),
      selectedFontSize: 12,
      selectedLabelStyle: const TextStyle(
        color: Color.fromARGB(255, 132, 206, 243),
      ),
      items: [
        _bottomNavigationBarItem("home", "홈"),
        _bottomNavigationBarItem("notes", "글 작성"),
        //_bottomNavigationBarItem("user", "사용자"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _bodyWidget(),
      bottomNavigationBar: _bottomNavigationBarWidget(),
    );
  }
}
