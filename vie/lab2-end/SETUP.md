# Инструкция по запуску

## Быстрый старт

### 1. Запуск Backend (Docker)
$env:Path += ";C:\Program Files\Docker\Docker\resources\bin"
```bash
docker-compose up -d
```

Это запустит:
- PostgreSQL на порту 5432
- Adminer на http://localhost:8081
- PHP API на http://localhost:8080

### 2. Установка зависимостей Frontend

Откройте **новый терминал** и выполните:

```bash
cd frontend
npm install
```

Это установит все необходимые пакеты (vue, vue-router, vuex, vuedraggable, axios).

### 3. Запуск Frontend

В том же терминале выполните:

```bash
npm run dev
```

Вы должны увидеть сообщение:
```
  VITE v7.x.x  ready in xxx ms
  ➜  Local:   http://localhost:5173/
```

**Важно:** Не закрывайте этот терминал! Dev сервер должен работать.

### 4. Откройте браузер

Откройте браузер и перейдите по адресу:
**http://localhost:5173/**

Если страница не открывается автоматически, скопируйте URL из терминала.

## Настройка Adminer

1. Откройте http://localhost:8081
2. Заполните форму входа:
   - Система: `PostgreSQL`
   - Сервер: `postgres`
   - Пользователь: `cv_user`
   - Пароль: `cv_password`
   - База данных: `cv_database`
3. Нажмите "Войти"

## Проверка работы API

```bash
# Получить список резюме
curl http://localhost:8080/api/cv

# Добавить резюме
curl -X POST http://localhost:8080/api/cv/0/add \
  -H "Content-Type: application/json" \
  -d '{"fullName":"Тест","status":"Новый"}'
```

## Остановка

```bash
docker-compose down
```

Для удаления всех данных:
```bash
docker-compose down -v
```

