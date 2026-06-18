from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
import models, schemas

router = APIRouter()

@router.get("/", response_model=list[schemas.MascotaOut])
def listar(db: Session = Depends(get_db)):
    return db.query(models.Mascota).all()

@router.get("/{id}", response_model=schemas.MascotaOut)
def obtener(id: int, db: Session = Depends(get_db)):
    mascota = db.query(models.Mascota).filter(models.Mascota.id == id).first()
    if not mascota:
        raise HTTPException(status_code=404, detail="Mascota no encontrada")
    return mascota

@router.post("/", response_model=schemas.MascotaOut, status_code=201)
def crear(data: schemas.MascotaCreate, db: Session = Depends(get_db)):
    nueva = models.Mascota(**data.model_dump())
    db.add(nueva)
    db.commit()
    db.refresh(nueva)
    return nueva

@router.put("/{id}", response_model=schemas.MascotaOut)
def actualizar(id: int, data: schemas.MascotaUpdate, db: Session = Depends(get_db)):
    mascota = db.query(models.Mascota).filter(models.Mascota.id == id).first()
    if not mascota:
        raise HTTPException(status_code=404, detail="Mascota no encontrada")
    for k, v in data.model_dump(exclude_unset=True).items():
        setattr(mascota, k, v)
    db.commit()
    db.refresh(mascota)
    return mascota

@router.delete("/{id}", status_code=204)
def eliminar(id: int, db: Session = Depends(get_db)):
    mascota = db.query(models.Mascota).filter(models.Mascota.id == id).first()
    if not mascota:
        raise HTTPException(status_code=404, detail="Mascota no encontrada")
    db.delete(mascota)
    db.commit()