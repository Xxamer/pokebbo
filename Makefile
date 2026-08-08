# Makefile for local development and Docker workflows

deps:
	mix deps.get

setup: deps
	mix ecto.setup
	mix assets.setup

format:
	mix format

lint:
	mix credo --strict

test:
	mix test

build:
	docker compose up --build

down:
	docker compose down

logs:
	docker compose logs -f

start: 
	docker-compose up
	
dev-console:
	iex -S mix
