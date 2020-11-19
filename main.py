""" Very simple API
"""
# standard
import os
from typing import Optional
# external
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    print('index!')
    return {"Hello": "World", "env_poc": os.environ.get('POC')}


@app.get("/items/{item_id}")
def read_item(item_id: int, q: Optional[str] = None):
    return {"item_id": item_id, "q": q}

@app.get("/health", status_code=200)
def health_check():
    print('heathly check!')
    return "OK"