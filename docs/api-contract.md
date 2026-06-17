# API-контракт: ai-fit-coach

Этот файл — единый источник правды по API. Любое изменение эндпоинта — через pull request, оба должны увидеть правку до того, как она сломает чью-то часть.

## Общие правила (одни для всех эндпоинтов)

- **Авторизация**: заголовок `Authorization: Bearer <token>` на всех запросах, кроме `/auth/*`
- **Формат дат**: ISO 8601, например `2026-06-17T14:00:00Z`
- **Формат ошибок** — всегда одинаковая форма:
```json
{ "error": { "code": "INVALID_INPUT", "message": "Поле age обязательно" } }
```
- **Статус-коды**: 200 — успех, 400 — ошибка валидации, 401 — не авторизован, 403 — нет доступа (например, исчерпан лимит бесплатного тарифа), 404 — не найдено, 429 — превышен rate limit, 500 — ошибка сервера

## Эндпоинты

### POST /auth/register
Запрос:
```json
{ "email": "user@mail.com", "password": "123456" }
```
Ответ:
```json
{ "token": "jwt...", "user_id": "uuid" }
```

### POST /auth/login
Запрос: то же, что register. Ответ: то же, что register.

### POST /users/onboarding
Запрос:
```json
{
  "goal": "weight_loss | muscle_gain | endurance",
  "level": "beginner | intermediate | advanced",
  "equipment": ["dumbbells", "none"],
  "restrictions": "боль в колене"
}
```
Ответ:
```json
{ "status": "saved" }
```

### POST /plans/generate
Запрос: `{}` (бэкенд берёт профиль из user_id в токене)
Ответ:
```json
{
  "plan_id": "uuid",
  "days": [
    { "day": "Monday", "exercises": [{ "name": "Squats", "sets": 3, "reps": 12 }] }
  ]
}
```

### GET /plans/current
Ответ: тот же формат, что у `/plans/generate`

### POST /chat/message
Запрос:
```json
{ "message": "Болит колено, что делать?" }
```
Ответ:
```json
{ "reply": "текст ответа AI", "remaining_requests_today": 7 }
```
Ошибка при исчерпанном лимите — 403 с кодом `LIMIT_REACHED`

### GET /chat/history
Параметры запроса: `?limit=50&before=<timestamp>`
Ответ:
```json
{ "messages": [{ "role": "user|assistant", "text": "...", "created_at": "..." }] }
```

### POST /progress/log
Запрос:
```json
{ "date": "2026-06-17", "weight_kg": 78, "workout_completed": true, "feedback": "too_easy | ok | too_hard" }
```
Ответ: `{ "status": "saved" }`

### GET /progress
Параметры: `?from=2026-05-01&to=2026-06-17`
Ответ:
```json
{ "entries": [{ "date": "...", "weight_kg": 78, "workout_completed": true }] }
```

### POST /billing/verify
Запрос:
```json
{ "purchase_token": "...", "product_id": "premium_monthly" }
```
Ответ:
```json
{ "status": "active", "expires_at": "2026-07-17T00:00:00Z" }
```

### GET /billing/status
Ответ:
```json
{ "tier": "free | premium", "expires_at": "..." }
```

## Что добавить по ходу разработки
- Эндпоинт для фото-калькулятора калорий (фаза 2) — скорее всего `POST /nutrition/analyze-photo`
- Push-токен устройства для уведомлений — `POST /users/push-token`
