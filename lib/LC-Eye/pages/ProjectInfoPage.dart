import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lc_eye_project/LC-Eye/config/api_config.dart';
import 'package:lc_eye_project/LC-Eye/pages/ProjectBasicInfoWidget.dart';
import 'package:lc_eye_project/LC-Eye/pages/ProjectExchangeWidget.dart';
import 'package:lc_eye_project/LC-Eye/pages/ProjectResultWidget.dart';

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
  bool dataLoading = false;
  // 데이터 관리
  Map<String,dynamic>? basicInfo = {};
  Map<String,dynamic>? resultMap = {};
  Map<String,dynamic>? exchangeMap = {};

  String? pjname;
  int? pjno;
  String? token;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // pjno 꺼내기
    final args = ModalRoute.of(context)?.settings.arguments;

    int? newPjno;
    String? newToken;
    String? newPjname;

    // int로 캐스팅
    if (args is Map) {
      newPjno = args['pjno'] as int?;
      newToken = args['token'] as String?;
      newPjname = args['pjname'] as String?;
    }// if end

    if(newPjno != null && (newPjno != pjno || token == null)){
      // 상태 변수 업데이트
      pjno = newPjno;
      token = newToken;
      pjname = newPjname;

      // 이전 데이터 초기화 및 로딩 시작
      setState(() {
        dataLoading = true;
        basicInfo = {};
        resultMap = {};
        exchangeMap = {};
      });

      // 상세정보 불러오기
      readAllDetails(pjno);
    }// if end

  }// f end

  // 프로젝트 상세조회
  void readAllDetails(int? pjno ) async{
    if (pjno == null || token == null) return;

    Map<String,dynamic>? basicData;
    Map<String,dynamic>? exchangeData;
    Map<String,dynamic>? resultData;

    // 1. 기본정보 상세조회
    try {
      final basicResponse = await ApiConfig().dio.get(
          "/api/project/flutter?pjno=${pjno}",
          options: Options(headers: { 'Authorization' : 'Bearer ${token}' })
      );
      print(basicResponse.data);
      basicData = basicResponse.data as Map<String, dynamic>;
    } catch (e) {
      print("기본정보 조회 오류: $e");
    }

    // 2. 투입물·산출물 조회
    try {
      final exchangeResponse = await ApiConfig().dio.get("/api/inout?pjno=${pjno}",options: Options(headers: { 'Authorization' : 'Bearer ${token}' }));
      print(exchangeResponse.data);
      exchangeData = exchangeResponse.data as Map<String, dynamic>;
    } catch (e) {
      print("투입물·산출물 조회 오류: $e");
    }

    // 3. LCI 결과 조회 (오류 발생 부분)
    try {
      final lciResponse = await ApiConfig().dio.get("/api/lci?pjno=${pjno}",options: Options(headers: { 'Authorization' : 'Bearer ${token}' }));
      print(lciResponse.data);
      resultData = lciResponse.data as Map<String, dynamic>;
    } catch (e) {
      print("LCI 결과 조회 오류: $e"); // 이 에러만 catch하고 다음 로직으로 진행
    }

    setState(() {
      if (basicData != null) {
        basicInfo = basicData;
        print("조회결과 : ${basicInfo} ");
      }
      if (exchangeData != null){
        exchangeMap = exchangeData;
        print(exchangeMap);
      }
      if (resultData != null) {
        resultMap = resultData;
        print(resultMap);
      }
      dataLoading = false;
    });


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
  Widget buildExchangeAccordion() {
    return ExpansionTile(
      initiallyExpanded: exchangeOpen,

      title: const Text(
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

      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(16.0),
          child: ProjectExchangeWidget(exchangeMap: exchangeMap ?? {}),
        ),
      ],
    );
  }

  // 결과 아코디언
  Widget buildResultAccordion() {
    return ExpansionTile(
      initiallyExpanded: resultOpen,

      title:  Text(
        'LCI 결과',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),

      onExpansionChanged: (expanded) {
        setState(() {
          resultOpen = expanded;
          if (expanded) {
            basicOpen = false;
            exchangeOpen = false;
          }
        });
      },

      children: <Widget>[
        Padding(
          padding:  EdgeInsets.all(16.0),
          child: ProjectResultWidget(resultMap: resultMap ?? {})
        ),
      ],
    );
  }

 // ProjectResultWidget(
  //             pjno: pjno,
  //             isOpen: resultOpen,
  //           ),


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
      body: dataLoading
      ? Center(child: CircularProgressIndicator(),)
      : SingleChildScrollView(
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