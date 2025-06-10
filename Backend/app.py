from flask import Flask, request, jsonify
from ultralytics import YOLO
import numpy as np
import cv2
import tempfile
import os

app = Flask(__name__)

# Load YOLOv8 model (once)
model_path = "models/best_float32.tflite"  # Adjust if needed
model = YOLO(model_path, task='segment')

@app.route('/detect-teeth', methods=['POST'])
def detect_teeth():
    if 'image' not in request.files:
        return jsonify({'error': 'No image uploaded'}), 400

    image_file = request.files['image']

    # Save to temp file
    with tempfile.NamedTemporaryFile(delete=False, suffix='.png') as temp_img:
        image_path = temp_img.name
        image_file.save(image_path)

    try:
        # Run YOLO inference
        results = model(image_path)[0]

        polygons = []
        if results.masks is not None:
            for poly in results.masks.xy:
                polygon = [[float(x), float(y)] for x, y in poly]
                polygons.append(polygon)

        return jsonify({'polygons': polygons})
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        os.remove(image_path)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5001)
