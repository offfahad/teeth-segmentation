# 🦷 Teeth Segmentation Mobile App (Flutter + YOLOv11 Backend)

This project implements a cross-platform mobile application for **teeth segmentation** using a YOLOv11 instance segmentation model. The solution is built in **Flutter** for the mobile front-end and uses a **Flask-based backend** for running the trained ML model. It accurately detects and outlines individual teeth from images and displays the segmentation in real time.

---

## 📹 Demo & Walkthrough

Watch the full project walkthrough on Loom:  
👉 [Loom Video Explanation](https://www.loom.com/share/e16fdf1eebbe4f5a836301466ba6af82)

---

## 🔍 Project Structure

### 📱 Flutter Frontend

- Built using **Flutter** for both Android and iOS support.
- Captures or selects teeth images from gallery.
- Sends image to the backend API for segmentation.
- Receives polygon coordinates and renders them over the image using `CustomPainter`.
- Smooth UI and fast response thanks to server-side inference.

**Key Features:**
- Flutter UI/UX
- API integration with Flask server
- Real-time polygon overlay
- CustomPainter for drawing masks

### 🧠 ML Backend (Flask + YOLOv8)

- Built with **Flask** to expose a lightweight HTTP API.
- Loads a custom-trained **YOLOv11 instance segmentation** model.
- Accepts image input via POST request.
- Runs inference and converts model output to polygon coordinates.
- Returns JSON response with detected teeth regions.

**Tech Stack:**
- Flask
- YOLOv11 (Ultralytics)
- OpenCV, NumPy
- Polygon conversion utilities

---

## 🏋️‍♂️ Model Training Process

- We curated and annotated a dental image dataset using **Roboflow**.
- Our ML developer manually labeled segmentation masks for accurate training.
- Trained a YOLOv8 instance segmentation model optimized for tooth boundaries.
- Exported the final model weights for backend inference.

---

## 💡 Potential Use Cases

- Dental diagnosis assistance
- Smile design & cosmetic simulations
- Automated teeth labeling and counting
- Pre/post treatment comparison
- Dental record digitization

---

## 🚀 How to Run

### Backend
1. Go to the `Backend/` folder.
2. Install dependencies: `Use PyCharm Editor`
3. Run server: `python app.py`

### Flutter App
1. Go to the `Frontend/` folder.
2. Install packages: `flutter pub get`
3. Run app: `flutter run`

> Make sure the backend is running and accessible by the mobile app.

---

## 📬 Contact

For any questions or collaboration inquiries, feel free to reach out via GitHub Issues or connect on LinkedIn.

- 🌐 Portfolio: [offfahad.netlify.app](https://offfahad.netlify.app/)
- 💼 LinkedIn: [linkedin.com/in/offfahad](https://www.linkedin.com/in/offfahad)
- 🐙 GitHub: [github.com/offfahad](https://github.com/offfahad)



