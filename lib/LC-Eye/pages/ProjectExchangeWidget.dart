import 'package:flutter/material.dart';

class ProjectExchangeWidget extends StatelessWidget{
  // 투입물·산출물 데이터
  final Map<String, dynamic>? exchangeMap;

  // 생성자
  const ProjectExchangeWidget({
    super.key,
    required this.exchangeMap,
  });

  Widget buildInOutTable(String title , String ioname, String ioamount, List<dynamic>? dataList){
    if(dataList == null || dataList.isEmpty){
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0 , horizontal: 16.0),
        child: Text("${title} 데이터가 없습니다."),
      );
    }// if end

    List<DataRow> rows = dataList.map<DataRow>((item){
      String name = item['pjename']?.toString() ?? 'N/A';
      String amount = item['pjeamount']?.toString() ?? '0';
      String uname = item['uname']?.toString() ?? 'N/A';
      String pname = item['pname']?.toString() ?? 'N/A';

      return DataRow(
        cells: [
          DataCell(Text(name)),
          DataCell(Text(amount)),
          DataCell(Text(uname)),
          DataCell(Text(pname)),
        ]
      );
    }).toList();

    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Text(
              '${title} 목록',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey[700]),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 25.0,
              dataRowMinHeight: 30.0,
              dataRowMaxHeight: 40.0,
              headingRowHeight: 40.0,
              columns: [
                DataColumn(label: Text(ioname, style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                DataColumn(label: Text(ioamount, style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('단위', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('매칭이름', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: rows,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );

  }// w end



  @override
  Widget build(BuildContext context) {
    List<dynamic>? inputs = exchangeMap?['inputList'] as List<dynamic>?;
    List<dynamic>? outputs = exchangeMap?['outputList'] as List<dynamic>?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. 투입물 테이블
        buildInOutTable('투입물','투입물명','투입량', inputs),
        const Divider(height: 1),

        // 2. 산출물 테이블
        buildInOutTable('산출물','산출물명','산출량', outputs),
      ],
    );
  }// f end
}// class end