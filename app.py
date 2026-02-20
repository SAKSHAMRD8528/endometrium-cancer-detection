import os
import re
import time
import matplotlib
matplotlib.use('Agg')  # Must be before pyplot import — prevents Tkinter crash in Flask threads
import matplotlib.pyplot as plt
import numpy as np
import cv2
import sqlite3

from flask import Flask, render_template, request
from sklearn.metrics import accuracy_score

from tensorflow.keras.preprocessing.image import load_img, img_to_array
from tensorflow.keras.utils import to_categorical
from tensorflow.keras.models import load_model

app = Flask(__name__)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Load CNN model once at startup — avoids reloading on every request
model = load_model(os.path.join(BASE_DIR, "Convolutional_Neural_Network.h5"))

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/userlog', methods=['GET', 'POST'])
def userlog():
    if request.method == 'POST':
        connection = sqlite3.connect(os.path.join(BASE_DIR, 'user_data.db'))
        cursor = connection.cursor()

        name = request.form['name']
        password = request.form['password']

        query = "SELECT name, password FROM user WHERE name = ? AND password = ?"
        cursor.execute(query, (name, password))
        result = cursor.fetchall()

        if len(result) == 0:
            return render_template('index.html', msg='Sorry, Incorrect Credentials Provided, Try Again')
        else:
            return render_template('userlog.html')

    return render_template('index.html')

@app.route('/userreg', methods=['GET', 'POST'])
def userreg():
    if request.method == 'POST':
        connection = sqlite3.connect(os.path.join(BASE_DIR, 'user_data.db'))
        cursor = connection.cursor()

        name = request.form['name']
        password = request.form['password']
        mobile = request.form['phone']
        email = request.form['email']

        command = """CREATE TABLE IF NOT EXISTS user(name TEXT, password TEXT, mobile TEXT, email TEXT)"""
        cursor.execute(command)

        cursor.execute("INSERT INTO user VALUES (?, ?, ?, ?)", (name, password, mobile, email))
        connection.commit()

        return render_template('index.html', msg='Successfully Registered')

    return render_template('index.html')

@app.route('/developer.html')
def developer():
    return render_template('developer.html')

@app.route('/graph.html', methods=['GET', 'POST'])
def graph():
    images = ['/static/acc_graph.png',
              '/static/loss_plot.png',
              '/static/conf_mat.png']
    content = ['Accuracy Graph', 'Loss Graph(Error Message)', 'Confusion Matrix']
    return render_template('graph.html', images=images, content=content)

@app.route('/image', methods=['GET', 'POST'])
def image():
    if request.method == 'POST':
        # Accept the uploaded file directly — no test/ folder needed
        uploaded_file = request.files.get('file')
        if not uploaded_file or uploaded_file.filename == '':
            return render_template('userlog.html', msg='No file selected. Please choose an image.')

        raw_name = uploaded_file.filename
        name_part, ext = os.path.splitext(raw_name)
        name_part = re.sub(r'[^\w\-]', '_', name_part)  # replace special chars with _
        fileName = name_part + ext.lower()
        dirPath = os.path.join(BASE_DIR, 'static', 'images')
        os.makedirs(dirPath, exist_ok=True)
        for f in os.listdir(dirPath):
            os.remove(os.path.join(dirPath, f))

        # Save the uploaded file straight into static/images/
        save_path = os.path.join(dirPath, fileName)
        uploaded_file.save(save_path)

        image = cv2.imread(save_path)

        gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        cv2.imwrite(os.path.join(BASE_DIR, 'static', 'gray.jpg'), gray_image)
        edges = cv2.Canny(image, 250, 254)
        cv2.imwrite(os.path.join(BASE_DIR, 'static', 'edges.jpg'), edges)
        _, threshold2 = cv2.threshold(gray_image, 128, 255, cv2.THRESH_BINARY)
        cv2.imwrite(os.path.join(BASE_DIR, 'static', 'threshold.jpg'), threshold2)

        blurred = cv2.GaussianBlur(gray_image, (5, 5), 0)
        _, thresh = cv2.threshold(blurred, 150, 255, cv2.THRESH_BINARY)
        contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

        total_cells = len(contours)
        damaged_cells = sum(1 for c in contours if cv2.contourArea(c) < 100)
        overlap_cells = 0

        for i in range(len(contours)):
            for j in range(i + 1, len(contours)):
                M_i = cv2.moments(contours[i])
                M_j = cv2.moments(contours[j])
                if M_i['m00'] != 0 and M_j['m00'] != 0:
                    cx_i = int(M_i['m10'] / M_i['m00'])
                    cy_i = int(M_i['m01'] / M_i['m00'])
                    cx_j = int(M_j['m10'] / M_j['m00'])
                    cy_j = int(M_j['m01'] / M_j['m00'])
                    distance = np.sqrt((cx_i - cx_j) ** 2 + (cy_i - cy_j) ** 2)
                    if distance < 20:
                        overlap_cells += 1

        path = os.path.join(BASE_DIR, 'static', 'images', fileName)

        class_labels = ['Endometrial Adocarcinoma', 'Endometrial hyper plsia', 'Endometria polyp', 'Normal Endometrium']

        def prepare_test_image(path):
            img = load_img(path, target_size=(128, 128), grayscale=True)
            x = img_to_array(img) / 255.0
            return np.expand_dims(x, axis=0)

        result = model.predict(prepare_test_image(path))
        class_result = np.argmax(result, axis=1)

        result = list(result[0])
        labels_map = {
            0: ("Endometrial Adocarcinoma", "stage1 cancer"),
            1: ("Endometrial hyper plsia", "stage2 cancer"),
            2: ("Endometria polyp", "stage3 cancer"),
            3: ("Normal Endometrium", "")
        }
        str_label, status1 = labels_map[class_result[0]]
        accuracy = f"The predicted image of the {str_label} is with a accuracy of {result[class_result[0]] * 100:.2f}%"

        dic = {'EA': result[0], 'EH': result[1], 'EP': result[2], 'NE': result[3]}
        plt.figure(figsize=(5, 5))
        plt.bar(dic.keys(), dic.values(), color='maroon', width=0.3)
        plt.xlabel("Comparison")
        plt.ylabel("Accuracy Level")
        plt.title("Accuracy Comparison between Endometrium Cancer")
        plt.savefig(os.path.join(BASE_DIR, 'static', 'matrix.png'))
        plt.close()

        cell_count = [total_cells, damaged_cells, overlap_cells]
        ts = int(time.time())  # cache-busting timestamp

        return render_template('userlog.html',
                               status=str_label,
                               Label=status1,
                               accuracy=accuracy,
                               cell_count=cell_count,
                               ImageDisplay=f"/static/images/{fileName}?t={ts}",
                               ImageDisplay1=f"/static/gray.jpg?t={ts}",
                               ImageDisplay2=f"/static/edges.jpg?t={ts}",
                               ImageDisplay3=f"/static/threshold.jpg?t={ts}",
                               ImageDisplay4=f"/static/matrix.png?t={ts}")

    return render_template('index.html')

@app.route('/logout')
def logout():
    return render_template('index.html')

if __name__ == "__main__":
    app.run(debug=True)
