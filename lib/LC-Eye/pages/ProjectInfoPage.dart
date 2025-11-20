import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

final dio = Dio();

class ProjectInfoPage extends StatefulWidget{
  ProjectInfoPageState createState() => ProjectInfoPageState();
}// class end

class ProjectInfoPageState extends State<ProjectInfoPage>{
  // 아코디언 open/close 관리
  bool basicOpen = false;
  bool exchangeOpen = false;
  bool resultOpen = false;
  // 로딩 상태 관리
  bool dataLoaded = false;
  // 데이터 관리
  Map<String,dynamic>? basicInfo = {};
  Map<String,dynamic>? resultMap = {};

  String? pjname;
  int? pjno;
  String? token;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 데이터를 추출했으면 리턴
    if (dataLoaded) {
      return;
    }// if end

    // pjno 꺼내기
    final args = ModalRoute.of(context)?.settings.arguments;

    // int로 캐스팅
    if (args is Map) {
      pjno = args['pjno'] as int?;
      token = args['token'] as String?;
      pjname = args['pjname'] as String?;
      // 상세정보 불러오기
      if (pjno != null) {
        readAllDetails();
        dataLoaded = true; // 로딩 시작 플래그 설정
      }// if end
    }// if end
  }// f end

  // 프로젝트 상세조회
  void readAllDetails() async{
    if (pjno == null || token == null) return;

    try{
      // 1. 기본정보 상세조회
      final basicResponse = await dio.get(
          "http://192.168.40.36:8080/api/project/flutter?pjno=$pjno",
          options: Options(headers: { 'Authorization' : 'Bearer $token' })
      );

      // 2. LCI 결과 조회
      final lciResponse = await dio.get("http://192.168.40.36:8080/api/lci?pjno=$pjno");

      setState(() {
        if (basicResponse.data != null) {
          basicInfo = basicResponse.data as Map<String, dynamic>;
        }
        if (lciResponse.data != null) {
          resultMap = lciResponse.data as Map<String, dynamic>;
        }
        dataLoaded = true;
      });
    }catch(e){
      print("통신 오류 : $e");
      setState(() {
        dataLoaded = true; // 통신 실패해도 로딩 완료 처리
      });
    }
  }// f end



  Widget buildBasicAccordion() {
    return ExpansionTile(
     initiallyExpanded: basicOpen,
      title: Text(
          '프로젝트 기본정보' ,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      // 아코디언 상태변경 로직
      onExpansionChanged: (expanded){
       setState(() {
         basicOpen = expanded;
         if(expanded){
           exchangeOpen = false;
           resultOpen = false;
         }
       });
      },
      children: <Widget>[
        ProjectBasicInfoWidget( basicData : basicInfo ?? {} )
      ],

    );
  }// widget end

  // 투입물·산출물 아코디언
  Widget _buildExchangeAccordion() {
    return ExpansionTile(
      initiallyExpanded: exchangeOpen,
      // 🚨 enabled 속성 제거 (기본값: true)

      title: const Text( // 🚨 색상 로직 제거
        '투입물·산출물 정보',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),

      onExpansionChanged: (expanded) {
        setState(() {
          exchangeOpen = expanded;
          // 그룹화 동작 (다른 아코디언 닫기)
          if (expanded) {
            basicOpen = false;
            resultOpen = false;
          }
        });
      },

      children: const <Widget>[
        Padding(
          padding: EdgeInsets.all(16.0),
          child: ProjectExchangeWidget(),
        ),
      ],
    );
  }

  // 결과 아코디언
  Widget _buildResultAccordion() {
    return ExpansionTile(
      initiallyExpanded: resultOpen,
      // 🚨 enabled 속성 제거 (기본값: true)

      title: const Text( // 🚨 색상 로직 제거
        'LCI 결과',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),

      onExpansionChanged: (expanded) {
        setState(() {
          resultOpen = expanded;
          // 그룹화 동작 (다른 아코디언 닫기)
          if (expanded) {
            basicOpen = false;
            exchangeOpen = false;
          }
        });
      },

      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ProjectResultWidget(
            pjno: pjno,
            isOpen: resultOpen,
          ),
        ),
      ],
    );
  }




  @override
  Widget build(BuildContext context) {
    Widget projectNameBox = Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          pjname ?? '프로젝트명을 불러오는 중...',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
    );
    return Scaffold(
      appBar: AppBar(title: Text("프로젝트 상세 정보"),),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            projectNameBox,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // 프로젝트 기본정보
                  buildBasicAccordion(),
                  Divider(height: 1,),

                  // 투입물·산출물 아코디언
                  buildExchangeAccordion(),
                  Divider(height: 1,),

                  // 결과 아코디언
                  buildResultAccordion()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }// f end
}// class end