# 🔬 Endometrium Cancer Detection (ECD) System

A deep learning–powered web application for histopathological classification of endometrium tissue slides using a Convolutional Neural Network (CNN).

## 🧪 What It Does

Upload a histopathological slide image and the system will:
1. **Preprocess** the image through a 4-step computer vision pipeline (Grayscale → Edge Detection → Binary Threshold)
2. **Count cells** — total, damaged, and overlapping
3. **Classify** the condition using a trained CNN model into one of four categories:
   - 🔴 **Stage 1 Cancer** — Endometrial Adenocarcinoma
   - 🟠 **Stage 2 Cancer** — Endometrial Hyperplasia
   - 🔵 **Stage 3 Cancer** — Endometrial Polyp
   - 🟢 **Normal** — No signs of cancer
4. **Display** severity level, disease description, and medical recommendations

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| Backend | Python, Flask |
| ML Model | TensorFlow / Keras CNN |
| Computer Vision | OpenCV |
| Frontend | HTML, Vanilla CSS, Jinja2 |
| Database | SQLite |

## 🚀 Getting Started

### 1. Clone the repository
```bash
git clone https://github.com/<your-username>/AIML_ECD.git
cd AIML_ECD
```

### 2. Create & activate a virtual environment
```bash
python -m venv venv

# Windows
venv\Scripts\activate

# macOS / Linux
source venv/bin/activate
```

### 3. Install dependencies
```bash
pip install -r requirements.txt
```

### 4. Set up the database
The app auto-creates `user_data.db` on first register. Just run the app and register a user.

### 5. Run the app
```bash
python app.py
```
Visit → [http://127.0.0.1:5000](http://127.0.0.1:5000)

## 📁 Project Structure

```
AIML_ECD/
├── app.py                          # Flask application & routes
├── requirements.txt                # Python dependencies
├── Convolutional_Neural_Network.h5 # Trained CNN model
├── ConvolutionalNeuralNetwork_ModelTraining.ipynb  # Training notebook
├── static/
│   ├── css/style.css               # Dark theme design system
│   └── acc_graph.png, ...          # Model performance graphs
└── templates/
    ├── base.html                   # Base layout (navbar, footer)
    ├── index.html                  # Login / Register page
    ├── userlog.html                # Upload & Results page
    ├── graph.html                  # Model performance graphs
    └── developer.html             # Developer profiles
```

## 👥 Developers

| Name | Role |
|---|---|
| Suhani Bodhke | Developer |
| Saksham Dhumale | Developer |
| Nishant Deshmukh | Developer |
| Vaishnavi Kulkarni | Developer |
| Yash Iskape | Developer |

**Institution:** Prof. Ram Meghe Institute of Technology & Research

## 📊 Model Performance

The CNN model is trained on labelled endometrium histopathology datasets across 4 classes.
Model accuracy graphs and confusion matrix are available in the **Model Graphs** section of the app.

## ⚠️ Disclaimer

This tool is intended for **research and educational purposes only**. It is not a substitute for professional medical diagnosis. Always consult a qualified medical professional.
