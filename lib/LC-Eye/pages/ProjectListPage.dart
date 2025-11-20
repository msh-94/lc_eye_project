import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

final dio = Dio();

class ProjectListPage extends StatefulWidget{
  final String? mname;
  final String? cname;
  final String? isLogIn;
  const ProjectListPage({
    super.key,
    required this.mname,
    required this.cname,
    required this.isLogIn
  });
  ProjectListPageState createState() => ProjectListPageState();
}// class end

class ProjectListPageState extends State<ProjectListPage>{

  dynamic projectList = [];
  bool isLoading = true;

  // 프로젝트 목록 조회
  void readAllProject() async{
    try{
      final response = await dio.get("http://192.168.40.36:8080/api/project/flutter/all",
          options: Options(
          headers: { 'Authorization' : 'Bearer ${widget.isLogIn}' }
      ));
      final data = response.data;
      if(data != null && data != ""){
        setState(() {
          projectList = data;
          isLoading = false;
        });
      }// if end
    }catch(e){
      setState(() {
        isLoading = false; // 실패 시 로딩 해제
      });
      print("통신 오류 : ${e}");
    }// try end
  }// f end

  // 첫 랜더링 시 실행
  void initState(){
    super.initState();
    isLoading = false;
  }// f end

  void didUpdateWidget(covariant ProjectListPage oldWidget){
    super.didUpdateWidget(oldWidget);
    if(oldWidget.isLogIn == "" && widget.isLogIn != ""){
      setState(() {
        isLoading = true;
      });
      readAllProject();
    }// if end
  }// f end

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
                widget.mname ?? '' ,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F3E77)
                ),
              ),
              Text(
                widget.cname ?? '' ,
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
        child: isLoading
          ? const CircularProgressIndicator()
          : projectList.isEmpty
          ? const Text("프로젝트가 없거나 통신에 실패했습니다.")
          : Column(
            children: [
              Expanded(child: ListView.builder(
                  itemCount: projectList.length,
                  itemBuilder: (context,index){
                    dynamic pj = projectList[index];
                    return Card(
                      child: ListTile(
                        title: Text(pj['pjname'] ?? '이름 없음'),
                        subtitle: Text(pj['createdate'] ?? '날짜 없음'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                onPressed: (){ Navigator.pushNamed(context, "/info",arguments: pj['pjno']); },
                                icon: Icon(Icons.info_outline)
                            )
                          ],
                        ),
                      ),
                    );
                  }
              )
            )
          ],
        ),
      ),
    );
  }// f end
}// class end