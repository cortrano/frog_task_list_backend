import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:redis/redis.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final userId = context.read<int>();
  final db = context.read<Connection>();
  final redis = context.read<Command>();
  final cacheKey = 'todos:user:$userId';

  switch (context.request.method) {
    case HttpMethod.get:
      final result = await db.execute(
        Sql.named(
            'SELECT id, title, completed FROM todos WHERE id = @id AND user_id = @userId'),
        parameters: {'id': int.parse(id), 'userId': userId},
      );
      if (result.isEmpty) {
        return Response.json(
            statusCode: 404, body: {'error': 'Todo not found'});
      }
      final todo = {
        'id': result[0][0].toString(), // Приводим int к строке
        'title': result[0][1],
        'completed': result[0][2],
      };
      return Response.json(body: todo);

    case HttpMethod.delete:
      final result = await db.execute(
        Sql.named(
            'DELETE FROM todos WHERE id = @id AND user_id = @userId RETURNING id'),
        parameters: {'id': int.parse(id), 'userId': userId},
      );
      if (result.isEmpty) {
        return Response.json(
            statusCode: 404, body: {'error': 'Todo not found'});
      }
      await redis.send_object(['DEL', cacheKey]);
      return Response(statusCode: 204);

    default:
      return Response(statusCode: 405);
  }
}
