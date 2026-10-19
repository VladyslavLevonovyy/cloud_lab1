
# Лабораторна робота №1
## Хмарні технології

**Виконав:** Левоновий Владислав

**Тема:** Розгортання REST API у хмарному середовищі AWS з використанням Docker, Terraform та GitHub Actions.

## 1. Мета роботи

Ознайомитися з контейнеризацією застосунків, створенням хмарної інфраструктури за допомогою Terraform та автоматизацією розгортання через GitHub Actions.

## 2. Опис проєкту

У лабораторній роботі створено REST API для роботи з клієнтами спортивного залу.

Застосунок написаний мовою Python з використанням Flask. Дані клієнтів зберігаються у базі даних MySQL.

Для локального запуску використовуються Docker і Docker Compose.

Для розгортання в AWS використовуються:

- Amazon VPC — віртуальна мережа.
- Amazon ECR — приватний реєстр Docker-образів.
- Amazon ECS Fargate — запуск контейнерів.
- Amazon RDS — база даних MySQL.
- Application Load Balancer — доступ до API через інтернет.
- AWS Secrets Manager — зберігання пароля бази даних.
- Amazon CloudWatch — журнали роботи контейнера.
- Terraform — створення інфраструктури.
- GitHub Actions — автоматизація розгортання.

## 3. Структура проєкту

```text
cloud_lab1/
├── .github/
│   └── workflows/
│       └── deploy.yml
├── db/
├── terraform/
│   ├── alb.tf
│   ├── ecr.tf
│   ├── ecs.tf
│   ├── endpoints.tf
│   ├── github_oidc.tf
│   ├── github_user.tf
│   ├── iam.tf
│   ├── network.tf
│   ├── provider.tf
│   ├── rds.tf
│   ├── security.tf
│   ├── versions.tf
│   └── .terraform.lock.hcl
├── app.py
├── compose.yaml
├── Dockerfile
├── requirements.txt
├── .gitignore
└── Readme.md
```

## 4. REST API

У застосунку реалізовано такі маршрути:

| Метод | Маршрут | Опис |
|---|---|---|
| GET | /health | Перевірка стану сервера |
| GET | /clients | Отримання списку клієнтів |
| POST | /clients | Додавання нового клієнта |

Приклад даних для додавання клієнта:

```json
{
  "name": "Vladyslav",
  "age": 19
}
```

Після додавання клієнт зберігається у таблиці `clients` бази даних MySQL.

## 5. Локальний запуск через Docker

Для локального запуску необхідно встановити Docker Desktop.

У корені проєкту потрібно створити файл `.env` з параметрами MySQL відповідно до `compose.yaml`.

Запуск контейнерів:

```bash
docker compose up --build -d
```

Перевірка контейнерів:

```bash
docker compose ps
```

Перевірка роботи API:

```bash
curl http://localhost:5000/health
```

Отримання списку клієнтів:

```bash
curl http://localhost:5000/clients
```

Додавання клієнта:

```bash
curl -X POST http://localhost:5000/clients \
  -H "Content-Type: application/json" \
  -d '{"name":"Vladyslav","age":19}'
```

Зупинка контейнерів:

```bash
docker compose down
```

### Збереження даних

У Docker Compose для MySQL налаштовано іменований Docker Volume.

Завдяки цьому після зупинки та повторного запуску контейнерів дані залишаються в базі.

## 6. Інфраструктура AWS

За допомогою Terraform створено хмарну інфраструктуру у регіоні `eu-north-1` (Stockholm).

До її складу входять:

1. VPC з публічними та приватними підмережами.
2. Internet Gateway і таблиці маршрутизації.
3. Security Groups для обмеження мережевого доступу.
4. Приватний Docker Registry в Amazon ECR.
5. Amazon RDS MySQL.
6. Amazon ECS Cluster та ECS Fargate Service.
7. Application Load Balancer.
8. CloudWatch Logs.
9. VPC Endpoints для доступу до сервісів AWS із приватної мережі.

### Схема роботи

```text
Користувач
    |
    v
Application Load Balancer
    |
    v
ECS Fargate (Flask API)
    |
    v
Amazon RDS (MySQL)
```

Docker-образ зберігається у приватному Amazon ECR.

ECS Fargate запускає контейнер із цим образом.

Application Load Balancer приймає HTTP-запити користувачів та передає їх застосунку.

## 7. Безпека мережі

Для захисту інфраструктури налаштовано Security Groups.

- ALB приймає HTTP-запити на порт 80.
- ECS приймає запити на порт 5000 тільки від Security Group ALB.
- RDS приймає з'єднання на порт 3306 тільки від Security Group ECS.
- База даних RDS не має публічного доступу.
- ECS працює у приватній підмережі без публічної IP-адреси.
- Для доступу до ECR та інших необхідних сервісів використовуються VPC Endpoints.

