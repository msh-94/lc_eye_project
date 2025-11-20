import 'package:flutter/material.dart';

class ProjectInfoPage extends StatefulWidget{
  ProjectInfoPageState createState() => ProjectInfoPageState();
}// class end

class ProjectInfoPageState extends State<ProjectInfoPage>{
  // 아코디언 open/close 관리
  bool basicOpen = false;
  bool exchangeOpen = false;
  bool resultOpen = false;

  String? projectName;
  int? pjno;

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
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("실제 정보 구역"),
        )
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
          projectName ?? '프로젝트명을 불러오는 중...',
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