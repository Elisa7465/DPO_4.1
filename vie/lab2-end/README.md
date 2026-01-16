# База данных резюме

Приложение для управления резюме с использованием Vue.js, PHP и PostgreSQL.

## Структура проекта

- `frontend/` - Vue.js приложение (SPA)
- `backend/` - PHP REST API
- `docker-compose.yml` - Конфигурация Docker для PostgreSQL, Adminer и PHP

## Установка и запуск

### Требования
- Docker и Docker Compose
- Node.js и npm (для frontend)

### Запуск backend (Docker)

```bash
docker-compose up -d
```

Это запустит:
- PostgreSQL на порту 5432
- Adminer на порту 8081
- PHP Apache на порту 8080

### Настройка frontend

```bash
cd frontend
npm install
npm run dev
```

Frontend будет доступен на http://localhost:5173

### Доступ к Adminer

1. Откройте http://localhost:8081
2. Заполните форму входа:
   - Система: PostgreSQL
   - Сервер: postgres
   - Пользователь: cv_user
   - Пароль: cv_password
   - База данных: cv_database
3. Нажмите "Войти"

## API Endpoints

- `GET /api/cv` - Получить список всех резюме
- `GET /api/cv/{id}` - Получить резюме по ID
- `POST /api/cv/0/add` - Добавить новое резюме
- `POST /api/cv/{id}/edit` - Редактировать резюме
- `POST /api/cv/{id}/status/update` - Обновить статус резюме

## Структура базы данных

### Таблица `resumes`
- id (SERIAL PRIMARY KEY)
- profession, city, photo_url, full_name, phone, email
- birth_date, status, education_level
- desired_salary, skills, about
- created_at, updated_at

### Таблица `educations`
- id (SERIAL PRIMARY KEY)
- resume_id (FOREIGN KEY)
- institution, faculty, specialization, graduation_year

## Использование

1. Откройте главную страницу `/`
2. Нажмите "Новое резюме" для добавления
3. Перетаскивайте резюме между колонками для изменения статуса
4. Кликните на резюме для редактирования

