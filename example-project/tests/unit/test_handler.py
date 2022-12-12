from example import handler
from tests.unit.fixtures import lambda_context


def test_handler_when_invoked_it_returns_hello_world():
    event = {"hey": "there"}
    assert handler.handle(event, lambda_context()) == {"hello": "world"}
