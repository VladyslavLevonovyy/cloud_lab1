
FROM python:3.12.12-slim-bookworm

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

RUN useradd --create-home appuser

USER appuser

EXPOSE 5000

CMD ["python", "app.py"]
