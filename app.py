from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib
import pandas as pd

app = Flask(__name__)
CORS(app)  # Penting agar Flutter bisa akses API

# Load model
model = joblib.load("crop_model.pkl")

# Mapping hasil prediksi ke Bahasa Indonesia
kamus = {
    'rice': 'Padi',
    'maize': 'Jagung',
    'banana': 'Pisang',
    'apple': 'Apel',
    'mango': 'Mangga',
    'chickpea': 'Kacang Arab'
}

@app.route('/predict', methods=['POST'])
def predict():
    try:
        data = request.get_json()
        df = pd.DataFrame([data])
        prediction = model.predict(df)[0]
        hasil = kamus.get(prediction, prediction)
        return jsonify({"rekomendasi": hasil})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)
