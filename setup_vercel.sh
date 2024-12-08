#!/bin/bash

# Create fresh project structure
rm -rf api
rm -f vercel.json

# Create new directories
mkdir -p api/endpoints

# Create main Flask application
cat > api/index.py << 'EOF'
from flask import Flask, request, jsonify
from api.endpoints.fortune import fortune_bp

app = Flask(__name__)
app.register_blueprint(fortune_bp)

@app.route("/")
def home():
    return jsonify({"status": "OK"})
EOF

# Create fortune blueprint
cat > api/endpoints/fortune.py << 'EOF'
from flask import Blueprint, request, jsonify
import os
import openai

fortune_bp = Blueprint('fortune', __name__)
openai.api_key = os.getenv("OPENAI_API_KEY")

@fortune_bp.route("/api/fortune", methods=['POST'])
def get_fortune():
    try:
        data = request.json
        if not data or "prompt" not in data:
            return jsonify({"error": "No prompt provided"}), 400

        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are a fortune-teller."},
                {"role": "user", "content": data["prompt"]}
            ]
        )
        return jsonify({"fortune": response.choices[0].message["content"]})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@fortune_bp.route("/api/health")
def health():
    return jsonify({
        "status": "healthy",
        "api_key_set": bool(openai.api_key)
    })
EOF

# Create vercel.json
cat > vercel.json << 'EOF'
{
  "version": 2,
  "builds": [
    {
      "src": "api/index.py",
      "use": "@vercel/python"
    }
  ],
  "routes": [
    {
      "src": "/api/(.*)",
      "dest": "api/index.py"
    },
    {
      "src": "/(.*)",
      "dest": "api/index.py"
    }
  ],
  "env": {
    "PYTHONPATH": "."
  }
}
EOF

# Create requirements.txt
cat > requirements.txt << 'EOF'
flask==2.0.1
openai==0.28.1
python-dotenv==0.19.0
EOF

echo "Project structure created successfully!"