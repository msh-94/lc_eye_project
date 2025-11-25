import 'package:flutter/material.dart';

class ProjectBasicInfoWidget extends StatelessWidget{
  final Map<String,dynamic> basicData;
  const ProjectBasicInfoWidget({super.key, required this.basicData});

  @override
  Widget build(BuildContext context) {
    print("상세정보확인 : ${basicData}");
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('프로젝트명: ${basicData['pjname'] ?? '정보없음'}'),
            const SizedBox(height: 8),
            Text('프로젝트 설명: ${basicData['pjdesc'] ?? '정보없음'}'),
            const SizedBox(height: 8),
            Text('작성자 : ${basicData['mname'] ?? '정보없음'}'),
            const SizedBox(height: 8),
            Text('대상 제품 생산량: ${basicData['pjamount'] ?? '정보없음'}'),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text('단위 그룹: ${basicData['ugname'] ?? '정보없음'}'),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Text('상세 단위: ${basicData['unit'] ?? '정보없음'}'),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text('등록일: ${basicData['createdate'] ?? '정보없음'}'),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Text('수정일: ${basicData['updatedate'] ?? ''}'),
                  ),
                ],
              ),
            ),
          ],
        )
    );
  }
}// class end