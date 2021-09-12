class Response {
  bool isSuccess;
  String message;
  dynamic result;

  Response({required this.isSuccess, this.message = '', this.result});
}