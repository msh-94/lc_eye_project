import 'package:dio/dio.dart';

class ApiConfig {
  // 1. 싱글톤 패턴 구현 (앱 전체에서 오직 하나의 인스턴스만 존재)
  static final ApiConfig _instance = ApiConfig._internal();
  factory ApiConfig() => _instance;

  ApiConfig._internal() {
    // 기본 IP로 Dio의 설정을 세팅합니다.
    _dio.options.baseUrl = "http://$currentIp";
    _dio.options.connectTimeout = const Duration(seconds: 5);
    print("[BaseUrl] 초기화 완료: ${_dio.options.baseUrl}");
  }

  // 2. 전역변수처럼 쓸 데이터들
  // 기본 IP 설정 (앱 켰을 때 초기값)
  String currentIp = "192.168.40.32:8080";
  bool isMultiServer = false;

  // 실제 API 요청에 쓰일 완성된 URL (Getter)
  String get currentBaseUrl => "http://$currentIp";

  // 전역으로 공유할 Dio 객체
  final Dio _dio = Dio();

  // 외부에서 dio를 가져다 쓸 수 있게 Getter 제공
  Dio get dio => _dio;

  // 회원 서버 전용 URL Getter (항상 8080 포트 사용)
  String get memberBaseUrl {
    // 1. 현재 설정된 주소에서 IP만 추출 (콜론(:) 앞부분)
    // 예: "192.168.40.32:8081" -> "192.168.40.32"
    String pureIp = currentIp.split(':')[0];

    // 2. http 프로토콜과 8080 포트를 붙여서 반환
    return "http://$pureIp:8080";
  }

  void updateServerUrl(String newIp, bool isMulti) {
    currentIp = newIp;
    isMultiServer = isMulti;
    // 입력받은 IP에 http:// 가 없으면 붙여주는 안전장치 추가
    String prefix = newIp.startsWith("http") ? "" : "http://";
    _dio.options.baseUrl = "$prefix$currentIp";

    print("[Project API] 주소 변경: ${_dio.options.baseUrl}");
    print("[Member API] 주소 고정: $memberBaseUrl");
  }
}