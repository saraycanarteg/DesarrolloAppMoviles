from sqlalchemy import Column, Integer, String, Float, Boolean, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from database import Base
from datetime import datetime

class Mascota(Base):
    __tablename__ = "mascotas"

    id         = Column(Integer, primary_key=True, index=True)
    nombre     = Column(String, nullable=False)
    especie    = Column(String, nullable=False)   
    raza       = Column(String, nullable=False)
    edad       = Column(Integer, nullable=False)
    descripcion= Column(String, nullable=False)
    imagen_url = Column(String, nullable=True)
    adoptada   = Column(Boolean, default=False)

    solicitudes = relationship("SolicitudAdopcion", back_populates="mascota")


class SolicitudAdopcion(Base):
    __tablename__ = "solicitudes_adopcion"

    id               = Column(Integer, primary_key=True, index=True)
    nombre_solicitante = Column(String, nullable=False)
    telefono         = Column(String, nullable=False)
    motivo           = Column(String, nullable=False)
    fecha_solicitud  = Column(DateTime, default=datetime.utcnow)
    aprobada         = Column(Boolean, default=False)
    mascota_id       = Column(Integer, ForeignKey("mascotas.id"), nullable=False)

    mascota = relationship("Mascota", back_populates="solicitudes")