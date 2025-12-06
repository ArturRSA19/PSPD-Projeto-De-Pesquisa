from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Dict, List
import time

app = FastAPI(title="Users REST Service")

class User(BaseModel):
    id: str
    name: str
    age: int

USERS: Dict[str, User] = {
    "1": User(id="1", name="Alice", age=30),
    "2": User(id="2", name="Bob", age=25),
}

@app.get("/users/{user_id}", response_model=User)
def get_user(user_id: str):
    if user_id not in USERS:
        raise HTTPException(status_code=404, detail="User not found")
    return USERS[user_id]

@app.get("/users", response_model=List[User])
def list_users():
    # Simula streaming no gRPC (latência incremental)
    time.sleep(0.4)  # agregada (equivalente a 4 * 0.1 do server streaming)
    return list(USERS.values())

@app.post("/users/bulk")
def create_users_bulk(payload: dict):
    users = payload.get("users", [])
    ids = []
    for u in users:
        user = User(**u)
        USERS[user.id] = user
        ids.append(user.id)
    return {"count": len(ids), "ids": ids}
