# app.py
from flask import Flask, jsonify
import random
from prometheus_client import Counter, generate_latest

app = Flask(__name__)

REQUEST_COUNT = Counter('request_count', 'Total Request Count', ['status'])

@app.route('/api')
def my_api():
    if random.choice([True, False]):
        REQUEST_COUNT.labels(status='success').inc()
        return jsonify({'message': 'Success'}), 200
    else:
        REQUEST_COUNT.labels(status='failure').inc()
        return jsonify({'message': 'Failure'}), 500

@app.route('/metrics')
def metrics():
    return generate_latest(), 200, {'Content-Type': 'text/plain; charset=utf-8'}

if __name__ == '__main__':
    app.run(host='0.0.0.0')
