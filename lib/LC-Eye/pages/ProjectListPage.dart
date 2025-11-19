import 'package:flutter/material.dart';

class ProjectListPage extends StatefulWidget{
  final String mname;
  final String cname;
  const ProjectListPage({
    super.key,
    required this.mname,
    required this.cname
  });
  ProjectListPageState createState() => ProjectListPageState();
}// class end

class ProjectListPageState extends State<ProjectListPage>{

  PreferredSizeWidget buildCustomAppBar(){
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 1,

      // 로고
      leadingWidth: 120,
      leading: Padding(
        padding: EdgeInsets.only(left: 10, top: 8, bottom: 8),
        child: Image.asset(
          'assets/images/LC-Eye_HeaderLogo.png',
          height: 30,
          fit: BoxFit.contain,
        ),
      ),

      // 2. 가운데 영역
      title: SizedBox.shrink(),

      //3. 회원정보 영역
      actions: [
        Padding(
            padding: EdgeInsets.only(right: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.mname,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F3E77)
                ),
              ),
              Text(
                widget.cname,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar(),
      body: Center(
        child: Text("프로젝트 목록 페이지"),
      ),
    );
  }// f end
}// class end