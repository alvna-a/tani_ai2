from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import joblib
import os

app = Flask(__name__)
CORS(app)

model = joblib.load("crop_model.pkl")  # pastikan file ini ada

@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json()
    df = pd.DataFrame([data])
    prediction = model.predict(df)[0]
    
    kamus = {
        'rice': 'padi',
        'maize': 'jagung',
        'chickpea': 'kacang arab',
        'banana': 'pisang',
        'mango': 'mangga',
        'apple': 'apel',
        'grapes': 'anggur',
        'watermelon': 'semangka',
        'muskmelon': 'blewah',
        'orange': 'jeruk',
        'papaya': 'pepaya',
        'coconut': 'kelapa',
        'cotton': 'kapas',
        'jute': 'jut',
        'coffee': 'kopi'
    }

    gambar_url = {
        'rice': 'https://example.com/images/rice.jpg',
        'maize': 'https://example.com/images/maize.jpg',
        'chickpea': 'https://example.com/images/chickpea.jpg',
        'banana': 'https://example.com/images/banana.jpg',
        'mango': 'https://example.com/images/mango.jpg',
        'apple': 'https://example.com/images/apple.jpg',
        'grapes': 'https://example.com/images/grapes.jpg',
        'watermelon': 'https://example.com/images/watermelon.jpg',
        'muskmelon': 'https://example.com/images/muskmelon.jpg',
        'orange': 'https://example.com/images/orange.jpg',
        'papaya': 'https://example.com/images/papaya.jpg',
        'coconut': 'https://example.com/images/coconut.jpg',
        'cotton': 'https://example.com/images/cotton.jpg',
        'jute': 'https://example.com/images/jute.jpg',
        'coffee': 'https://example.com/images/coffee.jpg'
    }

    return jsonify({
        "rekomendasi": kamus.get(prediction, prediction),
        "gambar": gambar_url.get(prediction, None)
    })

if __name__ == '__main__':
    port = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=port)
