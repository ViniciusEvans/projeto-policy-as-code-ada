.RECIPEPREFIX := >

.PHONY: install test lint run docker-build policy-test verify

install:
>uv sync --dev

test:
>uv run pytest -q

lint:
>uv run ruff check .
>uv run ruff format --check .

run:
>uv run uvicorn app.main:app --host 0.0.0.0 --port 8080

docker-build:
>docker build -t api-pagamentos:local .

policy-test:
>opa fmt --fail policies/
>opa test policies/ -v

verify: lint test policy-test
