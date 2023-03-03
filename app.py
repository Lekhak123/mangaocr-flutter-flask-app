from flask import Flask, request, jsonify
from flask_cors import CORS,cross_origin
from manga_ocr import MangaOcr
from PIL import Image
import base64
from io import BytesIO
import re
app = Flask(__name__)
CORS(app)
from deep_translator import GoogleTranslator
mocr = MangaOcr()



@app.route('/ocr', methods=['POST']) 
@cross_origin()
def foo():
    json = request.get_json()
    b64String= json["imgString"]
    bytes_decoded = base64.b64decode(b64String)
    img = Image.open(BytesIO(bytes_decoded))
    img.save("./TEMP_ocrImage/1.png")
    text = mocr('./TEMP_ocrImage/1.png')
    translated = GoogleTranslator(source='auto', target='en').translate(text) 
    newText = "{} -> {}".format(text,translated)
    data = {"text":newText}
    
    return data,200









if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8080)