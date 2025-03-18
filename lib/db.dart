import 'package:postgres/postgres.dart';
import 'package:redis/redis.dart';

class Database {
  static Future<Connection> get pgConnection async {
    return await Connection.open(
      Endpoint(
        host: 'localhost',
        port: 5432,
        database: 'todo_db',
        username: 'postgres',
        password: 'password',
      ),
      settings: ConnectionSettings(sslMode: SslMode.disable),
    );
  }

  static final _redisConnection = RedisConnection();

  static Future<Command> get redisCommand async {
    return await _redisConnection.connect('localhost', 6379);
  }
}

Future<void> initializeDatabase() async {
  final db = await Database.pgConnection;
  await db.execute('''
    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,
      email VARCHAR(255) UNIQUE NOT NULL,
      password VARCHAR(255) NOT NULL
    )
  ''');
  await db.execute('''
    CREATE TABLE IF NOT EXISTS todos (
      id SERIAL PRIMARY KEY,
      user_id INTEGER REFERENCES users(id),
      title VARCHAR(255) NOT NULL,
      completed BOOLEAN DEFAULT FALSE
    )
  ''');
  await db.close(); // Закрываем после инициализации
}
