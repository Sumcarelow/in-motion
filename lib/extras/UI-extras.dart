import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data.dart';

//ButtonsUI
GestureDetector buttonUI(BuildContext context, String label, Color backG, Color textColor, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
          decoration: BoxDecoration(
              color: backG,
              shape: BoxShape.rectangle,
              border: Border.all(color: colors[2], width: 0.9),
              borderRadius: BorderRadius.circular(25)
          ),
          width: MediaQuery.of(context).size.width * 0.4,
          child: Center(child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(label,
              style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: textColor, fontSize: 20,)),
            ),
          ))
      ),
    ),
  );
}
GestureDetector iconButtonUI(BuildContext context, String label, IconData icon, Color backG, Color iconColor, Color textColor, Color borderColor, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
        decoration: BoxDecoration(
            color: backG,
            shape: BoxShape.rectangle,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(25)
        ),
        width: MediaQuery.of(context).size.width * 0.9,
        child: Center(child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FaIcon(icon, color: iconColor),
              Text(label,
                style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ))
    ),
  );
}