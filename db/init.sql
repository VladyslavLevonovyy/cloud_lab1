CREATE TABLE IF NOT EXISTS clients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    age INT
);
INSERT INTO clients (name, age)
SELECT 'Ivan',
    22
WHERE NOT EXISTS (
        SELECT 1
        FROM clients
        WHERE name = 'Ivan'
    );
INSERT INTO clients (name, age)
SELECT 'Olena',
    25
WHERE NOT EXISTS (
        SELECT 1
        FROM clients
        WHERE name = 'Olena'
    );