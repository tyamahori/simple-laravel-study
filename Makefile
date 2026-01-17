# Variables
SHELL := /bin/bash
.SHELLFLAGS := -eo -o pipefail -c
BASE_COMMAND := docker compose -f compose.yaml
USER_NAME := $(shell whoami)
USER_ID := $(shell id -u)
GROUP_ID := $(shell id -g)

.PHONY: default buildPhp buildS3mock up exec down logs downWithVolume

default:
	@echo "Welcome to LaravelOrbStack Project!! $(USER_NAME)"

buildPhp:
	docker build -t laravel-sutdy/php:8.5 \
        -f docker/Dockerfile \
        --target=local \
        --build-arg USER_ID=$(USER_ID) \
        --build-arg GROUP_ID=$(USER_ID) \
        --build-arg USER_NAME=$(USER_NAME) \
        .

buildS3mock:
	docker build -t laravel-sutdy/s3mock:202601 \
        -f docker/Dockerfile \
        --target=s3mock \
        ./docker

up:
	docker compose up -d

exec:
	docker compose exec -it php bash

down:
	docker compose down

downWithVolume:
	docker compose down -v

logs:
	docker compose logs -f

ps:
	docker compose ps
