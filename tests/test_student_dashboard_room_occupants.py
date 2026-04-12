import app as app_module


class _FakeCursor:
    def __init__(self) -> None:
        self._one = None
        self._all = []

    def execute(self, query, params=None) -> None:
        normalized = " ".join(query.split())
        self._one = None
        self._all = []

        if "SELECT * FROM students WHERE student_id=%s" in normalized:
            self._one = {"student_id": 1, "name": "Demo Student", "roll_no": "STU001"}
            return

        if "SELECT r.* FROM rooms r JOIN room_allocation ra" in normalized:
            self._one = {"room_id": 10, "room_number": "A-101", "block": "A"}
            return

        if "SELECT DISTINCT s.student_id, s.name" in normalized:
            # Correct query should deduplicate occupants.
            self._all = [
                {"student_id": 1, "name": "Demo Student"},
                {"student_id": 2, "name": "Jiri Prohachka"},
            ]
            return

        if "FROM room_allocation ra" in normalized and "JOIN students s ON s.student_id = ra.student_id" in normalized:
            # If DISTINCT is removed in code, this path makes the test fail by returning duplicates.
            self._all = [
                {"student_id": 1, "name": "Demo Student"},
                {"student_id": 1, "name": "Demo Student"},
                {"student_id": 2, "name": "Jiri Prohachka"},
            ]
            return

        if "FROM fees WHERE student_id=%s ORDER BY due_date DESC LIMIT 1" in normalized:
            self._one = {"payment_status": "Pending", "amount": 12000, "due_date": None}
            return

        if "SELECT LOWER(REPLACE(status, ' ', '_')) AS status_key, COUNT(*) AS total" in normalized:
            self._all = [{"status_key": "pending", "total": 1}]
            return

        if "FROM complaints WHERE student_id=%s ORDER BY created_at DESC LIMIT 5" in normalized:
            self._all = []
            return

    def fetchone(self):
        return self._one

    def fetchall(self):
        return self._all

    def close(self) -> None:
        return


class _FakeConnection:
    def cursor(self, dictionary=True, buffered=True):
        return _FakeCursor()

    def close(self) -> None:
        return


def test_student_dashboard_renders_unique_room_occupants(monkeypatch) -> None:
    monkeypatch.setattr(app_module, "get_db_connection", lambda: _FakeConnection())

    client = app_module.app.test_client()
    with client.session_transaction() as session:
        session["role"] = "STUDENT"
        session["student_id"] = 1

    response = client.get("/student/dashboard")

    assert response.status_code == 200
    html = response.get_data(as_text=True)
    assert "Room Occupants" in html
    assert html.count("Demo Student (You)") == 1
    assert "Jiri Prohachka" in html