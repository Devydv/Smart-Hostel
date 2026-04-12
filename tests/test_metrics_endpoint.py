from app import app


def test_health_endpoint_returns_ok() -> None:
    client = app.test_client()
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json == {"status": "ok"}


def test_metrics_endpoint_exposes_custom_metrics() -> None:
    client = app.test_client()

    # Prime counters with a request so metric families exist with labels.
    client.get("/")

    response = client.get("/metrics")

    assert response.status_code == 200
    payload = response.get_data(as_text=True)
    assert "smarthostel_http_requests_total" in payload
    assert "smarthostel_http_request_latency_seconds" in payload
    assert "smarthostel_http_errors_total" in payload
