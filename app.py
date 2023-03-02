from flask import Flask, request, jsonify
from flask_cors import CORS
from manga_ocr import MangaOcr

app = Flask(__name__)
CORS(app)


mocr = MangaOcr()
text = mocr('./1.jpg')
print(text)
@app.route('/foo', methods=['POST']) 
def foo():
    text = mocr('./1.jpg')
    return text









if __name__ == '__main__':
    app.run(host="0.0.0.0", port=3000)