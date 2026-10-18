# Лабораторна 1 / Клауди

## Опис
REST API для роботи з клієнтами спортзалу. Python Flask + MySQL.

## Технології
Python, Flask, MySQL, Docker, Docker Compose, Terraform, AWS, GitHub Actions.

## API
GET /health — перевірка роботи

GET /clients — список клієнтів

POST /clients — додавання клієнта

## Локальний запуск
Створити файл `.env` з налаштуваннями бази.

Запустити команду:

`docker compose up -d --build`

Адреса: http://localhost:5000/clients

## Структура
`app.py` — код API

`requirements.txt` — бібліотеки

`Dockerfile` — Docker-образ

`compose.yaml` — запуск контейнерів

`db/init.sql` — таблиця клієнтів

`terraform/` — Terraform (буде додано)

`.github/workflows/` — CI/CD (буде додано)

## AWS
Публічна адреса: буде додана після розгортання.