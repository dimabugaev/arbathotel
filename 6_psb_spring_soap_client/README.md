# PSB Spring SOAP Client

Этот проект содержит Java SOAP клиент для работы с API Промсвязьбанка.

## Структура проекта

- `arbatSpringSoapClient/` - основной Maven проект
- `arbatSpringSoapClient/src/main/java/` - исходный код Java
- `arbatSpringSoapClient/Dockerfile` - Dockerfile для контейнеризации

## Требования

- Java 8 (Amazon Corretto 8)
- Maven 3.6+
- Docker (для контейнеризации)

## Сборка проекта

### Локальная сборка

```bash
cd arbatSpringSoapClient
mvn clean package
```

### Сборка Docker образа

```bash
cd arbatSpringSoapClient
docker build -t java-soap-client .
```

## Запуск

### Локальный запуск

```bash
java -cp target/arbatSpringSoapClient-1.0-SNAPSHOT.jar SoapContainerRunner
```

### Запуск в Docker

```bash
docker run -e source_id=22 -e datefrom=16.06.2025 -e dateto=22.06.2025 java-soap-client
```

## Параметры

Приложение принимает следующие параметры через переменные окружения:

- `source_id` - ID источника данных (целое число)
- `datefrom` - начальная дата в формате DD.MM.YYYY
- `dateto` - конечная дата в формате DD.MM.YYYY

## Интеграция с AWS

### Lambda функция

Для запуска SOAP задачи через AWS Lambda используется функция `run_soap_task.py`, которая:

1. Принимает параметры `source_id`, `datefrom`, `dateto`
2. Запускает ECS задачу с Java контейнером
3. Передает параметры через переменные окружения

### ECS задача

SOAP задача запускается в ECS Fargate с:

- CPU: 1024 (1 vCPU)
- Memory: 2048 MB
- Сетевой доступ через VPC
- Логирование в CloudWatch

### Пример вызова Lambda

```json
{
  "source_id": "22",
  "datefrom": "16.06.2025",
  "dateto": "22.06.2025"
}
```

## Мониторинг

Логи ECS задачи доступны в CloudWatch Logs в группе `/aws/ecs/{prefix}-ecs-cluster`.

## Развертывание

Проект автоматически развертывается через GitHub Actions workflow:

1. Сборка Java приложения
2. Создание Docker образа
3. Пуш в Amazon ECR
4. Обновление ECS задачи через Terraform 