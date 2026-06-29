# Vexor — AI Fitness Coach

> Персональный AI-тренер в твоём кармане. Умный план тренировок, чат с тренером, отслеживание прогресса.

![Flutter](https://img.shields.io/badge/Flutter-3.32-blue)
![FastAPI](https://img.shields.io/badge/FastAPI-0.138-green)
![Python](https://img.shields.io/badge/Python-3.11-yellow)

---

## О проекте

Vexor — мобильное приложение на Flutter с AI-бэкендом на FastAPI. Пользователь проходит онбординг, получает персональный план тренировок, общается с AI-тренером в чате и отслеживает прогресс по весу и тренировкам.

---

## Стек технологий

### Mobile (Flutter)
- **Flutter 3.32** — кроссплатформенный UI
- **Dart** — язык разработки
- **shared_preferences** — локальное хранение токена и настроек
- **flutter_local_notifications** — push-уведомления
- **http** — HTTP клиент
- **timezone** — работа с временными зонами

### Backend (FastAPI)
- **Python 3.11**
- **FastAPI** — REST API
- **SQLAlchemy** — ORM
- **PostgreSQL** — база данных
- **PyJWT** — авторизация через JWT
- **bcrypt** — хэширование паролей

### Infrastructure
- **GitHub Actions** — CI/CD, автосборка APK
- **Render** — хостинг бэкенда

---

## Архитектура Mobile

```
mobile/lib/
├── core/                    # Общие компоненты
│   ├── theme/               # Тема, цвета
│   ├── navigation/          # Fade-переходы
│   ├── widgets/             # VexorLogo, SkeletonBox, SnackbarHelper
│   └── constants/           # API endpoints
├── features/                # Фичи по модулям
│   ├── auth/                # Авторизация
│   ├── onboarding/          # Онбординг
│   ├── plan/                # План тренировок
│   ├── chat/                # AI-чат
│   ├── progress/            # Прогресс
│   ├── settings/            # Настройки
│   └── splash/              # Splash screen
├── services/                # Сервисы
│   ├── api_client.dart      # HTTP клиент
│   └── notification_service.dart
├── root_screen.dart         # Bottom navigation
└── main.dart                # Точка входа
```

---

## Запуск проекта

### Mobile (через GitHub Actions)
1. Запушить изменения в `main`
2. GitHub Actions автоматически соберёт APK
3. Скачать APK из вкладки **Actions → Artifacts**

### Backend (локально)
```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
```

### Backend (production)
Задеплоен на Render: `https://vexor-backend-84uf.onrender.com`

API документация: `https://vexor-backend-84uf.onrender.com/docs`

---

## API Контракт

Полный контракт: [`docs/api-contract.md`](docs/api-contract.md)

| Метод | Endpoint | Описание |
|-------|----------|----------|
| POST | `/register` | Регистрация |
| POST | `/login` | Авторизация → JWT токен |
| POST | `/chat/message` | Сообщение AI-тренеру |
| POST | `/plans/generate` | Генерация плана |
| GET | `/plans/current` | Текущий план |
| POST | `/progress/log` | Запись прогресса |
| GET | `/progress` | История прогресса |

---

## Команда

| Роль | Задачи |
|------|--------|
| **Mobile (EgorZxcf)** | Flutter, UI, GitHub Actions, CI/CD |
| **Backend (друг)** | FastAPI, PostgreSQL, AI интеграция, Render |

---

## Статус разработки

- [x] Авторизация (register/login)
- [x] Онбординг
- [x] Plan экран (моковые данные)
- [x] AI Chat (подключение к API в процессе)
- [x] Прогресс с графиком веса
- [x] Push-уведомления
- [x] Splash screen
- [ ] AI интеграция (Claude/OpenAI)
- [ ] Реальный план с бэкенда
- [ ] Google Play Billing
- [ ] Публикация в Play Store

---

## Дисклеймер

Приложение не заменяет консультацию врача. Перед началом тренировок проконсультируйтесь со специалистом.
