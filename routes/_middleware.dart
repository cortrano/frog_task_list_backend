import 'package:dart_frog/dart_frog.dart';
import 'package:frog_task_list_backend/db.dart';
import 'package:postgres/postgres.dart';
import 'package:redis/redis.dart';

// Глобальный флаг для инициализации базы
bool _isDatabaseInitialized = false;

Handler middleware(Handler handler) {
  return (context) async {
    // Инициализация базы один раз
    if (!_isDatabaseInitialized) {
      await initializeDatabase();
      _isDatabaseInitialized = true;
    }

    // Открываем соединения для каждого запроса
    final pgConnection = await Database.pgConnection;
    final redisCommand = await Database.redisCommand;

    final response = await handler
        .use(provider<Connection>((_) => pgConnection))
        .use(provider<Command>((_) => redisCommand))
        .call(context);

    // Закрываем соединение PostgreSQL после запроса
    await pgConnection.close();
    // Redis закрывать не нужно, Command управляет соединением

    return response;
  };
}
