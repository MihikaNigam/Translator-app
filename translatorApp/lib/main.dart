import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:translator/translator.dart';
import 'package:translatorApp/list.dart' as ls;
import 'package:translatorApp/output.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        accentColor: Colors.pink[200],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Translator App'),
      routes: {
        Outputs.routeName: (ctx) => Outputs(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

var key;

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    var text = "";
    var output;
    String _retrieveDataError;
    dynamic _pickImageError;
    bool imageLoaded = false;
    PickedFile _imageFile;
    File pickedImage;
    String selectedlanguage;

    GoogleTranslator translator = GoogleTranslator();
    var code = ls.Languages().code;
    var languages = ls.Languages().languages;

    translatee(String text, String v) async {
      print("v is $v");
      print(text);
      await translator
          .translate(text, to: code[v])
          .then((value) => setState(() {
                output = value;
              }));
      print("output i need $output");
      return showDialog(
          context: context,
          builder: (ctx) => Center(
                child: Card(
                  elevation: 10,
                  child: Container(
                    width: MediaQuery.of(context).size.width*0.75,
                    child: Flex(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      direction: Axis.vertical,
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          color: Colors.blue[300],
                          child: Text(
                            output.toString(),
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        FlatButton(
                            child: Text("OK", style: TextStyle(fontSize: 20)),
                            onPressed: () {
                              Navigator.of(ctx).pop();
                            }),
                      ],
                    ),
                  ),
                ),
              ),
          barrierDismissible: true);
    }

    textExtracting(File img) async {
      print('inside textExtracting func');
      FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(img);
      TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
      VisionText visionText = await textRecognizer.processImage(
          visionImage); //this object contains full text  and text blocks
      for (TextBlock block in visionText.blocks) {
        for (TextLine line in block.lines) {
          for (TextElement word in line.elements) {
            setState(() {
              text += word.text + ' ';
            });
          }
          text = text + '\n';
        }
      }
      textRecognizer.close();
      return text;
    }

    imagegetter(String mode) async {
      try {
        final awaitImage = mode == "camera"
            ? await ImagePicker().getImage(source: ImageSource.camera)
            : await ImagePicker().getImage(source: ImageSource.gallery);
        imageLoaded = true;
        setState(() {
          _imageFile = awaitImage;
          pickedImage = File(awaitImage.path);
          imageLoaded = true;
        });
      } catch (e) {
        imageLoaded = false;
        print(e);
        setState(() {
          _pickImageError = e;
        });
      }

      textExtracting(pickedImage).then((value) => translatee(value, key));
    }

    Widget mainscreen() {
      print("inside main screen widget");
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RaisedButton(
              textColor: Colors.white,
              child: Text('Choose From Gallery'),
              color: Theme.of(context).accentColor,
              elevation: 10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onPressed: () {
                if (key == null) {
                  return showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                            title: Text('Please select a language first'),
                            actions: [
                              FlatButton(
                                  child: Text("OK"),
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                  }),
                            ],
                            elevation: 10,
                          ),
                      barrierDismissible: true);
                } else {
                  imagegetter("gallery");
                }
              }),
          SizedBox(height: 20),
          RaisedButton(
              textColor: Colors.white,
              child: Text('Scan The Text'),
              color: Theme.of(context).accentColor,
              elevation: 10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onPressed: () {
                if (key == null) {
                  return showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                            title: Text('Please select a language first'),
                            actions: [
                              FlatButton(
                                  child: Text("OK"),
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                  }),
                            ],
                            elevation: 10,
                          ),
                      barrierDismissible: true);
                } else {
                  imagegetter("camera");
                }
              }),
          SizedBox(height: 20),
          Container(
            width: 300,
            child: DropdownButtonFormField(
              hint: Text('Please select a language'),
              value: selectedlanguage,
              style: TextStyle(color: Theme.of(context).primaryColor),
              items: languages.map((String val) {
                return new DropdownMenuItem(
                  value: val,
                  child: new Text(val),
                );
              }).toList(),
              icon: Icon(Icons.arrow_drop_down,
                  color: Theme.of(context).primaryColor),
              iconSize: 24,
              elevation: 16,
              onChanged: (String newValue) {
                setState(() {
                  key = newValue;
                  selectedlanguage = newValue;
                  print(selectedlanguage);
                });
              },
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(child: mainscreen()),
    );
  }
}
