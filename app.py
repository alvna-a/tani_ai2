from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import joblib

app = Flask(__name__)
CORS(app)

model = joblib.load("crop_model.pkl")  # pastikan file ini ada

@app.route('/predict', methods=['POST'])
def predict():
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
    
    return jsonify({
        "rekomendasi": kamus.get(prediction, prediction)
    })

if __name__ == '__main__':
    app.run()
