import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoleButton extends StatelessWidget{

  const RoleButton({
  required this.onRole,
    required this.roleImagePath,
    required this.roleTitle,
    required this.roleSubTitle,
  super.key});

  final void Function() onRole;
  final String roleImagePath;
  final String roleTitle;
  final String roleSubTitle;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFD2EDEF),
        elevation: 10,
        shadowColor: Colors.black,
        minimumSize: Size(400, 90),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            roleImagePath,
            width: 50,
          ),
          SizedBox(width: 30),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                roleTitle,
                textAlign: TextAlign.left,
                style: GoogleFonts.poppins(
                  fontSize: 30,
                  color: Color(0xFF23918C),
                ),
              ),
              Text(
                roleSubTitle,
                textAlign: TextAlign.left,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}