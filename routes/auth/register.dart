import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
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
  try {
    final result = await db.execute(
      Sql.named(
          'INSERT INTO users (email, password) VALUES (@email, @password) RETURNING id'),
      parameters: {'email': email, 'password': password},
    );
    final userId = result.first[0] as int;
    return Response.json(body: {'user_id': userId});
  } catch (e) {
    return Response.json(
        statusCode: 400, body: {'error': 'User already exists'});
  }
}
