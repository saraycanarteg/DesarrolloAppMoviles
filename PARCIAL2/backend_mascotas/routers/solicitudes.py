from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
import models, schemas

router = APIRouter()

@router.get("/", response_model=list[schemas.SolicitudOut])
def listar(db: Session = Depends(get_db)):
    return db.query(models.SolicitudAdopcion).all()

@router.get("/{id}", response_model=schemas.SolicitudOut)
def obtener(id: int, db: Session = Depends(get_db)):
    sol = db.query(models.SolicitudAdopcion).filter(models.SolicitudAdopcion.id == id).first()
    if not sol:
        raise HTTPException(status_code=404, detail="Solicitud no encontrada")
    return sol

@router.post("/", response_model=schemas.SolicitudOut, status_code=201)
def crear(data: schemas.SolicitudCreate, db: Session = Depends(get_db)):
    # Regla: no se puede solicitar si ya fue adoptada
    mascota = db.query(models.Mascota).filter(models.Mascota.id == data.mascota_id).first()
    if not mascota:
        raise HTTPException(status_code=404, detail="Mascota no encontrada")
    if mascota.adoptada:
        raise HTTPException(status_code=400, detail="Esta mascota ya fue adoptada")

    nueva = models.SolicitudAdopcion(**data.model_dump())
    db.add(nueva)
    db.commit()
    db.refresh(nueva)
    return nueva

@router.put("/{id}", response_model=schemas.SolicitudOut)
def actualizar(id: int, data: schemas.SolicitudUpdate, db: Session = Depends(get_db)):
    sol = db.query(models.SolicitudAdopcion).filter(models.SolicitudAdopcion.id == id).first()
    if not sol:
        raise HTTPException(status_code=404, detail="Solicitud no encontrada")

    for k, v in data.model_dump(exclude_unset=True).items():
        setattr(sol, k, v)

    # Regla: al aprobar, la mascota cambia a adoptada
    if data.aprobada:
        sol.mascota.adoptada = True

    db.commit()
    db.refresh(sol)
    return sol

@router.delete("/{id}", status_code=204)
def eliminar(id: int, db: Session = Depends(get_db)):
    sol = db.query(models.SolicitudAdopcion).filter(models.SolicitudAdopcion.id == id).first()
    if not sol:
        raise HTTPException(status_code=404, detail="Solicitud no encontrada")
    db.delete(sol)
    db.commit()