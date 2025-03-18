import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

Handler middleware(Handler handler) {
  return (context) async {
    final authHeader = context.request.headers['Authorization'];
    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});
    }

    final token = authHeader.substring(7);

    try {
      final jwt = JWT.verify(
        token,
        SecretKey('secret_key'),
        checkExpiresIn: true,
      );
      final userId = int.parse(jwt.payload['sub'] as String);
      return handler(context.provide<int>(() => userId));
    } on JWTExpiredException {
      return Response.json(
          statusCode: 401, body: {'error': 'Token has expired'});
    } on JWTException catch (e) {
      return Response.json(
          statusCode: 401, body: {'error': 'Invalid token: ${e.message}'});
    }
  };
}
