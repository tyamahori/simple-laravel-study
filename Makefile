# Variables
SHELL := /bin/bash
.SHELLFLAGS := -eo -o pipefail -c
BASE_COMMAND := docker compose -f compose.yaml
USER_NAME := $(shell whoami)
USER_ID := $(shell id -u)
GROUP_ID := $(shell id -g)

.PHONY: default build up exec down logs

default:
	@echo "Welcome to LaravelOrbStack Project!! $(USER_NAME)"

build:
	docker build -t laravel-sutdy/php:8.5 \
        -f docker/Dockerfile \
        --target=local \
        --build-arg USER_ID=$(USER_ID) \
        --build-arg GROUP_ID=$(USER_ID) \
        --build-arg USER_NAME=$(USER_NAME) \
        .

up:
	docker compose up -d

exec:
	docker compose exec -it php bash

down:
	docker compose down

logs:
	docker compose logs -f