Пароль бази даних зберігається в AWS Secrets Manager та передається контейнеру під час запуску.

Таким чином база даних недоступна для прямого підключення через інтернет.

## 8. Terraform

Terraform використовується для автоматичного створення та видалення AWS-ресурсів.

Для роботи необхідно встановити AWS CLI, Terraform та налаштувати доступ до AWS.

Перехід у папку Terraform:

```bash
cd terraform
```

Ініціалізація:

```bash
terraform init
```

Перевірка конфігурації:

```bash
terraform validate
```

Перегляд запланованих змін:

```bash
AWS_PROFILE=cloud-lab terraform plan
```

Створення інфраструктури:

```bash
AWS_PROFILE=cloud-lab terraform apply
```

У разі першого створення інфраструктури необхідно завантажити початковий Docker-образ у ECR з тегом, указаним у `ecs.tf`. Після цього ECS зможе успішно запустити контейнер.

Після завершення роботи інфраструктуру можна видалити:

```bash
AWS_PROFILE=cloud-lab terraform destroy
```

Видалення інфраструктури також видаляє RDS та її дані, тому команду потрібно виконувати лише після завершення демонстрації.

## 9. Автоматичне розгортання GitHub Actions

Для автоматизації розгортання створено workflow:

`.github/workflows/deploy.yml`

Workflow запускається після кожного `git push` у гілку `main`.

Він виконує такі дії:

1. Завантажує код проєкту з GitHub.
2. Авторизується в AWS.
3. Збирає новий Docker-образ застосунку.
4. Присвоює образу тег із SHA поточного коміту.
5. Завантажує образ у приватний Amazon ECR.
6. Створює нову ревізію ECS Task Definition.
7. Оновлює ECS Service.
8. Очікує стабільного стану сервісу.

Для авторизації використовуються GitHub Secrets:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

Створено окремого IAM-користувача з дозволами для роботи з ECR та ECS.

Також підготовлено Terraform-конфігурацію для OIDC. Однак у використаному AWS-акаунті створення IAM OIDC Provider обмежене політикою AWS Organizations (SCP).

Тому для поточного варіанта CI/CD використовується авторизація через GitHub Secrets, а не через OIDC.

## 10. Перевірка роботи в AWS

Застосунок розгорнуто в Amazon ECS Fargate.

Для доступу використовується DNS-адреса Application Load Balancer:

```text
http://levonovyi-gym-alb-745832772.eu-north-1.elb.amazonaws.com
```

Перевірка стану API:

```bash
curl http://levonovyi-gym-alb-745832772.eu-north-1.elb.amazonaws.com/health
```

Отримання клієнтів:

```bash
curl http://levonovyi-gym-alb-745832772.eu-north-1.elb.amazonaws.com/clients
```

Додавання клієнта:

```bash
curl -X POST \
  http://levonovyi-gym-alb-745832772.eu-north-1.elb.amazonaws.com/clients \
  -H "Content-Type: application/json" \
  -d '{"name":"Vladyslav","age":19}'
```

Під час перевірки було підтверджено роботу маршруту `/health`, отримання списку клієнтів та додавання нового клієнта до бази даних RDS.

DNS-адреса ALB може змінитися після повторного створення інфраструктури.

## 11. Захист конфіденційних даних

У проєкті реалізовано такі заходи:

- Пароль RDS зберігається в AWS Secrets Manager.
- AWS-ключі для CI/CD зберігаються в GitHub Secrets.
- Локальний файл `.env` не додається до Git.
- Terraform State та службові файли виключені через `.gitignore`.
- Docker-контейнер запускається від непривілейованого користувача.
- IAM-користувач для GitHub Actions має обмежені дозволи.
- База даних доступна лише з ECS.

У відкритому репозиторії не зберігаються паролі та секретні ключі доступу.

## 12. Висновок

Під час виконання лабораторної роботи було створено REST API мовою Python із використанням Flask та MySQL.

Реалізовано контейнеризацію застосунку за допомогою Docker і локальний запуск через Docker Compose зі збереженням даних у Docker Volume.

За допомогою Terraform створено інфраструктуру AWS, яка включає VPC, приватний реєстр ECR, ECS Fargate, RDS MySQL та Application Load Balancer.

Налаштовано мережеву ізоляцію бази даних через Security Groups та зберігання паролів в AWS Secrets Manager.

REST API успішно перевірено через Application Load Balancer.

Також налаштовано GitHub Actions для автоматичного збирання Docker-образу з тегом SHA коміту та оновлення застосунку в ECS після змін у репозиторії.

У результаті отримано практичний досвід роботи з Docker, Terraform, AWS та процесами CI/CD.
