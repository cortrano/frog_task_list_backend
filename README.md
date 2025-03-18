# Frog Task List Backend

Простой REST API для управления задачами (ToDo) и авторизацией пользователей, построенный на Dart Frog. Использует PostgreSQL для хранения данных, Redis для кэширования и JWT для аутентификации.

Используется в качестве бэка для Flutter приложения [Frog Task List](https://github.com/cortrano/frog_task_list) (см. инструкции ниже)

## Особенности
- Регистрация и вход пользователей с выдачей JWT-токена.
- CRUD-операции для задач (создание, получение списка, удаление).
- Кэширование списка задач в Redis (5 минут).
- Защищённые эндпоинты с проверкой токена.

## Требования
- Dart SDK: >=3.0.0 <4.0.0
- Docker: Для запуска PostgreSQL и Redis
- Dart Frog CLI: Для разработки и запуска

## Установка

1. **Клонируйте репозиторий**:
   ```bash
   git clone <repository-url>
   cd todo_backend
   ```

2. **Установите Dart Frog CLI** (если ещё не установлен):
   ```bash
   dart pub global activate dart_frog_cli
   ```

3. **Установите зависимости**:
   ```bash
   dart pub get
   ```

4. **Настройте Docker**:
   - Убедитесь, что Docker установлен и запущен.
   - Используйте `docker-compose.yml` для запуска PostgreSQL и Redis:
     ```bash
     docker-compose up -d
     ```
     - PostgreSQL: `localhost:5432`, база `todo_db`, пользователь `postgres`, пароль `password`.
     - Redis: `localhost:6379`.

## Запуск

1. **Запустите сервер**:
   ```bash
   dart_frog dev
   ```
   - Сервер будет доступен на `http://localhost:8080`.

## Эндпоинты
- **POST /auth/register**: Регистрация пользователя.
  - Тело: `{"email": "test@example.com", "password": "123456"}`
  - Ответ: `{"user_id": 1}`
- **POST /auth/login**: Вход пользователя.
  - Тело: `{"email": "test@example.com", "password": "123456"}`
  - Ответ: `{"token": "<jwt-token>"}`
- **GET /todos**: Получение списка задач (требуется токен).
  - Заголовок: `Authorization: Bearer <jwt-token>`
  - Ответ: `[{"id": "1", "title": "Buy milk", "completed": false}, ...]`
- **POST /todos**: Создание задачи (требуется токен).
  - Тело: `{"title": "Buy milk"}`
  - Ответ: `{"id": "1"}`
- **GET /todos/[id]**: Получение задачи по ID (требуется токен).
  - Ответ: `{"id": "1", "title": "Buy milk", "completed": false}`
- **DELETE /todos/[id]**: Удаление задачи (требуется токен).
  - Ответ: 204 No Content

## Структура проекта
```
/todo_backend
  /lib
    /db.dart        # Подключение к PostgreSQL и Redis
  /routes
    /_middleware.dart # Глобальная мидлварь (инициализация базы)
    /auth           # Эндпоинты авторизации
    /todos          # Эндпоинты задач
```

## Зависимости
- `dart_frog`: Фреймворк для API.
- `postgres`: Драйвер PostgreSQL.
- `redis`: Драйвер Redis.
- `dart_jsonwebtoken`: Генерация и проверка JWT.

## Тестирование
1. **Регистрация**:
   ```bash
   curl -X POST http://localhost:8080/auth/register -H "Content-Type: application/json" -d '{"email": "test@example.com", "password": "123456"}'
   ```
2. **Логин**:
   ```bash
   curl -X POST http://localhost:8080/auth/login -H "Content-Type: application/json" -d '{"email": "test@example.com", "password": "123456"}'
   ```
3. **Получение задач**:
   ```bash
   curl http://localhost:8080/todos -H "Authorization: Bearer <jwt-token>"
   ```