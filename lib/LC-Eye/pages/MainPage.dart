import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lc_eye_project/LC-Eye/pages/ProjectListPage.dart';


final dio = Dio();

class MainPage extends StatefulWidget{
  const MainPage({super.key});
  MainPageState createState() => MainPageState();
}// class end

class MainPageState extends State<MainPage>{
  String isLogIn = "";
  int currentPageIndex = 0;
  TextEditingController midCont = TextEditingController();
  TextEditingController mpwdCont = TextEditingController();

  String mname = "";
  String cname = "";
  bool isLoading = false;

  // 로그인 핸들러
  void handleLoginSuccess() async{
    final obj = { "mid" : midCont.text , "mpwd" : mpwdCont.text };
    try{
      final response = await dio.post("http://192.168.40.36:8080/api/member/flutter/login" , data: obj);
      final data = response.data;
      print( "로그인확인 : ${data}");
      if(data != null && data != ""){
        setState(() {
          isLogIn = data;
          currentPageIndex = 1; // 프로젝트 목록으로 이동
          print(currentPageIndex);
        });
        handleLoginInfo();
        showSnackBar("로그인에 성공했습니다.");
      }// if end
    }catch(e){
      showSnackBar("로그인에 실패하였습니다.");
    }// try end
  }// f end

  // 로그인 정보조회
  void handleLoginInfo() async{
    try{
      final response = await dio.get(
        "http://192.168.40.36:8080/api/member/flutter/getinfo",
        options: Options(
        headers: { 'Authorization' : 'Bearer $isLogIn' }
      )
    );
      final data = response.data;
      if(data != null && data != ""){
        setState(() {
          mname = data['mname'];
          cname = data['cname'];
        });
      }// if end
    }catch(e){
      print(e);
    }// try end
  }// f end

  // 로그아웃 핸들러
  void handleLogOut() async{
    try{
      final response = await dio.post(
        "http://192.168.40.36:8080/api/member/flutter/logout",
          options: Options(
          headers: { 'Authorization' : 'Bearer $isLogIn' }
        )
      );
      final data = response.data;
      if(data){
        setState(() {
          isLogIn = "";
          mname = "";
          cname = "";
          currentPageIndex = 0;
          print(currentPageIndex);
        });
        showSnackBar("로그아웃 되었습니다.");
      }// if end
    }catch(e){
      showSnackBar("로그아웃에 실패하였습니다.");
    }// try end
  }// f end

  // 알림
  void showSnackBar(String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
      )
    );
  }// f end

  // 로그인 위젯
  Widget _buildLogin() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset('assets/images/LC-Eye_Logo.png', // PNG 파일 경로로 변경
            height: 80, // 로그인 화면에서 로고를 더 크게 표시
            // fit: BoxFit.contain, // 필요에 따라 추가
          ),
          const SizedBox(height: 40),
          const Text(
            "제품의 전 과정을 눈으로 보는 듯 투명하게 드러내는 LCI 시스템",
            style: TextStyle(fontSize: 20 , fontWeight: FontWeight.bold, color: Color(0xFF2F3E77)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20,),
          const Text(
            '즉, LC-Eye는 단순한 계산기가 아니라 제품의 전 과정(Input-Output-Flow)을',
            style: TextStyle(fontSize: 14 , height: 1.5),
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
          const SizedBox(height: 15,),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: Colors.blue.shade600
            ),
            child: const Text(
              'LC-Eye 로그인',
              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    ) ,
  );

  List<Widget> get pages => [
    _buildLogin(),
    ProjectListPage(mname: mname, cname: cname,isLogIn: isLogIn,),
  ];

  BottomNavigationBarItem _buildAuthItem() => isLogIn != ""
      ? const BottomNavigationBarItem(
      icon: Icon(Icons.logout),
      label: "로그아웃",
  )
      : const BottomNavigationBarItem(
      icon: Icon(Icons.login),
      label: "로그인"
  );

  @override
  Widget build(BuildContext context) {
    final actualPageIndex = isLogIn != "" ? currentPageIndex : 0;
    return Scaffold(
      body: Center(
        child: IndexedStack( index: currentPageIndex, children: pages ),
      ) ,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: isLogIn != "" ? currentPageIndex : 0,
        onTap: (index){
          if(index == 0){
            if(isLogIn != ""){
              setState(() { currentPageIndex = 1; });
            }else {
              setState(() {
                currentPageIndex = 0;
              });
            }
          }else if(index == 1){
            if(isLogIn != ""){
              // 로그인 상태 -> 로그아웃 처리
              handleLogOut();
            }else{
              // 로그아웃 상태 -> 로그인 페이지 (Index 0)로 이동
              setState(() {
                currentPageIndex = 0;
              });
            }
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.featured_play_list_rounded) , label: "프로젝트 목록"),
          _buildAuthItem() ,
          ],
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue.shade600,
      ),
    );
  }// f end

}// class end