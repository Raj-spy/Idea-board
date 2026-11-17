from fastapi.testclient import TestClient
from sqlalchemy.exc import OperationalError

from app.database import get_db
from app.main import app


def test_ideas_can_be_created_and_retrieved(client: TestClient) -> None:
    create_response = client.post("/api/ideas", json={"content": "  Improve onboarding  "})

    assert create_response.status_code == 201
    created_idea = create_response.json()
    assert created_idea["content"] == "Improve onboarding"
    assert created_idea["id"] > 0
    assert created_idea["created_at"]

    list_response = client.get("/api/ideas")
    assert list_response.status_code == 200
    assert list_response.json() == [created_idea]


def test_idea_content_must_not_be_blank(client: TestClient) -> None:
    response = client.post("/api/ideas", json={"content": " \t "})

    assert response.status_code == 422


def test_idea_content_has_a_maximum_length(client: TestClient) -> None:
    response = client.post("/api/ideas", json={"content": "x" * 1001})

    assert response.status_code == 422


def test_idea_content_cannot_bypass_maximum_with_whitespace(client: TestClient) -> None:
    response = client.post("/api/ideas", json={"content": f"{' ' * 1001}x"})

    assert response.status_code == 422


def test_health_check_reports_database_connectivity(client: TestClient) -> None:
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {"status": "ok", "database": "connected"}


def test_health_check_hides_database_error_details(client: TestClient) -> None:
    class UnavailableSession:
        def execute(self, statement):
            raise OperationalError("SELECT 1", {}, RuntimeError("private connection detail"))

    def get_unavailable_db():
        yield UnavailableSession()

    app.dependency_overrides[get_db] = get_unavailable_db
    response = client.get("/health")

    assert response.status_code == 503
    assert response.json() == {"detail": "Database unavailable"}
    assert "private connection detail" not in response.text
