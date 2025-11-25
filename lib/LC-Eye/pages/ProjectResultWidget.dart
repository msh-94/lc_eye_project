import 'package:flutter/material.dart';

class ProjectResultWidget extends StatefulWidget {
  final Map<String, dynamic> resultMap;

  const ProjectResultWidget({
    super.key,
    required this.resultMap
  });

  @override
  ProjectResultStateWidget createState() => ProjectResultStateWidget();
} // class end

class ProjectResultStateWidget extends State<ProjectResultWidget> {
  int pageSize = 50; // 페이지당 로드할 아이템 수

  // --- [Input 관련 변수] ---
  bool isInputLoading = false;
  int inputLoadCount = 0;
  final ScrollController inputScrollCont = ScrollController();

  // --- [Output 관련 변수] ---
  bool isOutputLoading = false;
  int outputLoadCount = 0;
  final ScrollController outputScrollCont = ScrollController();

  @override
  void initState() {
    super.initState();
    // 초기 로드 개수 설정
    inputLoadCount = pageSize;
    outputLoadCount = pageSize;

    // 각각의 스크롤 리스너 등록
    inputScrollCont.addListener(onInputScroll);
    outputScrollCont.addListener(onOutputScroll);
  } // f end

  @override
  void dispose() {
    // 컨트롤러 메모리 해제
    inputScrollCont.dispose();
    outputScrollCont.dispose();
    super.dispose();
  } // f end

  // --- [Input 스크롤 로직] ---
  void onInputScroll() {
    if (inputScrollCont.hasClients &&
        inputScrollCont.position.pixels == inputScrollCont.position.maxScrollExtent) {
      loadMoreInput();
    }
  }

  void loadMoreInput() {
    List<dynamic> list = (widget.resultMap['inputList'] as List<dynamic>?) ?? [];
    if (inputLoadCount < list.length && !isInputLoading) {
      setState(() {
        isInputLoading = true;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            inputLoadCount += pageSize;
            isInputLoading = false;
          });
        }
      });
    }
  }

  // --- [Output 스크롤 로직] ---
  void onOutputScroll() {
    if (outputScrollCont.hasClients &&
        outputScrollCont.position.pixels == outputScrollCont.position.maxScrollExtent) {
      loadMoreOutput();
    }
  }

  void loadMoreOutput() {
    List<dynamic> list = (widget.resultMap['outputList'] as List<dynamic>?) ?? [];
    if (outputLoadCount < list.length && !isOutputLoading) {
      setState(() {
        isOutputLoading = true;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            outputLoadCount += pageSize;
            isOutputLoading = false;
          });
        }
      });
    }
  }

  // 테이블 빌드 함수 (공통 사용)
  Widget buildResultTable(String title, List<dynamic>? dataList,
      ScrollController? controller, int itemCount, bool isLoading) {

    final List<dynamic> safeDataList = dataList ?? [];
    int actualCount = safeDataList.length;
    int displayCount = (itemCount > actualCount ? actualCount : itemCount);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
            child: Text(
              '${title} 목록 (${displayCount}/${actualCount})',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[700]),
            ),
          ),

          if (actualCount == 0)
            const Expanded(
              child: Center(
                child: Text("- 데이터 없음 -", style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: 1 + displayCount + (isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Container(
                      color: Colors.grey[200],
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                      child: Row(
                        children: const [
                          Expanded(flex: 1, child: Text('항목명', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 1, child: Text("양", style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 1, child: Text("단위", style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                    );
                  }

                  if (isLoading && index == displayCount + 1) {
                    return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ));
                  }

                  int dataIndex = index - 1;
                  if (dataIndex >= safeDataList.length) return const SizedBox();

                  final row = safeDataList[dataIndex];
                  String name = row['fname']?.toString() ?? 'N/A';
                  String amount = row['amount']?.toString() ?? '0';
                  String uname = row['uname']?.toString() ?? 'N/A';

                  String amountFormatted;
                  try {
                    double amountDouble = double.parse(amount);
                    amountFormatted = amountDouble.toStringAsFixed(3);
                  } catch (e) {
                    amountFormatted = 'N/A';
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Row(
                      children: [
                        Expanded(flex: 1, child: Text(name, style: const TextStyle(fontSize: 13))),
                        Expanded(flex: 1, child: Text(amountFormatted, style: const TextStyle(fontSize: 13))),
                        Expanded(flex: 1, child: Text(uname, style: const TextStyle(fontSize: 13))),
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

  @override
  Widget build(BuildContext context) {
    List<dynamic> inputs = (widget.resultMap['inputList'] as List<dynamic>?) ?? [];
    List<dynamic> outputs = (widget.resultMap['outputList'] as List<dynamic>?) ?? [];

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // [Input 테이블] Input 전용 변수들 전달
              buildResultTable('Input', inputs, inputScrollCont, inputLoadCount, isInputLoading),

              const VerticalDivider(width: 1, thickness: 1, color: Colors.grey),

              // [Output 테이블] Output 전용 변수들 전달 (이제 여기도 페이징 됨)
              buildResultTable('Output', outputs, outputScrollCont, outputLoadCount, isOutputLoading),
            ],
          ),
        ),
      ],
    );
  }
} // class end