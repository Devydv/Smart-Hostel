from app import app


def test_health_endpoint_returns_ok() -> None:
    client = app.test_client()
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json == {"status": "ok"}


def test_metrics_endpoint_returns_prometheus_format() -> None:
    client = app.test_client()

    response = client.get("/metrics")

    assert response.status_code == 200
    assert response.mimetype == "text/plain"
    assert b"# HELP" in response.data
