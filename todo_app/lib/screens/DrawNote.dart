import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

//This screen is used to get the hand drawn note.
//Color pallet is provided to choose amongst different colors.
//Stroke width can be adjusted accordingly.

class DrawNote extends StatefulWidget {
  @override
  _DrawNoteState createState() => new _DrawNoteState();
}

class _DrawNoteState extends State<DrawNote> {
  GlobalKey _drawingKey = GlobalKey();

  List<DrawingType> points = [];
  Color selectedColor;
  double strokeWidth;

  @override
  void initState() {
    super.initState();
    selectedColor = Colors.black;
    strokeWidth = 2.0;
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                  Color.fromRGBO(138, 35, 135, 1.0),
                  Color.fromRGBO(233, 64, 87, 1.0),
                  Color.fromRGBO(242, 113, 33, 1.0),
                ])),
          ),
          Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              RepaintBoundary(
                key: _drawingKey,
                child: Column(children: [
                  Container(
                    width: width * 0.80,
                    height: height * 0.70,
                    child: new GestureDetector(
                      onPanDown: (details) {
                        setState(() {
                          points.add(DrawingType(
                              point: details.localPosition,
                              areaPaint: Paint()
                                ..color = selectedColor
                                ..strokeCap = StrokeCap.round
                                ..strokeWidth = strokeWidth));
                        });
                      },
                      onPanUpdate: (details) {
                        setState(() {
                          points.add(DrawingType(
                              point: details.localPosition,
                              areaPaint: Paint()
                                ..color = selectedColor
                                ..strokeCap = StrokeCap.round
                                ..strokeWidth = strokeWidth));
                        });
                      },
                      onPanEnd: (details) {
                        setState(() {
                          points.add(null);
                        });
                      },
                      child: SizedBox.expand(
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          child: CustomPaint(
                            painter: CustomNote(points: points),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                  width: width * 0.80,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  child: Row(children: <Widget>[
                    IconButton(
                        icon: Icon(
                          Icons.color_lens,
                          color: selectedColor,
                        ),
                        onPressed: () {
                          selectColor();
                        }),
                    Expanded(
                        child: Slider(
                            min: 1.0,
                            max: 7.0,
                            activeColor: selectedColor,
                            value: strokeWidth,
                            onChanged: (value) {
                              setState(() {
                                strokeWidth = value;
                              });
                            })),
                    IconButton(
                        icon: Icon(
                          Icons.format_clear,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          this.setState(() {
                            points.clear();
                          });
                        }),
                  ]))
            ]),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[900],
        child: new Icon(Icons.done_outline_rounded,
            size: 30, color: Colors.green[400]),
        onPressed: () => convertAndSave(),
      ),
    );
  }

  void selectColor() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Color Picker"),
              content: SingleChildScrollView(
                child: BlockPicker(
                  pickerColor: selectedColor,
                  onColorChanged: (color) {
                    this.setState(() {
                      selectedColor = color;
                    });
                  },
                ),
              ),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Close"))
              ],
            ));
  }

  convertAndSave() async {
    RenderRepaintBoundary repaintBoundary =
        _drawingKey.currentContext.findRenderObject();
    ui.Image boxImage = await repaintBoundary.toImage(pixelRatio: 1);
    ByteData byteData =
        await boxImage.toByteData(format: ui.ImageByteFormat.png);
    Uint8List uInt8List = byteData.buffer.asUint8List();

    String image64 = base64Encode(uInt8List);

    Navigator.pop(context, image64);
  }
}

class DrawingType {
  Offset point;
  Paint areaPaint;

  DrawingType({this.point, this.areaPaint});
}

class CustomNote extends CustomPainter {
  List<DrawingType> points;

  CustomNote({this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint background = Paint()..color = Colors.white;
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, background);
    canvas.clipRect(rect);

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(
            points[i].point, points[i + 1].point, points[i].areaPaint);
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawPoints(
            ui.PointMode.points, [points[i].point], points[i].areaPaint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
