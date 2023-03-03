// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_crop/image_crop.dart';
import "post_to_db.dart";
import 'package:image_picker/image_picker.dart';
import 'package:translator/translator.dart';

String myAppBarTitle = "Demo";
Future<void> main() async {
  // ignore: prefer_const_constructors
  runApp(MaterialApp(
    color: Colors.amber,
    home: Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          myAppBarTitle,
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: const HomePage(),
    ),
  ));
}

Future<Image> assetThumbToImage(String b64string) async {
  final datasd = base64.decode(b64string.split(',').last).buffer.asUint8List();
  final Image image = Image.memory(Uint8List.fromList(datasd));

  return image;
}

class HomePage extends StatefulHookWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final fieldText = TextEditingController();
  void clearText() {
    fieldText.clear();
  }

  final cropKey = GlobalKey<CropState>();
  @override
  Widget build(BuildContext context) {
    // const assetImage = AssetImage('assets/images/1.jpg');
    ValueNotifier<String> imageString = useState("");
    ValueNotifier<String> croppedString = useState('');
    ValueNotifier<bool> loadingcamera = useState(false);
    ValueNotifier<bool> loadingcrop = useState(false);
    ValueNotifier<String> ocrTextstate = useState("");

    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        Text(
          ocrTextstate.value,
          textAlign: TextAlign.center,
        ),
        OutlinedButton(
          onPressed: () async {
            loadingcrop.value = false;
            loadingcamera.value = true;
            XFile? imageFile =
                await ImagePicker().pickImage(source: ImageSource.camera);
            // await GallerySaver.saveImage(imageFile!.path);
            File imageFile_ = File(imageFile!.path);
            final bytes = imageFile_.readAsBytesSync();
            String base64Image = base64Encode(bytes);
            imageString.value = base64Image;
            loadingcamera.value = false;
          },
          style: OutlinedButton.styleFrom(
            shape: const StadiumBorder(),
          ),
          child: const Text(
            'Load Image',
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          color: Colors.black,
          padding: const EdgeInsets.all(20.0),
          height: 400,
          width: 400,
          alignment: Alignment.center,
          margin: const EdgeInsets.only(top: 10),
          child: !(imageString.value == "") & !(loadingcamera.value)
              ? Center(
                  child: Crop(
                    key: cropKey,
                    image: Image.memory(Uint8List.fromList(base64
                            .decode(imageString.value.split(',').last)
                            .buffer
                            .asUint8List()))
                        .image,
                  ),
                )
              : const Text(
                  "Loading the image.",
                  textAlign: TextAlign.center,
                ),
        ),
        OutlinedButton(
          onPressed: () async {
            if ((loadingcrop.value)) {
              return;
            }
            ocrTextstate.value = "";
            loadingcrop.value = true;
            final crop = cropKey.currentState;
            final area = crop?.area as Rect;

            // File _image;
            _savecrop() async {
              Uint8List toCropimagebuffer = Uint8List.fromList(base64
                  .decode(imageString.value.split(',').last)
                  .buffer
                  .asUint8List());
              final tempDir = await getTemporaryDirectory();
              File tempImagefile =
                  await File('${tempDir.path}/image.png').create();
              tempImagefile.writeAsBytesSync(toCropimagebuffer);

              final croppedFile = await ImageCrop.cropImage(
                file: File(tempImagefile.path),
                area: area,
              );
              final bytes = croppedFile.readAsBytesSync();
              String base64Image = base64Encode(bytes);
              //ignore: prefer_interpolation_to_compose_strings
              croppedString.value = base64Image;
              var ocrText = await ocr(base64Image);
              myAppBarTitle = ocrText;
              ocrTextstate.value = ocrText;
              loadingcrop.value = false;
            }

            _savecrop();
          },
          style: OutlinedButton.styleFrom(
            shape: const StadiumBorder(),
          ),
          child: (loadingcrop.value)
              ? const Text(
                  'Disabled',
                  textAlign: TextAlign.center,
                )
              : const Text(
                  'OCR',
                  textAlign: TextAlign.center,
                ),
        ),
        SingleChildScrollView(
          child: !(croppedString.value == "") & !(loadingcrop.value)
              ? Container(
                  color: Colors.black,
                  padding: const EdgeInsets.all(20.0),
                  height: 400,
                  width: 400,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(top: 10),
                  child: !(imageString.value == "")
                      ? Center(
                          child: Image(
                            image: Image.memory(Uint8List.fromList(base64
                                    .decode(croppedString.value.split(',').last)
                                    .buffer
                                    .asUint8List()))
                                .image,
                          ),
                        )
                      : const Text(
                          ".",
                          textAlign: TextAlign.center,
                        ),
                )
              : loadingcamera.value
                  ? const Text(
                      "Image not selected.",
                      textAlign: TextAlign.center,
                    )
                  : !(loadingcrop.value)
                      ? const Text("")
                      : const Text(
                          "Processing the image.",
                          textAlign: TextAlign.center,
                        ),
        )
      ],
    );
  }
}
