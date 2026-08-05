from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_health() -> None:
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_create_and_get_payment() -> None:
    create_response = client.post(
        "/payments",
        json={"amount": 149.90, "currency": "BRL", "description": "Pedido 123"},
    )
    assert create_response.status_code == 201
    payment = create_response.json()

    get_response = client.get(f"/payments/{payment['id']}")
    assert get_response.status_code == 200
    assert get_response.json()["currency"] == "BRL"


def test_reject_invalid_payment() -> None:
    response = client.post(
        "/payments",
        json={"amount": 0, "currency": "brl", "description": "x"},
    )
    assert response.status_code == 422
