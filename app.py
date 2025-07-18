from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import joblib
import os

app = Flask(__name__)
CORS(app)

model = joblib.load("crop_model.pkl")

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
        'rice': 'https://raw.githubusercontent.com/alvna-a/tani_ai2/main/gambar/rice.jpg',
        'maize': 'https://raw.githubusercontent.com/alvna-a/tani_ai2/main/gambar/maize.jpg',
        'chickpea': 'https://raw.githubusercontent.com/alvna-a/tani_ai2/main/gambar/chickpea.jpg',
        'banana': 'https://raw.githubusercontent.com/alvna-a/tani_ai2/main/gambar/banana.jpg',
        'mango': 'https://raw.githubusercontent.com/alvna-a/tani_ai2/main/gambar/mango.jpg',
        'apple': 'https://raw.githubusercontent.com/alvna-a/tani_ai2/main/gambar/apple.jpg',
        'grapes': 'https://raw.githubusercontent.com/alvna-a/tani_ai2/main/gambar/grapes.jpg',
        'watermelon': 'https://raw.githubusercontent.com/alvna-a/tani_ai2/main/gambar/watermelon.jpg',
        'muskmelon': 'https://raw.githubusercontent.com/alvna-a/tani_ai2/main/gambar/muskmelon.jpg',
        'orange': 'https://raw.githubusercontent.com/alvna-a/tani_ai2/main/gambar/orange.jpg',
        'papaya': 'https://raw.githubusercontent.com/alvna-a/tani_ai2/main/gambar/papaya.jpg',
        'coconut': 'https://raw.githubusercontent.com/alvna-a/tani_ai2/main/gambar/coconut.jpg',
        'cotton': 'https://raw.githubusercontent.com/alvna-a/tani_ai2/main/gambar/cotton.jpg',
        'jute': 'https://raw.githubusercontent.com/alvna-a/tani_ai2/main/gambar/jute.jpg',
        'coffee': 'https://raw.githubusercontent.com/alvna-a/tani_ai2/main/gambar/coffee.jpg'
    }

    return jsonify({
        "rekomendasi": kamus.get(prediction, prediction),
        "gambar": gambar_url.get(prediction, None)
    })

if __name__ == '__main__':
    port = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=port)
