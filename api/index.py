from flask import Flask, request, jsonify
from api.endpoints.fortune import fortune_bp

app = Flask(__name__)
app.register_blueprint(fortune_bp)

@app.route("/")
def home():
    return jsonify({"status": "OK"})
