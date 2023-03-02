// ignore_for_file: unused_local_variable, no_leading_underscores_for_local_identifiers
import 'package:path_provider/path_provider.dart';
// import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_crop/image_crop.dart';
// import "post_to_db.dart";
import 'package:image_picker/image_picker.dart';

Future<void> main() async {
  // ignore: prefer_const_constructors
  runApp(MaterialApp(
    color: Colors.amber,
    home: Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Demo"),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: const HomePage(),
    ),
  ));
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
    ValueNotifier<bool> initialLoad = useState(false);
    ValueNotifier<String> croppedString = useState("");
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        OutlinedButton(
          onPressed: () async {
            XFile? imageFile =
                await ImagePicker().pickImage(source: ImageSource.camera);
            await GallerySaver.saveImage(imageFile!.path);
            imageString.value = imageFile.path;
          },
          style: OutlinedButton.styleFrom(
            shape: const StadiumBorder(),
          ),
          child: const Text('Load Image'),
        ),
        Container(
          color: Colors.black,
          padding: const EdgeInsets.all(20.0),
          height: 400,
          width: 400,
          alignment: Alignment.center,
          margin: const EdgeInsets.only(top: 10),
          child: !(imageString.value == "")
              ? Center(
                  child: Crop(
                    key: cropKey,
                    image: Image.file(File(imageString.value)).image,
                    aspectRatio: 4.0 / 3.0,
                  ),
                )
              : const Text("."),
        ),
        OutlinedButton(
          onPressed: () async {
            final crop = cropKey.currentState;
            final area = crop?.area as Rect;
            final scale = crop?.scale as double;
            // File _image;
            XFile? image;
            _savecrop() async {
              // XFile? imageFile =
              //     await ImagePicker().pickImage(source: ImageSource.camera);
              final croppedFile = await ImageCrop.cropImage(
                file: File(imageString.value),
                area: area,
              );
              final bytes = croppedFile.readAsBytesSync();

              // String base64Image =
              //     "data:image/png;base64,${base64Encode(bytes)}";
              String dir = (await getApplicationDocumentsDirectory()).path;
              // ignore: prefer_interpolation_to_compose_strings

              File tempfile = File("$dir/1.png");
              print(tempfile);
              await tempfile.writeAsBytes(bytes);
              croppedString.value = tempfile.path;
              return;
            }

            _savecrop();
          },
          style: OutlinedButton.styleFrom(
            shape: const StadiumBorder(),
          ),
          child: const Text('OCR'),
        ),
        SingleChildScrollView(
          child: !(imageString.value == "")
              ? Container(
                  // ignore: prefer_const_constructors
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    image: DecorationImage(
                      image: Image.file(File(imageString.value)).image,
                    ),
                  ),
                )
              : const Text(""),
        )
      ],
    );
  }
}
