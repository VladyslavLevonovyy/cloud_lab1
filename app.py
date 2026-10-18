
import os
import pymysql
from flask import Flask, jsonify, request

app = Flask(__name__)


def get_connection():
    return pymysql.connect(
        host=os.environ.get("DB_HOST", "localhost"),
        port=int(os.environ.get("DB_PORT", "3306")),
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
        database=os.environ["DB_NAME"],
        cursorclass=pymysql.cursors.DictCursor
    )


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok"})


@app.route("/clients", methods=["GET"])
def get_clients():
    connection = get_connection()

    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT id, name, age FROM clients")
            clients = cursor.fetchall()
        return jsonify(clients)
    finally:
        connection.close()


@app.route("/clients", methods=["POST"])
def add_client():
    data = request.get_json(silent=True)

    if not isinstance(data, dict) or not data.get("name"):
        return jsonify({"error": "Name is required"}), 400

    connection = get_connection()

    try:
        with connection.cursor() as cursor:
            cursor.execute(
                "INSERT INTO clients (name, age) VALUES (%s, %s)",
                (data["name"], data.get("age"))
            )
            client_id = cursor.lastrowid

        connection.commit()

        return jsonify({
            "id": client_id,
            "name": data["name"],
            "age": data.get("age")
        }), 201
    finally:
        connection.close()


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
