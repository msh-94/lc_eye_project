import 'package:flutter/material.dart';

class ProjectBasicInfoWidget extends StatelessWidget{
  final Map<String,dynamic> basicData;
  const ProjectBasicInfoWidget({super.key, required this.basicData});
  @override
  Widget build(BuildContext context) {
    return Padding( // 전체 위젯에 여백을 주기 위해 Padding으로 감싸는 것이 좋습니다.
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('프로젝트명: ${basicData['pjname'] ?? '정보없음'}'),
            const SizedBox(height: 8),
            Text('프로젝트 설명: ${basicData['pjdesc'] ?? '정보없음'}'),
            const SizedBox(height: 8),
            Text('대상 제품 생산량: ${basicData['pjamount'] ?? '정보없음'}'),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text('단위 그룹: ${basicData['unitGroup'] ?? '정보없음'}'),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Text('상세 단위: ${basicData['detailUnit'] ?? '정보없음'}'),
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
                    child: Text('수정일: ${basicData['updatedate'] ?? '정보없음'}'),
                  ),
                ],
              ),
            ),
          ],
        )
    );
  }
}// class end