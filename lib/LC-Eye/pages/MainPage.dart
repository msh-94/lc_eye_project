import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lc_eye_project/LC-Eye/config/api_config.dart';
import 'package:lc_eye_project/LC-Eye/pages/ProjectListPage.dart'; // 기존 경로 유지

// 전역 Dio 객체
final dio = Dio();
final String memberUrl = ApiConfig().memberBaseUrl;

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  String isLogIn = "";
  int currentPageIndex = 0;

  // 로그인 입력 컨트롤러
  TextEditingController midCont = TextEditingController();
  TextEditingController mpwdCont = TextEditingController();

  // 서버 설정 관련 변수 및 컨트롤러
  TextEditingController ipCont = TextEditingController(text: ApiConfig().currentIp);
  bool isMultiServer = ApiConfig().isMultiServer; // false: 단일(Local), true: 다중(MSA)

  String mname = "";
  String cname = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // 앱 시작 시 기본 IP로 Dio 설정 초기화
    ipCont.text = ApiConfig().currentIp;
    isMultiServer = ApiConfig().isMultiServer;
  }

  // 로그인 핸들러
  void handleLoginSuccess() async {
    if (midCont.text.isEmpty || mpwdCont.text.isEmpty) {
      showSnackBar("아이디와 비밀번호를 입력해주세요.");
      return;
    }

    final obj = {"mid": midCont.text, "mpwd": mpwdCont.text};
    print("요청 전송: $memberUrl/api/member/flutter/login");

    try {
      final response = await ApiConfig().dio.post(
          "$memberUrl/api/member/flutter/login",
          data: obj
      );
      final data = response.data;
      print("로그인확인 : ${data}");

      if (data != null && data != "") {
        setState(() {
          isLogIn = data;
          currentPageIndex = 1; // 프로젝트 목록으로 이동
        });
        handleLoginInfo();
        showSnackBar("로그인에 성공했습니다.");
      } else {
        showSnackBar("아이디 또는 비밀번호를 확인해주세요.");
      }
    } catch (e) {
      print("로그인 에러: $e");
      showSnackBar("로그인 실패: 서버 연결을 확인해주세요.");
    }
  }

  // 로그인 정보조회
  void handleLoginInfo() async {
    try {
      final response = await ApiConfig().dio.get(
        "$memberUrl/api/member/flutter/getinfo",
        options: Options(headers: {'Authorization': 'Bearer $isLogIn'}),
      );
      final data = response.data;
      if (data != null && data != "") {
        setState(() {
          mname = data['mname'];
          cname = data['cname'];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  // 로그아웃 핸들러
  void handleLogOut() async {
    try {
      final response = await ApiConfig().dio.post(
        "$memberUrl/api/member/flutter/logout",
        options: Options(headers: {'Authorization': 'Bearer $isLogIn'}),
      );
      final data = response.data;
      if (data) {
        setState(() {
          isLogIn = "";
          mname = "";
          cname = "";
          currentPageIndex = 0;
          midCont.clear(); // 로그아웃 시 입력창 초기화
          mpwdCont.clear();
        });
        showSnackBar("로그아웃 되었습니다.");
      }
    } catch (e) {
      showSnackBar("로그아웃에 실패하였습니다.");
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void showServerConfigDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("서버 환경 설정"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. 단일/다중 서버 토글 스위치
                  SwitchListTile(
                    title: Text(isMultiServer ? "다중 서버 (MSA)" : "단일 서버(Local)"),
                    subtitle: const Text("서버 모드 선택"),
                    value: isMultiServer,
                    onChanged: (value) {
                      setStateDialog(() {
                        isMultiServer = value;
                        // 포트 자동 변경
                        String currentIpOnly = ipCont.text.split(':')[0]; // IP만 추출
                        if (isMultiServer) {
                          ipCont.text = "$currentIpOnly:8081"; // 다중 서버는 8081
                        } else {
                          ipCont.text = "$currentIpOnly:8080"; // 단일 서버는 8080
                        }
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                  const SizedBox(height: 10),
                  // 2. IP 주소 입력 필드
                  TextField(
                    controller: ipCont,
                    decoration: InputDecoration(
                      labelText: 'IP 주소 (또는 도메인)',
                      hintText: '예: 192.168.0.1:8080',
                      prefixText: "http://",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    keyboardType: TextInputType.url,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("취소", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    // ApiConfig 업데이트
                    ApiConfig().updateServerUrl(ipCont.text, isMultiServer);
                    // 현재 페이지 상태 동기화 (UI 갱신용)
                    setState(() {
                      isMultiServer = ApiConfig().isMultiServer;
                    });
                    Navigator.pop(context);
                    showSnackBar("서버 설정이 변경되었습니다.");
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600),
                  child: const Text("저장", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 로그인 위젯
  Widget _buildLogin() => Center(
    child: SingleChildScrollView( // 키보드가 올라왔을 때 오버플로우 방지
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- [설정 버튼 추가] ---
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: showServerConfigDialog,
                icon: const Icon(Icons.settings, color: Colors.grey),
                tooltip: "서버 설정",
              ),
            ),

            Image.asset(
              'assets/images/LC-Eye_Logo.png',
              height: 80,
            ),
            const SizedBox(height: 40),
            const Text(
              "제품의 전 과정을 눈으로 보는 듯 투명하게 드러내는 LCI 시스템",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F3E77)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              '즉, LC-Eye는 단순한 계산기가 아니라 제품의 전 과정(Input-Output-Flow)을',
              style: TextStyle(fontSize: 14, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const Text(
              "'한눈에 파악'하고 '정확히 분석'하는 시작적 LCI 도구라는 뜻을 가집니다.",
              style: TextStyle(fontSize: 14, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // 로그인 폼
            TextFormField(
              decoration: InputDecoration(
                labelText: '아이디',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              controller: midCont,
            ),
            const SizedBox(height: 15),
            TextFormField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              controller: mpwdCont,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: handleLoginSuccess,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.blue.shade600),
              child: const Text(
                'LC-Eye 로그인',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    ),
  );

  List<Widget> get pages => [
    _buildLogin(),
    ProjectListPage(mname: mname, cname: cname, isLogIn: isLogIn),
  ];

  BottomNavigationBarItem _buildAuthItem() => isLogIn != ""
      ? const BottomNavigationBarItem(
    icon: Icon(Icons.logout),
    label: "로그아웃",
  )
      : const BottomNavigationBarItem(
    icon: Icon(Icons.login),
    label: "로그인",
  );

  @override
  Widget build(BuildContext context) {
    // 현재 로그인 상태에 따라 페이지 인덱스 보정
    // (로그인 안되었으면 강제로 0번 페이지 표시)
    final actualPageIndex = isLogIn != "" ? currentPageIndex : 0;

    return Scaffold(
      body: Center(
        // IndexedStack은 상태를 유지하므로 유용함
        child: IndexedStack(index: actualPageIndex, children: pages),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: actualPageIndex,
        onTap: (index) {
          if (index == 0) {
            // 프로젝트 목록 탭 클릭
            if (isLogIn != "") {
              setState(() {
                currentPageIndex = 1; // 로그인 상태면 목록 보여줌
              });
            } else {
              setState(() {
                currentPageIndex = 0; // 아니면 로그인 화면 유지
              });
              showSnackBar("로그인이 필요한 서비스입니다.");
            }
          } else if (index == 1) {
            // 로그인/로그아웃 탭 클릭
            if (isLogIn != "") {
              handleLogOut();
            } else {
              setState(() {
                currentPageIndex = 0;
              });
            }
          }
        },
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.featured_play_list_rounded), label: "프로젝트 목록"),
          _buildAuthItem(),
        ],
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue.shade600,
      ),
    );
  }
}