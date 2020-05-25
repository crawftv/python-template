#!/usr/bin/env python3
import falcon
import pytest
from falcon import testing
from srv_falcon.api import api
import srv_falcon.api
import ujson
from faker import Faker
from srv_falcon.queries import CREATE_STORIES
import sqlite3


fake = Faker()


def make_mock_stories():
    data_generator = (
        fake.name,
        fake.name,
        fake.name,
        fake.name,
        fake.name,
    )
    data = []
    for _ in range(1, 50):
        data.append([ii() for ii in data_generator])
    return data


def mock_db():
    try:
        import os

        os.remove("test.db")
    except:
        pass
    _db = sqlite3.connect("test.db")
    _db.execute(CREATE_STORIES)
    m = make_mock_stories()
    _db.executemany("""INSERT INTO stories VALUES (?,?,?,?,?)""", m)
    _db.commit()
    return _db


@pytest.fixture
def client():
    return testing.TestClient(api)


def test_random_three(client, monkeypatch):
    #    sqlite3_execute_mock = mocker.Mock()
    #    sqlite3_mock_conn.return_value = sqlite3_execute_mock
    mock_db()
    monkeypatch.setattr(srv_falcon.api.random_three, "db", "test.db")
    response = client.simulate_get("/random_three")
    results = response.json["results"]
    assert response.status == falcon.HTTP_OK
    assert type(results) is list
    assert len(results) == 3
