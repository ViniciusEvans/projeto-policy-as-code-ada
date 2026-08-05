from __future__ import annotations

from datetime import datetime, timezone
from enum import StrEnum
from threading import Lock
from typing import Annotated
from uuid import UUID, uuid4

from fastapi import FastAPI, HTTPException, Path, status
from pydantic import BaseModel, Field


class PaymentStatus(StrEnum):
    CREATED = "created"
    APPROVED = "approved"


class PaymentCreate(BaseModel):
    amount: float = Field(gt=0, le=1_000_000, examples=[149.90])
    currency: str = Field(pattern=r"^[A-Z]{3}$", examples=["BRL"])
    description: str = Field(min_length=3, max_length=200, examples=["Pedido 123"])


class Payment(BaseModel):
    id: UUID
    amount: float
    currency: str
    description: str
    status: PaymentStatus
    created_at: datetime


app = FastAPI(
    title="API Pagamentos - Compliance Continuo",
    version="1.0.0",
    description="Aplicacao ficticia usada para demonstrar Policy as Code, SBOM, assinatura e provenance.",
)

_payments: dict[UUID, Payment] = {}
_lock = Lock()


@app.get("/health", tags=["operacao"])
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/payments", response_model=Payment, status_code=status.HTTP_201_CREATED, tags=["pagamentos"])
def create_payment(payload: PaymentCreate) -> Payment:
    payment = Payment(
        id=uuid4(),
        amount=payload.amount,
        currency=payload.currency,
        description=payload.description,
        status=PaymentStatus.CREATED,
        created_at=datetime.now(timezone.utc),
    )
    with _lock:
        _payments[payment.id] = payment
    return payment


@app.get("/payments/{payment_id}", response_model=Payment, tags=["pagamentos"])
def get_payment(
    payment_id: Annotated[UUID, Path(description="Identificador UUID do pagamento")],
) -> Payment:
    with _lock:
        payment = _payments.get(payment_id)
    if payment is None:
        raise HTTPException(status_code=404, detail="Pagamento nao encontrado")
    return payment
