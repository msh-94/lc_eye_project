import 'package:flutter/material.dart';

class ProjectResultWidget extends StatefulWidget{
  final Map<String,dynamic> resultMap;

  const ProjectResultWidget({
    super.key,
    required this.resultMap
  });

  ProjectResultStateWidget createState() => ProjectResultStateWidget();

}// class end

class ProjectResultStateWidget extends State<ProjectResultWidget>{
  bool isLoding = false; // 추가 데이터 로딩 확인
  int pageSize = 50; // 페이지당 로드할 아이템 수
  int loadItemCount = 0; // 현재 로드된 아이템 수

  final ScrollController scrollCont = ScrollController();

  void initState(){
    super.initState();
    loadItemCount = pageSize;
    scrollCont.addListener(onScroll);
  }// f end

  void dispose(){
    scrollCont.dispose();
    super.dispose();
  }// f end

  void onScroll(){
    if(scrollCont.position.pixels == scrollCont.position.maxScrollExtent){
      loadMoreData(); // 스크롤 끝에 도달시 추가 데이터 로드
    }// if end
  }// f end

  void loadMoreData(){
    if(loadItemCount < (widget.resultMap['inputList']?.length ?? 0)){
      setState(() {
        isLoding = true;
      });

      Future.delayed(Duration(milliseconds: 500),(){
        setState(() {
          loadItemCount += pageSize;
          isLoding = false;
        });
      });

    }// if end
  }// f end

  Widget buildResultTable(String title , List<dynamic>? dataList, ScrollController controller, int itemCount, bool isLoading){

    int actualCount = dataList!.length;
    int displayCount = (itemCount > actualCount ? actualCount : itemCount);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0,vertical: 1.0),
            child: Text(
              '${title} 목록 (${displayCount}/${actualCount})', // 로드된 아이템 수 표시
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey[700]),
            ),
          ),

          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: displayCount + (isLoading ? 1 : 0), // 로딩 중이면 아이템 1개 추가
              itemBuilder: (context, index) {
                if(index == 0){
                 return Padding(
                   padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                   child: Row(
                    children: [
                      Expanded(flex: 1, child: Text('항목명',style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 1, child: Text("양",style: TextStyle(fontWeight: FontWeight.bold),)),
                      Expanded(flex: 1, child: Text("단위",style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                   ),
                 );
                }

                if (index == displayCount) {
                  // 로딩 인디케이터 표시
                  return Center(child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ));
                }// if end

                final row = dataList[index];
                String name = row['fname']?.toString() ?? 'N/A';
                String amount = row['amount']?.toString() ?? 'N/A';
                String uname = row['uname']?.toString() ?? 'N/A';

                String amountFormatted;
                try{
                  double amountDouble = double.parse(amount);
                  amountFormatted = amountDouble.toStringAsFixed(3);
                }catch(e){
                  amountFormatted = 'N/A';
                }// try end

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    children: [
                      Expanded(flex: 1, child: Text(name)),
                      Expanded(flex: 1, child: Text(amountFormatted)),
                      Expanded(flex: 1, child: Text(uname)),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // @override build 메서드
  @override
  Widget build(BuildContext context) {
    List<dynamic>? inputs = widget.resultMap['inputList'] as List<dynamic>?;
    List<dynamic>? outputs = widget.resultMap['outputList'] as List<dynamic>?;

    // 테이블 두 개를 나란히 배치하는 Row
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildResultTable('Input', inputs, scrollCont, loadItemCount, isLoding),
              const VerticalDivider(width: 1, thickness: 1, color: Colors.grey),
              buildResultTable("Output", outputs, ScrollController(), outputs?.length ?? 0, false), // Output은 페이징 미적용 예시
            ],
          ),
        ),
      ],
    );
  }

}// class end