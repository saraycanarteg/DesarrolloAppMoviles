import re

from pydantic import BaseModel, Field, field_validator
from datetime import datetime
from typing import Optional, List

# Mascota
class MascotaBase(BaseModel):
    nombre:      str
    especie:     str
    raza:        str
    edad:        int = Field(gt=0, lt=100)
    descripcion: str
    imagen_url:  Optional[str] = None

    @field_validator("raza")
    @classmethod
    def validar_raza(cls, value: str) -> str:
        value = value.strip()
        if not value:
            raise ValueError("La raza no puede estar vacia")
        if not re.fullmatch(r"[A-Za-zÁÉÍÓÚÜÑáéíóúüñ\s]+", value):
            raise ValueError("La raza debe contener solo letras")
        return value

    @field_validator("imagen_url")
    @classmethod
    def validar_imagen_url(cls, value: Optional[str]) -> Optional[str]:
        if value is None:
            return value
        value = value.strip()
        if not value:
            raise ValueError("La url no puede estar vacia")
        if not re.fullmatch(r"https?://[^\s]+", value):
            raise ValueError("La url debe ser valida")
        return value

class MascotaCreate(MascotaBase):
    pass

class MascotaUpdate(MascotaBase):
    adoptada: Optional[bool] = None

class MascotaOut(MascotaBase):
    id:       int
    adoptada: bool

    class Config:
        from_attributes = True

# Solicitud
class SolicitudBase(BaseModel):
    nombre_solicitante: str
    telefono:           str
    motivo:             str
    mascota_id:         int

    @field_validator("telefono")
    @classmethod
    def validar_telefono(cls, value: str) -> str:
        value = value.strip()
        if not re.fullmatch(r"\d{10}", value):
            raise ValueError("El telefono debe contener exactamente 10 numeros")
        return value

class SolicitudCreate(SolicitudBase):
    pass

class SolicitudUpdate(BaseModel):
    nombre_solicitante: Optional[str] = None
    telefono:           Optional[str] = None
    motivo:             Optional[str] = None
    aprobada:           Optional[bool] = None

    @field_validator("telefono")
    @classmethod
    def validar_telefono(cls, value: Optional[str]) -> Optional[str]:
        if value is None:
            return value
        value = value.strip()
        if not re.fullmatch(r"\d{10}", value):
            raise ValueError("El telefono debe contener exactamente 10 numeros")
        return value

class SolicitudOut(SolicitudBase):
    id:               int
    fecha_solicitud:  datetime
    aprobada:         bool
    mascota:          MascotaOut

    class Config:
        from_attributes = True