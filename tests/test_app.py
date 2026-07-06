import pytest
from backend.app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_users_endpoint(client):
    rv = client.get('/api/users')
    assert rv.status_code in (200, 500)  # 500 if no DB connection

def test_songs_endpoint(client):
    rv = client.get('/api/songs')
    assert rv.status_code in (200, 500)
