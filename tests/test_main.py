import azure.functions as func
import pytest

from HttpExample import main

def test_main():
    req = func.HttpRequest(
        method="POST",
        headers={
            "Content-Type": "text",
        },
        params={"name":"Mat"},
        body="",
        url="/",
    )

    response = main(req)
    assert 200 == response.status_code
    response_body = response.get_body().decode("utf-8")
    assert response_body.find("Mat") >= 0