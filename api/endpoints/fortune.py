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
