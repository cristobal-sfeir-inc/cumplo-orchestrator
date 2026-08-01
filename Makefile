-include .env
export

.PHONY: \
  lint \
  format \
  start \
  build \
  down \
  login \
  update_common

.PHONY: lint
lint:
	@poetry run ruff check .
	@poetry run ruff format --check .
	@poetry run basedpyright
	@poetry run docformatter --check --recursive .

.PHONY: format
format:
	@poetry run ruff format .
	@poetry run ruff check --fix .
	@poetry run docformatter --in-place --recursive .

build:
	@docker-compose build cumplo-orchestrator --build-arg CUMPLO_PYPI_BASE64_KEY=`base64 -i cumplo-pypi-credentials.json`

start:
	@docker-compose up -d cumplo-orchestrator

down:
	@docker-compose down

# Activates the project configuration and logs in to gcloud
login:
	@gcloud config configurations activate $(PROJECT_ID)
	@gcloud auth application-default login

update_common:
	@rm -rf .venv
	@poetry cache clear --no-interaction --all cumplo-pypi
	@poetry update