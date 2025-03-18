import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final body = await context.request.json() as Map<String, dynamic>;
  final email = body['email'] as String?;
  final password = body['password'] as String?;

  if (email == null || password == null) {
    return Response.json(
        statusCode: 400, body: {'error': 'Email and password are required'});
  }

  final db = context.read<Connection>();
  final result = await db.execute(
    Sql.named('SELECT id, password FROM users WHERE email = @email'),
    parameters: {'email': email},
  );

  if (result.isEmpty || result.first[1] != password) {
    return Response.json(
        statusCode: 401, body: {'error': 'Invalid credentials'});
  }

  final userId = result.first[0] as int;

  final jwt = JWT(
    {'sub': userId.toString()},
    issuer: 'todo_backend',
  );

  final token = jwt.sign(
    SecretKey('secret_key'),
    algorithm: JWTAlgorithm.HS256,
    expiresIn: Duration(hours: 1),
  );

  return Response.json(body: {'token': token});
}
