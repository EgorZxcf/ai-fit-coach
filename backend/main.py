from datetime import datetime, timedelta, timezone
import jwt
from fastapi import FastAPI, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session
import bcrypt

import models
from database import engine, SessionLocal


models.Base.metadata.create_all(bind=engine)

app = FastAPI()

SECRET_KEY = "super_puper_secret_key_menya_nado_izmenit"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


class UserCreate(BaseModel):
    email: str
    password: str


@app.post("/register", status_code=status.HTTP_201_CREATED)
def register_user(user_data: UserCreate, db: Session = Depends(get_db)):
    
    existing_user = db.query(models.User).filter(models.User.email == user_data.email).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Пользователь с таким email уже зарегистрирован"
        )
    
    
    password_bytes = user_data.password.encode('utf-8')
    salt = bcrypt.gensalt()
    hashed_password_bytes = bcrypt.hashpw(password_bytes, salt)
    
    hashed_pwd = hashed_password_bytes.decode('utf-8')
    
    
    new_user = models.User(
        email=user_data.email,
        hashed_password=hashed_pwd
    )
    
    
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    return {"status": "success", "message": "Пользователь успешно зарегистрирован", "user_id": new_user.id}

@app.get("/")
def read_root():
    return {"status": "Server is running", "project": "AI Fitness Trainer"}

@app.post("/login")
def login_user(user_data: UserCreate, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.email == user_data.email).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Неверный email или пароль"
        )
    
    
    password_bytes = user_data.password.encode('utf-8')
    hashed_bytes = user.hashed_password.encode('utf-8')
    
    if not bcrypt.checkpw(password_bytes, hashed_bytes):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Неверный email или пароль"
        )
    
 
    access_token_expires = timedelta(minutes=15) 
    expire = datetime.now(timezone.utc) + access_token_expires
    token_data = {"sub": user.id, "exp": expire}
    jwt_token = jwt.encode(token_data, SECRET_KEY, algorithm=ALGORITHM)

    access_token = create_access_token(data={"user_id": user.id})
    
    return {
        "status": "success", 
        "message": "Авторизация успешна", 
        "access_token": access_token,
        "token_type": "bearer"
    }

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt