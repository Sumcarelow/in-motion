import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:in_motion/extras/data.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
class VehicleSelect extends StatefulWidget {
  final Set<Polyline> polyline;
  VehicleSelect({@required this.polyline});
  @override
  _VehicleSelectState createState() => _VehicleSelectState();
}

class _VehicleSelectState extends State<VehicleSelect> {
  String id, name;
  SharedPreferences prefs;
  bool isLoading = false;

  void readLocal() async{
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    name = prefs.getString('firstName') ?? '';
    setState(() {

    });
  }

  void updateData(){
    setState(() {
      isLoading = true;
    });
    DocumentReference docRef = Firestore.instance.collection('requests').document();
    docRef.setData({
      'name': name,
      'userId': id,
      'status': 'pending',
      'id': docRef.documentID,
      'date': DateFormat('dd MMMM yyyy').format(DateTime.now()).toString(),
      'time': DateFormat('hh:mm:ss').format(DateTime.now()).toString()
    }).then((data) async {

    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: err.toString());
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    readLocal();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              backgroundColor: colors[2],
              title: Text("Vehicle Selection",
              style: TextStyle(color: colors[4]),
              ),
              centerTitle: true,
            ),

            body: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: updateData,
                        child: Container(
                          color: colors[3],
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Private Car",
                            style: TextStyle(color: colors[4]),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: updateData,
                        child: Container(
                          color: colors[3],
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Family Size Car",
                              style: TextStyle(color: colors[4]),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: updateData,
                          child: Container(
                            color: colors[3],
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Van",
                                style: TextStyle(color: colors[4]),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: updateData,
                          child: Container(
                            color: colors[3],
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Construction Vehicle",
                                style: TextStyle(color: colors[4]),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

          isLoading
              ? Container(
            color: colors[5],
            child: Material(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      backgroundColor: colors[3],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Looking for Driver...', style: TextStyle(color: colors[1])),
                    )
                  ],
                ),
              ),
            ),
          )
              :
          Container()
        ],
      ),
    );
  }
}
