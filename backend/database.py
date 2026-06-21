from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# 1. Указываем, где будет лежать файл нашей базы данных SQLite
SQLALCHEMY_DATABASE_URL = "sqlite:///./fitness_app.db"

# 2. Создаем "движок" для работы с SQLite
engine = create_engine(
    # check_same_thread нужен только для SQLite, чтобы FastAPI мог безопасно работать из разных потоков
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)

# 3. Создаем фабрику сессий — через нее мы будем отправлять запросы (добавить юзера, найти юзера)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# 4. Базовый класс, от которого мы будем наследовать наши таблицы (модели)
Base = declarative_base()