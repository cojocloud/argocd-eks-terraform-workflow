import time
from flask import Flask, jsonify, request, g
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

REQUEST_COUNT = Counter(
    "flask_request_count",
    "Total HTTP request count",
    ["method", "endpoint", "status"],
)
REQUEST_LATENCY = Histogram(
    "flask_request_latency_seconds",
    "HTTP request latency in seconds",
    ["endpoint"],
)


@app.before_request
def before_request():
    g.start_time = time.time()


@app.after_request
def after_request(response):
    if request.path != "/metrics":
        latency = time.time() - g.start_time
        REQUEST_COUNT.labels(
            method=request.method,
            endpoint=request.path,
            status=response.status_code,
        ).inc()
        REQUEST_LATENCY.labels(endpoint=request.path).observe(latency)
    return response


@app.route("/")
def index():
    return jsonify(
        {
            "app": "flask-demo",
            "message": "Hello from EKS! Deployed via ArgoCD.",
            "status": "ok",
        }
    )


@app.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200


@app.route("/metrics")
def metrics():
    return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
