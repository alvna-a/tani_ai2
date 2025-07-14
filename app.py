from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import joblib
import os

app = Flask(__name__)
CORS(app)

# Cek apakah model tersedia
MODEL_PATH = "crop_model.pkl"
if os.path.exists(MODEL_PATH):
    try:
        model = joblib.load(MODEL_PATH)
    except Exception as e:
        model = None
        print(f"❌ Gagal load model: {e}")
else:
    model = None
    print("❌ File crop_model.pkl tidak ditemukan!")

@app.route('/')
def home():
    return "TaniAI Backend is running!"

@app.route('/predict', methods=['POST'])
def predict():
    if model is None:
        return jsonify({"error": "Model belum tersedia di server"}), 500

    try:
        data = request.get_json()
        df = pd.DataFrame([data])
        prediction = model.predict(df)[0]

        kamus = {
            'rice': 'Padi',
            'maize': 'Jagung',
            'banana': 'Pisang',
            'apple': 'Apel',
            'mango': 'Mangga',
            'chickpea': 'Kacang Arab'
        }

        hasil = kamus.get(prediction, prediction)
        return jsonify({"rekomendasi": hasil})

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.environ.get("PORT", 5000)))
