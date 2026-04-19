class CircuitBreaker:
    def __init__(self, threshold, timeout):
        self.threshold = threshold
        self.timeout = timeout
        self.failures = 0
        self.circuit_open = False
        self.opened_at = None

    def is_circuit_open(self):
        if self.circuit_open:
            if self.opened_at + self.timeout < time.time():
                self.circuit_open = False
                self.failures = 0
            return True
        return False

    def reset(self):
        self.circuit_open = False
        self.failures = 0

    def try_execute(self, func, *args, **kwargs):
        if self.is_circuit_open():
            raise Exception("Circuit is open")
        try:
            result = func(*args, **kwargs)
            self.failures = 0
            return result
        except Exception as e:
            self.failures += 1
            if self.failures >= self.threshold:
                self.circuit_open = True
                self.opened_at = time.time()
            raise e

import time
import random

def example_function():
    if random.random() < 0.5:
        raise Exception("Example exception")
    return "Example result"

circuit_breaker = CircuitBreaker(threshold=3, timeout=10)

for i in range(10):
    try:
        result = circuit_breaker.try_execute(example_function)
        print(result)
    except Exception as e:
        print(e)

print(circuit_breaker.circuit_open)

class State:
    CLOSED = 1
    OPEN = 2
    HALF_OPEN = 3

class CircuitBreakerState:
    def __init__(self):
        self.state = State.CLOSED
        self.opened_at = None
        self.timeout = 10
        self.threshold = 3
        self.failures = 0

    def is_open(self):
        return self.state == State.OPEN

    def is_closed(self):
        return self.state == State.CLOSED

    def is_half_open(self):
        return self.state == State.HALF_OPEN

    def reset(self):
        self.state = State.CLOSED
        self.opened_at = None
        self.failures = 0

    def try_execute(self, func, *args, **kwargs):
        if self.is_open():
            if time.time() - self.opened_at > self.timeout:
                self.state = State.HALF_OPEN
            else:
                raise Exception("Circuit is open")
        try:
            result = func(*args, **kwargs)
            if self.is_half_open():
                self.state = State.CLOSED
                self.opened_at = None
                self.failures = 0
            self.failures = 0
            return result
        except Exception as e:
            self.failures += 1
            if self.failures >= self.threshold and self.is_closed():
                self.state = State.OPEN
                self.opened_at = time.time()
            raise e

circuit_breaker_state = CircuitBreakerState()
for i in range(10):
    try:
        result = circuit_breaker_state.try_execute(example_function)
        print(result)
    except Exception as e:
        print(e)

print(circuit_breaker_state.is_open())