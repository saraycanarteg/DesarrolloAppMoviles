from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from database import engine, Base
import models
from routers import mascotas, solicitudes

Base.metadata.create_all(bind=engine)

app = FastAPI(title="API Adopción de Mascotas")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(mascotas.router, prefix="/mascotas", tags=["Mascotas"])
app.include_router(solicitudes.router, prefix="/solicitudes", tags=["Solicitudes"])