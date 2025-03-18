import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:redis/redis.dart';

Future<Response> onRequest(RequestContext context) async {
  final userId = context.read<int>();
  final redis = context.read<Command>();
  final db = context.read<Connection>();
  final cacheKey = 'todos:user:$userId';

  switch (context.request.method) {
    case HttpMethod.get:
      final cached = await redis.send_object(['GET', cacheKey]);
      if (cached != null) {
        return Response.json(body: {'todos': jsonDecode(cached as String)});
      }
      final result = await db.execute(
        Sql.named(
            'SELECT id, title, completed FROM todos WHERE user_id = @userId'),
        parameters: {'userId': userId},
      );
      final todos = result
          .map((row) => {
                'id': row[0].toString(),
                'title': row[1],
                'completed': row[2],
              })
          .toList();
      await redis.send_object(['SETEX', cacheKey, 300, jsonEncode(todos)]);
      return Response.json(body: {'todos': todos}); // Оборачиваем в объект

    case HttpMethod.post:
      final body = await context.request.json() as Map<String, dynamic>;
      final title = body['title'] as String?;
      if (title == null) {
        return Response.json(
            statusCode: 400, body: {'error': 'Title is required'});
      }
      final result = await db.execute(
        Sql.named(
            'INSERT INTO todos (user_id, title) VALUES (@userId, @title) RETURNING id'),
        parameters: {'userId': userId, 'title': title},
      );
      await redis.send_object(['DEL', cacheKey]);
      return Response.json(
          statusCode: 201, body: {'id': result.first[0].toString()});

    default:
      return Response(statusCode: 405);
  }
}
