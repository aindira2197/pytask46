CREATE TABLE CircuitBreaker (
    id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE Circuit (
    id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) NOT NULL,
    circuitBreakerId INT,
    FOREIGN KEY (circuitBreakerId) REFERENCES CircuitBreaker(id)
);

CREATE TABLE Breaker (
    id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) NOT NULL,
    circuitId INT,
    FOREIGN KEY (circuitId) REFERENCES Circuit(id)
);

INSERT INTO CircuitBreaker (name, description, status) VALUES ('CB1', 'Circuit Breaker 1', 'ON');
INSERT INTO CircuitBreaker (name, description, status) VALUES ('CB2', 'Circuit Breaker 2', 'OFF');
INSERT INTO Circuit (name, description, status, circuitBreakerId) VALUES ('C1', 'Circuit 1', 'ON', 1);
INSERT INTO Circuit (name, description, status, circuitBreakerId) VALUES ('C2', 'Circuit 2', 'OFF', 2);
INSERT INTO Breaker (name, description, status, circuitId) VALUES ('B1', 'Breaker 1', 'ON', 1);
INSERT INTO Breaker (name, description, status, circuitId) VALUES ('B2', 'Breaker 2', 'OFF', 2);

CREATE VIEW CircuitBreakerView AS SELECT CB.name, CB.description, CB.status, C.name AS circuitName, B.name AS breakerName
FROM CircuitBreaker CB
JOIN Circuit C ON CB.id = C.circuitBreakerId
JOIN Breaker B ON C.id = B.circuitId;

SELECT * FROM CircuitBreakerView;

CREATE PROCEDURE toggleCircuitBreaker(IN id INT)
BEGIN
    UPDATE CircuitBreaker SET status = IF(status = 'ON', 'OFF', 'ON') WHERE id = id;
END;

CALL toggleCircuitBreaker(1);

SELECT * FROM CircuitBreaker;

CREATE TRIGGER updateCircuitTrigger AFTER UPDATE ON CircuitBreaker
FOR EACH ROW
BEGIN
    UPDATE Circuit SET status = NEW.status WHERE circuitBreakerId = NEW.id;
END;

UPDATE CircuitBreaker SET status = 'OFF' WHERE id = 1;

SELECT * FROM Circuit;

CREATE INDEX idx_circuitBreaker_id ON Circuit (circuitBreakerId);
CREATE INDEX idx_circuit_id ON Breaker (circuitId);

EXPLAIN SELECT * FROM Circuit WHERE circuitBreakerId = 1;

DROP INDEX idx_circuitBreaker_id ON Circuit;
DROP INDEX idx_circuit_id ON Breaker;

ALTER TABLE Circuit ADD COLUMN voltage DECIMAL(10, 2);
ALTER TABLE Breaker ADD COLUMN current DECIMAL(10, 2);

UPDATE Circuit SET voltage = 220.00 WHERE id = 1;
UPDATE Breaker SET current = 10.00 WHERE id = 1;

SELECT * FROM Circuit;
SELECT * FROM Breaker;