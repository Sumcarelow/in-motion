import 'package:flutter/material.dart';
import 'package:in_motion/extras/data.dart';
class Confirm extends StatefulWidget {
  @override
  _ConfirmState createState() => _ConfirmState();
}

class _ConfirmState extends State<Confirm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Confirm Order",
        style: TextStyle(
          color: colors[4]
        ),
        ),
        centerTitle: true,
        backgroundColor: colors[1],
      ),

      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
            backgroundColor: colors[4],
          ),
            Center(
              child: Text("Waiting for driver",
              style: TextStyle(
                color: colors[1]
              ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
